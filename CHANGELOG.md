# Changelog

## 0.2.0 (2026-07-23)
- **Seam QA 추가** (`references/seam-qa.md`) — 정본↔구현 계약 대조 검증. V(구현 위반)/G(계약 공백)/S(정본 노후) 3-판정 체계, seam 유형별 경계면 버그 패턴, QA 에이전트 정의 템플릿, 점진 검증 타이밍. `assets/seam-qa-report.template.md` 동반.
- **스킬 작성 가이드 추가** (`references/skill-authoring.md`) — description 설계(후속 키워드 포함), 본문 원칙, 4단계 Progressive Disclosure(정본 포함), "컨텍스트 자산 참조" 섹션 규격, 중복 검토.
- **스킬 테스트 가이드 추가** (`references/skill-testing.md`) — should/should-NOT 트리거 검증(near-miss는 인접 seam 위주), with-skill vs without-skill 비교, 정본 준수 기반 평가, 검증 순서.
- **실행 모드 가이드 추가** (`references/execution-modes.md`) — 팀/서브/하이브리드 의사결정, 아키텍처 패턴, 에이전트 분리 기준(seam 오너십 1순위), 데이터 전달 프로토콜에 "정본" 경로 추가, 팀 크기, 에러 핸들링.
- **재실행 가이드 추가** (`references/re-execution.md`) — 초기/부분/새/**CE 재실행** 판별, 산출물 보존 규칙, 확장 시 Phase 선택 매트릭스, drift 감사, 진화 트리거.
- `harness-engineering.md`를 HE 허브로 재편, `verification.md`를 6단계 검증 순서로 재구성(싼 것 → 비싼 것).
- SKILL.md: QA 에이전트를 팀 필수 구성으로 명시, 산출물 체크리스트에 오너십 정합·QA·트리거 검증 항목 추가.

### 배포·이식성 (clone해서 바로 쓸 수 있게)
- **`jq` 의존성 제거** — `progress-stop-check.sh`가 jq 없이도 동작한다. 이전에는 jq가 없으면 `stop_hook_active` 판별이 실패해 종료가 반복 차단될 수 있었다. jq 유무 × 활성 여부 4가지 경우를 모두 테스트했다.
- **사전 요구사항 안내 추가** — 에이전트 팀 실험 기능(`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`), python3, bash, jq(선택). 팀 도구가 없는 환경에서는 서브 에이전트 모드로 진행하고, 계약 변경 통지를 순차 재호출로 대체하도록 `execution-modes.md`에 명시.
- **직접 clone 설치법 추가** — 로컬 폴더를 마켓플레이스로 등록하는 방법, 스킬만 복사하는 방법.
- README 전면 재작성 — 번역투를 걷어내고, 용어(경계면·정본·주인·어긋남)를 앞에 정의하고, 복붙 프롬프트와 산출물 트리를 넣었다. `references/`·`assets/`의 용어와 밀도는 그대로 유지한다.
- CHANGELOG에서 비공개 저장소 참조 제거, `.gitignore`에 개인 설정 파일 추가.

## 0.1.0 (2026-07-23)
- 초기 릴리스. Context-First Harness 메타 스킬(CFHM).
- 파이프라인 P-A(입력 큐레이션) · P-B(Seam 발견, HE보다 먼저) · HE(팀 구성) · P-C(계약 시드) · P-D(배선) · P-E(거버넌스) · P-F(진행·기억).
- references 6종, assets 7종(템플릿), scripts 3종(split-source, Stop 훅 2).
