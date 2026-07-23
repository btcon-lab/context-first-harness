# Context-First Harness (CFHM)

> Claude Code 플러그인 · 메타 스킬. 도메인 한 문장이나 개발/계획 문서를 **컨텍스트 정본(seam 계약) → 에이전트 팀 → 거버넌스 → 진행관리**로 표준 변환한다.

기존 하네스 도구는 대개 **에이전트·스킬(HE)까지만** 만든다. 실전 품질을 좌우하는 그 다음 작업 — 컨텍스트 정본(계약), seam/design 경계, 변경 프로토콜, 진행 일지, 갱신 강제 훅 — 은 매번 수작업으로 반복된다. **CFHM은 그 전체를 하나의 파이프라인으로 표준화**한다.

## 핵심 아이디어
1. **Context-First** — 계약(seam)이 기반, 에이전트는 그 위 일꾼. **Seam 발견을 HE보다 먼저** 하여 에이전트를 seam 소유자로 정의한다. (이 순서가 계약 재작업을 없앤다.)
2. **Seam-only 정본** — `docs/context`는 2+ 소비자가 공유하는 인터페이스 사실만. 구현(how)은 `docs/design`이 갖고 계약을 **링크만** 한다. → context↔design drift·오버스펙 방지.
3. **CE-우선 변경** — 계약 수정은 정본 먼저 → 통지 → 반영 → 검증 → 기록. Drift 시 정본이 진실.
4. **Progressive Disclosure + 진화** — 토큰 절약 로딩, PROGRESS·변경이력·메모리·훅으로 장기 관리.

## 파이프라인
```
현황 감사 → 도메인 분석
  → P-A 입력 큐레이션    (원문 → plan-extracts/)
  → P-B Seam 발견        (경계면 식별 → 계약 set + 오너십)   ★ HE보다 먼저
  → HE  팀 구성          (에이전트·스킬·오케스트레이터, seam 소유자)
  → P-C 계약 시드        (docs/context/{seam}.md, seam-only)
  → P-D 배선             (스킬↔context, references/)
  → P-E 거버넌스         (context/README: SoT·경계·변경 프로토콜)
  → P-F 진행·기억        (PROGRESS·CLAUDE.md·memory·Stop 훅)
  → 검증 → 진화
```

## 설치
```
/plugin marketplace add btcon-lab/context-first-harness
/plugin install context-first-harness@cfh-marketplace
```

> **설치 후 새 세션이 필요하다.** 스킬은 세션 시작 시점에 로드되므로, 설치한 그 세션에서는 `context-first-harness` 스킬이 목록에 잡히지 않고 아래 "사용"의 자연어 트리거도 동작하지 않는다. Claude Code를 종료 후 다시 실행하거나 `/clear`로 새 세션을 연다.
>
> `/reload-plugins`는 플러그인 목록만 다시 읽는다. 이미 로드된 세션의 스킬 목록에는 반영되지 않을 수 있으므로, 설치 직후에는 새 세션을 여는 쪽이 확실하다.

## 사용
Claude Code에서:
```
"이 개발 계획서로 context-first 하네스를 구성해줘"   (문서 첨부/경로)
"CFHM으로 하네스 구축"
```
스킬이 P-A~P-F를 순서대로 안내하며 `docs/context/`(정본) + `.claude/`(팀) + `PROGRESS.md` + `CLAUDE.md`를 생성한다.

## 구성
```
.claude-plugin/{marketplace.json, plugin.json}
skills/context-first-harness/
├── SKILL.md              메타 스킬 (파이프라인)
├── references/           단계별 상세 가이드 6종
├── assets/               템플릿 (context-README·seam-contract·glossary·fr-index·open-decisions·PROGRESS·hooks 스니펫)
└── scripts/              split-source.py · session-start-stamp.sh · progress-stop-check.sh
```

## 언제 쓰나 / 언제 과한가
- **적합:** 다중 서비스·경계면이 많은 프로젝트, 계약 정합성·추적성이 중요한 경우, 장기 진행 관리가 필요한 경우.
- **과함:** 에이전트/스킬 하나면 되는 단발 작업. 이때는 일반 하네스나 단일 스킬로 충분.

## 라이선스
MIT
