# P-F: 진행·기억 (상세)

## PROGRESS.md
`대상/PROGRESS.md`(템플릿 `assets/PROGRESS.template.md`)를 만든다. 여러 로그에 흩어진 이력을 꿰는 **시계열 작업 일지**.
- 담는 것: 현재 상태 / 마일스톤 / 세션 로그 / 다음 할 일 / 블로커.
- **내러티브 + 포인터만.** 계약·FR·의사결정 상세는 각 정본을 링크하고 복제하지 않는다(drift 방지). 이 규칙을 파일 상단에 명시.
- 다른 로그와 역할 구분: PROGRESS=지금 어디/다음, fr-index=기능 완료, README 이력=계약 변경, CLAUDE 이력=구성 변경, open-decisions=의사결정.

## CLAUDE.md 포인터
`대상/CLAUDE.md`에 최소 포인터만(매 세션 로드): 하네스 트리거(오케스트레이터 스킬), 컨텍스트 자산 위치(`docs/context`)와 SoT/경계, CE-우선 변경 프로토콜 요약, PROGRESS 위치, 변경 이력. **에이전트/스킬 목록·디렉토리 구조는 넣지 않는다**(중복).

## 메모리
세션을 넘어 유지할 것(미결 의사결정, 버전 고정, ASSUMPTION, 다음 세션 계획)을 프로젝트 메모리에 시드.

## (옵션) Stop 훅으로 PROGRESS 갱신 강제
작업했는데 PROGRESS 갱신을 잊는 것을 막는다.

**설치:**
1. 스크립트를 대상에 복사:
   ```
   mkdir -p 대상/.claude/hooks
   cp skills/context-first-harness/scripts/session-start-stamp.sh 대상/.claude/hooks/
   cp skills/context-first-harness/scripts/progress-stop-check.sh 대상/.claude/hooks/
   chmod +x 대상/.claude/hooks/*.sh
   ```
2. `assets/settings-hooks.snippet.json`의 `hooks` 블록을 대상 `.claude/settings.local.json`(개인) 또는 `.claude/settings.json`(팀 공유)에 **병합**(기존 설정 보존).
3. `.gitignore`에 `.claude/.session-start` 추가.

**동작:** SessionStart가 마커를 각인 → Stop이 "실질 파일 변경 있음 + PROGRESS 미갱신"이면 `decision:block`으로 Claude에게 갱신 요청. `stop_hook_active`로 무한루프 방지, 노이즈 디렉토리(.claude/_workspace/node_modules/.git) 제외.

**주의:** 훅을 세션 중 처음 설치하면 감시자가 못 잡을 수 있다 — `/hooks`를 한 번 열거나 재시작하면 로드된다. 차단 훅이므로 팀 공유가 부담되면 `settings.local.json`(개인)에 둔다.

**검증(설치 후):** raw 파이프 테스트 —
```
echo '{"stop_hook_active":false}' | 대상/.claude/hooks/progress-stop-check.sh   # 변경+미갱신 시 block JSON
echo '{"stop_hook_active":true}'  | 대상/.claude/hooks/progress-stop-check.sh   # 통과(무출력)
```
