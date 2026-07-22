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

# 학교 속성: 지역(권역) · 설립(공/사립) — 피벗/언피벗 실습용 차원
REGION = {
    "가람초등학교": "동부", "나래초등학교": "동부", "다온초등학교": "동부", "라온초등학교": "동부",
    "마루초등학교": "서부", "바롬초등학교": "서부", "사랑초등학교": "서부",
    "아람초등학교": "남부", "한솔초등학교": "남부", "해솔초등학교": "남부",
}
SETUP = {
    "가람초등학교": "공립", "나래초등학교": "사립", "다온초등학교": "공립", "라온초등학교": "사립",
    "마루초등학교": "공립", "바롬초등학교": "사립", "사랑초등학교": "공립", "아람초등학교": "사립",
    "한솔초등학교": "공립", "해솔초등학교": "공립",
}

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
    region, setup = REGION[full], SETUP[full]
    ex1_schools.append({"file": full, "short": short, "region": region, "setup": setup,
                        "title": title, "memo": memo, "rows": ex1_rows})
    ex2_schools.append({"file": full, "short": short, "region": region, "setup": setup,
                        "title": title, "memo": memo, "rows": ex2_rows})

cfg["ex1"]["schools"] = ex1_schools
cfg["ex2"]["schools"] = ex2_schools

# 지역·설립 라벨 추가
cfg["L"]["region"] = "지역"
cfg["L"]["setup"] = "설립"

# 안내문에 지역·공사립 집계 실습 안내 보강
cfg["notes1"] = [
    "[예제 1] 방과후학교 수강 현황 - 머리글 1줄 (단일 측정값: 수강인원)",
    "",
    "실습 흐름:",
    "1) 취합 : 원본 폴더의 학교 파일들을 VBA 추가기능으로 한 번에 세로로 쌓는다 (A열=파일명, B열=시트명).",
    "2) 전처리 : 제목행/메모행/빈행/반복된 머리글행/합계행을 걷어낸다. 병합된 영역 셀은 해제 후 아래로 채운다. '-'(폐강)은 빈칸으로.",
    "3) 언피벗 : 1학기/2학기 두 열을 파워쿼리에서 언피벗 -> 학기 / 수강인원 두 열로 길게 푼다.",
    "4) 학교 열 : 파일명(A열)을 다듬어 학교 열을 만든다.",
    "5) 지역·설립 붙이기(기본) : '학교속성표.xlsx'를 학교 기준으로 VLOOKUP(또는 파워쿼리 병합)해 지역·설립 열을 붙인다.",
    "   (심화 시연) 원본 3행의 '지역: OO  설립: OO' 텍스트에서 직접 추출하는 방법도 있음 - 함수/파워쿼리/AI 추가기능 활용.",
    "6) 분석 : 피벗테이블로 학교별/지역별/공사립별 x 학기별 수강인원 합계를 자유롭게 만든다.",
    "",
    "핵심: 데이터형(데이터베이스 구조)으로 한 번 정리해 두면, 학교·지역·공사립 등 무엇으로 집계하든 피벗 기준만 바꾸면 끝난다.",
    "이 통합문서의 '데이터형' 시트가 2~5단계의 정답, '피벗요약' 시트가 6단계의 정답이다.",
]
cfg["notes2"] = [
    "[예제 2] 방과후학교 운영 현황 - 머리글 2줄 (측정값 2개: 강좌수 + 수강인원)",
    "",
    "핵심 포인트: 강좌수와 수강인원은 단위가 다른 별개의 측정값이므로",
    "한 '값' 열로 모두 녹이면 안 된다(엉뚱한 합계가 나옴). 아래 기법으로 각자 열로 되돌린다.",
    "",
    "실습 흐름:",
    "1) 취합 : 원본 폴더의 학교 파일들을 VBA로 한 번에 쌓는다 (A열=파일명, B열=시트명).",
    "2) 전처리 : 제목/메모/빈행/반복 머리글/소계/합계 행 제거, 병합 영역 채우기, '-' 빈칸 처리.",
    "3) 머리글 합치기 : 2줄 머리글을 '1학기.강좌수' / '1학기.수강인원' ... 형태로 만든다.",
    "4) 언피벗 : 학기x지표 4개 열을 모두 언피벗한다 (특성 열에 '1학기.강좌수' 식).",
    "5) 분리 : 특성 열을 구분자(.)로 분리 -> 학기 / 지표 두 열로.",
    "6) 다시 피벗 : 지표 열만 다시 피벗(값=값, 집계 안 함) -> 강좌수 / 수강인원이 각자 열로 복원.",
    "7) 학교·지역·설립 열 : 파일명으로 학교 열을 만들고, '학교속성표.xlsx'를 VLOOKUP/병합해 지역·설립을 붙인다.",
    "   (심화 시연) 원본 3행의 '지역/설립' 텍스트에서 직접 추출하는 방법도 있음 - 함수/파워쿼리/AI 추가기능 활용.",
    "8) 분석 : 피벗테이블로 학교별/지역별/공사립별 x 학기별 강좌수·수강인원 합계를 만든다.",
    "",
    "핵심: 데이터가 많아도 데이터형으로 정리해 두면 파워쿼리가 자동으로 처리하고, 집계 기준(지역·공사립 등)은 피벗에서 즉시 바꿀 수 있다.",
    "이 통합문서의 '데이터형' 시트가 2~6단계의 정답, '피벗요약' 시트가 8단계의 정답이다.",
]

json.dump(cfg, open(PATH, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
print(f"schools={len(ex1_schools)}, "
      f"ex1_rows={sum(len(s['rows']) for s in ex1_schools)}, "
      f"ex2_rows={sum(len(s['rows']) for s in ex2_schools)}")
