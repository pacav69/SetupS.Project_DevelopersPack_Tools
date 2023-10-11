#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ppApp.ico
#AutoIt3Wrapper_Outfile=#ExtraApp#.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Comment=Inspired by the original "Link Luster Clean" by AnneAardvark
#AutoIt3Wrapper_Res_Description=SetupS Cleaner. Automatically clean all your dead shortcuts & folders from your Start Menu, Desktop, & Quicklaunch.
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=© #cYear# #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=10
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################

	#ExtraApp# v#ProjectVersion#
	Copyright © #cYear#, #cHolder#
	All rights reserved.

	#ExtraApp# is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published
	by the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version of the License.

	DISCLAIMER:
	#ExtraApp# is distributed in the hope that it will be useful, but
	is provided by #cHolder# "AS IS", without warranty of any kind,
	express or implied, including but not limited to the warranties of
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT.
	In no event shall the authors or #cHolder# be liable for any direct,
	indirect, incidental, special, exemplary, or consequential damages
	(including, but not limited to, procurement of substitute goods or
	services; loss of use, data, or profits; or business interruption)
	however caused and on any theory of liability, whether in an action of
	contract, strict liability, or tort (including negligence or otherwise)
	arising from, out of or in connection with the software or the use or
	other dealings in the software, even if advised of the possibility of
	such damage.

	See the GNU General Public License for more details. You should have received a
	copy of the GNU General Public License along with #ExtraApp#. If not,
	see <http://www.gnu.org/licenses/>.

#ce ##################################################################################
#cs ##################################################################################

	Script Function:
	Deep clean your dud links automatically & safely. Removes all the dead
	shortcuts & empty folders from your Start Menu, Desktop, Sendto, and
	QuickLaunch. Safely deletes everything to the Recycle Bin.
	(Inspired by the original "Link Luster Clean" by AnneAardvark)

#ce ##################################################################################
#include <..\SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then
	;Some examples of how to use this:
;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--TrayOnly' ;'--Mute' ;'--TrayOnly' ; Switches

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '-ssClean=StartmenuOnly,NoDeepScan,NotDudInstallPaths'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '-StartmenuOnly'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '-NoDeepScan'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '-NotDudInstallPaths'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--Help' ; '?' ; Help

	Opt('TrayIconDebug', 1)
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

#include <StaticConstants.au3>
#include <WindowsConstants.au3>
Dim $TempCCleaner, $szDrive, $szDir, $szFName, $szExt, $Update
Local $AutoClose = 3, $UpdateINI, $MyName = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt)
Local $aPos, $CleanStartMenuDir = False, $CLIparametersCount = $CLIparameters[0]
Local $Mute, $TrayOnly, $SplashOnly
Local $ssCleanerNow, $ssCleanerNowDeleteDudAppPath, $ssCleanerNowDeleteUninstalled
Local $App_Title_ExtraApp, $App_BuildType_ExtraApp, $App_Version_ExtraApp, $App_InstallPath_ExtraApp
Local $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssExtraApp = CheckINI($ThisAppFilename & '.ini')
;~ If $MakeDefaultINI Then SetExtraAppDefaults($ssExtraApp)
Opt('GUIOnEventMode', 1)
$HelpFile = '';FindMe('ssTek.chm')

;----------------------------------------------------- Get Parameters -------------------------------------------------------------
If $Debug Then _ConsoleWrite('@@ Debug Start (' & @ScriptName & ') : ' & _NowCalc(), True) ; set 2nd arg = True to start a new file
GetExtraAppOptions($ssExtraApp)
GetReportingMode($ssExtraApp)
;Get legacy parameters
If GetParameter('StartmenuOnly') Or GetParameter('Startmenu') Then $ssCleaner = 1
If GetParameter('All') Or GetParameter('AllShortcuts') Then $ssCleaner = 2
If GetParameter('DudAppPaths') Or GetParameter('DudInstallPaths') Then $ssCleanerDeleteDudAppPath = True
If GetParameter('NotDudAppPaths') Or GetParameter('NotDudInstallPaths') Then $ssCleanerDeleteDudAppPath = False
If GetParameter('Uninstalled') Or GetParameter('DeepScan') Then $ssCleanerDeleteUninstalled = True
If GetParameter('NotUninstalled') Or GetParameter('NoDeepScan') Then $ssCleanerDeleteUninstalled = False
Local $SplashTipsLocal = $SplashTips
If GetParameter('Help') Or GetParameter('?') Then EndGame('Help requested', 'See displayed', True)

;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
GetMenuStyle()
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn)
If $AutoUpdate And Not $NoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)
If $UseGUI Then
	#region ### START Koda GUI section ### Form=ssCleaner.kxf
	Global $ssCleanerGUI = GUICreate("SetupS Cleaner", 396, 210, -1, -1)
	GUISetOnEvent($GUI_EVENT_CLOSE, "ssCleanerGUIClose")
	GUISetOnEvent($GUI_EVENT_MINIMIZE, "ssCleanerGUIMinimize")
	GUISetOnEvent($GUI_EVENT_MAXIMIZE, "ssCleanerGUIMaximize")
	GUISetOnEvent($GUI_EVENT_RESTORE, "ssCleanerGUIRestore")
	Global $ButtonOkay = GUICtrlCreateButton("Begin", 203, 180, 46, 20)
	GUICtrlSetOnEvent(-1, "ButtonOkayClick")
	Global $ButtonCancel = GUICtrlCreateButton("Cancel", 143, 180, 46, 20)
	GUICtrlSetOnEvent(-1, "ssCleanerGUIClose")
	Global $Label_CheckForUpdate = GUICtrlCreateLabel("Check for update...", 269, 182, 114, 17, $SS_RIGHT)
	GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "Label_CheckForUpdateClick")
	Global $Group_ssCleanerOptions = GUICtrlCreateGroup("Dud-shortcut removal:", 8, 5, 190, 92)
	GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000080)
	Global $Radio_ssCleanerAllShortcuts = GUICtrlCreateRadio("All Dud Shortcuts", 15, 56, 113, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "All shortcut locations such as Desktop, Sendto, & QuickLaunch will be included in the cleaning.")
	GUICtrlSetOnEvent(-1, "Radio_ssCleanerAllShortcutsClick")
	Global $Radio_ssCleanerStartmenuOnly = GUICtrlCreateRadio("Startmenu Only", 15, 39, 113, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Limits the cleaning location to only the Startmenu.")
	GUICtrlSetOnEvent(-1, "Radio_ssCleanerStartmenuOnlyClick")
	Global $Radio_ssCleanerDisabled = GUICtrlCreateRadio("Disabled", 15, 22, 113, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Do not perform any cleaning functions.")
	GUICtrlSetOnEvent(-1, "Radio_ssCleanerDisabledClick")
	Global $Checkbox_ssCleanerRemoved = GUICtrlCreateCheckbox("Check removed Startmenu items", 15, 73, 180, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Cleaning is automatically performed when shortcuts are removed such as during Startmenu Style changes.")
	GUICtrlSetOnEvent(-1, "Checkbox_ssCleanerRemovedClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_ssCleanerNow = GUICtrlCreateGroup("Instant ssCleaning", 220, 5, 170, 160)
	GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000080)
	Global $Button_ssCleanerNow = GUICtrlCreateButton("ssClean Now!", 248, 138, 110, 21)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetOnEvent(-1, "Button_ssCleanerNowClick")
	Global $Group_ssCleanerNowAppPathRemoval = GUICtrlCreateGroup("Remove Folders:", 225, 73, 160, 57)
	Global $Checkbox_ssCleanerNowDeleteDudAppPath = GUICtrlCreateCheckbox("Dud Installed-to paths", 232, 90, 148, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Whether or not to remove the install-to paths referenced by dud shortcuts.")
	GUICtrlSetOnEvent(-1, "Checkbox_ssCleanerNowDeleteDudAppPathClick")
	Global $Checkbox_ssCleanerNowDeleteUninstalled = GUICtrlCreateCheckbox("Uninstalled (deep scan)", 232, 107, 148, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Do a deep-scan of uninstalled apps or games and remove their folders.")
	GUICtrlSetOnEvent(-1, "Checkbox_ssCleanerNowDeleteUninstalledClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_ssCleanerNowOptions = GUICtrlCreateGroup("Dud-shortcut removal:", 225, 19, 160, 54)
	Global $Radio_ssCleanerNowStartmenuOnly = GUICtrlCreateRadio("Startmenu Only", 232, 36, 113, 17)
	GUICtrlSetState(-1, $GUI_CHECKED)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Limits the cleaning location to only the Startmenu.")
	GUICtrlSetOnEvent(-1, "Radio_ssCleanerNowStartmenuOnlyClick")
	Global $Radio_ssCleanerNowAllShortcuts = GUICtrlCreateRadio("All Dud Shortcuts", 232, 53, 113, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "All shortcut locations such as Desktop, Sendto, & QuickLaunch will be included in the cleaning.")
	GUICtrlSetOnEvent(-1, "Radio_ssCleanerNowAllShortcutsClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Group_AppPathRemoval = GUICtrlCreateGroup("Remove Folders:", 7, 101, 190, 61)
	GUICtrlSetFont(-1, 9, 800, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000080)
	Global $Checkbox_ssCleanerDeleteDudAppPath = GUICtrlCreateCheckbox("Dud Installed-to paths", 14, 118, 180, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Whether or not to remove the install-to paths referenced by dud shortcuts.")
	GUICtrlSetOnEvent(-1, "Checkbox_ssCleanerDeleteDudAppPathClick")
	Global $Checkbox_ssCleanerDeleteUninstalled = GUICtrlCreateCheckbox("Uninstalled (deep scan)", 14, 135, 180, 17)
	GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x000000)
	GUICtrlSetTip(-1, "Do a deep-scan of uninstalled apps or games and remove their folders.")
	GUICtrlSetOnEvent(-1, "Checkbox_ssCleanerDeleteUninstalledClick")
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Global $Label_ResetINI = GUICtrlCreateLabel("Restore Defaults", 7, 182, 99, 17)
	GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetOnEvent(-1, "Label_ResetINIClick")
	GUISetState(@SW_SHOW)
	#endregion ### END Koda GUI section ###

	;Detail
	ControlSetText('', '', $ssCleanerGUI, $ThisAppTitle)
	GUICtrlSetCursor($Label_CheckForUpdate, 0) ; hand-hover
	GUICtrlSetCursor($Label_ResetINI, 0) ; hand-hover
	If $NoUpdate Then GUICtrlSetState($Label_CheckForUpdate, $GUI_DISABLE)
	Switch $ssCleaner
		Case 0
			GUICtrlSetState($Radio_ssCleanerDisabled, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_DISABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_DISABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_DISABLE)
		Case 2
			GUICtrlSetState($Radio_ssCleanerAllShortcuts, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
		Case Else
			GUICtrlSetState($Radio_ssCleanerStartmenuOnly, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
			GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
	EndSwitch
	If $ssCleanRemovedMenuItem Then
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_UNCHECKED)
	EndIf
	If $ssCleanerDeleteUninstalled Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_UNCHECKED)
	EndIf
	If $ssCleanerDeleteDudAppPath Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_UNCHECKED)
	EndIf
	Switch $ssCleanerNow
		Case 2
			GUICtrlSetState($Radio_ssCleanerNowAllShortcuts, $GUI_CHECKED)
		Case Else
			GUICtrlSetState($Radio_ssCleanerNowStartmenuOnly, $GUI_CHECKED)
	EndSwitch
	GUICtrlSetState($Checkbox_ssCleanerNowDeleteDudAppPath, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerNowDeleteUninstalled, $GUI_ENABLE)
	If $ssCleanerNowDeleteUninstalled Then
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteUninstalled, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteUninstalled, $GUI_UNCHECKED)
	EndIf
	If $ssCleanerNowDeleteDudAppPath Then
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteDudAppPath, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteDudAppPath, $GUI_UNCHECKED)
	EndIf

	GUIRegisterMsg($WM_COMMAND, "MY_WM_COMMAND")
	GUISetState(@SW_SHOW, $ssCleanerGUI)
	HotKeySet('{F1}', 'HelpReq')

	Global $SetNow = False
	While 1
		Sleep(100)
	WEnd
Else
	If $BalloonTips Then
		RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
		Opt('TrayIconHide', 0) ;Show tray icon
		Opt('TrayAutoPause', 0) ;Turn off autopause
		_TrayTip($ThisAppTitle, 'Initializing...', 30, 17)
		AdlibRegister('_ShowTray', 5000)
	Else
		;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
		Opt('TrayIconHide', 1) ;Hide tray icon
	EndIf
	If $SplashTips Then SplashThis($ThisAppFilename, 'Initializing...')
	Main()
EndIf

;---------------------------------------------------- Finished ------------------------------------------------------------------
EndGame('Finished...', $LLChecked & ' Items Checked, ' & $LLDeleted & ' Items Deleted.', False, $AutoClose)

Func GetExtraAppOptions($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetExtraAppOptions(): $Defaults=' & $Defaults & @CRLF)
	Local $test, $parmlist, $i
	If FileExists($Defaults) Then ;Get default settings
		$AutoUpdate = IniRead_Binary($Defaults, 'Options', 'AutoUpdate', 'No')
		Switch IniRead($Defaults, 'ssCleaning', 'DudShortcuts', '')
			Case 'off', 'no', 'never'
				$ssCleaner = 0
			Case 'All', 'AllShortcuts'
				$ssCleaner = 2
			Case Else
				$ssCleaner = 1
		EndSwitch
		$ssCleanRemovedMenuItem = IniRead_Binary($Defaults, 'ssCleaning', 'RemovedMenuItem', 'Yes')
		$ssCleanerDeleteDudAppPath = IniRead_Binary($Defaults, 'ssCleaning', 'DudAppPaths', 'Yes')
		$ssCleanerDeleteUninstalled = IniRead_Binary($Defaults, 'ssCleaning', 'Uninstalled', 'No')
		$ssCleanerNowDeleteDudAppPath = IniRead_Binary($Defaults, 'Now', 'DudAppPaths', 'Yes')
		$ssCleanerNowDeleteUninstalled = IniRead_Binary($Defaults, 'Now', 'Uninstalled', 'No')
		Switch IniRead($Defaults, 'Now', 'DudShortcuts', '')
			Case 'All', 'AllShortcuts'
				$ssCleanerNow = 2
			Case Else
				$ssCleanerNow = 1
		EndSwitch
	EndIf
	$test = GetParameter('AutoUpdate', '=')
	If $test <> '' Then
		If FileExists($test) Then
			DeleteMe($test)
			$AutoUpdate = False
			$AutoUpdateReturn = 1
		Else
			$AutoUpdate = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
		EndIf
	EndIf
	$test = GetParameter('ssCleanOptions', '=')
	If $test = '' Then $test = GetParameter('ssCleaningOptions', '=')
	If $test = '' Then $test = GetParameter('ssCleanerOptions', '=')
	If $test <> '' Then
		$parmlist = StringSplit($test, ',')
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'off', 'no', 'never'
					$ssCleaner = 0
				Case 'Startmenu', 'StartmenuOnly'
					$ssCleaner = 1
				Case 'All', 'AllShortcuts'
					$ssCleaner = 2
				Case 'DudAppPaths', 'DudInstallPaths'
					$ssCleanerDeleteDudAppPath = True
				Case 'Uninstalled', 'DeepScan'
					$ssCleanerDeleteUninstalled = True
				Case 'NotDudAppPaths', 'NotDudInstallPaths'
					$ssCleanerDeleteDudAppPath = False
				Case 'NotUninstalled', 'NoDeepScan'
					$ssCleanerDeleteUninstalled = False
			EndSwitch
		Next
		Switch $ssCleaner
			Case 0
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'Never')
			Case 1
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'StartmenuOnly')
			Case 2
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'AllShortcuts')
			Case 3
				NeoIniWrite($Defaults, 'ssCleaning', 'DudShortcuts', 'Default')
		EndSwitch
		NeoIniWrite($Defaults, 'ssCleaning', 'DudAppPaths', $ssCleanerDeleteDudAppPath)
		NeoIniWrite($Defaults, 'ssCleaning', 'Uninstalled', $ssCleanerDeleteUninstalled)
	EndIf
	$test = GetParameter('ssClean', '=')
	If $test = '' Then $test = GetParameter('ssCleaning', '=')
	If $test = '' Then $test = GetParameter('ssCleaner', '=')
	If $test <> '' Then
		$parmlist = StringSplit($test, ',')
		For $i = 1 To $parmlist[0]
			Switch $parmlist[$i]
				Case 'off', 'no', 'never'
					$ssCleaner = 0
				Case 'Startmenu', 'StartmenuOnly'
					$ssCleaner = 1
				Case 'All', 'AllShortcuts'
					$ssCleaner = 2
				Case 'DudAppPaths', 'DudInstallPaths'
					$ssCleanerDeleteDudAppPath = True
				Case 'Uninstalled', 'DeepScan'
					$ssCleanerDeleteUninstalled = True
				Case 'NotDudAppPaths', 'NotDudInstallPaths'
					$ssCleanerDeleteDudAppPath = False
				Case 'NotUninstalled', 'NoDeepScan'
					$ssCleanerDeleteUninstalled = False
			EndSwitch
		Next
	ElseIf GetParameter('ssClean') Or GetParameter('ssCleaning') Or GetParameter('ssCleaner') Then
		$ssCleaner = 1
	EndIf
EndFunc

Func Main()
	If $AutoUpdate And Not $NoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)
	If $ssCleaner > 0 Then
		Switch $ssCleaner
			Case 1
				ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
				ssCleaner(@StartMenuDir) ; Current User Start Menu
			Case 2
				ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
				ssCleaner(@StartMenuDir) ; Current User Start Menu
				ssCleaner(@DesktopCommonDir) ; All Users Desktop
				ssCleaner(@DesktopDir) ; Current User Desktop
				ssCleaner(EnvGet('ALLUSERSPROFILE') & '\SendTo'); All Users Sendto
				ssCleaner(@UserProfileDir & '\SendTo') ; Current User Sendto
				ssCleaner(@AppDataDir & '\Microsoft\Internet Explorer\Quick Launch') ; QuickLaunch
		EndSwitch
		If $ssCleanerDeleteUninstalled Then
			DeleteUninstalled(@ProgramFilesDir)
			If StringInStr(@CommonFilesDir, @ProgramFilesDir) <> 1 Then DeleteUninstalled(@CommonFilesDir); In case not a subdir
			If $OSArch64 And $ProgramFilesDir32 Then
				DeleteUninstalled(EnvGet('ProgramFiles(x86)'))
				If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) <> 1 Then DeleteUninstalled(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
			EndIf
			DeleteUninstalled(@WindowsDir)
			If StringInStr(@SystemDir, @WindowsDir) <> 1 Then DeleteUninstalled(@SystemDir); In case not a subdir
			DeleteUninstalled($ppAppsDrive & '\ppApps')
			DeleteUninstalled($ppGamesDrive & '\ppGames')
		EndIf
	EndIf
	ssCleanerGUIClose()
EndFunc

Func MY_WM_COMMAND($hWnd, $msg, $wParam, $lParam)
	;If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|MY_WM_COMMAND()' & @CRLF)
	Local $nNotifyCode = _HiWord($wParam), $hCtrl = $lParam, $nID = _LoWord($wParam)
EndFunc
#region ;########################################## Form Controls ###############################################################

Func Button_ssCleanerNowClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_ssCleanerNowClick()' & @CRLF)
	Local $BalloonTipsIn = True, $SplashTipsIn = False
	Local $ssCleaner_Temp = $ssCleaner, $ssCleanerDeleteUninstalled_Temp = $ssCleanerDeleteUninstalled, $ssCleanerDeleteDudAppPath_Temp = $ssCleanerDeleteDudAppPath
	Select
		Case BitAND(GUICtrlRead($Radio_ssCleanerNowStartmenuOnly), $GUI_CHECKED) = $GUI_CHECKED
			$ssCleaner = 1
		Case BitAND(GUICtrlRead($Radio_ssCleanerNowAllShortcuts), $GUI_CHECKED) = $GUI_CHECKED
			$ssCleaner = 2
	EndSelect
	$ssCleanerDeleteUninstalled = (BitAND(GUICtrlRead($Checkbox_ssCleanerNowDeleteUninstalled), $GUI_CHECKED) = $GUI_CHECKED)
	$ssCleanerDeleteDudAppPath = (BitAND(GUICtrlRead($Checkbox_ssCleanerNowDeleteDudAppPath), $GUI_CHECKED) = $GUI_CHECKED)
	If $ssCleaner > 0 Then
		Switch $ssCleaner
			Case 1
				ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
				ssCleaner(@StartMenuDir) ; Current User Start Menu
			Case 2
				ssCleaner(@StartMenuCommonDir) ; All Users Start Menu
				ssCleaner(@StartMenuDir) ; Current User Start Menu
				ssCleaner(@DesktopCommonDir) ; All Users Desktop
				ssCleaner(@DesktopDir) ; Current User Desktop
				ssCleaner(EnvGet('ALLUSERSPROFILE') & '\SendTo'); All Users Sendto
				ssCleaner(@UserProfileDir & '\SendTo') ; Current User Sendto
				ssCleaner(@AppDataDir & '\Microsoft\Internet Explorer\Quick Launch') ; QuickLaunch
		EndSwitch
		If $ssCleanerDeleteUninstalled Then
			DeleteUninstalled(@ProgramFilesDir)
			If StringInStr(@CommonFilesDir, @ProgramFilesDir) <> 1 Then DeleteUninstalled(@CommonFilesDir); In case not a subdir
			If $OSArch64 And $ProgramFilesDir32 Then
				DeleteUninstalled(EnvGet('ProgramFiles(x86)'))
				If StringInStr(EnvGet('COMMONPROGRAMFILES(x86)'), EnvGet('ProgramFiles(x86)')) <> 1 Then DeleteUninstalled(EnvGet('COMMONPROGRAMFILES(x86)')); In case not a subdir
			EndIf
			DeleteUninstalled(@WindowsDir)
			If StringInStr(@SystemDir, @WindowsDir) <> 1 Then DeleteUninstalled(@SystemDir); In case not a subdir
			DeleteUninstalled($ppAppsDrive & '\ppApps')
			DeleteUninstalled($ppGamesDrive & '\ppGames')
		EndIf
	EndIf
	If $KeepStartMenuFolders Then CopyMenu($MenuStyle)
	$ssCleaner = $ssCleaner_Temp
	$ssCleanerDeleteUninstalled = $ssCleanerDeleteUninstalled_Temp
	$ssCleanerDeleteDudAppPath = $ssCleanerDeleteDudAppPath_Temp
	_TrayTip($ThisAppTitle, '', 300, 16)
	SplashOff()
	If $Log Or $Debug Then _ConsoleWrite($ThisAppTitle & ': ' & 'Scanning Done' & @CRLF)
EndFunc
Func ButtonOkayClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ButtonOkayClick()' & @CRLF)
	GUISetState(@SW_HIDE, $ssCleanerGUI)
	Main()
EndFunc
Func Checkbox_ssCleanerRemovedClick()
	$ssCleanRemovedMenuItem = Not $ssCleanRemovedMenuItem
	If $ssCleanRemovedMenuItem Then
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssExtraApp, 'ssCleaning', 'RemovedMenuItem', $ssCleanRemovedMenuItem)
EndFunc
Func Checkbox_ssCleanerNowDeleteDudAppPathClick()
	$ssCleanerNowDeleteDudAppPath = Not $ssCleanerNowDeleteDudAppPath
	If $ssCleanerNowDeleteDudAppPath Then
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteDudAppPath, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteDudAppPath, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssExtraApp, 'Now', 'DudAppPaths', $ssCleanerNowDeleteDudAppPath)
EndFunc
Func Checkbox_ssCleanerNowDeleteUninstalledClick()
	$ssCleanerNowDeleteUninstalled = Not $ssCleanerNowDeleteUninstalled
	If $ssCleanerNowDeleteUninstalled Then
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteUninstalled, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerNowDeleteUninstalled, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssExtraApp, 'Now', 'Uninstalled', $ssCleanerNowDeleteUninstalled)
EndFunc
Func Checkbox_ssCleanerDeleteDudAppPathClick()
	$ssCleanerDeleteDudAppPath = Not $ssCleanerDeleteDudAppPath
	If $ssCleanerDeleteDudAppPath Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssExtraApp, 'ssCleaning', 'DudAppPaths', $ssCleanerDeleteDudAppPath)
EndFunc
Func Checkbox_ssCleanerDeleteUninstalledClick()
	$ssCleanerDeleteUninstalled = Not $ssCleanerDeleteUninstalled
	If $ssCleanerDeleteUninstalled Then
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_UNCHECKED)
	EndIf
	NeoIniWrite($ssExtraApp, 'ssCleaning', 'Uninstalled', $ssCleanerDeleteUninstalled)
EndFunc

Func Label_CheckForUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CheckForUpdateClick()' & @CRLF)
	UpdateMe('update.ini', @ScriptDir, True, $UseGUI)
EndFunc

Func Label_ResetINIClick()
	ResetINI($ThisAppFilename & '.ini')
	Local $TempDL = GenerateTempFolder(), $File = FileOpen($TempDL & '\' & 'ResetMe.cmd', 10)
	If $File <> -1 Then
		FileWrite($File, 'cd ..' & @CRLF)
		FileWrite($File, '"' & @ScriptFullPath & '" -AutoUpdate=' & $TempDL & @CRLF)
		FileWrite($File, 'exit' & @CRLF)
		FileClose($File)
		FileChangeDir($TempDL)
		If $SetupSFolder <> '' And Not StringInStr(EnvGet('Path'), $SetupSFolder) Then EnvSet('path', $SetupSFolder & ';' & EnvGet('path'))
		Run('ResetMe.cmd', $TempDL, @SW_HIDE)
		Sleep(100)
		FileChangeDir(@ScriptDir)
		Cleanup()
		Exit
	EndIf
EndFunc

Func Radio_ssCleanerAllShortcutsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerAllShortcutsClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
EndFunc
Func Radio_ssCleanerDisabledClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerDisabledClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_DISABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_DISABLE)
EndFunc

Func Radio_ssCleanerNowStartmenuOnlyClick()
	$ssCleanerNow = 1
	NeoIniWrite($ssExtraApp, 'Now', 'DudShortcuts', 'StartmenuOnly')
EndFunc
Func Radio_ssCleanerNowAllShortcutsClick()
	$ssCleanerNow = 2
	NeoIniWrite($ssExtraApp, 'Now', 'DudShortcuts', 'AllShortcuts')
EndFunc

Func Radio_ssCleanerStartmenuOnlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_ssCleanerStartmenuOnlyClick()' & @CRLF)
	GUICtrlSetState($Checkbox_ssCleanerDeleteDudAppPath, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerDeleteUninstalled, $GUI_ENABLE)
	GUICtrlSetState($Checkbox_ssCleanerRemoved, $GUI_ENABLE)
EndFunc
Func SaveSettings()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SaveSettings()' & @CRLF)
	If FileExists($ssExtraApp) And $UseGUI Then
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Mute', $Mute)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'TrayOnly', $TrayOnly)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnly', $SplashOnly)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnTop', $SplashOnTop)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Debug', $Debug)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Log', $Log)
		Select
			Case BitAND(GUICtrlRead($Radio_ssCleanerDisabled), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 0
				NeoIniWrite($ssExtraApp, 'ssCleaning', 'DudShortcuts', 'Never')
			Case BitAND(GUICtrlRead($Radio_ssCleanerStartmenuOnly), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 1
				NeoIniWrite($ssExtraApp, 'ssCleaning', 'DudShortcuts', 'StartmenuOnly')
			Case BitAND(GUICtrlRead($Radio_ssCleanerAllShortcuts), $GUI_CHECKED) = $GUI_CHECKED
				$ssCleaner = 2
				NeoIniWrite($ssExtraApp, 'ssCleaning', 'DudShortcuts', 'AllShortcuts')
		EndSelect
		NeoIniWrite($ssExtraApp, 'ssCleaning', 'RemovedMenuItem', $ssCleanRemovedMenuItem)
		NeoIniWrite($ssExtraApp, 'ssCleaning', 'DudAppPaths', $ssCleanerDeleteDudAppPath)
		NeoIniWrite($ssExtraApp, 'ssCleaning', 'Uninstalled', $ssCleanerDeleteUninstalled)
	EndIf
EndFunc
Func ssCleanerGUIClose()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|ssCleanerGUIClose()' & @CRLF)
	SaveSettings()
	Cleanup()
	If ProcessExists($Help_PID) Then ProcessClose($Help_PID)
	Exit
EndFunc
Func ssCleanerGUIMaximize()
EndFunc
Func ssCleanerGUIMinimize()
EndFunc
Func ssCleanerGUIRestore()
EndFunc
#endregion
