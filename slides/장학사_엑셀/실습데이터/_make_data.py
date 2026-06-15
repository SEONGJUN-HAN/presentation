# -*- coding: utf-8 -*-
"""10개 학교 x 과목 10개 내외로 ex1/ex2 데이터를 생성해 _data.json에 반영.
L/sem/out/notes 등 나머지 설정은 보존한다. 시드 고정으로 매번 동일 결과."""
import json, os, random

BASE = os.path.dirname(os.path.abspath(__file__))
PATH = os.path.join(BASE, "_data.json")
cfg = json.load(open(PATH, encoding="utf-8"))
random.seed(20250616)

SCHOOLS = [
    ("가람초등학교", "가람초"), ("나래초등학교", "나래초"), ("다온초등학교", "다온초"),
    ("라온초등학교", "라온초"), ("마루초등학교", "마루초"), ("바롬초등학교", "바롬초"),
    ("사랑초등학교", "사랑초"), ("아람초등학교", "아람초"), ("한솔초등학교", "한솔초"),
    ("해솔초등학교", "해솔초"),
]

POOL = {
    "교과": ["영어회화", "수학사고력", "한국사", "독서논술", "한자교실",
             "과학실험", "글쓰기교실", "시사토론", "사회탐구", "영문법"],
    "예체능": ["바이올린", "방송댄스", "축구교실", "미술교실", "피아노",
               "농구교실", "합창단", "난타", "배드민턴", "태권도"],
    "정보": ["코딩", "로봇과학", "3D프린팅", "AI기초", "드론교실", "메이커교실"],
}
AREAS = ["교과", "예체능", "정보"]  # 출력 순서 고정

NAMES = ["김가람", "이나래", "박다온", "최라온", "정마루", "강바롬",
         "윤사랑", "임아람", "한지솔", "오해솔", "서지은", "조현우"]

TITLE_TPL = [
    "{full} 2025학년도 방과후학교 운영 현황",
    "{short} 2025 방과후학교 운영현황",
    "{full} 방과후학교 운영 현황 (2025학년도)",
    "2025학년도 {short} 방과후학교 운영 결과",
]
MEMO_TPL = [
    "작성자: {name}  /  작성일 2025-03-{dd:02d}",
    "담당: {name} (2025. 3. {dd}.)",
    "작성: {short} 행정실",
    "방과후 담당 {name} 제출  (2025.03.{dd:02d})",
]


def make_courses():
    """과목 9~11개를 영역별로 뽑아 (영역, 강좌명, c1,n1,c2,n2) 생성."""
    n_kyo = random.randint(4, 5)
    n_ye = random.randint(4, 5)
    n_jung = random.randint(1, 2)
    picks = []
    for area, k in (("교과", n_kyo), ("예체능", n_ye), ("정보", n_jung)):
        picks += [(area, c) for c in random.sample(POOL[area], k)]
    rows_master = []
    for area, course in picks:
        c1 = random.choices([1, 2, 3], weights=[5, 3, 1])[0]
        n1 = sum(random.randint(12, 21) for _ in range(c1))
        if random.random() < 0.06:          # 2학기 폐강
            c2, n2 = None, None
        else:
            c2 = max(1, c1 + random.choice([0, 0, 0, 1, -1]))
            n2 = sum(max(8, random.randint(12, 21) + random.choice([-2, 0, 1]))
                     for _ in range(c2))
        rows_master.append((area, course, c1, n1, c2, n2))
    # 영역 순서대로 정렬 (취합/소계가 영역별로 묶이도록)
    rows_master.sort(key=lambda r: AREAS.index(r[0]))
    return rows_master


ex1_schools, ex2_schools = [], []
for idx, (full, short) in enumerate(SCHOOLS):
    name = NAMES[idx % len(NAMES)]
    dd = random.randint(5, 18)
    title = TITLE_TPL[idx % len(TITLE_TPL)].format(full=full, short=short)
    memo = MEMO_TPL[idx % len(MEMO_TPL)].format(name=name, short=short, dd=dd)
    master = make_courses()
    ex1_rows, ex2_rows = [], []
    for area, course, c1, n1, c2, n2 in master:
        ex1_rows.append({"area": area, "course": course, "v": [n1, n2]})
        ex2_rows.append({"area": area, "course": course, "c": [c1, c2], "n": [n1, n2]})
    ex1_schools.append({"file": full, "short": short, "title": title, "memo": memo, "rows": ex1_rows})
    ex2_schools.append({"file": full, "short": short, "title": title, "memo": memo, "rows": ex2_rows})

cfg["ex1"]["schools"] = ex1_schools
cfg["ex2"]["schools"] = ex2_schools
json.dump(cfg, open(PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"schools={len(ex1_schools)}, "
      f"ex1_rows={sum(len(s['rows']) for s in ex1_schools)}, "
      f"ex2_rows={sum(len(s['rows']) for s in ex2_schools)}")
