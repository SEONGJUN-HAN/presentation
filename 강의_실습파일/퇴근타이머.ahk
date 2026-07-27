; ============================================================
;  퇴근 타이머  (AutoHotkey v1.1)
; ------------------------------------------------------------
;  화면 오른쪽 아래에 퇴근까지 남은 시간을 표시합니다.
;    · 창을 마우스로 끌어서 옮길 수 있습니다.
;    · 창 위에서 마우스 오른쪽 클릭 → 퇴근 시각 변경 / 종료
;    · 30분 이내로 남으면 주황색, 퇴근 후에는 빨간색으로 바뀝니다.
; ============================================================

#NoEnv
#SingleInstance, force
SetBatchLines, -1

; ▼▼▼ 여기만 바꾸세요 ▼▼▼
global OFF_H := 16, OFF_M := 30      ; 퇴근 시각
global ON_H  := 8,  ON_M  := 30      ; 출근 시각 (진행률 계산용)
; ▲▲▲ 여기까지 ▲▲▲

global C_BG   := "12151C"            ; 창 배경색
global C_DIM  := "8B949E"            ; 흐린 글씨
global C_GO   := "84CC16"            ; 평상시   (연두)
global C_SOON := "F59E0B"            ; 30분 이내 (주황)
global C_DONE := "EF4444"            ; 퇴근 이후 (빨강)
global LastState := ""

; ── 창 만들기 ──
Gui, +AlwaysOnTop -Caption +ToolWindow +HwndhTimer
Gui, Color, %C_BG%
Gui, Margin, 26, 18

Gui, Font, s10 c%C_DIM%, 맑은 고딕
Gui, Add, Text, vLblTop w250 BackgroundTrans, 퇴근까지

Gui, Font, s36 bold c%C_GO%, Consolas
Gui, Add, Text, vLblTime w250 BackgroundTrans, 00:00:00

Gui, Add, Progress, vBar w250 h6 Background2A2F3A c%C_GO%, 0

Gui, Font, s9 norm c%C_DIM%, 맑은 고딕
Gui, Add, Text, vLblSub w250 BackgroundTrans, 출근 00:00 · 퇴근 00:00

; ── 화면 오른쪽 아래에 배치 ──
Gui, Show, Hide AutoSize, 퇴근 타이머
DetectHiddenWindows, On
WinGetPos, , , W, H, ahk_id %hTimer%
DetectHiddenWindows, Off
Gui, Show, % "NoActivate x" (A_ScreenWidth - W - 32) " y" (A_ScreenHeight - H - 80)

WinSet, Region, 0-0 w%W% h%H% R16-16, ahk_id %hTimer%   ; 모서리 둥글게
WinSet, Transparent, 240, ahk_id %hTimer%               ; 살짝 반투명

; ── 오른쪽 클릭 메뉴 ──
Menu, Ctx, Add, 퇴근 시각 바꾸기, MenuChangeTime
Menu, Ctx, Add
Menu, Ctx, Add, 종료, MenuExit

OnMessage(0x201, "DragWindow")     ; 왼쪽 버튼으로 창 끌기

SetTimer, Tick, 1000
Gosub, Tick
return


; ============================================================
;  1초마다 남은 시간 갱신
; ============================================================
Tick:
    FormatTime, ymd, , yyyyMMdd
    tOff := ymd . Zero2(OFF_H) . Zero2(OFF_M) . "00"     ; 오늘 퇴근 시각
    tOn  := ymd . Zero2(ON_H)  . Zero2(ON_M)  . "00"     ; 오늘 출근 시각

    rem := tOff
    EnvSub, rem, %A_Now%, Seconds        ; 퇴근까지 남은 초

    span := tOff
    EnvSub, span, %tOn%, Seconds         ; 하루 근무 총 초

    GuiControl, , LblSub, % "출근 " Zero2(ON_H) ":" Zero2(ON_M) "   ·   퇴근 " Zero2(OFF_H) ":" Zero2(OFF_M)

    if (rem <= 0)                        ; 퇴근 시간이 지났을 때
    {
        SetColor("DONE")
        GuiControl, , LblTop, 퇴근 시간입니다. 수고하셨습니다!
        GuiControl, , LblTime, 00:00:00
        GuiControl, , Bar, 100
        return
    }

    SetColor(rem <= 1800 ? "SOON" : "GO")            ; 30분(1800초) 이내면 주황
    GuiControl, , LblTop, % (rem <= 1800) ? "곧 퇴근입니다!" : "퇴근까지"
    GuiControl, , LblTime, % Zero2(rem // 3600) ":" Zero2(Mod(rem, 3600) // 60) ":" Zero2(Mod(rem, 60))

    pct := (span > 0) ? Round((span - rem) / span * 100) : 0
    pct := (pct < 0) ? 0 : ((pct > 100) ? 100 : pct)
    GuiControl, , Bar, %pct%
return


; ============================================================
;  오른쪽 클릭 메뉴 동작
; ============================================================
GuiContextMenu:
    Menu, Ctx, Show
return

MenuChangeTime:
    def := Zero2(OFF_H) ":" Zero2(OFF_M)
    InputBox, ans, 퇴근 시각, 퇴근 시각을 입력하세요 (예: 17:00), , 300, 140, , , , , %def%
    if ErrorLevel
        return
    if RegExMatch(ans, "^\s*(\d{1,2})\s*:\s*(\d{1,2})\s*$", m)
    {
        OFF_H := m1 + 0
        OFF_M := m2 + 0
        Gosub, Tick
    }
    else
        MsgBox, 48, 입력 오류, 16:30 처럼 입력해 주세요.
return

MenuExit:
GuiClose:
    ExitApp
return


; ============================================================
;  도우미 함수
; ============================================================
; 한 자리 숫자 앞에 0 붙이기 (7 → 07)
Zero2(n)
{
    return (n < 10) ? "0" . n : n
}

; 상태에 따라 글자·진행바 색 바꾸기 (바뀔 때만 실행)
SetColor(state)
{
    global
    if (state = LastState)
        return
    LastState := state
    col := (state = "DONE") ? C_DONE : ((state = "SOON") ? C_SOON : C_GO)
    Gui, Font, s36 bold c%col%, Consolas
    GuiControl, Font, LblTime
    GuiControl, +c%col%, Bar
}

; 창의 아무 곳이나 왼쪽 버튼으로 끌어서 이동
DragWindow()
{
    global hTimer
    PostMessage, 0xA1, 2, , , ahk_id %hTimer%
}
