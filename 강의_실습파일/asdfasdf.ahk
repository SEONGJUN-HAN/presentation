#NoEnv
#SingleInstance Force
SetBatchLines, -1
SetTimer, UpdateTime, 1000

;==============================
; 설정
;==============================
QuitHour := 16
QuitMin  := 30

Gui, +AlwaysOnTop +ToolWindow -MaximizeBox -MinimizeBox
Gui, Margin, 10, 10
Gui, Font, s16 Bold, 맑은 고딕
Gui, Add, Text, vRemain w260 Center cBlue, 계산중...

Gui, Font, s9 Normal, 맑은 고딕
Gui, Add, Text, vNow w260 Center, 현재시간

Gui, Show,, 퇴근 타이머

Gosub, UpdateTime
Return

;==============================
UpdateTime:

FormatTime, Today,, yyyyMMdd
Target := Today

if (QuitHour < 10)
    Target .= "0" QuitHour
else
    Target .= QuitHour

if (QuitMin < 10)
    Target .= "0" QuitMin
else
    Target .= QuitMin

Target .= "00"

Diff := Target
EnvSub, Diff, %A_Now%, Seconds

if (Diff >= 0)
{
    h := Floor(Diff/3600)
    m := Floor(Mod(Diff,3600)/60)
    s := Mod(Diff,60)

    hh := (h<10 ? "0" h : h)
    mm := (m<10 ? "0" m : m)
    ss := (s<10 ? "0" s : s)

    GuiControl,+cBlue,Remain
    GuiControl,,Remain,% "? 퇴근까지 " hh ":" mm ":" ss
}
else
{
    Diff := -Diff

    h := Floor(Diff/3600)
    m := Floor(Mod(Diff,3600)/60)
    s := Mod(Diff,60)

    hh := (h<10 ? "0" h : h)
    mm := (m<10 ? "0" m : m)
    ss := (s<10 ? "0" s : s)

    GuiControl,+cRed,Remain
    GuiControl,,Remain,% "?? 퇴근 +" hh ":" mm ":" ss
}

FormatTime, NowText,, HH:mm:ss
GuiControl,,Now,% "현재시간 : " NowText

Return

;==============================
; 창 아무 곳이나 드래그
;==============================
WM_LBUTTONDOWN() {
    PostMessage, 0xA1, 2
}
OnMessage(0x201, "WM_LBUTTONDOWN")

GuiClose:
ExitApp

Esc::
ExitApp