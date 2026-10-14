/* ============================================================
   navigation.js — 슬라이드 네비게이션 & 유틸리티
   loader.js가 initPresentation()을 호출하면 활성화됩니다.
   ============================================================ */

   let currentSlide = 0;
   let slides = [];
   let totalSlides = 0;
   
   /* ─── 초기화 (loader.js에서 호출) ─── */
   function initPresentation() {
       slides = document.querySelectorAll('.slide-container');
       totalSlides = slides.length;
       currentSlide = 0;
   
       updateSlideUI();
       adjustScale();
       syncFullscreenIcon();
       fitAllText();
   }
   
   /* ─── 슬라이드 UI 업데이트 ─── */
   function updateSlideUI() {
       slides.forEach((slide, idx) => {
           slide.classList.toggle('active', idx === currentSlide);
       });
   
       document.getElementById('slideIndicator').innerText =
           `${currentSlide + 1} / ${totalSlides}`;
   
       document.getElementById('prevBtn').disabled = (currentSlide === 0);
       document.getElementById('nextBtn').disabled = (currentSlide === totalSlides - 1);
   
       const percent = ((currentSlide + 1) / totalSlides) * 100;
       document.getElementById('progressBar').style.width = `${percent}%`;
   }
   
   /* ─── 슬라이드 이동 ─── */
   function navigateSlide(direction) {
       const next = currentSlide + direction;
       if (next >= 0 && next < totalSlides) {
           currentSlide = next;
           updateSlideUI();
       }
   }
   
   /* ─── 슬라이드 번호 직접 점프 ─── */
   function jumpToSlide() {
       const input = prompt(
           `이동할 슬라이드 번호를 입력하세요 (1 ~ ${totalSlides}):`,
           currentSlide + 1
       );
       const num = parseInt(input);
       if (!isNaN(num) && num >= 1 && num <= totalSlides) {
           currentSlide = num - 1;
           updateSlideUI();
       }
   }
   
   /* ─── 자동 스케일링 (1280x720 → 화면 크기 맞춤) ─── */
   function adjustScale() {
       const wrapper = document.getElementById('presentationWrapper');
       const scaleX = window.innerWidth / 1280;
       const scaleY = window.innerHeight / 720;
       const scale  = Math.min(scaleX, scaleY);   // 여백 없이 화면에 꽉 맞춤
       wrapper.style.transform = `scale(${scale})`;
   }
   
   /* ─── 전체화면 ─── */
   function toggleFullscreen() {
       if (!document.fullscreenElement) {
           document.documentElement.requestFullscreen()
               .catch(err => console.warn('전체화면 전환 실패:', err.message));
       } else {
           document.exitFullscreen()
               .catch(err => console.warn('전체화면 해제 실패:', err.message));
       }
   }

   /* 아이콘은 실제 상태 변화에 맞춰 갱신 → Esc 로 빠져나와도 어긋나지 않음 */
   function syncFullscreenIcon() {
       const btn = document.getElementById('fullscreenBtn');
       if (!btn) return;
       const icon = document.fullscreenElement ? 'fa-compress' : 'fa-expand';
       btn.innerHTML = `<i class="fa-solid ${icon}"></i>`;
       btn.title = document.fullscreenElement ? '전체화면 종료 (F)' : '전체화면 (F)';
   }

   document.addEventListener('fullscreenchange', syncFullscreenIcon);
   
   /* ─── 컨트롤러 숨김/표시 (H 키) ─── */
   function toggleControls() {
       document.querySelector('.controls')?.classList.toggle('hidden');
   }

   /* ─── 코드 복사 ─── */
   async function copyCode(button) {
       const pre = button.nextElementSibling?.querySelector('pre');
       if (!pre) return;
   
       const text = pre.innerText;
   
       try {
           // 최신 브라우저: Clipboard API
           await navigator.clipboard.writeText(text);
           showCopySuccess(button);
       } catch {
           // 구형 브라우저 폴백: execCommand
           try {
               const ta = document.createElement('textarea');
               ta.value = text;
               ta.style.cssText = 'position:fixed;opacity:0;';
               document.body.appendChild(ta);
               ta.select();
               document.execCommand('copy');
               document.body.removeChild(ta);
               showCopySuccess(button);
           } catch (err) {
               console.error('복사 실패:', err);
           }
       }
   }
   
   function showCopySuccess(button) {
       showToast();
       const orig = button.innerText;
       button.innerText = '복사 완료!';
       button.style.cssText = 'background-color:#84cc16; color:#000;';
       setTimeout(() => {
           button.innerText = orig;
           button.style.cssText = '';
       }, 2000);
   }
   
   function showToast() {
       const toast = document.getElementById('toast');
       toast.style.display = 'block';
       setTimeout(() => { toast.style.display = 'none'; }, 2000);
   }
   
   /* ─── 이미지 로드 실패 처리 ─── */
   function handleImgError(img) {
       img.parentElement.innerHTML = `
           <div style="text-align:center; padding:40px; color:#94a3b8;">
               <i class="fa-solid fa-image"
                  style="font-size:48px; margin-bottom:16px; color:#334155; display:block;"></i>
               <p style="font-size:15px; margin:0; line-height:1.8;">
                   <code style="color:#fbbf24;">${img.src.split('/').pop()}</code><br>
                   파일을 img/ 폴더에 넣어주세요
               </p>
           </div>`;
   }
   
   /* ─── 키보드 단축키 ─── */
   document.addEventListener('keydown', (e) => {
       const forward  = ['ArrowRight', ' ', 'Enter', 'PageDown'];
       const backward = ['ArrowLeft', 'Backspace', 'PageUp'];

       // 덱 선택 화면에서는 Enter/Space 로 링크를 열 수 있게 그대로 둠
       if (document.body.classList.contains('picker-mode')) return;

       // 입력 중이거나 조합키가 눌린 경우는 무시
       if (e.ctrlKey || e.altKey || e.metaKey) return;
       const tag = e.target.tagName;
       if (tag === 'INPUT' || tag === 'TEXTAREA' || e.target.isContentEditable) return;

       // 단축키 (한글 자판 상태에서도 동작하도록 ㅗ/ㄹ 같이 처리)
       const hideKeys = ['h', 'H', 'ㅗ'];
       const fullKeys = ['f', 'F', 'ㄹ'];

       if (hideKeys.includes(e.key)) {
           e.preventDefault();
           toggleControls();
       } else if (fullKeys.includes(e.key)) {
           e.preventDefault();
           toggleFullscreen();
       } else if (forward.includes(e.key)) {
           e.preventDefault();
           navigateSlide(1);
       } else if (backward.includes(e.key)) {
           e.preventDefault();
           navigateSlide(-1);
       }
   });
   
   /* ─── 터치 스와이프 ─── */
   let touchStartX = 0;
   document.addEventListener('touchstart', (e) => {
       touchStartX = e.changedTouches[0].screenX;
   }, { passive: true });
   
   document.addEventListener('touchend', (e) => {
       const diff = touchStartX - e.changedTouches[0].screenX;
       if (Math.abs(diff) > 60) navigateSlide(diff > 0 ? 1 : -1);
   }, { passive: true });
   
   /* ─── 창 크기 변경 시 스케일 재조정 ─── */
   window.addEventListener('resize', adjustScale);

   /* ─── 줄바꿈 자동 정돈 ───
      CSS(base.css 의 word-break / text-wrap)가 1차로 처리하고,
      그래도 마지막 줄에 짧은 꼬리만 남은 문단은 자간을 단계적으로(-0.01em 씩,
      최대 -0.04em) 줄여 한 줄을 덜어냅니다. 줄 수가 줄지 않으면 원래대로 되돌립니다. */
   function fitAllText() {
       const FIT_SELECTOR = 'p, li, td, th, h1, h2, h3, h4, [class*="title"], [class*="desc"]';
       const BLOCK_CHILD  = 'p, li, ul, ol, div, table, pre, section';

       // 요소 안 글자가 차지한 줄들을 [{top,bottom,left,right}] 로 돌려줌
       function measureLines(el) {
           const range = document.createRange();
           range.selectNodeContents(el);
           const rects = [...range.getClientRects()]
               .filter(b => b.width > 0.5 && b.height > 0.5)
               .sort((a, b) => a.top - b.top);
           const lines = [];
           rects.forEach(b => {
               const cy = (b.top + b.bottom) / 2;
               const last = lines[lines.length - 1];
               if (last && cy > last.top + 1 && cy < last.bottom - 1) {
                   last.top    = Math.min(last.top, b.top);
                   last.bottom = Math.max(last.bottom, b.bottom);
                   last.left   = Math.min(last.left, b.left);
                   last.right  = Math.max(last.right, b.right);
               } else {
                   lines.push({ top: b.top, bottom: b.bottom, left: b.left, right: b.right });
               }
           });
           return lines;
       }

       function fitOne(el) {
           if (el.closest('pre, code, .code-tile')) return;
           if (el.querySelector(BLOCK_CHILD)) return;               // 글자만 담은 말단 요소만
           const cs = getComputedStyle(el);
           if (!['block', 'list-item', 'table-cell'].includes(cs.display)) return;

           const lines = measureLines(el);
           if (lines.length < 2) return;

           const box   = el.getBoundingClientRect();
           const scale = el.offsetWidth ? box.width / el.offsetWidth : 1;
           const inner = box.width - (parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight)) * scale;
           const tail  = lines[lines.length - 1];
           if (tail.right - tail.left > inner * 0.22) return;       // 꼬리가 짧을 때만 손댐

           const fs   = parseFloat(cs.fontSize);
           const base = (parseFloat(cs.letterSpacing) || 0) / fs;   // 현재 자간(em)
           for (let step = 1; step <= 4; step++) {
               el.style.letterSpacing = (base - step * 0.01) + 'em';
               if (measureLines(el).length < lines.length) return;  // 성공 → 유지
           }
           el.style.letterSpacing = '';                             // 실패 → 원복
       }

       const run = () => slides.forEach(s => s.querySelectorAll(FIT_SELECTOR).forEach(fitOne));
       const ready = (document.fonts && document.fonts.ready) ? document.fonts.ready : Promise.resolve();
       ready.then(() => requestAnimationFrame(run));
   }
