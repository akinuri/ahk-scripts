^+NumpadAdd:: ResizeWin(1.1)
^+NumpadSub:: ResizeWin(0.9)

#HotIf GetKeyState("x", "P")
^+NumpadAdd:: ResizeWin(1.1, "x")
^+NumpadSub:: ResizeWin(0.9, "x")
#HotIf

#HotIf GetKeyState("z", "P")
^+NumpadAdd:: ResizeWin(1.1, "y")
^+NumpadSub:: ResizeWin(0.9, "y")
#HotIf

^+NumpadEnter:: CenterWin(1920, 1080, -12.5, -2.5)

ResizeWin(factor, axis := "xy") {
    win := WinGetID("A")

    WinGetPos(&x, &y, &w, &h, win)

    newW := w
    newH := h

    if InStr(axis, "x")
        newW := Round(w * factor)

    if InStr(axis, "y")
        newH := Round(h * factor)

    newX := x - (newW - w) / 2
    newY := y - (newH - h) / 2

    WinMove(newX, newY, newW, newH, win)
}

CenterWin(width, height, xOffsetPct := 0, yOffsetPct := 0) {
    win := WinGetID("A")

    MonitorGet(, &left, &top, &right, &bottom)
    screenW := right - left
    screenH := bottom - top

    centerX := (screenW - width) / 2 + (screenW * xOffsetPct / 100)
    centerY := (screenH - height) / 2 + (screenH * yOffsetPct / 100)

    WinMove(centerX, centerY, width, height, win)
}