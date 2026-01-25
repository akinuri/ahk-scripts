KeySequences := Map()
KeySequences["11"] := A_ScriptDir "\sounds\cartoon-fail-trumpet-278822.mp3"
KeySequences["22"] := A_ScriptDir "\sounds\failed-295059.mp3"

InputBuffer := "" 
SequenceTimeout := 1000
DebounceTimeout := 300

Numpad0::HandleKeyPress("0")
Numpad1::HandleKeyPress("1")
Numpad2::HandleKeyPress("2")
Numpad3::HandleKeyPress("3")
Numpad4::HandleKeyPress("4")
Numpad5::HandleKeyPress("5")
Numpad6::HandleKeyPress("6")
Numpad7::HandleKeyPress("7")
Numpad8::HandleKeyPress("8")
Numpad9::HandleKeyPress("9")

HandleKeyPress(Key) {
    global InputBuffer, SequenceTimeout, DebounceTimeout
    InputBuffer .= Key
    Send(Key)
    SetTimer(ResetDebounceTimer, -DebounceTimeout)
    SetTimer(CheckSequence, -SequenceTimeout)
}

ResetDebounceTimer() {
    ; Do nothing for now, just keep the timer alive
}

CheckSequence() {
    global InputBuffer, KeySequences
    if (KeySequences.Has(InputBuffer)) {
        SoundPlay(KeySequences[InputBuffer])
    }
    InputBuffer := ""
}