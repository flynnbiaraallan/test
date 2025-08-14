# Build the kiosk script in a here-string
$s = @'
Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase
Add-Type -AssemblyName System.Windows.Forms

$red = [Windows.Media.Color]::FromRgb(255,0,0)
$redBrush = New-Object Windows.Media.SolidColorBrush $red

$win = New-Object Windows.Window
$win.WindowStyle = 'None'
$win.ResizeMode = 'NoResize'
$win.WindowState = 'Maximized'
$win.Topmost = $true
$win.Background = 'Black'
$win.Focusable = $true
$win.Title = 'Acherontia atropos'

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

$grid = New-Object Windows.Controls.Grid
$tb = New-Object Windows.Controls.TextBlock
$tb.Text = $moth
$tb.Foreground = $redBrush
$tb.FontFamily = 'Consolas'
$tb.FontSize = 16
$tb.TextAlignment = 'Left'
$tb.HorizontalAlignment = 'Center'
$tb.VerticalAlignment = 'Center'
$tb.TextWrapping = 'NoWrap'
$tb.LineHeight = 16
$tb.LineStackingStrategy = 'BlockLineHeight'
$grid.Children.Add($tb) | Out-Null
$win.Content = $grid

[System.Windows.Forms.Cursor]::Hide()
$win.Add_Closed({[System.Windows.Forms.Cursor]::Show()})

# Close with Ctrl+Shift+M
$win.Add_KeyDown({
    param($s,$e)
    $m = $e.KeyboardDevice.Modifiers
    if (($m -band [Windows.Input.ModifierKeys]::Control) -and 
        ($m -band [Windows.Input.ModifierKeys]::Shift) -and 
        ($e.Key -eq 'M')) {
        $s.Close()
    }
})

$win.ShowDialog() | Out-Null
'@

# Save to %TEMP% and run hidden
$p = Join-Path $env:TEMP 'moth.ps1'
Set-Content -Path $p -Value $s -Encoding UTF8
Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File `"$p`""
exit
