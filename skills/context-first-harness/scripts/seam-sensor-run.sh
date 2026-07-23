#!/usr/bin/env bash
# PostToolUse 훅(HE Observability): 파일이 바뀌면 관련 센서를 돌려 "사실"을 수집한다.
#
# 설계 원칙 — 이 스크립트는 측정만 한다.
#   · 위반 여부를 판정하지 않는다. 정본과 대조하는 판정은 Claude가 한다.
#   · 센서가 실패해도 파이프라인을 멈추지 않는다. 실패는 SENSOR_ERROR로 기록한다.
#   · 미측정을 통과로 처리하지 않는다.
#
# 출력: 관측 리포트 파일(기본 _workspace/observations/). 훅 stdout 처리 방식이
#       버전마다 달라도 결과가 남도록 파일로 떨어뜨린다.
#
# 설정: 대상 프로젝트의 .claude/seam-sensors.json (assets/seam-sensors.template.json 참고)

set -u

input=$(cat 2>/dev/null || true)
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
cfg="$proj/.claude/seam-sensors.json"

[ -f "$cfg" ] || exit 0          # 설정이 없으면 조용히 통과
command -v jq >/dev/null 2>&1 || exit 0   # 설정 파싱에는 jq가 필요하다. 없으면 훅을 건너뛴다

# 타임아웃 실행. timeout/gtimeout이 없는 환경(기본 macOS)에서도 제한이 걸리도록
# 순수 bash로 폴백한다. 제한이 조용히 무력화되면 센서가 세션을 붙잡는다.
# 반환: 명령의 종료코드, 시간 초과 시 124
run_with_timeout() {
  local tmo="$1" cmd="$2" dir="$3"
  if command -v timeout >/dev/null 2>&1; then
    ( cd "$dir" && timeout "$tmo" sh -c "$cmd" ); return $?
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    ( cd "$dir" && gtimeout "$tmo" sh -c "$cmd" ); return $?
  fi
  local tmp; tmp=$(mktemp 2>/dev/null) || tmp="/tmp/seam-sensor.$$"
  ( cd "$dir" && sh -c "$cmd" >"$tmp" 2>&1 ) &
  local pid=$! waited=0
  while kill -0 "$pid" 2>/dev/null; do
    if [ "$waited" -ge "$tmo" ]; then
      kill -TERM "$pid" 2>/dev/null
      sleep 1
      kill -KILL "$pid" 2>/dev/null
      cat "$tmp" 2>/dev/null; rm -f "$tmp" 2>/dev/null
      return 124
    fi
    sleep 1
    waited=$((waited+1))
  done
  wait "$pid"; local rc=$?
  cat "$tmp" 2>/dev/null; rm -f "$tmp" 2>/dev/null
  return $rc
}

# --- 바뀐 파일 확인 -----------------------------------------------------------
changed=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
if [ -z "$changed" ]; then
  # 파일 경로가 없는 도구 호출(Bash 등)은 git으로 변경분을 본다
  changed=$(cd "$proj" && git diff --name-only HEAD 2>/dev/null | head -20)
fi
[ -z "$changed" ] && exit 0

rel_list=""
while IFS= read -r f; do
  [ -z "$f" ] && continue
  case "$f" in "$proj"/*) f="${f#"$proj"/}" ;; esac
  rel_list="$rel_list$f"$'\n'
done <<< "$changed"

# --- 매칭되는 센서 고르기 -----------------------------------------------------
# 모든 센서를 매번 돌리지 않는다. 바뀐 파일과 관련된 것만.
matched=$(jq -r '.sensors[]? | @base64' "$cfg" 2>/dev/null)
[ -z "$matched" ] && exit 0

outdir="$proj/$(jq -r '.observation_dir // "_workspace/observations"' "$cfg" 2>/dev/null)"
mkdir -p "$outdir" 2>/dev/null || exit 0
stamp=$(date +%Y%m%d-%H%M%S)
report="$outdir/observation-$stamp.md"

ran=0
{
  echo "# 관측 리포트 — $(date '+%Y-%m-%d %H:%M:%S')"
  echo
  echo "> **사실만 기록한다.** 위반 여부는 판정하지 않았다."
  echo "> 판정은 \`docs/context/{seam}.md\` 정본과 대조해서 한다 — \`references/seam-qa.md\`"
  echo
  echo "## 바뀐 파일"
  printf '%s' "$rel_list" | sed 's/^/- /'
  echo
  echo "## 센서 실행 결과"
  echo
} > "$report"

while IFS= read -r enc; do
  [ -z "$enc" ] && continue
  s=$(printf '%s' "$enc" | base64 --decode 2>/dev/null) || continue

  id=$(printf '%s' "$s" | jq -r '.id // "unnamed"')
  seam=$(printf '%s' "$s" | jq -r '.seam // "-"')
  rules=$(printf '%s' "$s" | jq -r '(.rules // []) | join(", ")')
  cmd=$(printf '%s' "$s" | jq -r '.command // empty')
  measures=$(printf '%s' "$s" | jq -r '.measures // "-"')
  tmo=$(printf '%s' "$s" | jq -r '.timeout // 120')
  [ -z "$cmd" ] && continue

  # glob 매칭
  hit=0
  while IFS= read -r pat; do
    [ -z "$pat" ] && continue
    while IFS= read -r f; do
      [ -z "$f" ] && continue
      # shellcheck disable=SC2254
      case "$f" in $pat) hit=1; break 2 ;; esac
      case "$pat" in
        *'/**'*) base="${pat%%/\*\**}"; case "$f" in "$base"/*) hit=1; break 2 ;; esac ;;
      esac
    done <<< "$rel_list"
  done < <(printf '%s' "$s" | jq -r '(.match // [])[]')
  [ "$hit" -eq 0 ] && continue

  ran=$((ran+1))
  {
    echo "### $id"
    echo "- seam: \`$seam\` · 관련 Rule: ${rules:--}"
    echo "- 측정 대상: $measures"
    echo "- 명령: \`$cmd\`"
  } >> "$report"

  out=""; rc=0
  out=$(run_with_timeout "$tmo" "$cmd" "$proj" 2>&1); rc=$?

  if [ "$rc" -eq 124 ]; then
    echo "- 결과: \`SENSOR_ERROR\` — ${tmo}초 초과. **측정하지 못했다(통과 아님).**" >> "$report"
  elif [ "$rc" -eq 127 ]; then
    echo "- 결과: \`SENSOR_ERROR\` — 명령을 찾을 수 없음. **측정하지 못했다(통과 아님).**" >> "$report"
  else
    echo "- 종료코드: $rc" >> "$report"
  fi
  {
    echo
    echo '```'
    printf '%s\n' "$out" | tail -40
    echo '```'
    echo
  } >> "$report"
done <<< "$matched"

if [ "$ran" -eq 0 ]; then
  rm -f "$report" 2>/dev/null
  exit 0
fi

{
  echo "## 다음 단계 (판정)"
  echo
  echo "1. 위 사실을 관련 seam 정본과 대조한다."
  echo "2. 불일치는 **V**(구현 위반) / **G**(계약 공백) / **S**(정본 노후) / **D**(점진 이탈) 중 하나로 판정한다."
  echo "3. 심각도는 규칙 등급에서 정한다 — MUST 위반 = FAIL, SHOULD 이탈 = WARN."
  echo "4. \`SENSOR_ERROR\`는 통과가 아니다. 원인을 해소하고 다시 측정한다."
  echo "5. **G·S·D는 정본을 고치는 일이므로 사람 승인이 필요하다** — \`references/governance.md\`."
} >> "$report"

echo "[seam-sensor] 센서 ${ran}개 실행. 관측 리포트: ${report#"$proj"/}" >&2
exit 0
