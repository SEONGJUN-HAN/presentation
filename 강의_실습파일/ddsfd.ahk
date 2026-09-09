#Requires AutoHotkey v2.0

; Ctrl + Alt + L → 런처 창
^!l::
{
    ; 창 만들기 (제목: 나만의 런처)
    myGui := Gui(, "나만의 런처")
    myGui.AddText(, "원하는 버튼을 누르세요")
    ; 버튼 붙이고, 누르면 할 일 연결
    btn := myGui.AddButton("w260", "🌐 나이스 접속")
    btn.OnEvent("Click", (*) => Run("https://www.neis.go.kr"))
    myGui.Show()          ; 화면에 보여주기
}