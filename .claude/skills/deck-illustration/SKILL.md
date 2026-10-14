---
name: deck-illustration
description: 발표 덱(slides/<덱>/)에 그림을 넣을 때 사용. 어느 장에 그림이 필요한지 판단하고, 안티그래비티(나노바나나)용 img/<덱>/프롬프트.md 를 쓰고, 생성된 그림을 슬라이드에 배치·검증한다. "그림 기획해줘", "이미지 넣어줘", "그림 만들었어 배치해줘", "이 덱 그림형으로" 같은 요청이 대상.
---

# 덱 그림 기획 → 생성(안티그래비티) → 배치

그림은 **Claude 가 직접 그리지 않는다** (SVG 삽화 금지 — 품질이 나빠 사용자가 거부함).
사용자가 안티그래비티에서 나노바나나로 생성하고, Claude 는 **기획·프롬프트·배치·검증**만 한다.

두 단계로 나뉜다. 요청이 어느 쪽인지 보고 해당 단계만 한다.

- **A. 기획** — "그림 기획해줘", "그림 넣어줘" (아직 그림 없음)
- **B. 배치** — "그림 만들었어", "배치해줘" (`img/<덱>/` 에 png 가 생김)

---

## A. 기획

### 1. 덱을 읽고 장마다 "할 일"로 판단

`slides/<덱>/*.html` 을 전부 읽는다. 각 장을 아래 셋 중 하나로 분류한다.

| 그 장이 하는 일 | 그림 | 배치 방식 |
|---|---|---|
| **느낌·공감** (표지, 섹션 표지, "왜?", 목표, 마무리) | 넣음 | 흐린 배경 `sk--photo` · 16:9 |
| **비유로 설명** (섬, 미로, 다리, 길…) | 넣음 | 옆에 크게 `shot` · 4:3 |
| **읽고 따라 하기** (절차, 메뉴 위치, 코드, 숫자표) | **넣지 않음** | 글씨 + 실제 화면 캡처 |

- 한 덱에 **4~8장**. 전부 넣으면 강조가 사라진다.
- 실습·절차 장에는 그림 대신 **실제 화면 캡처**를 사용자에게 요청한다.
- 같은 비유가 두 장에 걸치면(예: 끊어진 섬 → 이어진 섬) **같은 소재로 이어지게** 기획한다. 덱 전체에 흐름이 생긴다.

### 2. 사용자에게 기획표를 먼저 보여 준다

| 파일 | 슬라이드 | 장면 | 방식 |
|---|---|---|---|

확인을 받은 뒤 3으로 간다. (기획이 이미 합의된 상태면 바로 3)

### 3. `img/<덱>/프롬프트.md` 작성

[prompt-template.md](prompt-template.md) 를 복사해서 채운다. 원칙:

- **파일명** `NN_영문.png` — NN 은 슬라이드 번호 (예: `05_islands.png`). 슬라이드 번호가 바뀌면 파일명도 같이 바꾼다.
- **프롬프트는 영어**, 설명·안내는 한국어.
- **[공통 스타일]** 은 덱 테마에서 가져온다. 기본은 검정 배경 + 앰버(#fbbf24) 하나, 아이소메트릭 3D 클레이. 덱에 `[data-deck]` 테마 오버라이드가 있으면 그 색으로 바꾼다.
- **그림 안에 글자·숫자·로고 금지** — 한글이 깨진다. 글씨는 HTML 로 얹는다.
- **1번을 먼저 만들고 나머지는 1번을 스타일 참조**로 넘기라고 적는다.
- **구도**
  - 흐린 배경용(16:9): **소재를 화면 가운데에**. 위아래를 비우라고 하지 않는다.
  - 옆에 두는 그림(4:3): 소재가 프레임을 채우게.
  - ❌ "위쪽 55%를 비우고 소재는 아래" 구도 금지 — 제목이 위로 밀려 작아져서 실패했다.
- 사람은 **faceless stylized figure** 로.

마지막에 사용자에게 안티그래비티에 붙여 넣을 한 줄을 준다.

```
img/<덱>/프롬프트.md 를 읽고 그대로 이미지 만들어서 저장해줘
```

---

## B. 배치

### 1. 그림을 전부 본다

`img/<덱>/*.png` 를 Read 로 하나씩 열어 확인한다. 글자가 들어갔거나 화풍이 튀면 그 파일만 다시 만들어 달라고 한다.

### 2. 슬라이드에 넣는다

**흐린 배경 표지**
```html
<div class="sk sk-cover sk--photo tone-amber">
  <img class="sk-bg" src="img/<덱>/01_cover.png" alt="">
  <div class="sk-cover__label">라벨</div>
  <h1 class="sk-cover__title">제목<br><em>강조</em></h1>
  <p class="sk-cover__desc">문장마다<br>줄바꿈</p>
</div>
```
- 이모지 아이콘(`sk-cover__icon`)과 글로우(`sk-cover__glow`)는 뺀다 — 그림이 그 역할.
- 제목은 두 줄이 좋다 (58px 로 자동 확대).

**흐린 배경 본문** — 카드는 **`card--row` 로 납작하게** 해서 아래로 모은다. 카드를 크게 쓰면 그림이 다 가려진다.
```html
<div class="sk sk--photo tone-amber">
  <img class="sk-bg" src="img/<덱>/03_worry.png" alt="">
  <div class="s-head">...</div>
  <div class="cols">
    <div class="card card--row">
      <div class="card__icon"><i class="fa-solid fa-..."></i></div>
      <div><div class="card__title">제목</div><div class="card__body">한 줄</div></div>
    </div>
    ...
  </div>
</div>
```

**옆에 크게**
```html
<div class="cols cols--right">          <!-- 그림 쪽이 넓게 -->
  <div class="col"><img class="shot" src="img/<덱>/05_islands.png" alt="설명"></div>
  <div class="col"> card--row 여러 개 </div>
</div>
```

- `src` 는 반드시 `img/` 로 시작 (build.js 가 이 패턴만 base64 로 넣는다).
- slide-kit.css 를 고쳤으면 `index.html` 의 `slide-kit.css?v=` 숫자를 올린다.

### 3. 검증 — 1280×720 실제 크기로

1. preview 서버(`presentation`)를 띄우고 `resize_window` 1280×720.
2. `?deck=<덱>` 으로 열고 JS 로 장을 옮기며 스크린샷:
   ```js
   currentSlide = N; updateSlideUI();
   ```
   (화살표 키 연타는 전환 애니메이션 중에 찍혀 흐리게 나온다 — 2초 기다린 뒤 찍는다.)
3. 넘침·깨진 그림 검사:
   ```js
   [...document.querySelectorAll('.slide-container .sk')].map((s,i)=>
     (i+1)+':'+s.scrollHeight+'/'+s.clientHeight+'/'+
     [...s.querySelectorAll('img')].map(m=>m.naturalWidth?'ok':'X').join('')).join(' ')
   ```
   모든 장이 `720/720`, 그림은 `ok` 여야 한다.
4. 눈으로 볼 것: 표지 제목이 가운데에 크게 있는가 / 본문 배경 그림이 카드에 다 가려지지 않았는가.
5. 끝나면 `resize_window` preset desktop 으로 되돌린다.

### 4. 빌드

```bash
node build.js <덱>
```
`⚠ 이미지 없음` 경고가 없어야 한다.

---

## 참고
- 디자인 규칙 전체: `SLIDE_GUIDE.md` 3-1절
- 잘 된 본보기: `slides/교데통_사용자교육/` + `img/교데통/프롬프트.md` (단, 1차 표지 4장의 "위쪽 55% 비우기" 구도는 따라 하지 말 것 — 2차 2장 방식이 정답)
