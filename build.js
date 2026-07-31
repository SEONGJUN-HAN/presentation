/* ============================================================
   build.js — 슬라이드 폴더를 자동 스캔하는 단일파일 빌더

   • loader.js 에서 CURRENT_DECK 만 읽습니다. (SLIDE_COUNT 불필요)
   • slides/<덱>/ 폴더의 *.html 을 번호순으로 자동 정렬해 빌드합니다.
   • img/ , video/ 참조는 Base64 로 인라인 → dist/<덱>.html 단일 파일 생성.

   실행: node build.js   (프로젝트 루트에서)
   ============================================================ */

const fs   = require('fs');
const path = require('path');

// ─── loader.js 에서 CURRENT_DECK 읽기 ───
const loaderCode = fs.readFileSync('js/loader.js', 'utf8');
const deckMatch  = loaderCode.match(/CURRENT_DECK\s*=\s*'([^']+)'/);

if (!deckMatch) {
    console.error('❌ loader.js 에서 CURRENT_DECK 를 찾을 수 없습니다.');
    process.exit(1);
}

const CURRENT_DECK = deckMatch[1];
const SLIDE_DIR    = path.join('slides', CURRENT_DECK);

if (!fs.existsSync(SLIDE_DIR)) {
    console.error(`❌ 슬라이드 폴더가 없습니다: ${SLIDE_DIR}`);
    process.exit(1);
}

// ─── 폴더 스캔 → *.html 을 숫자 순으로 자동 정렬 ───
const SLIDE_FILES = fs.readdirSync(SLIDE_DIR)
    .filter(f => f.toLowerCase().endsWith('.html'))
    .sort((a, b) => {
        // 파일명 앞쪽 숫자 기준 자연 정렬 (01,02,...,10,11)
        const na = parseInt(a.match(/\d+/)?.[0] ?? '0', 10);
        const nb = parseInt(b.match(/\d+/)?.[0] ?? '0', 10);
        return na - nb || a.localeCompare(b);
    })
    .map(f => path.join(SLIDE_DIR, f));

if (SLIDE_FILES.length === 0) {
    console.error(`❌ ${SLIDE_DIR} 안에 .html 슬라이드가 없습니다.`);
    process.exit(1);
}

const SLIDE_COUNT = SLIDE_FILES.length;

console.log(`\n📁 덱: ${CURRENT_DECK}`);
console.log(`📊 슬라이드: ${SLIDE_COUNT}장 (폴더 자동 스캔)`);
console.log(`─────────────────────────────`);

// ─── 이미지 → Base64 ───
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

// ─── 영상 → Base64 (10MB 이하만) ───
function videoToBase64(filePath) {
    try {
        const ext  = path.extname(filePath).slice(1).toLowerCase();
        const mimeMap = { webm: 'webm', ogg: 'ogg', mov: 'quicktime' };
        const mime = mimeMap[ext] || 'mp4';
        const data = fs.readFileSync(filePath);
        const size = (data.length / 1024 / 1024).toFixed(1);

        if (data.length > 10 * 1024 * 1024) {
            console.warn(`  ⚠ 영상 용량 초과 (${size}MB): ${filePath}`);
            console.warn(`    → 10MB 이하만 인라인됩니다. 로컬 참조로 유지합니다.`);
            return null;
        }
        console.log(`  🎬 영상 변환 (${size}MB): ${filePath}`);
        return `data:video/${mime};base64,${data.toString('base64')}`;
    } catch {
        console.warn(`  ⚠ 영상 없음: ${filePath}`);
        return null;
    }
}

// ─── 슬라이드 읽기 + 미디어 인라인 ───
// 작은따옴표/큰따옴표 모두 지원, img/ · video/ 접두사 모두 처리
let slidesHTML = '';

SLIDE_FILES.forEach((file, i) => {
    try {
        let html = fs.readFileSync(file, 'utf8');

        // 이미지
        const imgRefs = [...html.matchAll(/src=["'](img\/[^"']+)["']/g)];
        imgRefs.forEach(([full, imgPath]) => {
            const b64 = imgToBase64(imgPath);
            if (b64) html = html.replace(full, `src="${b64}"`);
        });

        // 영상
        const videoRefs = [...html.matchAll(/src=["'](video\/[^"']+)["']/g)];
        videoRefs.forEach(([full, videoPath]) => {
            const b64 = videoToBase64(videoPath);
            if (b64) html = html.replace(full, `src="${b64}"`);
        });

        slidesHTML += `
            <div class="slide-container" id="slide-${i}">
                ${html}
            </div>`;
        console.log(`  ✓ (${i + 1}/${SLIDE_COUNT}) ${path.basename(file)}`);
    } catch (e) {
        console.warn(`  ✗ ${file} → 읽기 실패, 건너뜀`);
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
    <div class="controls" title="H 키를 누르면 이 바가 숨겨지고 다시 나타납니다">
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

// ─── dist 저장 ───
if (!fs.existsSync('dist')) fs.mkdirSync('dist');
const outputName = `${CURRENT_DECK}.html`;
fs.writeFileSync(`dist/${outputName}`, output, 'utf8');

console.log(`\n✅ 빌드 완료 → dist/${outputName}`);
console.log(`   슬라이드 총 ${SLIDE_COUNT}장`);
