# 슬라이드 만들기 가이드

새 발표자료는 **내용만 얹으면** 되도록 디자인이 `css/slide-kit.css` 에 정리돼 있습니다.

---

## 1. 새 프로젝트 시작하기

```bash
# 1) 템플릿을 복사
cp -r slides/_템플릿 slides/새프로젝트이름
```

2) `js/loader.js` 맨 위 `DECKS` 목록에 한 줄 추가합니다. (첫 화면 덱 선택 목록)

```js
{ folder: '새프로젝트이름', title: '표지 제목', desc: '한 줄 설명' },
```

3) 로컬 서버로 엽니다. (`file://` 로 직접 열면 안 됩니다)

```bash
npx serve
```

> 💡 `index.html` 을 그냥 열면 덱 선택 화면이 나오고, 주소 뒤에 `?deck=폴더명` 을 붙이면 그 덱이 바로 열립니다.
> 예) `index.html?deck=_템플릿` — 목록에 없는 덱도 이렇게 열 수 있고, 탭마다 다른 덱을 동시에 띄울 수 있습니다.

---

## 2. 슬라이드 한 장의 뼈대

**본문 슬라이드**

```html
<div class="sk tone-cyan">
  <div class="s-head">
    <div class="s-head__main">
      <span class="s-badge">배지</span>
      <h2 class="s-title">슬라이드 제목</h2>
    </div>
    <span class="s-pill">오른쪽 알약(선택)</span>
  </div>

  <div class="cols">
    <div class="col"> ... 왼쪽 ... </div>
    <div class="col"> ... 오른쪽 ... </div>
  </div>
</div>
```

**표지 / 섹션 커버**

```html
<div class="sk sk-cover tone-lime">
  <div class="sk-cover__glow"></div>
  <div class="sk-cover__icon">📌</div>
  <div class="sk-cover__label">Part 1</div>
  <h2 class="sk-cover__title">제목 <em>강조</em></h2>
  <p class="sk-cover__desc">한 줄 설명</p>
</div>
```

> ⚠️ 루트는 반드시 `sk` 로 시작하세요. 그래야 여백이 자동으로 잡힙니다.
> (`sk` 가 없으면 예전 방식으로 동작합니다)

---

## 3. 자주 쓰는 조각

| 하고 싶은 것 | 클래스 |
|---|---|
| 2단 배치 | `cols` · 비율 조절은 `cols--left` / `cols--right` / `cols--3` |
| 열 안의 세로 정렬 | `col` (기본 가운데) · `col--top` · `col--fill` |
| 카드 | `card` · 옅게 `card--plain` · 강조 `card--pick` |
| 카드 구성 | `card__head` `card__icon` `card__title` `card__body` `card__foot` |
| 체크 목록 | `<ul class="list">` + `<li>` · 경고 `is-warn` · 금지 `is-no` |
| 강조 문장 | `note` |
| Before → After | `ba` + `ba__item ba__before` / `ba__after` |
| 단계 타임라인 | `steps` + `step` (`step__num` `step__line` `step__title` `step__desc`) |
| 파일명·출처 주석 | `tag` |
| 짧은 글 카드(아이콘 크게·가운데) | `card--hero` |
| 그림 옆에 쌓는 납작한 카드 | `card--row` |
| 열 하나를 채우는 그림 | `<img class="shot">` |
| 흐린 그림 배경 | 루트에 `sk--photo` + 첫 줄에 `<img class="sk-bg">` |
| 그림·글씨 초점 나누기 | `sk--photo` 에 더해 `sk--photo-left`(그림 주인공) / `sk--photo-right`(글씨 주인공) |
| 제목 아래 도입 문단 | `<p class="lead">` |
| 열 안의 소제목 (카드 밖) | `s-h3` |
| 카드 제목 위 작은 라벨 / 맨 아래 한 줄 | `card__kicker` / `card__end` (구분선) |
| 톤 색으로 꽉 채운 강조 카드 | `card--fill` |
| 가로로 긴 카드 (2~4개 세로로 쌓기) | `stack stack--fill` 안에 `card--wide` |
| 카드 사이 화살표 | `flow` + `<i class="fa-solid fa-arrow-right flow__arrow">` · 세로 `flow--down` |
| 번호 / 점 / 아이콘 목록 | `list--num` · `list--dot` · `list--icon` (li 첫 줄에 `<i>`) · 열 채우기 `list--spread` |
| 메모·폴더 구조 같은 고정폭 글 | `memo` |
| 표 첫 칸을 머리말처럼 | `<table class="tbl--key">` |
| 잘리면 안 되는 캡처 | `shot shot--contain` |
| 칸 안 그림 가장자리 흐리게 | `shot shot--fade` |

> 💡 글은 `<p>` 로 쓰세요 (`<p class="card__body">` 등). p 안의 `<strong>` 이 흰색이 되고, 줄바꿈 자동 정돈도 p 에만 작동합니다.

---

## 3-1. 그림 쓰기 — 글씨형 덱 / 그림형 덱

**같은 slide-kit 하나로 둘 다 만듭니다.** 그림은 슬라이드마다 골라 넣는 것이고, 덱 전체를 바꾸는 스위치는 없습니다.

### 언제 그림을 넣나 — 슬라이드의 "할 일"로 판단

| 이 슬라이드가… | 그림 | 예 |
|---|---|---|
| **느낌·공감**을 줘야 한다 | ✅ 흐린 배경 (`sk--photo`) | 표지, "왜 바꿨나?", 목표, 마무리 |
| **비유**로 설명한다 | ✅ 옆에 크게 (`shot`) | 데이터의 섬, 서류 미로 |
| **읽고 따라 해야** 한다 | ❌ 글씨·캡처만 | 절차, 메뉴 위치, 코드, 숫자표 |

- **그림형 덱:** 연수 도입부, 설득, 동기부여, 처음 보는 청중
- **글씨형 덱:** 실습 따라하기, 매뉴얼, 내부 보고
- 그림형 덱이라도 **실습 장은 글씨형**으로 둡니다. 섞어 쓰는 것이 기본입니다.
- 한 덱에 그림은 **4~8장**이 적당합니다. 전부 넣으면 강조가 사라집니다.

### 흐린 그림 배경

```html
<div class="sk sk-cover sk--photo tone-amber">      <!-- 표지 -->
  <img class="sk-bg" src="img/덱이름/01_cover.png" alt="">
  ...
</div>

<div class="sk sk--photo tone-amber">                <!-- 본문 -->
  <img class="sk-bg" src="img/덱이름/03_worry.png" alt="">
  ...카드는 자동으로 바탕이 채워져 글이 읽힙니다...
</div>
```

흐림 정도는 `--photo-dim` (표지 0.42 / 본문 0.5 / 좌우 분리 0.8).

### 그림과 글씨의 초점은 좌우로 나눈다 (기본)

둘 다 가운데에 두면 초점이 겹쳐 그림을 많이 죽여야 합니다. 좌우로 나누면 그림을 밝게 살리고도 글씨가 읽힙니다.

| 이 장의 주인공 | 클래스 | 배치 |
|---|---|---|
| 그림 | `sk--photo-left` | 그림 왼쪽(먼저 보임) · 글씨 오른쪽 |
| 글씨 | `sk--photo-right` | 글씨 왼쪽 · 그림 오른쪽(보조) |

```html
<div class="sk sk-cover sk--photo sk--photo-left tone-amber">
  <img class="sk-bg" src="img/덱이름/07_speak.png" alt="">
  ...
</div>
```

그림은 처음부터 **소재를 한쪽 60% 안에, 반대쪽 40%는 빈 검정**으로, 인물은 글씨 쪽을 바라보게 만듭니다. 배경은 화면 전체가 이어진 순수한 검정(회색 바닥 금지 — 세로 경계선이 생김).
가운데 구도로 만든 옛 그림은 `style="--photo-w: 74%"` 로 한쪽에 붙여 씁니다.

### 그림 가장자리는 흐리게 (비네트)

딱 끊긴 테두리는 단절감을 줍니다. 가운데는 밝게, 끝으로 갈수록 어둡게 검정 배경에 녹입니다.
- 좌우 분리 배경(`sk--photo-left/right`)은 이미 위아래·바깥쪽까지 비네트가 들어가 있습니다.
- 칸 안의 그림은 `<img class="shot shot--fade">` — 테두리 없이 타원으로 녹아듭니다. 덱 전체를 바꾸려면 `[data-deck="..."] .sk--photo { --photo-dim: .3; }`

### 그림 만들기 (안티그래비티 + 나노바나나)

1. Claude 에게 "이 덱 그림 기획해줘" → `deck-illustration` 스킬이 `img/<덱이름>/프롬프트.md` 생성
2. 안티그래비티에서 같은 폴더 열고: `img/<덱이름>/프롬프트.md 를 읽고 그대로 이미지 만들어서 저장해줘`
3. Claude 에게 "배치해줘"

프롬프트 원칙 — `img/교데통/프롬프트.md` 를 본보기로 쓰세요.
- 첫 장을 먼저 만들고 **나머지는 첫 장을 스타일 참조**로 → 화풍 통일
- **그림 안에 글자 금지** (한글이 깨짐). 글씨는 HTML 로 얹습니다
- 배경은 덱 테마색(지금은 검정), 포인트는 테마 강조색(앰버) 하나만
- 흐린 배경용은 **소재를 한쪽 60% 안에, 반대쪽 40% 비움**(주인공에 따라 좌/우), 옆에 두는 그림은 4:3

---

## 4. 색 바꾸기

`tone-*` 클래스만 붙이면 그 안의 카드·아이콘·테두리·강조가 **한꺼번에** 바뀝니다.

```html
<div class="sk tone-violet">        <!-- 슬라이드 전체 -->
  <div class="card tone-amber">     <!-- 이 카드만 다른 색 -->
```

쓸 수 있는 톤: `tone-cyan` `tone-lime` `tone-amber` `tone-red` `tone-sky` `tone-violet` `tone-fuchsia`

---

## 5. 크기·간격 바꾸기

숫자를 직접 쓰지 말고 토큰을 쓰세요. (`slide-kit.css` 상단)

```
글씨  --fs-micro 12 / --fs-xs 14 / --fs-sm 15 / --fs-body 17 / --fs-lead 19
      --fs-h3 22 / --fs-h2 34 / --fs-h1 44
여백  --sp-1 6 / --sp-2 10 / --sp-3 14 / --sp-4 18 / --sp-5 24 / --sp-6 32
```

덱 전체의 느낌만 바꾸고 싶으면 `slide-kit.css` 맨 아래에 이렇게 추가합니다.

```css
[data-deck="새프로젝트이름"] {
    --tone:     var(--c-violet);
    --fs-body:  18px;
    --slide-py: 40px;
}
```

---

## 6. 겪었던 함정 (같은 실수 반복 방지)

| 증상 | 원인 | 예방 |
|---|---|---|
| 내용이 위로 쏠리고 아래가 빔 | 그리드가 `align-items:start` 라 열이 내용 높이로 줄어듦 | `cols` 사용 (이미 `stretch`) |
| 글씨가 작고 여백만 넓음 | 컨테이너와 슬라이드가 padding 을 **이중** 적용 | 루트에 `sk` 사용 (컨테이너 padding 자동 해제) |
| 배경 글로우가 글자를 덮음 | `position:absolute` + `z-index:0` 은 본문보다 **나중에** 그려짐 | 장식은 `z-index:-1` |
| CSS 를 고쳤는데 반영이 안 됨 | 브라우저가 css 파일을 캐시 | `index.html` 의 `?v=` 숫자를 올리고 `Ctrl+Shift+R` |
| 헤더 오른쪽 알약이 잘림 | 긴 제목이 폭을 다 차지 | `s-head__main`(`min-width:0`) + `s-pill`(`flex-shrink:0`) |
| 카드마다 색을 바꿨는데 안 먹힘 | 파생 변수를 부모에서 한 번만 계산 | 파생값은 `*` 에 선언 (이미 적용됨) |
| 목록 속 굵은 글씨 앞뒤로 간격이 벌어짐 | `li` 가 flex 라 글 조각이 따로 떨어진 칸이 됨 | `.list li` 는 block + 아이콘 absolute (이미 적용됨) |

---

## 7. 폴더 구조

```
presentation/
├── index.html          ← css 링크의 ?v= 로 캐시 관리
├── css/
│   ├── base.css        ← 화면 껍데기(덱·네비·인쇄)
│   ├── components.css  ← 예전 덱용 (건드리지 말 것)
│   └── slide-kit.css   ← ★ 디자인 시스템. 새 덱은 여기만 보면 됨
├── js/loader.js        ← DECKS 목록(덱 선택 화면) / ?deck= 지원
└── slides/
    ├── _템플릿/        ← ★ 새로 만들 때 복사
    └── <각 발표자료>/
```


## 줄바꿈·자간은 자동입니다

- `css/base.css` 가 한글을 어절 단위로 줄바꿈하고(`word-break: keep-all`), 마지막 줄에 한 단어만 남는 것을 막고(`text-wrap: pretty`), 제목 줄 길이를 고릅니다(`balance`).
- `navigation.js` 의 `fitAllText()` 가 마지막 줄에 짧은 꼬리만 남은 문단의 자간을 최대 -0.04em 까지 줄여 한 줄을 덜어냅니다.
- 그러니 새 슬라이드에서 보기 좋게 하려고 `<br>` 을 넣지 마세요. 문장 단위로 끊고 싶을 때만 `<br>` 을 씁니다.
- 코드(`pre`, `code`)는 자간·줄바꿈을 건드리지 않습니다. 글자 크기는 14px 아래로 내리지 마세요.
