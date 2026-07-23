#!/usr/bin/env bash
# Stop 훅(P-F): 이번 세션에 실질 작업(파일 변경)이 있었는데 PROGRESS.md가 갱신되지 않았으면
# Claude에게 갱신을 요청(decision:block)한다. 한 번만 알리고(무한루프 방지) 정상 종료로 넘어간다.
input=$(cat)
active=$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)
[ "$active" = "true" ] && exit 0

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
marker="$proj/.claude/.session-start"
progress="$proj/PROGRESS.md"

[ -f "$marker" ]   || exit 0
[ -f "$progress" ] || exit 0
[ "$progress" -nt "$marker" ] && exit 0   # 이미 갱신됨 → 통과

changed=$(find "$proj" -type d \( -name .git -o -name node_modules -o -name .claude -o -name '_workspace*' \) -prune -o \
  -type f -newer "$marker" -not -name PROGRESS.md -print 2>/dev/null | head -1)
[ -z "$changed" ] && exit 0   # 실질 변경 없음 → 통과

cat <<'JSON'
{"decision":"block","reason":"이번 세션에서 파일이 변경됐지만 PROGRESS.md가 아직 갱신되지 않았습니다. 종료 전에 PROGRESS.md의 '세션 로그'에 한 줄 추가하고 '현재 상태/다음 할 일'을 최신화하세요(상세는 각 정본 링크 — 내용 복제 금지). 계약(정본)을 바꿨다면 docs/context/README.md 변경 이력에도 기록하세요. 갱신 후 정상 종료됩니다."}
JSON
exit 0
