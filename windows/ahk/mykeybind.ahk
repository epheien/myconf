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
SetTitleMatchMode 2
SendMode Input

; swap left command/windows key with left alt
;LWin::LAlt
;LAlt::LWin ; add a semicolon in front of this line if you want to disable the windows key

; --------------------------------------------------------------
; Emacs/Vim style shortcuts
; --------------------------------------------------------------
#If (not WinActive("ahk_exe gvim.exe")
     and not WinActive("ahk_class FaTTY")
     and not WinActive("ahk_exe nvim-qt.exe"))
; Emacs style shortcuts
^a::Send {Home}
^e::Send {End}
^p::Send {Up}
^n::Send {Down}
^b::Send {Left}
^f::Send {Right}

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
^#v::Run "C:\Program Files\Vim\vim81\gvim.exe"
^#t::Run "C:\Users\fxq\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\wsl-terminal"
