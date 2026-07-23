# Changelog

## 0.3.0 (2026-07-23)

판정 체계를 정밀화했다. 내부 검토 자료(*Cloud Native 기반 AI Native의 진화*, 장덕성, 2026-04)의 Decay/Rot/Drift 분류, MUST/SHOULD Rule ID 체계, Observability≠Control 단일 책임 원칙을 CFHM의 계약 구조에 맞춰 반영했다.

- **D(점진 이탈) 판정 추가** — 기존 V/G/S로는 "개별 건은 위반이 아닌데 같은 방향으로 누적되는" 이탈을 잡지 못했다. 에러도 없고 테스트도 통과하므로 매 시점의 대조로는 영영 안 잡힌다. D는 한 회차가 아니라 **추세로 판정**하며, 정본에 감시 축과 임계를 미리 정의하고 QA가 회차 간 카운트를 누적한다.
- **규칙 등급과 Rule ID** — 계약 항목에 `[MUST]`(`{SEAM}-P###`, override 불가) / `[SHOULD]`(`{SEAM}-G###`, 이유 명시 시 가능) / 등급 없음(구현 자유)을 부여한다. 이전에는 정본의 모든 문장이 같은 무게여서 QA가 심각도를 매길 수 없었다. 심각도는 이제 등급에서 기계적으로 나온다 — MUST 위반=FAIL, SHOULD 이탈=WARN. Rule ID는 삭제 후에도 재사용하지 않는다(위반 이력 추적).
- **측정과 판정 분리** — 사실 수집 단계에서는 위반 여부를 말하지 않는다. 섞으면 "위반 같으니 그만 보자"며 수집을 중단하거나 "애매하니 넘어가자"며 사실을 누락시킨다.
- **`SENSOR_ERROR` 도입** — 검사 도구가 실행되지 않은 것과 이상이 없는 것을 구분한다. 미측정을 통과로 처리하면 아무도 보지 않은 곳이 검사를 통과한 것으로 둔갑한다. 기존 `SKIP`(대상 미존재)과도 분리했다.
- **미분류 관측** — 어떤 Rule과도 매칭되지 않는 사실은 판정하지 않고 G 후보로 기록한다. 규칙 추가가 필요하다는 신호다.
- `seam-contract.template.md` 재작성(등급·Rule ID·점진 이탈 감시·검증 항목·변경 이력), `seam-qa-report.template.md` 재작성(측정/판정 분리, D 누적 추적).

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
