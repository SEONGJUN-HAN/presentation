/* ============================================================
   loader.js — 슬라이드 자동 로드 + 중요 슬라이드 자동 감지
   
   ✏️ 새 발표자료 만들 때 CURRENT_DECK 만 바꾸면 됩니다.
   ✏️ 슬라이드 수는 SLIDE_COUNT 만 바꾸면 됩니다.
   ============================================================ */

// ─── 여기만 수정 ──────────────────────────────
const CURRENT_DECK  = '1정_예산회계';   // slides/ 안의 폴더명
const SLIDE_COUNT   = 20;               // 슬라이드 총 개수
// ──────────────────────────────────────────────

// 숫자를 01, 02, 03 형식으로 변환
function padNum(n) {
    return String(n).padStart(2, '0');
}

// SLIDE_COUNT 만큼 자동으로 경로 생성
const SLIDE_FILES = Array.from(
    { length: SLIDE_COUNT },
    (_, i) => `slides/${CURRENT_DECK}/${padNum(i + 1)}.html`
);

async function loadSlides() {
    const deck = document.getElementById('deck');

    for (let i = 0; i < SLIDE_FILES.length; i++) {
        try {
            const response = await fetch(SLIDE_FILES[i]);
            if (!response.ok) throw new Error(`HTTP ${response.status}`);

            const html = await response.text();

            const slideEl = document.createElement('div');
            slideEl.className = 'slide-container';
            slideEl.id = `slide-${i}`;
            slideEl.innerHTML = html;

            // data-important="true" 감지 → .important 클래스 자동 추가
            const titleEl = slideEl.querySelector('[data-important="true"]');
            if (titleEl) slideEl.classList.add('important');

            deck.appendChild(slideEl);

        } catch (err) {
            const errorSlide = document.createElement('div');
            errorSlide.className = 'slide-container';
            errorSlide.id = `slide-${i}`;
            errorSlide.innerHTML = `
                <h2 class="slide-title" style="color:#ef4444; border-left-color:#ef4444;">
                    슬라이드 로드 실패
                </h2>
                <div class="content-area" style="justify-content:center; align-items:center;">
                    <div class="info-box" style="border-left-color:#ef4444; text-align:center;">
                        <p style="color:#ef4444; font-size:20px; margin-bottom:10px;">
                            <strong>${SLIDE_FILES[i]}</strong>
                        </p>
                        <p>파일을 찾을 수 없습니다. 경로를 확인해주세요.</p>
                        <p style="font-size:15px; margin-top:8px;">오류: ${err.message}</p>
                    </div>
                </div>`;
            deck.appendChild(errorSlide);
        }
    }

    if (typeof initPresentation === 'function') {
        initPresentation();
    }
}

window.addEventListener('DOMContentLoaded', loadSlides);