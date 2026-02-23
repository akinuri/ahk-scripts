^+NumpadAdd:: ResizeWin(1.1)
^+NumpadSub:: ResizeWin(0.9)

^!+Up:: MoveWin(0, -3)
^!+Down:: MoveWin(0, 3)
^!+Left:: MoveWin(-3, 0)
^!+Right:: MoveWin(3, 0)

#HotIf GetKeyState("x", "P")
^+NumpadAdd:: ResizeWin(1.1, "x")
^+NumpadSub:: ResizeWin(0.9, "x")
#HotIf

#HotIf GetKeyState("z", "P")
^+NumpadAdd:: ResizeWin(1.1, "y")
^+NumpadSub:: ResizeWin(0.9, "y")
#HotIf

^+NumpadEnter:: CenterWin(1920, 1080, -75, -25)

MoveWin(dx, dy) {
    win := WinGetID("A")

    MonitorGet(, &left, &top, &right, &bottom)
    screenW := right - left
    screenH := bottom - top

    moveX := Round(screenW * dx / 100)
    moveY := Round(screenH * dy / 100)

    WinGetPos(&x, &y, &w, &h, win)
    WinMove(x + moveX, y + moveY, w, h, win)
}

ResizeWin(factor, axis := "xy") {
    win := WinGetID("A")

    WinGetPos(&x, &y, &w, &h, win)

    newW := w
    newH := h

    if InStr(axis, "x")
        newW := Round(w * factor)

    if InStr(axis, "y")
        newH := Round(h * factor)

    deltaW := newW - w
    deltaH := newH - h

    newX := x - Round(deltaW * 0.1)
    newY := y - Round(deltaH * 0.1)

    WinMove(newX, newY, newW, newH, win)
}

CenterWin(width, height, xOffsetPct := 0, yOffsetPct := 0) {
    win := WinGetID("A")

    MonitorGet(, &left, &top, &right, &bottom)
    screenW := right - left
    screenH := bottom - top

    marginX := (screenW - width) / 2
    marginY := (screenH - height) / 2

    centerX := marginX * (1 + xOffsetPct / 100)
    centerY := marginY * (1 + yOffsetPct / 100)

    WinMove(centerX, centerY, width, height, win)
}