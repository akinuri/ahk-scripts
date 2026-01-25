^+NumpadAdd::ResizeWin(1.1)
^+NumpadSub::ResizeWin(0.9)
^+NumpadEnter::WinMove(100, 100, 1920, 1080, "A")

ResizeWin(factor) {
    win := WinGetID("A")

    WinGetPos(&x, &y, &w, &h, win)

    newW := Round(w * factor)
    newH := Round(h * factor)

    newX := x - (newW - w) / 2
    newY := y - (newH - h) / 2

    WinMove(newX, newY, newW, newH, win)
}
