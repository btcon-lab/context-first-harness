#!/usr/bin/env bash
# SessionStart 훅(P-F): 세션 시작 시각을 마커에 각인.
# Stop 훅이 "이번 세션에 PROGRESS.md가 갱신됐는가"를 이 마커 mtime과 비교해 판정한다.
proj="${CLAUDE_PROJECT_DIR:-$PWD}"
mkdir -p "$proj/.claude" 2>/dev/null
touch "$proj/.claude/.session-start" 2>/dev/null
exit 0
