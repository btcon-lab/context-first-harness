---
name: context-first-harness
description: "Context-First 하네스를 구성하는 메타 스킬. 도메인 설명이나 개발/계획 문서를 입력으로 (1) 컨텍스트 정본(seam 계약)을 먼저 만들고 (2) 그 seam의 소유자로 에이전트 팀(HE)을 구성하며 (3) 거버넌스(단일 진실원천 + CE-우선 변경 프로토콜)·진행관리(PROGRESS)·갱신 강제 훅까지 표준화한다. '하네스 구성/구축', 'context-first 하네스', 'CFHM', '컨텍스트 정본/seam 계약 만들기', '개발 계획서로 하네스', '하네스 표준화/확장/점검' 요청 시 사용. 단순 에이전트/스킬 하나만 필요하면 과할 수 있으니 규모를 먼저 판단."
---

# Context-First Harness (CFHM) — 메타 스킬

도메인/프로젝트를 **컨텍스트 정본(seam) → 에이전트 팀(HE) → 거버넌스 → 진행관리**로 표준 변환한다. 핵심은 HE에서 멈추지 않고, 계약(seam)을 **먼저** 세운 뒤 그 위에 팀을 얹는 것이다.

## 핵심 원칙 (왜 Context-First인가)
1. **Context-First** — 계약(seam)이 기반, 에이전트는 그 위 일꾼. seam을 먼저 발견하고 에이전트를 seam **소유자**로 정의한다. 이 순서가 아니면 나중에 계약 재작업(seam 다이어트)이 반복된다.
2. **Seam-only 정본** — `docs/context`는 2+ 소비자가 공유하는 인터페이스 사실만. 구현(how)은 `docs/design`이 갖고 계약을 **링크만** 한다(재기술 금지). 이것이 context↔design drift와 오버스펙을 막는다.
3. **단일 진실원천 + CE-우선 변경** — 같은 사실은 한 곳에만. 수정은 **정본 먼저** → 통지 → 반영 → 검증 → 기록.
4. **Progressive Disclosure** — 항상 로드(CLAUDE.md) → 트리거 시(스킬 본문) → 필요 시(references/·정본). 원문은 섹션 큐레이션 후 해당 조각만.
5. **진화 + 규율** — PROGRESS·변경이력·메모리로 장기지평 관리, 훅으로 갱신 강제. 하네스는 고정물이 아니라 진화 시스템이다.

## 워크플로우 (파이프라인)

```
Phase 0 현황 감사 → Phase 1 도메인 분석
  → [P-A] 입력 큐레이션      원문→plan-extracts/ (읽기용)
  → [P-B] Seam 발견          도메인 경계면 식별→계약 파일 set + 오너십
  → [HE]  팀 구성            에이전트·스킬·오케스트레이터 (seam 소유자로)
  → [P-C] 계약 시드          seam당 정본 1개, [TODO]/[OPEN] 시드
  → [P-D] 배선               스킬↔context 포인터, references/, 오너십 확정
  → [P-E] 거버넌스           context/README (SoT+경계+변경 프로토콜)
  → [P-F] 진행·기억          PROGRESS·변경이력·memory·(옵션)Stop 훅
  → Phase 8 검증 → Phase 9 진화
```
> HE와 CE는 상호의존이라 완전 선형은 아니다. **불변 규칙: P-B(Seam 발견)는 HE보다 앞선다.**

### Phase 0: 현황 감사
`대상프로젝트/.claude/agents`, `.claude/skills`, `docs/context/`, `CLAUDE.md`, `PROGRESS.md`를 읽는다. 분기: **신규 구축**(비어있음→전체) / **확장**(일부 Phase) / **운영·유지보수**(감사·동기화). 기존 자산과 CLAUDE.md 기록을 대조해 drift를 보고하고 실행 계획을 확인받는다.

### Phase 1: 도메인 분석
도메인/작업 유형 파악, 사용자 숙련도 감지(용어 조절), 기존 자산과의 충돌/중복 분석. 입력이 문서면 P-A로, 한 문장이면 P-B로.

### P-A: 입력 큐레이션
무거운 원문을 매번 컨텍스트에 넣지 않도록 한 번만 파싱→섹션 분리한다.
- 스크립트 `scripts/split-source.py`로 `.docx`/`.md`를 `docs/context/plan-extracts/NN_*.md`로 분리(읽기용·"정본 아님" 배너).
- 원문 수정이 없으면 재생성 불필요. 각 에이전트는 **자기 섹션만** 로드.
- 상세: `references/phase-input-curation.md`.

### P-B: Seam 발견 (HE보다 먼저)
도메인의 **경계면(2+ 소비자가 공유하는 사실)**을 식별해 계약 파일 set과 오너십을 결정한다.
- 판단 기준: "누가 무엇을 공유하는가?" 공유 사실 → seam(→context). 한 소유자의 구현 → design.
- 웹 서비스면 대개: 용어 / 데이터모델 / API / 상태머신 / RBAC / 지표. 도메인이 다르면 seam도 다르다 — **고정 목록이 아니라 도출**한다.
- 출력: seam 목록 + seam별 소유 에이전트(오너십 맵 초안).
- 상세·도메인별 seam 카탈로그: `references/seam-discovery.md`.

### HE: 팀 구성 (에이전트·스킬·오케스트레이터)
seam 오너십을 바탕으로 팀을 만든다. **모든 에이전트는 `대상/.claude/agents/{name}.md` 파일로 정의**(빌트인 타입이라도), `model: "opus"`. 각 에이전트는 담당 seam의 소유자이자 하나의 스킬(들)을 쓴다. seam마다 소유자는 **정확히 1명**(둘이 나눠 가지면 SoT가 깨진다).
- 정의 템플릿·오너십 규칙: `references/harness-engineering.md`
- 실행 모드(팀/서브/하이브리드)·데이터 전달·에러 핸들링: `references/execution-modes.md`
- 스킬 작성(description·본문·중복 검토): `references/skill-authoring.md`
- 오케스트레이터 스킬 1개가 팀을 조율하고, 완료 시 **정본을 채우고 design은 링크만** 하도록 명시한다.
- **QA 에이전트를 팀에 포함한다** — 정본을 정답지로 구현을 대조하는 역할. seam을 소유하지 않는다: `references/seam-qa.md`

### P-C: 계약 시드 (CE, seam-only)
P-B의 seam마다 `대상/docs/context/{seam}.md` 정본 1개를 만든다.
- 입력(plan-extracts)에서 사실을 시드, 미정은 `[TODO]`, 착수 전 결정은 `[OPEN]`, 가정은 `[ASSUMPTION]`.
- **모든 계약 항목에 등급과 Rule ID를 붙인다** — `[MUST]`(`{SEAM}-P###`, override 불가) / `[SHOULD]`(`{SEAM}-G###`, 이유 명시 시 가능) / 등급 없음(구현 자유). 등급이 없으면 QA가 심각도를 매길 수 없다.
- **seam-only 배너 필수.** 구현 상세는 넣지 말고 `docs/design`으로 이관 포인터를 남긴다.
- 템플릿: `assets/seam-contract.template.md`, `assets/glossary.template.md`, `assets/fr-index.template.md`, `assets/open-decisions.template.md`.

### P-D: 배선
HE와 CE를 연결한다.
- 각 스킬 본문에 "## 컨텍스트 자산 참조" 섹션 추가 — 소유/참조 정본을 명시(Read로 로드, 항상 로드 금지).
- 대용량 외부지식은 스킬 `references/`로 분리(Progressive Disclosure).
- 오너십 맵 확정: seam → 소유 에이전트 → 소비 에이전트.

### P-E: 거버넌스
`대상/docs/context/README.md`를 만든다(템플릿 `assets/context-README.template.md`). 담을 것:
- **SoT 규칙**(같은 사실 한 곳, 정본을 읽어 참조·복제 금지)
- **Context(seam) vs Design 경계**(무엇이 context, 무엇이 design)
- **CE-우선 변경 프로토콜**(정본 먼저→통지→반영→검증→기록, Drift 시 정본이 진실)
- **두 루프 분리 + 승인 게이트** — 구현 교정(V)은 자동, **정본 변경(G·S·D)은 사람 승인 필수**. 에이전트가 검증 결과만 보고 계약을 고치면 "구현에 맞춰 계약을 낮추는" 방향으로 흘러 정본이 코드의 사후 요약이 된다.
- **규칙 등급**(MUST/SHOULD/등급 없음)과 Rule ID 부여 규칙
- **변경 이력** 테이블
상세: `references/governance.md`.

### P-F: 진행·기억
- `대상/PROGRESS.md` 생성(템플릿 `assets/PROGRESS.template.md`): 현재상태·마일스톤·세션로그·다음할일. **내러티브+포인터만**, 상세는 권위 로그를 링크(변경이력·fr-index·open-decisions).
- `CLAUDE.md`에 하네스 포인터 + 컨텍스트 자산 포인터 + 변경 프로토콜 요약 등록(항상 로드).
- 세션 간 기억이 필요하면 프로젝트 메모리에 시드.
- (옵션) **Stop 훅**으로 PROGRESS 갱신 강제: `scripts/session-start-stamp.sh` + `scripts/progress-stop-check.sh` + `assets/settings-hooks.snippet.json`을 설치. 상세: `references/progress-and-hooks.md`.
- **제어 루프** — 코드가 바뀌면 관련 seam 검사를 자동 실행해 사실을 수집한다(`실행→관측→판정→교정`). `scripts/seam-sensor-run.sh` + `assets/seam-sensors.template.json`. **훅은 측정만 하고 판정은 정본과 대조해서 한다.** 상세: `references/control-loop.md`.
  - **선택 기능이지만 스킵은 명시적 결정으로 남긴다.** "옵션"이라고 조용히 지나가지 않는다 — seam이 여럿이거나 장기 구현이면 이탈을 통합 시점에야 발견하게 되므로 제어 루프의 이득이 크다. 셋 중 하나로 결정하고 그 판단을 PROGRESS에 기록한다:
    - **설치** — `seam-sensors.json` 정의(센서마다 `seam`·`rules`) + 훅 설치
    - **연기** — 구현 착수 전이라 검사할 코드가 없으면, "구현 단계에서 설치"를 PROGRESS의 다음 할 일로 등재
    - **생략** — seam이 적어 과하다고 판단하면, 그 사유를 PROGRESS에 한 줄 남긴다

### Phase 8: 검증
싼 것부터: 구조 → 정본 무결성 → 트리거 → 드라이런 → 실행 테스트 → **Seam QA**. 상세: `references/verification.md`.
- 트리거·실행 테스트(with/without 비교, near-miss 작성): `references/skill-testing.md`
- **Seam QA** — 정본을 assertion으로 전개해 구현과 대조한다. **측정(사실 수집)과 판정을 분리**하고, 불일치는 **V(구현 위반)/G(계약 공백)/S(정본 노후)/D(점진 이탈)로 판정**한다. 심각도는 규칙 등급에서 나온다(MUST 위반=FAIL, SHOULD 이탈=WARN). "다름"에서 멈추지 않는 것이 핵심: `references/seam-qa.md`

### Phase 9: 진화
실행 후 피드백 수집 → 유형별 반영(품질=스킬, 역할=에이전트, 순서=오케스트레이터, 계약=정본). 모든 변경은 CLAUDE.md/README 변경 이력에 기록. **CE-우선 원칙에 따라 계약 변경은 항상 정본부터.**
- 재실행 판별(초기/부분/새/CE 재실행)·확장 시 Phase 선택·drift 감사: `references/re-execution.md`
- **연기된 운영 결정 게이트** — P-F에서 "연기"로 남긴 결정(제어 루프 등)은 매 실행 Phase 0에서 PROGRESS의 "하네스 운영 결정"을 읽어 조건 충족 여부를 확인한다. 충족되면(예: 제어 루프 "M3 착수 시" ↔ 지금 구현 단계) 실행을 선행 작업으로 올린다. **조건 판정은 사람에게 확인받고, 정본에서 도출 가능한 것(seam·rules)은 자동 시드하되 `command`는 사람이 채운다** — command를 추측해 채우면 SENSOR_ERROR를 양산하는 "판단 없는 설치"가 된다: `references/execution-modes.md`·`control-loop.md`
- **계약이 바뀌면 소비자 전원이 대상이다.** 한 명만 반영하면 그 자체가 경계면 버그다.
- **정본 변경은 사람 승인을 거친다.** 규칙의 추가·완화·삭제는 자동 반영하지 않는다.
- 실패한 태스크는 **매 회차 컨텍스트를 강화하며 최대 3회 재시도**, 소진 시 보류하고 사람에게 넘긴다: `references/execution-modes.md`

## 산출물 체크리스트
- [ ] `docs/context/plan-extracts/` (입력 문서가 있을 때)
- [ ] `docs/context/{seam}.md` 정본들 — **seam-only 배너 + [정본]/[TODO]/[OPEN] 표기**
- [ ] **모든 계약 항목에 등급(MUST/SHOULD)과 Rule ID 부여**, 점진 이탈 감시 축 정의
- [ ] `docs/context/{glossary,fr-index,open-decisions}.md`
- [ ] `docs/context/README.md` — SoT + Context/Design 경계 + CE-우선 변경 프로토콜 + **오너십 맵** + **승인 게이트** + 규칙 등급 + 변경 이력
- [ ] `.claude/agents/*.md` — seam 소유자로 정의, 모두 `model: opus`, "재호출 시" 지침 포함
- [ ] **모든 seam에 소유자 정확히 1명 + 소비자 1명 이상** (고아 정본·유령 seam 없음)
- [ ] `.claude/skills/*/SKILL.md` — "컨텍스트 자산 참조" 포함, 오케스트레이터 1개
- [ ] **QA 에이전트 존재** — `general-purpose`, seam 미소유, 계약 수정 권한 없음
- [ ] 오케스트레이터에 **실행 모드 명시** + Phase 0 컨텍스트 확인 + description에 후속 작업 키워드
- [ ] **오케스트레이터 Phase 0에 "연기된 운영 결정 확인" 배선** — 생성된 스킬 본문에 있어야 개발 단계 직접 호출 시 게이트가 돈다(reference에만 있으면 실패)
- [ ] 트리거 검증 완료 — should / should-NOT(near-miss, 인접 seam 위주)
- [ ] **Seam QA 1회 이상 수행** — 측정/판정 분리, 판정(V/G/S/D)·심각도(FAIL/WARN)·Rule ID 기록
- [ ] `SENSOR_ERROR`로 남은 미측정 항목 없음 (통과로 처리하지 않았는가)
- [ ] `PROGRESS.md` — 내러티브+포인터
- [ ] `CLAUDE.md` — 하네스·컨텍스트·변경 프로토콜 포인터
- [ ] (옵션) Stop 훅 설치
- [ ] **제어 루프 — 설치·연기·생략 중 하나로 결정하고 PROGRESS에 사유 기록** (옵션이지만 결정은 필수, 조용한 스킵 금지)
- [ ] `.claude/commands/` — 아무것도 생성하지 않음
- [ ] **P-B(Seam 발견)가 HE보다 먼저 수행됨**

## 참조
**CE(계약)** — `references/phase-input-curation.md` · `seam-discovery.md` · `governance.md`
**HE(팀)** — `references/harness-engineering.md`(허브) · `execution-modes.md` · `skill-authoring.md`
**검증** — `references/verification.md` · `skill-testing.md` · **`seam-qa.md`**(경계면 계약 대조)
**운영** — `references/progress-and-hooks.md` · `re-execution.md` · `control-loop.md`(실행→관측→판정→교정)
템플릿: `assets/` · 도구: `scripts/`
