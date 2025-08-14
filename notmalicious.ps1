Add-Type @"
using System;
using System.Runtime.InteropServices;

public class MouseOps {
    [DllImport("user32.dll")]
    public static extern bool SetCursorPos(int X, int Y);

    [DllImport("user32.dll")]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo);

    public const uint MOUSEEVENTF_LEFTDOWN = 0x02;
    public const uint MOUSEEVENTF_LEFTUP   = 0x04;

    public static void MoveMouse(int x, int y) {
        SetCursorPos(x, y);
    }

    public static void LeftClick() {
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, UIntPtr.Zero);
        mouse_event(MOUSEEVENTF_LEFTUP,   0, 0, 0, UIntPtr.Zero);
    }
}
"@

[MouseOps]::MoveMouse(400, 650)
Start-Sleep -Seconds 2
[MouseOps]::LeftClick()
