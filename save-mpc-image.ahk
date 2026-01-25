sleepDuration := 500

; Middle mouse button (wheel click) will trigger the save image process in MPC-HC

MButton::  ; Binds the middle mouse button to this action
{
    if WinActive("ahk_class MediaPlayerClassicW")  ; Only activate if MPC-HC is the active window
    {
        ; Send("{Click}")
        ; Sleep(sleepDuration)
        
        Send("w")
        Sleep(sleepDuration)
        
        Send("!f")  ; Alt+F to open File menu
        
        Sleep(sleepDuration)
        Send("I")   ; Press "i" for Save Image
        
        Sleep(sleepDuration)
        Send("{F4}")  ; Press F4 to focus the location/address bar
        
        Sleep(sleepDuration)
        SendText(A_Desktop)  ; Type Desktop path
        Send("{Enter}")
        
        Sleep(sleepDuration)
        Send("{Tab 7}")  ; Navigate back to the filename field
        
        Send("{Enter}")  ; Press Enter to finalize save
        
        Sleep(sleepDuration)
        Send("w")
        
        Sleep(sleepDuration * 2)
        Send("{Click}")  ; Press Enter to finalize save
    }
    else
    {
        Send("{MButton}")  ; This sends the default middle click action
    }
}
