#Requires AutoHotkey v2.0
; ============================================================
;  나만의 업무 런처  (내업무도구.ahk)  — AutoHotkey v2
; ------------------------------------------------------------
;  ▶ 실행 : VS Code에서 Ctrl + F9   (중지는 Ctrl + F6)
;
;  이 파일은 위아래로 성격이 다릅니다.
;
;   ┌ 윗부분 [0~6단계]  — 배우는 곳.  Ctrl + Alt + L
;   │   가장 쉬운 것부터 직접 쳐 보면서 만듭니다. 전부 이해하고 넘어갑니다.
;   │
;   └ 아랫부분 [7~10단계] — 쓰는 곳.  Ctrl + Alt + Shift + L
;       같이 드린 프로그램들이 이미 연결돼 있고,
;       Alt + 마우스로 창 다루기 같은 편의 기능도 들어 있습니다.
;       이해 못 해도 됩니다. 눌러서 바로 써 보세요.
;       무슨 단축키가 있는지는 Ctrl + Alt + H (자동 목록)
;
;  ★ 슬라이드의 [N단계] = 이 파일의 [N단계] 주석 위치입니다.
;  ★ 바꿀 곳은 전부 "▼ 여기만 바꾸세요" 로 표시해 두었습니다.
;  ★ 이 파일은 배포 폴더 안에 그대로 두세요. 옆의 도구 폴더를 찾아 씁니다.
; ============================================================

#SingleInstance Force        ; 두 번 실행하면 이전 것을 끄고 새로 시작

global g_Gui := ""           ; 런처 창을 담아 둘 자리 (맨 위에서 비워 둡니다)


; ============================================================
;  [0단계] 워밍업 : Ctrl + Alt + M → 내 첫 알림창
; ------------------------------------------------------------
;  Ctrl+F9 로 실행하고 Ctrl + Alt + M 을 눌러 창이 뜨면 성공!
;  문구를 바꿔 다시 실행해 보세요.
;  (이 MsgBox 는 아래 ❓ 도움말 버튼에서 다시 만납니다)
; ============================================================
^!m::MsgBox("반갑습니다! 첫 스크립트 성공!")          ; 첫 알림창 (0단계 워밍업)


; ============================================================
;  [1단계] 맛보기 단축키 : 단축키 + Run 한 줄이면 뭐든 열립니다
; ------------------------------------------------------------
;  ^ = Ctrl,  ! = Alt,  + = Shift,  # = Win
; ============================================================
^!n::Run("https://www.naver.com")        ; Ctrl+Alt+N → 네이버

; 할 일이 여러 줄이면 { } 로 묶습니다
^!k::                                     ; 네이버 + 구글 한꺼번에 열기
{
    Run("https://www.naver.com")
    Run("https://www.google.com")
}


; ============================================================
;  [2단계] 런처 창 : Ctrl + Alt + L → 버튼 모음 창이 뜹니다
; ============================================================
^!l::ShowLauncher()                       ; 런처 열기 (기본형)

ShowLauncher(*)
{
    global g_Gui

    CloseLauncher()                                   ; 이미 열려 있으면 먼저 닫기

    g_Gui := Gui("+AlwaysOnTop", "나만의 런처")
    g_Gui.SetFont("s11", "맑은 고딕")
    g_Gui.AddText(, "원하는 버튼을 누르세요")

    ; ▼▼▼ [3단계] 여기만 바꾸세요 — 버튼 하나가 두 줄 ▼▼▼
    ;     첫 줄 : 버튼을 만들고        (글자만 바꾸면 됩니다)
    ;     둘째 줄 : 누르면 뭘 열지     (따옴표 안만 바꾸면 됩니다)
    ;
    ;     버튼을 늘리려면 두 줄을 복사해 붙여넣고
    ;     b1 → b2 → b3 … 처럼 이름만 겹치지 않게 바꾸세요.
    ;
    ;     경로 따는 법 : 파일을 Shift + 우클릭 → "경로로 복사"

    b1 := g_Gui.AddButton("xm w280 h34", "📄  업무일지 열기")
    b1.OnEvent("Click", (*) => OpenIt("C:\Users\내이름\Documents\업무일지.xlsx"))

    b2 := g_Gui.AddButton("xm w280 h34", "🌐  네이버 열기")
    b2.OnEvent("Click", (*) => OpenIt("https://www.naver.com"))

    b3 := g_Gui.AddButton("xm w280 h34", "📁  올해 업무 폴더")
    b3.OnEvent("Click", (*) => OpenIt("C:\Users\내이름\Documents\2026_업무"))

    b4 := g_Gui.AddButton("xm w280 h34", "✉️  메일 쓰기")
    b4.OnEvent("Click", (*) => OpenIt("mailto:"))

    ; 파일 대신 '함수'를 부르는 버튼도 똑같이 두 줄입니다.
    b5 := g_Gui.AddButton("xm w280 h34", "📝  메모장에 할 일 쓰기")
    b5.OnEvent("Click", (*) => DoIt(WriteTodo))       ; [6단계] 일하는 버튼

    b6 := g_Gui.AddButton("xm w280 h34", "❓  단축키 도움말")
    b6.OnEvent("Click", (*) => DoIt(ShowMyHelp))      ; [0단계] MsgBox 재활용
    ; ▲▲▲ 여기까지 ▲▲▲

    g_Gui.OnEvent("Close",  (*) => CloseLauncher())
    g_Gui.OnEvent("Escape", (*) => CloseLauncher())   ; Esc 로 닫기
    g_Gui.Show()
}

; 버튼 두 줄을 짧게 쓰려고 만들어 둔 도우미 둘입니다.
;   ( * 는 "넘어오는 값이 더 있어도 무시하라"는 뜻입니다)
OpenIt(target)          ; 런처를 닫고 → 파일·폴더·사이트를 엽니다
{
    CloseLauncher()
    Run(target)
}

DoIt(func)              ; 런처를 닫고 → 그 함수를 실행합니다
{
    CloseLauncher()
    func()
}

CloseLauncher()
{
    global g_Gui
    if IsObject(g_Gui)
    {
        try g_Gui.Destroy()
        g_Gui := ""
    }
}


; ============================================================
;  [4단계] 상용구(핫스트링) : /단어 를 치면 → 내용으로 자동 변환
; ------------------------------------------------------------
;  전화번호·이메일처럼 영문·숫자는 이렇게 한 줄이면 끝입니다.
;  (긴 한글 문장은 아래 [5단계] 클립보드 방식을 쓰세요)
; ============================================================
; ▼▼▼ 여기만 바꾸세요 (왼쪽=칠 단어, 오른쪽=나올 내용) ▼▼▼
::/tel::063-123-4567
::/mail::admin@school.kr
; ▲▲▲ 여기까지 ▲▲▲


; ============================================================
;  [5단계] 한글 상용구는 클립보드로!
; ------------------------------------------------------------
;  한글을 4단계 방식으로 길게 내보내면 IME 때문에 글자가 깨질 수
;  있습니다(세→8 처럼). 한글은 A_Clipboard 에 담아 ^v 가 안전합니다.
;
;  ※ 코드를 실행하려면 반드시 { } 로 감싸야 합니다.
;     { } 없이 ::/hi::PasteText(...) 라고 쓰면 그 글자가 그대로 입력됩니다.
; ============================================================
; ▼▼▼ 여기만 바꾸세요 ▼▼▼
::/hi::                                    ; 인사말 (한 줄)
{
    A_Clipboard := "안녕하세요. 이리고등학교 행정실 홍길동입니다."
    Send("^v")
}

::/sign::                                  ; 내 서명 (짧은 버전)
{
    ; 여러 줄로 만들 때는 `n 으로 줄을 바꿉니다.
    A_Clipboard := "홍길동 | 행정실`n☎ 063-000-0000`n✉ hong@korea.kr"
    Send("^v")
}

; 단축키로도 붙여넣기 : Ctrl + Alt + 1~3
;   (Ctrl+숫자는 브라우저 탭 전환과 겹쳐서 Alt 까지 함께 누릅니다)
^!1::                                     ; 빠른 붙여넣기 - 계좌번호
{
    A_Clipboard := "○○은행 123-456-789 홍길동"
    Send("^v")
}

^!2::                                     ; 빠른 붙여넣기 - 인사말
{
    A_Clipboard := "늘 감사드립니다. 오늘도 좋은 하루 보내세요."
    Send("^v")
}

^!3::                                     ; 빠른 붙여넣기 - 회신 문구
{
    A_Clipboard := "확인 후 회신드리겠습니다."
    Send("^v")
}
; ▲▲▲ 여기까지 ▲▲▲


; ============================================================
;  [6단계] 일하는 버튼 : 열기만 하는 게 아니라 '일'까지 시킵니다
; ------------------------------------------------------------
;  프로그램을 열고 → 뜰 때까지 기다렸다가 → 대신 입력해 줍니다.
;  ※ Sleep 을 0 으로 바꿔 실행해 보세요. 입력이 사라집니다.
;     그게 Sleep 이 필요한 이유입니다.
; ============================================================
WriteTodo(*)
{
    Run("notepad.exe")
    Sleep(1000)                            ; 메모장이 뜰 때까지 대기

    A_Clipboard := "📌 오늘 할 일`n1. `n2. `n3. "
    Send("^v")                             ; 한글이라 클립보드로!
}

; [0단계] 에서 배운 MsgBox 가 도움말 버튼이 되어 돌아왔습니다.
ShowMyHelp(*)
{
    MsgBox("단축키 안내`n`n"
         . "Ctrl+Alt+L       : 런처 열기 (기본형)`n"
         . "Ctrl+Alt+Shift+L : 런처 열기 (실전형)`n"
         . "Ctrl+Alt+N       : 네이버 바로가기`n"
         . "/tel  /mail  /hi  /sign : 상용구`n"
         . "Ctrl+Alt+1~3     : 빠른 붙여넣기`n"
         . "Ctrl+Alt+C/X/V   : 클릭 1·2·3단계",
           "나만의 업무 도구")
}


; ============================================================
;  [클릭 1~3단계] 마우스를 대신 눌러 주기
; ------------------------------------------------------------
;  지금까지는 '여는' 것만 했습니다. 이제 '누르는' 것까지 시킵니다.
;
;  왜 필요한가 —
;    에듀파인·메신저처럼 우리가 손댈 수 없는 프로그램은
;    Run 으로 열기까지만 되고, 그 안에서는 결국 사람이 클릭해야 합니다.
;    그 클릭을 대신 시키는 것이 여기입니다.
;
;  ▶ 준비 : 계산기를 켜 두세요.  (Win + R → calc)
;  ▶ 좌표 보는 법 : 작업표시줄 H 아이콘 우클릭 → Window Spy →
;                   버튼 위에 마우스를 올리면 Screen 좌표가 보입니다.
; ============================================================
CoordMode "Mouse", "Screen"      ; WindowSpy 와 같은 '화면 전체' 기준


; ── [클릭 1단계] 한 곳 누르기 : Ctrl + Alt + C ──
; ▼▼▼ 여기만 바꾸세요 (WindowSpy 로 본 좌표) ▼▼▼
^!c::Click(200, 300)                      ; 클릭 1단계 - 한 곳 누르기


; ── [클릭 2단계] 두 곳을 순서대로 : Ctrl + Alt + X ──
;    사이의 Sleep 을 0 으로 바꿔 실행해 보세요.
;    프로그램이 못 따라와서 두 번째 클릭이 헛나갑니다. 그게 Sleep 이 필요한 이유입니다.
^!x::                                     ; 클릭 2단계 - 두 곳 순서대로
{
    ; ▼▼▼ 여기만 바꾸세요 ▼▼▼
    Click(200, 300)              ; 첫 번째 자리
    Sleep(300)                   ; 0.3초 기다렸다가
    Click(250, 300)              ; 두 번째 자리
    ; ▲▲▲ 여기까지 ▲▲▲
}


; ── [클릭 3단계] 그림을 찾아서 누르기 : Ctrl + Alt + V ──
;    좌표는 창을 옮기거나 해상도가 바뀌면 그대로 깨집니다.
;    "이 그림이 있는 자리"를 찾아 누르면 창이 어디에 있든 맞습니다.
;
;    ▶ 그림 만드는 법
;       1) Win + Shift + S  →  누르고 싶은 버튼만 잘라내기
;       2) Win + R → mspaint → Ctrl + V
;       3) Ctrl + S → 옆의 '클릭이미지' 폴더에 PNG 로 저장
;       4) 저장한 파일 Shift + 우클릭 → "경로로 복사" → 아래 따옴표 안에 붙여넣기
;
;    아래 세 줄이 전부입니다.
;       ImageSearch : 화면에서 그림을 찾아 그 자리를 x, y 에 담아라
;       MouseMove   : 그 자리로 마우스를 옮겨라
;       Click       : 거기를 눌러라
;
;    ※ 못 찾으면 x, y 가 빈 값이 되어 MouseMove 에서 멈추고 오류창이 뜹니다.
;       "empty string" 이라고 나오면 = 화면에서 그 그림을 못 찾았다는 뜻입니다.
;       마우스가 움직이지 않으니 엉뚱한 곳이 눌릴 일은 없습니다.
;    ※ 버튼 주변 배경까지 넓게 자르면 못 찾습니다. 버튼만 딱.
;    ※ 배경이 '투명'한 PNG 는 절대 못 찾습니다. 그림판으로 저장하세요.
;    ※ 화면 배율이 다른 PC에서 만든 그림도 안 맞습니다. 내 PC에서 내가 캡처.
^!v::                                     ; 클릭 3단계 - 그림 찾아 누르기
{
    ; ▼▼▼ 여기만 바꾸세요 (따옴표 안에 "경로로 복사" 붙여넣기) ▼▼▼
    ImageSearch(&x, &y, 0, 0, A_ScreenWidth, A_ScreenHeight,
                "C:\Users\내이름\Pictures\계산기_5.png")
    MouseMove(x, y)              ; 찾은 자리로 마우스를 옮기고
    Click()                      ; 거기를 누른다
    ; ▲▲▲ 여기까지 ▲▲▲
}


; ############################################################
;  [7~9단계] 실전형 런처 — 여기서부터는 '키우는' 단계입니다
; ------------------------------------------------------------
;  위에서 만든 Ctrl + Alt + L 런처는 그대로 둡니다.
;  대신 Ctrl + Alt + Shift + L 로 열리는 '실전형'을 나란히 만들어서,
;  둘을 번갈아 열어 보며 무엇이 늘었는지 눈으로 비교합니다.
;
;     [7단계]  목록   → 버튼을 배열로 묶고 for 로 한꺼번에 만들기
;     [8단계]  key    → Alt + 글자로 바로 실행 · 그룹으로 묶기
;     [9단계]  경로   → A_ScriptDir 기준으로 적어서 어디로 옮겨도 그대로 실행
;
;  ★ 여기는 이해 못 해도 괜찮습니다. 지금 바로 눌러서 써 보는 곳입니다.
;     고칠 데가 필요하면 아래 "▼ 여기만 바꾸세요" 한 군데뿐입니다.
; ############################################################

^!+l::ShowLauncher2()                     ; 런처 열기 (실전형)


; ============================================================
;  [9단계] 경로는 'A_ScriptDir 기준'으로 적습니다
; ------------------------------------------------------------
;  A_ScriptDir = 이 파일이 지금 들어 있는 폴더.
;
;  그래서 아래 도구들은 경로를 한 글자도 안 고쳐도 됩니다.
;  이 폴더를 통째로 USB나 내 PC로 복사하기만 하면
;  그 자리에서 바로 실행됩니다. (C:\... 로 적었다면 전부 깨졌을 것입니다)
;
;      오토핫키연수_배포\
;        ├── 내업무도구.ahk      ← 지금 이 파일
;        ├── 도구\               ← 아래 g_ToolDir
;        ├── 이모티콘\
;        └── 통합연락처\
; ============================================================
global g_ToolDir      := A_ScriptDir . "\도구"

global g_PathHwpForm  := g_ToolDir . "\전북교육_한글_서식도우미_v2.6.exe"
global g_PathDocTidy  := g_ToolDir . "\PDF·한글 문서정리 도우미 v2.1.exe"
global g_PathImgSmall := g_ToolDir . "\이미지용량줄이기_image-compressor.html"
global g_PathToolBox  := g_ToolDir . "\전북특별자치도교육청_간단 도구 모음(v1.0).html"
global g_PathEmoticon := A_ScriptDir . "\이모티콘\이모티콘.ahk"
global g_PathContact  := A_ScriptDir . "\통합연락처\통합연락처.ahk"

; ▼▼▼ 여기만 바꾸세요 — 내 것들 ▼▼▼
global g_PathMyDocs  := A_MyDocuments                     ; 내 문서 폴더
global g_PathNaver   := "https://www.naver.com"
global g_PathGoogle  := "https://www.google.com"
; ▲▲▲ 여기까지 ▲▲▲

global g_Gui2 := ""          ; 실전형 런처 창을 담아 둘 자리


; ============================================================
;  [7·8단계] 버튼 목록 — 배열로 묶고, key(단축글자)와 그룹을 붙였습니다
; ------------------------------------------------------------
;     key   : Alt + 이 글자로 바로 실행 (버튼에 밑줄로 표시됩니다)
;     label : 버튼에 보일 글자
;     run   : 열고 싶은 파일 · 폴더 · 사이트
;     go    : (파일 대신) 실행할 함수 이름
;
;  [3단계]에서는 버튼 하나가 두 줄이었습니다. 여기서는 한 줄입니다.
;  대신 아래 ShowLauncher2 가 그 목록을 읽어서 버튼을 대신 만들어 줍니다.
; ============================================================
BuildMyMenu()
{
    m := []                                   ; 그룹들을 담을 빈 목록

    ; ── 같이 드린 도구들 (배포 폴더 안에 있어서 경로를 안 고쳐도 됩니다) ──
    g := { title: "📄  문서 · 서식", items: [] }
    g.items.Push({ key: "1", label: "📝  한글 서식도우미",    run: g_PathHwpForm })
    g.items.Push({ key: "2", label: "📑  PDF·한글 문서정리",  run: g_PathDocTidy })
    g.items.Push({ key: "3", label: "🗜  이미지 용량 줄이기",  run: g_PathImgSmall })
    m.Push(g)

    g := { title: "🧰  도구 모음", items: [] }
    g.items.Push({ key: "4", label: "🧮  간단 도구 모음",   run: g_PathToolBox })
    g.items.Push({ key: "5", label: "📞  통합연락처",       run: g_PathContact })
    g.items.Push({ key: "6", label: "😀  이모티콘 입력기",  run: g_PathEmoticon })
    m.Push(g)

    ; ▼▼▼ 여기만 바꾸세요 — 한 줄이 버튼 하나 ▼▼▼
    g := { title: "🌐  내가 자주 쓰는 것", items: [] }
    g.items.Push({ key: "Q", label: "📁  내 문서 폴더", run: g_PathMyDocs })
    g.items.Push({ key: "W", label: "🌐  네이버",       run: g_PathNaver })
    g.items.Push({ key: "E", label: "🌐  구글",         run: g_PathGoogle })

    ; 버튼을 늘리려면 — 위 한 줄을 복사해 붙여넣고 key·label·run 만 바꾸세요.
    ;   경로 따는 법 : 파일을 Shift + 우클릭 → "경로로 복사"
    ; g.items.Push({ key: "R", label: "📄  업무일지", run: "C:\업무\업무일지.xlsx" })

    m.Push(g)
    ; ▲▲▲ 여기까지 ▲▲▲

    g := { title: "⚙  자주 하는 일", items: [] }
    g.items.Push({ key: "A", label: "📝  메모장에 할 일 쓰기", go: WriteTodo })
    g.items.Push({ key: "F", label: "❓  단축키 도움말",       go: ShowAllHotkeys })
    m.Push(g)

    return m
}

; 버튼을 눌렀을 때 실제로 실행되는 부분 — [3단계]의 RunItem 과 하는 일이 같습니다.
;   달라진 건 Run 대신 RunTarget 을 부른다는 것뿐입니다. ([9단계])
RunMenuItem(item, *)
{
    CloseLauncher2()
    if item.HasOwnProp("go")
        item.go()
    else
        RunTarget(item.run)
}


; ============================================================
;  [8단계] 실전형 런처 창 만들기
; ------------------------------------------------------------
;  좌표를 하나도 안 씁니다. xm 만 붙이면 오토핫키가 알아서 아래로 쌓아 줍니다.
;  [2단계]에서 AddButton 을 쓰던 감각 그대로입니다.
;
;  달라진 건 딱 하나 — for 가 두 겹이 된 것뿐입니다.
;  목록을 그룹으로 한 겹 감쌌으니, 꺼낼 때도 한 겹 더 들어갑니다.
; ============================================================
ShowLauncher2(*)
{
    global g_Gui2

    CloseLauncher2()
    lg := Gui("+AlwaysOnTop", "나만의 런처 (실전형)")
    lg.SetFont("s11", "맑은 고딕")

    for grp in BuildMyMenu()                   ; ① 그룹을 하나씩 꺼내서
    {
        lg.SetFont("s11 bold")
        lg.AddText("xm y+14", grp.title)       ; 그룹 제목 한 줄
        lg.SetFont("s11 norm")

        for it in grp.items                    ; ② 그 안의 버튼을 하나씩
        {
            ; [7단계] 글자 앞의 & 는 "Alt + 그 글자"로 누를 수 있게 해줍니다.
            btn := lg.AddButton("xm w280 h34", it.label . " (&" . it.key . ")")
            btn.OnEvent("Click", RunMenuItem.Bind(it))     ; [3단계]와 똑같은 Bind
        }
    }

    close := lg.AddButton("xm y+16 w280 h32 Default", "❌  닫기 (Esc)")
    close.OnEvent("Click", (*) => CloseLauncher2())

    lg.OnEvent("Close",  (*) => CloseLauncher2())
    lg.OnEvent("Escape", (*) => CloseLauncher2())

    g_Gui2 := lg
    lg.Show()
}

CloseLauncher2()
{
    global g_Gui2
    if IsObject(g_Gui2)
    {
        try g_Gui2.Destroy()
        g_Gui2 := ""
    }
}


; ============================================================
;  [9단계] 친절하게 여는 함수
; ------------------------------------------------------------
;  그냥 Run 을 쓰면, 경로를 잘못 적었을 때 아무 일도 안 일어납니다.
;  "왜 안 되지?" 로 30분을 쓰게 되는 지점이라, 실전판은 이렇게 알려줍니다.
; ============================================================
RunTarget(target)
{
    ; 경로에 ":\" 가 있으면 파일·폴더라는 뜻입니다. (사이트 주소에는 없습니다)
    if (InStr(target, ":\") && !FileExist(target))
    {
        MsgBox("경로가 없습니다.`n`n" . target
             . "`n`n[9단계] 경로 설정을 고쳐 주세요.", "찾을 수 없음", 48)
        return
    }
    Run(target)
}


; (클릭 실습 [클릭 1~3단계] 은 위쪽 [6단계] 뒤로 옮겼습니다)


; ############################################################
;  [10단계] 덤 — 받아서 그냥 쓰는 기능들
; ------------------------------------------------------------
;  여기는 읽지 않아도 됩니다. 눌러서 써 보는 곳입니다.
;  전부 위에서 배운 것의 확장일 뿐입니다.
;
;     핫키 + 함수 부르기   → 창 제어 · 창 배치
;     클립보드 ([5단계])   → 서식 없이 복사·붙여넣기
;     파일 읽기            → 단축키 도움말 자동 생성
;
;  ▶ 바꾸고 싶으면 단축키 글자만 바꾸세요.
;       ^ = Ctrl    ! = Alt    # = Win    + = Shift
; ############################################################

global g_DoubleAlt := false      ; Alt 를 연달아 두 번 눌렀는지 기억해 두는 곳


; ── 창 제어 : Alt 를 누른 채 마우스로 어떤 창이든 다룹니다 ──
;    최대화되지 않은 창이면 제목표시줄을 안 잡아도 옮겨집니다.
!LButton::                                       ; Alt + 왼쪽 드래그 = 창 옮기기
{
    global g_DoubleAlt
    MouseGetPos(&x1, &y1, &id)
    if !id
        return
    if (g_DoubleAlt)                             ; Alt 두 번 + 클릭 = 창 이동 메뉴
    {
        PostMessage(0x112, 0xF020, , , "ahk_id " id)
        g_DoubleAlt := false
        return
    }
    if WinGetMinMax("ahk_id " id)                ; 최대화된 창은 옮기지 않음
        return
    WinGetPos(&wx, &wy, , , "ahk_id " id)
    Loop                                         ; 버튼을 놓을 때까지 계속 따라다님
    {
        if !GetKeyState("LButton", "P")
            break
        MouseGetPos(&x2, &y2)
        try WinMove(wx + x2 - x1, wy + y2 - y1, , , "ahk_id " id)
    }
}

!RButton::                                       ; Alt + 오른쪽 드래그 = 크기 조절
{
    global g_DoubleAlt
    MouseGetPos(&x1, &y1, &id)
    if !id
        return
    if (g_DoubleAlt)                             ; Alt 두 번 + 우클릭 = 최대화/복원
    {
        if WinGetMinMax("ahk_id " id)
            WinRestore("ahk_id " id)
        else
            WinMaximize("ahk_id " id)
        g_DoubleAlt := false
        return
    }
    if WinGetMinMax("ahk_id " id)
        return
    WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " id)
    isLeft := (x1 < wx + ww / 2)                 ; 창의 어느 모서리를 잡았는지 판단
    isTop  := (y1 < wy + wh / 2)
    Loop
    {
        if !GetKeyState("RButton", "P")
            break
        MouseGetPos(&x2, &y2)
        newX := isLeft ? wx + (x2 - x1) : wx
        newY := isTop  ? wy + (y2 - y1) : wy
        newW := isLeft ? ww - (x2 - x1) : ww + (x2 - x1)
        newH := isTop  ? wh - (y2 - y1) : wh + (y2 - y1)
        try WinMove(newX, newY, newW, newH, "ahk_id " id)
    }
}

!MButton::                                       ; Alt + 가운데 클릭 = 항상 위 켜기/끄기
{
    global g_DoubleAlt
    if (g_DoubleAlt)                             ; Alt 두 번 + 가운데 클릭 = 창 닫기
    {
        MouseGetPos( , , &id)
        if id
            try WinClose("ahk_id " id)
        g_DoubleAlt := false
    }
    else
        try WinSetAlwaysOnTop(-1, "A")           ; -1 = 켜짐/꺼짐 뒤집기
}

!WheelUp::WinSetTransparent(255, "A")            ; Alt + 휠 위 = 불투명하게
!WheelDown::WinSetTransparent(200, "A")          ; Alt + 휠 아래 = 반투명하게

; Alt 를 짧은 시간에 두 번 눌렀는지 기억해 둡니다(위 창 제어에서 사용).
~Alt::
{
    global g_DoubleAlt
    g_DoubleAlt := (A_PriorHotkey = "~Alt" && A_TimeSincePriorHotkey < 400)
    KeyWait("Alt")
}

#f3::Macro_ResetWindows()                        ; 투명도·항상위 전체 해제

; 열려 있는 모든 창의 '항상 위'와 '투명도'를 원래대로 되돌립니다.
Macro_ResetWindows(*)
{
    for hwnd in WinGetList()
    {
        try WinSetAlwaysOnTop(0, "ahk_id " hwnd)
        try WinSetTransparent("Off", "ahk_id " hwnd)
    }
}


; ── 창 격자 배치 : 활성 창이 있는 모니터를 3x3 으로 나눠 그 칸에 맞춥니다 ──
;       7 8 9              좌상  상단  우상
;       4 5 6      =       좌측  중앙  우측
;       1 2 3              좌하  하단  우하
#Numpad7::MoveToGrid(0, 0)                       ; 창 배치 - 좌상단
#Numpad8::MoveToGrid(1, 0)                       ; 창 배치 - 상단
#Numpad9::MoveToGrid(2, 0)                       ; 창 배치 - 우상단
#Numpad4::MoveToGrid(0, 1)                       ; 창 배치 - 좌측
#Numpad5::MoveToGrid(1, 1)                       ; 창 배치 - 중앙
#Numpad6::MoveToGrid(2, 1)                       ; 창 배치 - 우측
#Numpad1::MoveToGrid(0, 2)                       ; 창 배치 - 좌하단
#Numpad2::MoveToGrid(1, 2)                       ; 창 배치 - 하단
#Numpad3::MoveToGrid(2, 2)                       ; 창 배치 - 우하단

MoveToGrid(col, row)
{
    hwnd := WinExist("A")
    if !hwnd
        return
    if WinGetMinMax("ahk_id " hwnd)
        WinRestore("ahk_id " hwnd)               ; 최대화 상태면 먼저 복원

    MonitorGetWorkArea(MonitorFromWindow(hwnd), &left, &top, &right, &bottom)
    cw := (right - left) // 3
    ch := (bottom - top) // 3

    x := left + col * cw
    y := top  + row * ch
    w := (col = 2) ? (right - x)  : cw           ; 맨 끝 칸은 나머지까지 채워 틈 방지
    h := (row = 2) ? (bottom - y) : ch

    WinMove(x, y, w, h, "ahk_id " hwnd)
}

; 창의 중심이 있는 모니터 번호(1부터)를 구합니다. 못 찾으면 1번.
MonitorFromWindow(hwnd)
{
    WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hwnd)
    cx := wx + ww // 2
    cy := wy + wh // 2
    Loop MonitorGetCount()
    {
        MonitorGet(A_Index, &l, &t, &r, &b)
        if (cx >= l && cx < r && cy >= t && cy < b)
            return A_Index
    }
    return 1
}


; ── 서식 없이 복사 / 붙여넣기 ──
;    한글·워드·메일에서 글꼴·색·표를 버리고 '글자만' 옮깁니다.
;    [5단계]에서 쓴 A_Clipboard 를 한 번 더 활용한 것입니다.
^+c::CopyAsPlainText()                           ; 서식 없이 복사
^+v::PasteAsPlainText()                          ; 서식 없이 붙여넣기

CopyAsPlainText()
{
    A_Clipboard := ""            ; 복사가 실제로 됐는지 확인하려고 먼저 비움
    SendInput("^c")
    if !ClipWait(1)
        return
    A_Clipboard := A_Clipboard   ; 문자열로 한 번 받았다 넣으면 서식이 사라집니다
}

PasteAsPlainText()
{
    text := A_Clipboard
    if (text = "")
        return
    savedClip := ClipboardAll()  ; 원래 클립보드를 잠시 보관
    A_Clipboard := ""
    A_Clipboard := text
    if !ClipWait(1, 1)
    {
        A_Clipboard := savedClip
        return
    }
    SendInput("^v")
    Sleep(150)
    A_Clipboard := savedClip     ; 원래 클립보드로 되돌려 놓기
}


; ── 단축키 도움말 : 스크립트가 자기 자신을 읽어서 만듭니다 ──
;    단축키 목록을 손으로 적어두면 반드시 코드와 어긋납니다.
;    그래서 이 파일을 읽어, 단축키 줄 옆에 붙은 ; 설명을 모아 보여줍니다.
;    → 새 단축키를 만들고 옆에 ; 설명만 달면 목록에 저절로 나타납니다.
^!h::ShowAllHotkeys()                            ; 단축키 도움말 (자동 생성)

ShowAllHotkeys(*)
{
    list := "이 파일에 들어 있는 단축키`n"
    list .= "================================`n"

    scriptText := FileRead(A_ScriptFullPath, "UTF-8")

    Loop Parse scriptText, "`n", "`r"
    {
        line := A_LoopField
        if !InStr(line, ";")
            continue
        parts := StrSplit(line, ";")             ; ; 앞뒤로 자르고
        desc  := Trim(parts.Length >= 2 ? parts[2] : "")
        if (desc = "")
            continue
        if RegExMatch(line, "^\s*([#^!+<>*~$\w\.]+)::", &m)    ; 단축키 줄인가?
            list .= Format("{:-22}", Trim(m[1])) . desc . "`n"
    }

    ; 핫스트링도 같은 방식으로 모읍니다.
    list .= "`n상용구 (치면 바뀌는 글자)`n"
    list .= "================================`n"

    Loop Parse scriptText, "`n", "`r"
    {
        line := A_LoopField
        if !InStr(line, ";")
            continue
        parts := StrSplit(line, ";")
        desc  := Trim(parts.Length >= 2 ? parts[2] : "")
        if (desc = "")
            continue
        if RegExMatch(line, "^\s*::(.*?)::", &m2)
            list .= Format("{:-22}", Trim(m2[1])) . desc . "`n"
    }

    MsgBox(list, "단축키 · 상용구 도움말", 64)
}


; ############################################################
;  [11단계] 덤 — 메일 상용구 (내 정보만 바꾸면 전부 반영됩니다)
; ------------------------------------------------------------
;  공문·메일 쓸 때 매번 치던 것들입니다.
;  아래 '내 정보' 여섯 줄만 내 것으로 바꾸면, 서명도 인사말도 한꺼번에 바뀝니다.
;
;     /ad   →  메일 한 통 통째로 (첫인사 + 본문 자리 + 감사 + 서명)
;     /sg   →  서명 블록만
;     /gr   →  첫인사만
;     /rq   →  협조 요청 문구        /fw  →  붙임 자료 안내 문구
;     /dt   →  오늘 날짜             //1  →  ①  (//2 //3 …)
; ############################################################

; ▼▼▼ 여기만 바꾸세요 — 내 정보 ▼▼▼
;    빈 칸("")으로 두면 그 줄은 서명에서 통째로 빠집니다.
global g_SignName := "홍길동"
global g_SignOrg  := "○○학교 행정실"
global g_SignTel  := "063-000-0000"
global g_SignFax  := ""
global g_SignMail := "hong@korea.kr"
global g_SignAddr := ""
; ▲▲▲ 여기까지 ▲▲▲


; ── 한 줄짜리 핫스트링 ──
;    ⚠ 한 줄 형식은 :: 뒤가 끝까지 전부 '나올 내용'이라
;       옆에 ; 주석을 달면 주석까지 그대로 입력됩니다. 그래서 여기엔 주석이 없습니다.
:://1::①
:://2::②
:://3::③
:://4::④
:://5::⑤


; ── 한글이 들어가는 것은 { } 로 감싸서 클립보드로 ──
;    ([5단계]에서 배운 그대로입니다. 주석도 달 수 있어 도움말에 나옵니다)
::/dt::                                    ; 오늘 날짜
{
    PasteText(FormatTime(A_Now, "yyyy. M. d."))
}

::/gr::                                    ; 메일 첫인사
{
    PasteText(MailGreeting())
}

::/sg::                                    ; 메일 서명 블록
{
    PasteText(MailSignature())
}

::/ad::                                    ; 메일 한 통 통째로
{
    PasteText(MailFullText())
}

::/rq::                                    ; 협조 요청 문구
{
    PasteText("업무에 협조해 주셔서 감사합니다.`r`n아래 내용 확인하시고 회신 부탁드립니다.")
}

::/fw::                                    ; 붙임 자료 안내 문구
{
    PasteText("관련 자료를 붙임과 같이 보내드립니다.`r`n확인 후 회신 부탁드립니다.")
}


; ── 메일 문구 만드는 곳 ──
;    위 '내 정보'를 가져다 조립합니다. 문구가 마음에 안 들면 여기서 고치세요.
MailGreeting()          ; 첫인사
{
    NL := "`r`n"
    return "안녕하세요." . NL . NL . g_SignOrg . " " . g_SignName . "입니다."
}

MailSignature()         ; 서명 블록 (빈 칸으로 둔 항목은 알아서 빠집니다)
{
    NL   := "`r`n"
    rule := "──────────────────────────────"

    s := rule . NL
    s .= "  🏫  " . g_SignName
    if (g_SignOrg != "")
        s .= "  |  " . g_SignOrg
    s .= NL
    if (g_SignTel != "")
        s .= "  ☎  " . g_SignTel . NL
    if (g_SignFax != "")
        s .= "  📠  " . g_SignFax . NL
    if (g_SignMail != "")
        s .= "  ✉  " . g_SignMail . NL
    if (g_SignAddr != "")
        s .= "  📍  " . g_SignAddr . NL
    s .= rule
    return s
}

MailFullText()          ; 첫인사 + 본문 자리 + 맺음말 + 서명
{
    NL := "`r`n"
    return MailGreeting() . NL . NL . NL . NL . "감사합니다." . NL . NL . MailSignature()
}


; 한글 IME 와 상관없이 글자를 넣습니다.
;   Send 로 한글을 길게 내보내면 글자가 깨지므로([5단계]에서 본 그것),
;   클립보드에 담아 Ctrl+V 로 붙여넣고 원래 클립보드를 되돌려 놓습니다.
PasteText(text)
{
    savedClip := ClipboardAll()          ; 원래 클립보드를 잠시 보관
    A_Clipboard := ""
    A_Clipboard := text
    if !ClipWait(1, 1)
    {
        A_Clipboard := savedClip
        return
    }
    SendInput("^v")
    Sleep(150)
    A_Clipboard := savedClip             ; 원래대로 되돌리기
}
