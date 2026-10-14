/* ============================================================
   build.js — 슬라이드 폴더를 자동 스캔하는 단일파일 빌더

   • slides/<덱>/ 폴더의 *.html 을 번호순으로 자동 정렬해 빌드합니다.
   • img/ , video/ 참조는 Base64 로 인라인 → dist/<덱>.html 단일 파일 생성.
   • css(base · components · slide-kit)와 navigation.js 도 한 파일에 넣습니다.

   실행 (프로젝트 루트에서):
     node build.js                      loader.js 의 DECKS 목록 전부를 빌드
     node build.js AI업무자동화_연수      지정한 덱만 빌드 (여러 개면 공백으로 나열)
   ============================================================ */

const fs   = require('fs');
const path = require('path');

// ─── 빌드할 덱 목록 정하기 ───
// 인자가 있으면 그 덱만, 없으면 loader.js 의 DECKS(주석 처리된 줄 제외) 전부.
function decksFromLoader() {
    const code = fs.readFileSync('js/loader.js', 'utf8');
    return code.split(/\r?\n/)
        .filter(line => !line.trim().startsWith('//'))
        .map(line => line.match(/folder:\s*'([^']+)'/)?.[1])
        .filter(Boolean);
}

const argDecks = process.argv.slice(2);
const DECKS    = argDecks.length ? argDecks : decksFromLoader();

if (DECKS.length === 0) {
    console.error('❌ 빌드할 덱이 없습니다.');
    console.error('   node build.js <덱폴더명>  으로 지정하거나, js/loader.js 의 DECKS 를 확인하세요.');
    process.exit(1);
}

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

// ─── CSS / JS (모든 덱 공통) ───
const baseCss       = fs.readFileSync('css/base.css', 'utf8');
const componentsCss = fs.readFileSync('css/components.css', 'utf8');
const slideKitCss   = fs.readFileSync('css/slide-kit.css', 'utf8');
const navigationJs  = fs.readFileSync('js/navigation.js', 'utf8');

// ─── 덱 하나 빌드 ───
function buildDeck(deckName) {
    const slideDir = path.join('slides', deckName);

    if (!fs.existsSync(slideDir)) {
        console.error(`❌ 슬라이드 폴더가 없습니다: ${slideDir}`);
        return false;
    }

    // 폴더 스캔 → *.html 을 숫자 순으로 자동 정렬 (01,02,...,10,11)
    const slideFiles = fs.readdirSync(slideDir)
        .filter(f => f.toLowerCase().endsWith('.html'))
        .sort((a, b) => {
            const na = parseInt(a.match(/\d+/)?.[0] ?? '0', 10);
            const nb = parseInt(b.match(/\d+/)?.[0] ?? '0', 10);
            return na - nb || a.localeCompare(b);
        })
        .map(f => path.join(slideDir, f));

    if (slideFiles.length === 0) {
        console.error(`❌ ${slideDir} 안에 .html 슬라이드가 없습니다.`);
        return false;
    }

    console.log(`\n📁 덱: ${deckName}`);
    console.log(`📊 슬라이드: ${slideFiles.length}장 (폴더 자동 스캔)`);
    console.log(`─────────────────────────────`);

    let slidesHTML = '';

    slideFiles.forEach((file, i) => {
        try {
            let html = fs.readFileSync(file, 'utf8');

            // 이미지·영상 (작은따옴표/큰따옴표 모두, img/ · video/ 접두사)
            [...html.matchAll(/src=["'](img\/[^"']+)["']/g)].forEach(([full, imgPath]) => {
                const b64 = imgToBase64(imgPath);
                if (b64) html = html.replace(full, `src="${b64}"`);
            });
            [...html.matchAll(/src=["'](video\/[^"']+)["']/g)].forEach(([full, videoPath]) => {
                const b64 = videoToBase64(videoPath);
                if (b64) html = html.replace(full, `src="${b64}"`);
            });

            slidesHTML += `
            <div class="slide-container" id="slide-${i}">
                ${html}
            </div>`;
            console.log(`  ✓ (${i + 1}/${slideFiles.length}) ${path.basename(file)}`);
        } catch (e) {
            console.warn(`  ✗ ${file} → 읽기 실패, 건너뜀`);
        }
    });

    // 최종 HTML 조립
    // data-deck : 덱 전용 css([data-deck="..."] 선택자)가 단일 파일에서도 먹도록 남깁니다.
    const output = `<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${deckName}</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
${baseCss}
${componentsCss}
${slideKitCss}
    </style>
</head>
<body>
    <div class="progress-bar-container">
        <div class="progress-bar" id="progressBar"></div>
    </div>
    <div id="toast" class="toast">코드가 복사되었습니다!</div>
    <div class="presentation-wrapper" id="presentationWrapper">
        <div class="deck" id="deck" data-deck="${deckName}">
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
        <button id="fullscreenBtn" title="전체화면 (F)" onclick="toggleFullscreen()">
            <i class="fa-solid fa-expand"></i>
        </button>
    </div>
    <script>
${navigationJs}
        window.addEventListener('DOMContentLoaded', initPresentation);
    </script>
</body>
</html>`;

    if (!fs.existsSync('dist')) fs.mkdirSync('dist');
    const outPath = path.join('dist', `${deckName}.html`);
    fs.writeFileSync(outPath, output, 'utf8');

    const mb = (Buffer.byteLength(output) / 1024 / 1024).toFixed(1);
    console.log(`\n✅ 빌드 완료 → ${outPath}  (${slideFiles.length}장, ${mb}MB)`);
    return true;
}

// ─── 실행 ───
let failed = 0;
DECKS.forEach(name => { if (!buildDeck(name)) failed++; });

if (failed) {
    console.error(`\n❌ ${failed}개 덱 빌드 실패`);
    process.exit(1);
}
