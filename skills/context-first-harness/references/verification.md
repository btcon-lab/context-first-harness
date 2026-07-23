# Phase 8: 검증 (상세)

## 구조 검증
- 에이전트 파일이 `.claude/agents/`에 올바르게, frontmatter(name, description, model:opus).
- 스킬 frontmatter(name, description), 본문 500줄 이내.
- **`.claude/commands/`에 아무것도 생성 안 됨.**
- 오케스트레이터 1개 존재, 데이터 흐름·에러 핸들링·테스트 시나리오 포함.

## 정본(CE) 무결성
- 각 seam 계약에 **seam-only 배너** 존재, 구현 상세 없음(design으로 이관 포인터).
- design 산출물이 계약을 **재기술하지 않고 링크**만.
- 표기 규약(`[정본]/[TODO]/[OPEN]/[ASSUMPTION]`) 일관.
- `docs/context/README.md`에 SoT·경계·변경 프로토콜·변경 이력 존재.
- 같은 사실이 두 곳에 중복 존재하지 않음(drift 0).

## 경계면 교차 검증 (QA 핵심)
"존재 확인"이 아니라 "교차 비교". 각 seam마다 소유자 정본 ↔ 소비자 산출물을 **동시에 읽어** 대조:
- 인터페이스 응답 형식 ↔ 소비자 타입
- 상태 전이 맵 ↔ 실제 status 업데이트(죽은 전이·무단 전이 없음)
- 권한 매트릭스 ↔ API/화면 권한
- 지표 산식 ↔ 대시보드 계산

## 트리거 검증
오케스트레이터·스킬 description에 대해 should-trigger(8~10) / should-NOT-trigger(near-miss 8~10)로 오작동 확인. 기존 스킬과의 충돌 점검.

## 드라이런
Phase 순서 논리성, 데이터 전달 경로 dead link 없음, 각 에이전트 입력이 이전 출력과 매칭, 에러 폴백 실행 가능.

## 산출물 체크리스트
SKILL.md의 "산출물 체크리스트"를 그대로 점검한다. 특히 **P-B(Seam 발견)가 HE보다 먼저** 수행됐는지 확인.
