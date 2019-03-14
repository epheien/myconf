;-----------------------------------------
; Mac keyboard to Windows Key Mappings
;=========================================

; --------------------------------------------------------------
; NOTES
; --------------------------------------------------------------
; ! = ALT
; ^ = CTRL
; + = SHIFT
; # = WIN
;
; Debug action snippet: MsgBox You pressed Control-A while Notepad is active.

#InstallKeybdHook
#SingleInstance force
; 1: 窗口标题必须以指定的 WinTitle 开头.
; 2: 窗口标题的某个位置必须包含 WinTitle。(default)
; 3: 窗口标题必须准确匹配 WinTitle.
SetTitleMatchMode 3
SendMode Input

; swap left command/windows key with left alt
;LWin::LAlt
;LAlt::LWin ; add a semicolon in front of this line if you want to disable the windows key

; --------------------------------------------------------------
; Emacs/Vim style shortcuts
; --------------------------------------------------------------
#If (not WinActive("ahk_class Vim")
     and not WinActive("ahk_class FaTTY")
     and not WinActive("ahk_class mintty")
     and not WinActive("ahk_exe Xshell.exe")
     and not WinActive("ahk_exe nvim-qt.exe"))
; Emacs style shortcuts
^a::Send {Home}
^e::Send {End}
^p::Send {Up}
^n::Send {Down}
^b::Send {Left}
^f::Send {Right}

^w::Send ^{Backspace}

; Vim style shortcuts
^k::Send {Up}
^j::Send {Down}
^h::Send {Left}
^l::Send {Right}
#if

; --------------------------------------------------------------
; OS X system shortcuts
; --------------------------------------------------------------

; Make Ctrl + S work with cmd (windows) key
#s::Send ^s

; Selecting
#a::Send ^a

; Copying
#c::Send ^c

; Pasting
#v::Send ^v

; Cutting
#x::Send ^x

; Opening
#o::Send ^o

; Finding
#f::Send ^f

; Undo
#z::Send ^z

; Redo
#y::Send ^y

; New tab
#t::Send ^t

; close tab
#w::Send ^w

; Close windows (cmd + q to Alt + F4)
#q::Send !{F4}

; Remap Windows + Tab to Alt + Tab.
LWin & Tab::AltTab

; minimize active windows
#m::WinMinimize, A

LWin & Backspace::Send ^{Backspace}

; 禁用掉烦死人的 Win 按键！
LWin::return
RWin::return

; --------------------------------------------------------------
; Application specific
; --------------------------------------------------------------

; Google Chrome
#IfWinActive, ahk_class Chrome_WidgetWin_1

; Show Web Developer Tools with cmd + alt + i
#!i::Send {F12}

; Show source code with cmd + alt + u
#!u::Send ^u

#IfWinActive

; --------------------------------------------------------------
; Trigger
; --------------------------------------------------------------
; NOTE: 通过启动快捷方式的方式来指定其他参数
^#v::Run "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Vim 8.1\gVim"
^#n::Run "D:\opt\Neovim\bin\nvim-qt.exe" -qwindowgeometry 720x765
^#t::Run "C:\Users\fxq\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\wsl-terminal"
