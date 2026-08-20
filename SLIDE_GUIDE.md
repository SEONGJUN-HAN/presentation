# 슬라이드 만들기 가이드

새 발표자료는 **내용만 얹으면** 되도록 디자인이 `css/slide-kit.css` 에 정리돼 있습니다.

---

## 1. 새 프로젝트 시작하기

```bash
# 1) 템플릿을 복사
cp -r slides/_템플릿 slides/새프로젝트이름
```

2) `js/loader.js` 맨 위에서 폴더명만 바꿉니다.

```js
const DEFAULT_DECK = '새프로젝트이름';
```

3) 로컬 서버로 엽니다. (`file://` 로 직접 열면 안 됩니다)

```bash
npx serve
```

> 💡 파일을 안 고치고 잠깐 다른 덱을 보고 싶으면 주소 뒤에 `?deck=폴더명` 을 붙이세요.
> 예) `index.html?deck=_템플릿`

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

---

## 7. 폴더 구조

```
presentation/
├── index.html          ← css 링크의 ?v= 로 캐시 관리
├── css/
│   ├── base.css        ← 화면 껍데기(덱·네비·인쇄)
│   ├── components.css  ← 예전 덱용 (건드리지 말 것)
│   └── slide-kit.css   ← ★ 디자인 시스템. 새 덱은 여기만 보면 됨
├── js/loader.js        ← DEFAULT_DECK 지정 / ?deck= 지원
└── slides/
    ├── _템플릿/        ← ★ 새로 만들 때 복사
    └── <각 발표자료>/
```
