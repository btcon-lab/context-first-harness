#!/usr/bin/env python3
"""
split-source.py — 입력 큐레이션(P-A).
무거운 원문(.docx / .md / .txt)을 번호 섹션(top-level heading)별로 분리하여
docs/context/plan-extracts/NN_*.md 로 저장한다(읽기용·정본 아님).

용법:
  python3 split-source.py <source_file> [out_dir]
    out_dir 기본값: docs/context/plan-extracts

지원:
  - .docx : word/document.xml 문단 추출
  - .md/.txt : 그대로 라인 사용

섹션 분리 규칙:
  - Markdown '# ' / '## ' 헤딩, 또는 'N. 제목' 형태의 번호 헤딩에서 분리
  - 번호 헤딩은 단조 증가하는 것만 최상위 섹션으로 인정(표 안의 '0. …' 오인 방지)
"""
import sys, os, re, zipfile

def read_docx(path):
    from xml.etree import ElementTree as ET
    ns = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
    xml = zipfile.ZipFile(path).read("word/document.xml").decode("utf-8")
    root = ET.fromstring(xml)
    return ["".join(n.text for n in p.iter(ns + "t") if n.text)
            for p in root.iter(ns + "p")]

def read_text(path):
    with open(path, encoding="utf-8") as f:
        return f.read().splitlines()

def slug(s, n=24):
    return re.sub(r"[^0-9A-Za-z가-힣]+", "-", s.strip()).strip("-")[:n] or "sec"

def split(lines):
    num = re.compile(r"^(\d{1,2})\.\s+\S")
    mdh = re.compile(r"^#{1,2}\s+\S")
    expected, cur, buf, out = 1, "00_overview", [], []
    for ln in lines:
        m = num.match(ln)
        if m and int(m.group(1)) == expected:
            out.append((cur, buf))
            n = int(m.group(1))
            cur = f"{n:02d}_{slug(ln.split('.',1)[1])}"; buf = [ln]; expected = n + 1
        elif mdh.match(ln):
            out.append((cur, buf))
            cur = f"{len(out):02d}_{slug(re.sub(r'^#+', '', ln))}"; buf = [ln]
        else:
            buf.append(ln)
    out.append((cur, buf))
    return out

def main():
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(1)
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else "docs/context/plan-extracts"
    lines = read_docx(src) if src.lower().endswith(".docx") else read_text(src)
    os.makedirs(out, exist_ok=True)
    banner = f"<!-- 출처: {os.path.basename(src)} 자동추출 · 읽기용(정본 아님). 정본은 docs/context/의 계약 파일 -->\n\n"
    made = 0
    for key, para in split(lines):
        body = re.sub(r"\n{3,}", "\n\n", "\n".join(para)).strip()
        if not body:
            continue
        with open(os.path.join(out, key + ".md"), "w", encoding="utf-8") as f:
            f.write(banner + body + "\n")
        made += 1
        print(f"  {key}.md ({len(para)} paras)")
    print(f"[done] {made} sections -> {out}")

if __name__ == "__main__":
    main()
