#Requires AutoHotkey v2.0
; ============================================================
;  AI 문장 다듬기  (AutoHotkey v2 + Gemini API)
; ------------------------------------------------------------
;  드래그한 문장을 AI가 공문체로 다듬어서 그 자리에 바로 넣어줍니다.
;
;  ▶ 사용법
;     1) 한글·워드·메일 어디서든 문장을 드래그해서 선택
;     2) Ctrl + Alt + G
;     3) 잠시 뒤 문장이 다듬어진 것으로 바뀝니다
;
;  ▶ 준비 (한 번만)
;     · https://aistudio.google.com 에서 무료 API 키 발급
;     · 이 파일과 같은 폴더에 gemini_key.txt 를 만들고
;       키만 한 줄 붙여넣고 저장
;
;  ※ 키를 파일로 분리한 이유 — 스크립트를 남에게 줘도 키가 딸려가지 않습니다.
; ============================================================

#SingleInstance Force

; ▼▼▼ 여기만 바꾸세요 ① — 어떻게 다듬을지 ▼▼▼
global g_Prompt := "너는 공문서 작성을 돕는 도우미야."
                 . " 다음 문장을 공문에 쓸 수 있도록 정중하고 간결하게 다듬어 줘."
                 . " 설명이나 따옴표 없이, 다듬은 문장만 출력해.`n`n문장:`n"
; ▲▲▲ 여기까지 ▲▲▲

; ▼▼▼ 여기만 바꾸세요 ② — 모델 이름 (바뀌면 여기만 고치면 됩니다) ▼▼▼
global g_Model   := "gemini-2.0-flash"
global g_ApiBase := "https://generativelanguage.googleapis.com/v1beta/models/"
; ▲▲▲ 여기까지 ▲▲▲

global g_KeyFile := A_ScriptDir . "\gemini_key.txt"


; ============================================================
;  Ctrl + Alt + G : 드래그한 문장을 다듬어 바로 교체
; ============================================================
^!g::RefineSelection()

RefineSelection(*)
{
    key := LoadKey()
    if (key = "")
        return

    ; --- 드래그한 글자 복사 (클립보드를 먼저 비워야 새 내용을 알아챕니다) ---
    saved := ClipboardAll()
    A_Clipboard := ""
    Send("^c")
    if !ClipWait(1)
    {
        A_Clipboard := saved
        MsgBox("먼저 다듬을 문장을 드래그해서 선택해 주세요.", "안내", 48)
        return
    }
    src := Trim(A_Clipboard)

    ; --- AI에게 물어보기 ---
    ToolTip("AI가 다듬는 중…")
    out := AskGemini(key, g_Prompt . src)
    ToolTip()

    if (out = "")
    {
        A_Clipboard := saved
        return
    }

    ; --- 선택돼 있던 문장을 다듬은 문장으로 교체 ---
    A_Clipboard := out
    ClipWait(1)
    Send("^v")
    Sleep(150)
    A_Clipboard := saved          ; 원래 클립보드 복구
}


; ============================================================
;  Gemini 에게 물어보고 답만 돌려줍니다.
; ============================================================
AskGemini(apiKey, promptText)
{
    url  := g_ApiBase . g_Model . ":generateContent?key=" . apiKey
    body := '{"contents":[{"parts":[{"text":"' . JsonEscape(promptText) . '"}]}]}'

    try
    {
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "application/json; charset=utf-8")
        http.Send(body)

        if (http.Status != 200)
        {
            MsgBox("AI 서버가 오류를 돌려줬습니다. (상태 " . http.Status . ")`n`n"
                 . SubStr(http.ResponseText, 1, 300), "요청 실패", 48)
            return ""
        }
        return ExtractText(http.ResponseText)
    }
    catch as e
    {
        MsgBox("인터넷 연결 또는 주소를 확인해 주세요.`n`n" . e.Message, "통신 오류", 48)
        return ""
    }
}


; ============================================================
;  도우미 함수
; ============================================================

; API 키를 옆에 있는 gemini_key.txt 에서 읽어옵니다.
LoadKey()
{
    if !FileExist(g_KeyFile)
    {
        MsgBox("API 키 파일이 없습니다.`n`n" . g_KeyFile . "`n`n"
             . "이 위치에 gemini_key.txt 를 만들고`n"
             . "aistudio.google.com 에서 받은 키를 한 줄 붙여넣어 주세요.", "키 없음", 48)
        return ""
    }
    key := Trim(FileRead(g_KeyFile, "UTF-8"), " `t`r`n")
    if (key = "")
        MsgBox("gemini_key.txt 가 비어 있습니다.", "키 없음", 48)
    return key
}

; 글자를 JSON 안에 넣을 수 있게 특수문자를 바꿔줍니다.
JsonEscape(s)
{
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`r`n", "\n")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "\n")
    s := StrReplace(s, "`t", "\t")
    return s
}

; 응답(JSON)에서 다듬어진 문장만 꺼냅니다.
ExtractText(json)
{
    ; "text": "……" 중 첫 번째 것을 찾습니다 (\" 같은 이스케이프도 포함)
    if !RegExMatch(json, 's)"text"\s*:\s*"((?:[^"\\]|\\.)*)"', &m)
    {
        MsgBox("응답에서 문장을 찾지 못했습니다.`n`n" . SubStr(json, 1, 300), "응답 오류", 48)
        return ""
    }
    return JsonUnescape(m[1])
}

; JSON 이스케이프를 원래 글자로 되돌립니다.
JsonUnescape(s)
{
    s := StrReplace(s, "\n", "`n")
    s := StrReplace(s, "\r", "`r")
    s := StrReplace(s, "\t", "`t")
    s := StrReplace(s, '\"', '"')
    s := StrReplace(s, "\/", "/")
    ; \uXXXX 형태(한글이 이렇게 올 때가 있습니다)를 글자로
    while RegExMatch(s, "\\u([0-9a-fA-F]{4})", &m)
        s := StrReplace(s, m[0], Chr("0x" . m[1]))
    s := StrReplace(s, "\\", "\")
    return s
}
