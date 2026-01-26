^+NumpadAdd:: ResizeWin(1.1)
^+NumpadSub:: ResizeWin(0.9)
^+NumpadEnter:: CenterWin(1920, 1080, -12.5, -2.5)

ResizeWin(factor) {
    win := WinGetID("A")

    WinGetPos(&x, &y, &w, &h, win)

    newW := Round(w * factor)
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