# --- Relaunch in STA and hide the console ------------------------------------
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA') {
  $ps = (Get-Command powershell.exe).Source
  Start-Process -FilePath $ps -WindowStyle Hidden -ArgumentList "-NoProfile -ExecutionPolicy Bypass -STA -File `"$PSCommandPath`""
  exit
}

# Hide current console window (if any)
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public static class Win32 {
  [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
  [DllImport("user32.dll")]  public static extern bool ShowWindow(IntPtr h, int n);
}
"@
$h = [Win32]::GetConsoleWindow()
if ($h -ne [IntPtr]::Zero) { [Win32]::ShowWindow($h, 0) }  # 0 = SW_HIDE

# --- WPF setup ----------------------------------------------------------------
Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase

# ASCII payload
$moth = @"
.-"""""""---,.               n,                                      ..--------..
\-          ,,'''-..      n   '\.                ,.n           ..--''           )
 \-     . .,;))     ''-,   \     ''.. .'"'. .,-''    .n   ..-''   (( o         _/
  \- ' ''''':'          ''-.'"|'--_  '     '  ,.--'''..-''         ' ' ' - .  _/
   \-                       ''->.  \'  ,--. '/' >..''                        _/
    \                     (,       /  /.  .\ \ ''    ,)                     ./
     ''.    .  ..         ')          \ .. /         ('          ..       ./
        ''-... . ._ .__         .''.  //..\\  ,'.            __ _ _,__.--'
            /' ((    ..'' ' ' '-'  6  \/__\/  ' '- - -' ' ',''   - '\
           '(.  6,    '..          /.   ''  .'          ,,'     ) )  )
            '\  \'C_,_   ==,      / '_      _|\       ,'', ,,_.;-' _/
              '._ ,   ')   E     /'|_ ')()('_' \     C  ,I'''  _.-'
                 ''''''\ (('   ,/  ''  (()) ''  '-._ _ __---'''
                        '' '' '    '==='()'=='
                                   '(       )'    PhH
     Acherontia atropos            '6        '
    (Totenkopfschwaermer,           \       /
     Death's Head Hawk-moth,        '       '
     P"a"akallokiit"aj"a)           '       '
                                     '      '
                                      '    '
                                       '..'
"@

# Pick a mono font that actually exists
$preferred = 'Cascadia Mono','Consolas','Lucida Console','Courier New','DejaVu Sans Mono'
$installed = [System.Windows.Media.Fonts]::SystemFontFamilies | ForEach-Object { $_.Source }
$mono = ($preferred | Where-Object { $installed -contains $_ } | Select-Object -First 1)
if (-not $mono) { $mono = 'Consolas' }

# Window
$win = New-Object System.Windows.Window
$win.WindowStyle = 'None'
$win.ResizeMode = 'NoResize'
$win.WindowState = 'Maximized'
$win.Topmost = $true
$win.Background = [System.Windows.Media.Brushes]::Black
$win.ShowInTaskbar = $false
$win.SnapsToDevicePixels = $true
$win.UseLayoutRounding = $true
$win.Title = 'Acherontia atropos'
$win.Focusable = $true

# Text
$txt = New-Object System.Windows.Controls.TextBlock
$txt.Text = $moth
$txt.FontFamily = New-Object System.Windows.Media.FontFamily($mono)
$txt.FontSize = 20
$txt.Foreground = New-Object System.Windows.Media.SolidColorBrush ([System.Windows.Media.Color]::FromRgb(255,0,0))
$txt.TextAlignment = 'Left'
$txt.HorizontalAlignment = 'Center'
$txt.VerticalAlignment = 'Center'
$txt.TextWrapping = 'NoWrap'
$txt.Padding = 20
$txt.LineStackingStrategy = 'BlockLineHeight'
$txt.LineHeight = $txt.FontSize
[System.Windows.Media.TextOptions]::SetTextFormattingMode($txt,'Ideal')
[System.Windows.Media.TextOptions]::SetTextRenderingMode($txt,'ClearType')

$grid = New-Object System.Windows.Controls.Grid
[void]$grid.Children.Add($txt)
$win.Content = $grid

# --- Exit gestures: Ctrl+Alt+F11 OR tap F11 x5 within 2s ---------------------
$script:F11Count = 0
$script:F11Timer = New-Object System.Diagnostics.Stopwatch

$win.Add_PreviewKeyDown({
  param($s,$e)
  $ctrl = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl) -or
          [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightCtrl)
  $alt  = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftAlt)  -or
          [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightAlt)

  if ($e.Key -eq [System.Windows.Input.Key]::F11 -and $ctrl -and $alt) { $s.Close(); return }

  if ($e.Key -eq [System.Windows.Input.Key]::F11) {
    if (-not $script:F11Timer.IsRunning) { $script:F11Timer.Start(); $script:F11Count = 0 }
    if ($script:F11Timer.ElapsedMilliseconds -gt 2000) { $script:F11Count = 0; $script:F11Timer.Restart() }
    $script:F11Count++
    if ($script:F11Count -ge 5) { $s.Close(); return }
  }

  $e.Handled = $true
})

$win.Add_PreviewMouseDown({ $_.Handled = $true })

# If you later add audio, guard the cleanup
$win.Add_Closed({ if ($script:audioCleanup) { try { & $script:audioCleanup } catch {} } })

# Go
[void]$win.ShowDialog()
