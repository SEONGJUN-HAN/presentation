# <덱 제목> — 슬라이드 그림 생성 요청

> **안티그래비티 에이전트에게**
> 아래 이미지들을 나노바나나(가능하면 Pro)로 생성해서 **이 폴더(`img/<덱>/`)에 지정한 파일 이름 그대로** PNG로 저장해 주세요.
>
> - 반드시 **첫 번째 이미지를 먼저** 만들고, 나머지는 첫 번째를 **스타일 참조 이미지**로 넘겨서 화풍·색감·조명을 통일해 주세요.
> - 모든 프롬프트 뒤에 아래 **[공통 스타일]**을 그대로 붙여 주세요.
> - 이미지 안에 **글자·숫자·로고·워터마크가 하나도 없어야** 합니다. 글자가 생기면 다시 생성해 주세요.
> - 이 폴더 밖의 파일(슬라이드 html, css 등)은 수정하지 마세요.
> - 끝나면 저장한 파일 목록만 알려 주세요.

---

## [공통 스타일]

```
Style: clean isometric 3D illustration, soft matte clay render, rounded simple shapes,
pure black background (#000000), warm amber (#fbbf24) as the only accent color for glows and highlights,
everything else in muted dark grays and soft whites, gentle rim lighting, subtle soft shadows,
minimal and uncluttered, calm and professional mood, high detail but few objects.
Absolutely no text, no letters, no numbers, no symbols, no logos, no watermark, no UI labels.
People (if any) are simple faceless stylized figures.
```

---

## 1. `NN_slug.png` — <슬라이드 제목> (NN번 슬라이드)

- 비율: **16:9** (1920×1080) — 흐린 배경용
- 배치: 그림은 **왼쪽**(또는 오른쪽)에, 반대쪽 빈 자리에 제목이 들어갑니다.

```
<장면 묘사 — 영어. 무엇이, 어떤 빛으로.>
Place everything inside the LEFT 60% of the frame; characters face toward the right.
Leave the RIGHT 40% of the frame completely empty pure black.
The background is one seamless pure black (#000000) across the entire frame:
no floor, no wall, no gray backdrop, no gradient, no visible edge or split.
```
(글씨가 주인공인 장이면 LEFT↔RIGHT 를 바꾼다)

## 2. `NN_slug.png` — <슬라이드 제목> (NN번 슬라이드)

- 비율: **4:3** (1600×1200) — 옆에 크게
- 배치: 슬라이드 한쪽 열을 채웁니다. 소재가 프레임을 꽉 채우게 해 주세요.

```
<장면 묘사 — 영어>
```

---

## 체크리스트 (생성 후 확인)

- [ ] 파일 이름이 정확한가
- [ ] 글자·숫자·로고가 없는가
- [ ] 모든 그림의 화풍·색감이 같은가
- [ ] 16:9 배경용은 소재가 한쪽 60% 안에 있고, 반대쪽 40%가 비어 있는가
- [ ] 인물이 빈 쪽(글씨 쪽)을 바라보는가
- [ ] 오른쪽 아래 워터마크(✦)가 없는가
