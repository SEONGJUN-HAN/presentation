/* ============================================================
   loader.js — 슬라이드 자동 탐색 로더 (SLIDE_COUNT 불필요)

   ✏️ 새 발표자료를 만들 때 CURRENT_DECK 만 바꾸면 됩니다.
   ✏️ 슬라이드는 01.html, 02.html, 03.html ... 순서대로
      "끊김 없이" 번호를 매기면 자동으로 끝까지 읽습니다.
      (예: 01,02,03 OK / 01,02,04 → 03에서 멈춤)

   ⚠️ 이 로더는 fetch 를 쓰므로 file:// 로 직접 열면 막힙니다.
      개발 중에는 로컬 서버로 여세요:
        npx serve        (또는 VS Code Live Server)
      최종 배포본은 build.js 결과(dist/*.html) 단일 파일을 쓰면
      서버 없이 어디서든 열립니다.
   ============================================================ */

// ─── 여기만 수정 ──────────────────────────────
const CURRENT_DECK = '오토핫키교육';   // slides/ 안의 폴더명
const MAX_SLIDES   = 300;                     // 무한 루프 방지용 안전 상한
// ──────────────────────────────────────────────

function padNum(n) {
    return String(n).padStart(2, '0');
}

async function loadSlides() {
    const deck = document.getElementById('deck');
    let loaded = 0;

    for (let i = 0; i < MAX_SLIDES; i++) {
        const file = `slides/${CURRENT_DECK}/${padNum(i + 1)}.html`;

        let response;
        try {
            response = await fetch(file);
        } catch (err) {
            // 네트워크 오류 또는 file:// 차단
            if (i === 0) {
                showFatalError(deck, file, err);
            }
            break;
        }

        // 404 등 → 더 이상 슬라이드가 없다고 보고 종료
        if (!response.ok) {
            if (i === 0) {
                showFatalError(
                    deck, file,
                    new Error(`HTTP ${response.status} — 첫 슬라이드를 찾을 수 없습니다.`)
                );
            }
            break;
        }

        const html = await response.text();

        const slideEl = document.createElement('div');
        slideEl.className = 'slide-container';
        slideEl.id = `slide-${i}`;
        slideEl.innerHTML = html;

        // data-important="true" 감지 → .important 클래스 자동 추가
        if (slideEl.querySelector('[data-important="true"]')) {
            slideEl.classList.add('important');
        }

        deck.appendChild(slideEl);
        loaded++;
    }

    if (loaded > 0 && typeof initPresentation === 'function') {
        initPresentation();
    }
}

/* 첫 슬라이드조차 못 읽었을 때(보통 file:// 또는 폴더명 오타) 안내 */
function showFatalError(deck, file, err) {
    const slide = document.createElement('div');
    slide.className = 'slide-container active';
    slide.innerHTML = `
        <h2 class="slide-title" style="color:#ef4444; border-left-color:#ef4444;">
            슬라이드를 불러올 수 없습니다
        </h2>
        <div class="content-area" style="justify-content:center;">
            <div class="info-box" style="border-left-color:#ef4444;">
                <p style="color:#ef4444; font-size:20px; margin-bottom:10px;">
                    <strong>${file}</strong> 읽기 실패
                </p>
                <p>다음을 확인하세요:</p>
                <ul style="margin-top:8px;">
                    <li><code>CURRENT_DECK</code> 폴더명이 정확한가요? (현재: <code>${CURRENT_DECK}</code>)</li>
                    <li><code>file://</code> 로 직접 열지 않았나요? → 로컬 서버로 여세요 (<code>npx serve</code>)</li>
                    <li>슬라이드 번호가 <code>01.html</code> 부터 시작하나요?</li>
                </ul>
                <p style="font-size:15px; margin-top:8px;">오류: ${err.message}</p>
            </div>
        </div>`;
    deck.appendChild(slide);

    // 컨트롤바 최소 표시
    const ind = document.getElementById('slideIndicator');
    if (ind) ind.innerText = '0 / 0';
}

window.addEventListener('DOMContentLoaded', loadSlides);
