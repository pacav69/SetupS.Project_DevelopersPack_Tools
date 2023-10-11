#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIListView.au3>
$h = WinGetHandle("[CLASS:Progman]")
$hwnd = ControlGetHandle($h,"","SysListView321")

$View = _GUICtrlListView_GetView($hwnd)
If $View = 1 Then
	_GUICtrlListView_SetView($hwnd,3)
Else
	_GUICtrlListView_SetView($hwnd,1)
EndIf



