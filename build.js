/* ============================================================
   build.js — loader.js 의 CURRENT_DECK / SLIDE_COUNT 자동 읽기
   ============================================================ */

   const fs   = require('fs');
   const path = require('path');
   
   // loader.js 에서 CURRENT_DECK, SLIDE_COUNT 자동 파싱
   const loaderCode = fs.readFileSync('js/loader.js', 'utf8');
   
   const deckMatch  = loaderCode.match(/CURRENT_DECK\s*=\s*'([^']+)'/);
   const countMatch = loaderCode.match(/SLIDE_COUNT\s*=\s*(\d+)/);
   
   if (!deckMatch || !countMatch) {
       console.error('❌ loader.js 에서 CURRENT_DECK 또는 SLIDE_COUNT 를 찾을 수 없습니다.');
       process.exit(1);
   }
   
   const CURRENT_DECK = deckMatch[1];
   const SLIDE_COUNT  = parseInt(countMatch[1]);
   
   function padNum(n) {
       return String(n).padStart(2, '0');
   }
   
   const SLIDE_FILES = Array.from(
       { length: SLIDE_COUNT },
       (_, i) => `slides/${CURRENT_DECK}/${padNum(i + 1)}.html`
   );
   
   console.log(`\n📁 덱: ${CURRENT_DECK}`);
   console.log(`📊 슬라이드: ${SLIDE_COUNT}장`);
   console.log(`─────────────────────────────`);
   
   // ─── 이미지 → Base64 변환 함수 ───
   function imgToBase64(filePath) {
       try {
           const ext  = path.extname(filePath).slice(1).toLowerCase();
           const mime = ext === 'jpg' ? 'jpeg' : ext;
           const data = fs.readFileSync(filePath);
           return `data:image/${mime};base64,${data.toString('base64')}`;
       } catch {
           console.warn(`  ⚠ 이미지 없음: ${filePath}`);
           return null;
       }
   }
   
   // ─── 영상 → Base64 변환 (추가) ───
    function videoToBase64(filePath) {
        try {
            const ext  = path.extname(filePath).slice(1).toLowerCase();
            const mime = ext === 'webm' ? 'webm' : 'mp4';
            const data = fs.readFileSync(filePath);
            const size = (data.length / 1024 / 1024).toFixed(1);

            if (data.length > 10 * 1024 * 1024) {
                console.warn(`  ⚠ 영상 용량 초과 (${size}MB): ${filePath}`);
                console.warn(`    → 10MB 이하만 Base64 변환됩니다. 로컬 참조로 유지합니다.`);
                return null;
            }

            console.log(`  🎬 영상 변환 (${size}MB): ${filePath}`);
            return `data:video/${mime};base64,${data.toString('base64')}`;
        } catch {
            console.warn(`  ⚠ 영상 없음: ${filePath}`);
            return null;
        }
    }

   // ─── 슬라이드 HTML 읽기 + 이미지 자동 변환 ───
   let slidesHTML = '';
   
   SLIDE_FILES.forEach((file, i) => {
        try {
            let html = fs.readFileSync(file, 'utf8');

            // 이미지 자동 변환 (기존)
            const imgRefs = [...html.matchAll(/src="(img\/[^"]+)"/g)];
            imgRefs.forEach(([full, imgPath]) => {
                const base64 = imgToBase64(imgPath);
                if (base64) html = html.replace(full, `src="${base64}"`);
            });

            // 영상 자동 변환 (추가)
            const videoRefs = [...html.matchAll(/src="(video\/[^"]+)"/g)];
            videoRefs.forEach(([full, videoPath]) => {
                const base64 = videoToBase64(videoPath);
                if (base64) html = html.replace(full, `src="${base64}"`);
            });

            slidesHTML += `
            <div class="slide-container" id="slide-${i}">
                ${html}
            </div>`;
            console.log(`  ✓ (${i + 1}/${SLIDE_COUNT}) ${file}`);

        } catch (e) {
            console.warn(`  ✗ ${file} → 파일 없음, 건너뜀`);
        }
    });
   
   // ─── CSS / JS 읽기 ───
   const baseCss       = fs.readFileSync('css/base.css', 'utf8');
   const componentsCss = fs.readFileSync('css/components.css', 'utf8');
   const navigationJs  = fs.readFileSync('js/navigation.js', 'utf8');
   
   // ─── 최종 HTML 조립 ───
   const output = `<!DOCTYPE html>
   <html lang="ko">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>${CURRENT_DECK}</title>
       <link rel="preconnect" href="https://fonts.googleapis.com">
       <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
       <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
       <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
       <style>
   ${baseCss}
   ${componentsCss}
       </style>
   </head>
   <body>
       <div class="progress-bar-container">
           <div class="progress-bar" id="progressBar"></div>
       </div>
       <div id="toast" class="toast">코드가 복사되었습니다!</div>
       <div class="presentation-wrapper" id="presentationWrapper">
           <div class="deck" id="deck">
               ${slidesHTML}
           </div>
       </div>
       <div class="controls">
           <button id="prevBtn" onclick="navigateSlide(-1)" disabled>
               <i class="fa-solid fa-chevron-left"></i>
           </button>
           <span id="slideIndicator" onclick="jumpToSlide()">1 / 1</span>
           <button id="nextBtn" onclick="navigateSlide(1)">
               <i class="fa-solid fa-chevron-right"></i>
           </button>
           <button id="fullscreenBtn" onclick="toggleFullscreen()">
               <i class="fa-solid fa-expand"></i>
           </button>
       </div>
       <script>
   ${navigationJs}
           window.addEventListener('DOMContentLoaded', initPresentation);
       </script>
   </body>
   </html>`;
   
   // ─── dist 폴더에 저장 ───
   if (!fs.existsSync('dist')) fs.mkdirSync('dist');
   
   const outputName = `${CURRENT_DECK}.html`;
   fs.writeFileSync(`dist/${outputName}`, output, 'utf8');
   
   console.log(`\n✅ 빌드 완료 → dist/${outputName}`);
   console.log(`   슬라이드 총 ${SLIDE_COUNT}장`);