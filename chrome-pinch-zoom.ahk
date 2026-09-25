#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================
; Chrome pinch zoom
;
; Shift + Alt + Wheel Up   = pinch zoom in
; Shift + Alt + Wheel Down = pinch zoom out
;
; This injects two Windows touch contacts into Chrome.
; It does NOT use Ctrl+Wheel / Chrome page zoom.
; ============================================================

#HotIf WinActive("ahk_exe chrome.exe")

$+!WheelUp::{
    ReleaseZoomModifiers()
    PinchAtMouse(1)
}

$+!WheelDown::{
    ReleaseZoomModifiers()
    PinchAtMouse(-1)
}

#HotIf


ReleaseZoomModifiers() {
    ; Prevent Chrome/Windows from seeing Alt/Shift during
    ; the synthetic touchscreen gesture.
    SendEvent "{Alt up}{Shift up}"
}


PinchAtMouse(direction) {
    static initialized := false

    if A_PtrSize != 8
        throw Error("This script requires 64-bit AutoHotkey.")

    if !initialized {
        ; TOUCH_FEEDBACK_NONE = 3
        if !DllCall(
            "user32\InitializeTouchInjection",
            "UInt", 2,
            "UInt", 3,
            "Int"
        ) {
            throw Error(
                "InitializeTouchInjection failed. Win32 error: "
                A_LastError
            )
        }

        initialized := true
    }

    CoordMode "Mouse", "Screen"
    MouseGetPos &cx, &cy

    ; --------------------------------------------------------
    ; Virtual desktop bounds
    ; --------------------------------------------------------

    vx := DllCall(
        "user32\GetSystemMetrics",
        "Int", 76,
        "Int"
    )

    vy := DllCall(
        "user32\GetSystemMetrics",
        "Int", 77,
        "Int"
    )

    vw := DllCall(
        "user32\GetSystemMetrics",
        "Int", 78,
        "Int"
    )

    vh := DllCall(
        "user32\GetSystemMetrics",
        "Int", 79,
        "Int"
    )

    minX := vx
    minY := vy
    maxX := vx + vw - 1
    maxY := vy + vh - 1

    ; --------------------------------------------------------
    ; Gesture geometry
    ;
    ; Each value is the distance of ONE finger from the
    ; mouse cursor.
    ;
    ; Zoom in:
    ;
    ;       <- finger       finger ->
    ;               mouse
    ;
    ; Zoom out does the reverse.
    ; --------------------------------------------------------

    if direction > 0 {
        startDistance := 45
        endDistance   := 115
    } else {
        startDistance := 115
        endDistance   := 45
    }

    steps := 7

    ; POINTER_TOUCH_INFO is 144 bytes on x64.
    contactSize := 144

    contacts := Buffer(contactSize * 2, 0)

    y := Clamp(cy, minY, maxY)

    ; --------------------------------------------------------
    ; TOUCH DOWN
    ; --------------------------------------------------------

    x1 := Clamp(cx - startDistance, minX, maxX)
    x2 := Clamp(cx + startDistance, minX, maxX)

    SetTouchContact(
        contacts,
        0,
        0,
        x1,
        y,
        "down"
    )

    SetTouchContact(
        contacts,
        1,
        1,
        x2,
        y,
        "down"
    )

    InjectTouches(contacts)

    ; --------------------------------------------------------
    ; PINCH MOVEMENT
    ; --------------------------------------------------------

    Loop steps {
        t := A_Index / steps

        ; Smoothstep interpolation.
        ; Makes the movement less abrupt than linear motion.
        t := t * t * (3 - 2 * t)

        distance := Round(
            startDistance
            + (endDistance - startDistance) * t
        )

        x1 := Clamp(cx - distance, minX, maxX)
        x2 := Clamp(cx + distance, minX, maxX)

        SetTouchContact(
            contacts,
            0,
            0,
            x1,
            y,
            "update"
        )

        SetTouchContact(
            contacts,
            1,
            1,
            x2,
            y,
            "update"
        )

        InjectTouches(contacts)

        ; Keep this short.
        ; Long delays can make Windows interpret the gesture
        ; as touch-and-hold / context menu.
        Sleep 3
    }

    ; --------------------------------------------------------
    ; TOUCH UP
    ;
    ; The UP position must exactly match the last UPDATE.
    ; --------------------------------------------------------

    SetTouchContact(
        contacts,
        0,
        0,
        x1,
        y,
        "up"
    )

    SetTouchContact(
        contacts,
        1,
        1,
        x2,
        y,
        "up"
    )

    InjectTouches(contacts)
}


SetTouchContact(
    buffer,
    index,
    id,
    x,
    y,
    state
) {
    static SIZE := 144

    static PT_TOUCH := 2

    static POINTER_FLAG_INRANGE   := 0x00000002
    static POINTER_FLAG_INCONTACT := 0x00000004

    static POINTER_FLAG_DOWN   := 0x00010000
    static POINTER_FLAG_UPDATE := 0x00020000
    static POINTER_FLAG_UP     := 0x00040000

    base := index * SIZE

    ; Clear old contents so no stale fields remain.
    DllCall(
        "ntdll\RtlZeroMemory",
        "Ptr", buffer.Ptr + base,
        "UPtr", SIZE
    )

    switch state {
        case "down":
            flags := (
                POINTER_FLAG_DOWN
                | POINTER_FLAG_INRANGE
                | POINTER_FLAG_INCONTACT
            )

        case "update":
            flags := (
                POINTER_FLAG_UPDATE
                | POINTER_FLAG_INRANGE
                | POINTER_FLAG_INCONTACT
            )

        case "up":
            flags := POINTER_FLAG_UP

        default:
            throw Error(
                "Invalid touch state: " state
            )
    }

    ; ========================================================
    ; POINTER_INFO
    ; ========================================================

    ; POINTER_INPUT_TYPE pointerType
    ; offset 0
    NumPut(
        "UInt",
        PT_TOUCH,
        buffer,
        base + 0
    )

    ; UINT32 pointerId
    ; offset 4
    NumPut(
        "UInt",
        id,
        buffer,
        base + 4
    )

    ; UINT32 frameId
    ; offset 8
    NumPut(
        "UInt",
        0,
        buffer,
        base + 8
    )

    ; POINTER_FLAGS pointerFlags
    ; offset 12
    NumPut(
        "UInt",
        flags,
        buffer,
        base + 12
    )

    ; HANDLE sourceDevice
    ; offset 16
    NumPut(
        "Ptr",
        0,
        buffer,
        base + 16
    )

    ; HWND hwndTarget
    ; offset 24
    NumPut(
        "Ptr",
        0,
        buffer,
        base + 24
    )

    ; POINT ptPixelLocation
    ; offset 32
    NumPut(
        "Int",
        x,
        buffer,
        base + 32
    )

    NumPut(
        "Int",
        y,
        buffer,
        base + 36
    )

    ; Remaining POINTER_INFO fields stay zero.

    ; ========================================================
    ; POINTER_TOUCH_INFO
    ; ========================================================

    ; TOUCH_FLAGS touchFlags
    ; offset 96
    NumPut(
        "UInt",
        0,
        buffer,
        base + 96
    )

    ; TOUCH_MASK touchMask
    ; offset 100
    ;
    ; No pressure/contact rectangle/orientation requested.
    NumPut(
        "UInt",
        0,
        buffer,
        base + 100
    )
}


InjectTouches(contacts) {
    if !DllCall(
        "user32\InjectTouchInput",
        "UInt", 2,
        "Ptr", contacts.Ptr,
        "Int"
    ) {
        throw Error(
            "InjectTouchInput failed. Win32 error: "
            A_LastError
        )
    }
}


Clamp(value, minimum, maximum) {
    if value < minimum
        return minimum

    if value > maximum
        return maximum

    return value
}