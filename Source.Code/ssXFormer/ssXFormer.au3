#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ppApp.ico
#AutoIt3Wrapper_Outfile=#ExtraApp#.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS XFormer. Convert SetupS archives to SFX (Self-extracting Executables)!
#AutoIt3Wrapper_Res_Fileversion=#ProjectVersion#
#AutoIt3Wrapper_Res_LegalCopyright=© #cYear# #cHolder#
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|#ProjectDate#
#AutoIt3Wrapper_Res_Field=#WebSite1#|http://#WebLink1#
#AutoIt3Wrapper_Res_Field=#WebSite2#|http://#WebLink2#
#AutoIt3Wrapper_Res_Field=#WebSite3#|http://#WebLink3#
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################
	
	#ExtraApp# v#ProjectVersion#
	Copyright © #cYear#, #cHolder#
	All rights reserved.
	
	#ExtraApp# is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published by the
	Free Software Foundation, either version 3 of the License, or (at your option)
	any later version of the License.
	
	DISCLAIMER:
	#ExtraApp# is distributed in the hope that it will be useful, but is
	provided by #cHolder# "AS IS", without warranty of any kind, express or
	implied, including but not limited to the warranties of MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT. In no event shall
	the authors or #cHolder# be liable for any direct, indirect, incidental, special,
	exemplary, or consequential damages (including, but not limited to, procurement of
	substitute goods or services; loss of use, data, or profits; or business
	interruption) however caused and on any theory of liability, whether in an action
	of contract, strict liability, or tort (including negligence or otherwise) arising
	from, out of or in connection with the software or the use or other dealings in the
	software, even if advised of the possibility of such damage.
	
	See the GNU General Public License for more details. You should have received a
	copy of the GNU General Public License along with #ExtraApp#. If not,
	see <http://www.gnu.org/licenses/>.
	
#ce ##################################################################################
#cs ##################################################################################
	
	Script Function:
	App to convert SetupS archives to SFX
	
#ce ##################################################################################
#include <..\SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled And Not GetParameter('Test') Then
	$CLIparameters[0] += 1
	ReDim $CLIparameters[$CLIparameters[0] + 1]
	$CLIparameters[$CLIparameters[0]] = 'D:\ssInstalls\AIMP_v3.60_ssApp.apz' ;specific test

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '-autobuild' ;specific test

	Opt('TrayIconDebug', 1)
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <..\UDFs\7zRead.au3>

Dim $TempCCleaner, $szDrive, $szDir, $szFName, $szExt, $Update
Local $AutoClose = 3, $UpdateINI, $MyName = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt)
Local $aPos, $CleanStartMenuDir = False, $CLIparametersCount = $CLIparameters[0]
Local $SFXMute, $SFXTrayOnly, $SFXSplashOnly, $SFXSplashOnTop, $SFXVerbose
Local $App_Title_ExtraApp, $App_BuildType_ExtraApp, $App_Version_ExtraApp, $App_InstallPath_ExtraApp
Local $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssExtraApp = CheckINI($ThisAppFilename & '.ini')
;~ If $MakeDefaultINI Then SetExtraAppDefaults($ssExtraApp)
Global $7Zip, $AddonInstaller, $AddToHosts, $ProcessKill, $WaitForIt ;Components
Global $Startmenus, $DefaultFaders, $FaderModules, $FontReg ;Extras
Global $Recompress, $Append ;Options
Global $Archive_Drive, $Archive_Dir, $Archive_FileName, $Archive_Ext, $Archive_Extracted
Global $AutoBuild = GetParameter('Build') Or GetParameter('AutoBuild')
Local $nMsg, $ssXFormerINI = CheckINI($ThisAppFilename & '.ini')
Local $SFXFaderOnTop = True, $SFXFadertainer, $SFXFaderSpeed
If $App_File = '' Then ;obtain update info
	_AppReset()
	$App_File = _AppRead(@ScriptDir, False, True)
	$App_Version_ExtraApp = $App_Version
	If StringInStr($App_Version_ExtraApp, '#ProjectVersion#') Then $App_Version_ExtraApp = 'v' & $SetupS_CoreVer
	While StringInStr($App_Version_ExtraApp, 'v')
		$App_Version_ExtraApp = StringReplace($App_Version_ExtraApp, 'v', '')
	WEnd
	$App_InstallPath_ExtraApp = ConvertFromVars($App_InstallPath)
	$App_Title_ExtraApp = $App_Title
	If StringInStr($App_Title_ExtraApp, '#ExtraApp#') Then $App_Title_ExtraApp = $ThisAppFilename
	$App_BuildType_ExtraApp = $App_BuildType
EndIf
$HelpFile = '';FindMe('ssTek.chm')
Opt("GUIOnEventMode", 1)

;----------------------------------------------------- Get Parameters -------------------------------------------------------------
If $Debug Then _ConsoleWrite('@@ Debug Start (' & @ScriptName & ') : ' & _NowCalc(), True) ; set 2nd arg = True to start a new file
GetExtraAppOptions($ssExtraApp)
GetReportingMode($ssExtraApp)
Local $SplashTipsLocal = $SplashTips
If GetParameter('Help') Or GetParameter('?') Then EndGame('Help requested', 'See displayed', True)

;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
If $ToolsPath = '' Then GetToolsFolder()
GetMenuStyle()
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn)
If $AutoUpdate And Not $NoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)

#cs ##################################################################################
	# Don't change anything between Koda Gui Section Regions!
	# It will be over-written by any changes made to the .kxf file.
	# Use Ctrl+U from the Form=[see below] to update and save both files.
#ce ##################################################################################
#region ### START Koda GUI section ### Form=ssXFormer.kxf
Global $frm_MakeSFX = GUICreate("ssXFormerMaker", 528, 192, 204, 128)
GUISetOnEvent($GUI_EVENT_CLOSE, "frm_MakeSFXClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "frm_MakeSFXMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "frm_MakeSFXMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "frm_MakeSFXRestore")
Global $Input_Filename = GUICtrlCreateInput("", 49, 5, 346, 21)
GUICtrlSetOnEvent($Input_Filename, "Input_FilenameChange")
Global $Button_BrowseForFile = GUICtrlCreateButton("···", 399, 6, 20, 20)
GUICtrlSetFont($Button_BrowseForFile, 12, 800, 0, "MS Sans Serif")
GUICtrlSetOnEvent($Button_BrowseForFile, "Button_BrowseForFileClick")
Global $Group_Include = GUICtrlCreateGroup("Include:", 5, 33, 226, 124)
Global $Checkbox_AllTools = GUICtrlCreateCheckbox("All Tools:", 13, 49, 135, 17)
GUICtrlSetOnEvent($Checkbox_AllTools, "Checkbox_AllToolsClick")
Global $Checkbox_7zip = GUICtrlCreateCheckbox("7-Zip", 30, 65, 80, 17)
GUICtrlSetOnEvent($Checkbox_7zip, "Checkbox_7zipClick")
Global $Checkbox_Startmenus = GUICtrlCreateCheckbox("Startmenus", 133, 65, 93, 17)
GUICtrlSetOnEvent($Checkbox_Startmenus, "Checkbox_StartmenusClick")
Global $Checkbox_DefaultFaders = GUICtrlCreateCheckbox("Default Faders", 133, 81, 93, 17)
GUICtrlSetOnEvent($Checkbox_DefaultFaders, "Checkbox_DefaultFadersClick")
Global $Checkbox_AddToHosts = GUICtrlCreateCheckbox("AddToHosts", 30, 97, 80, 17)
GUICtrlSetOnEvent($Checkbox_AddToHosts, "Checkbox_AddToHostsClick")
Global $Checkbox_ProcessKill = GUICtrlCreateCheckbox("ProcessKill", 30, 113, 80, 17)
GUICtrlSetOnEvent($Checkbox_ProcessKill, "Checkbox_ProcessKillClick")
Global $Checkbox_AddonInstaller = GUICtrlCreateCheckbox("AddonInstaller", 30, 81, 88, 17)
GUICtrlSetOnEvent($Checkbox_AddonInstaller, "Checkbox_AddonInstallerClick")
Global $Checkbox_WaitForIt = GUICtrlCreateCheckbox("WaitForIt", 30, 129, 80, 17)
GUICtrlSetOnEvent($Checkbox_WaitForIt, "Checkbox_WaitForItClick")
Global $Checkbox_FaderModules = GUICtrlCreateCheckbox("Fader Modules", 133, 97, 93, 17)
GUICtrlSetOnEvent($Checkbox_FaderModules, "Checkbox_FaderModulesClick")
Global $Checkbox_FontReg = GUICtrlCreateCheckbox("Font(s) Installer", 133, 113, 93, 17)
GUICtrlSetOnEvent($Checkbox_FontReg, "Checkbox_FontRegClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Button_MakeSFX = GUICtrlCreateButton("MakeSFX", 439, 4, 62, 25)
GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
GUICtrlSetOnEvent($Button_MakeSFX, "Button_MakeSFXClick")
Global $Group_Reporting = GUICtrlCreateGroup("Reporting:", 229, 33, 104, 124)
Global $Checkbox_SplashOnTop = GUICtrlCreateCheckbox("Splash on top", 237, 113, 86, 17)
GUICtrlSetOnEvent($Checkbox_SplashOnTop, "Checkbox_SplashOnTopClick")
Global $Radio_Verbose = GUICtrlCreateRadio("Verbose", 237, 49, 80, 17)
GUICtrlSetOnEvent($Radio_Verbose, "Radio_VerboseClick")
Global $Radio_Mute = GUICtrlCreateRadio("Mute", 237, 65, 80, 17)
GUICtrlSetOnEvent($Radio_Mute, "Radio_MuteClick")
Global $Radio_Trayonly = GUICtrlCreateRadio("Tray only", 237, 81, 80, 17)
GUICtrlSetOnEvent($Radio_Trayonly, "Radio_TrayonlyClick")
Global $Radio_Splashonly = GUICtrlCreateRadio("Splash only", 237, 97, 80, 17)
GUICtrlSetOnEvent($Radio_Splashonly, "Radio_SplashonlyClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Fadertainer = GUICtrlCreateGroup("Fadertainer:", 331, 33, 95, 124)
Global $Checkbox_FaderOnTop = GUICtrlCreateCheckbox("OnTop", 339, 81, 54, 17)
GUICtrlSetState($Checkbox_FaderOnTop, $GUI_CHECKED)
GUICtrlSetOnEvent($Checkbox_FaderOnTop, "Checkbox_FaderOnTopClick")
Global $Label_FaderSpeed = GUICtrlCreateLabel("Speed:", 336, 106, 38, 17, $SS_RIGHT)
GUICtrlSetOnEvent($Label_FaderSpeed, "Label_FaderSpeedClick")
Global $Input_FaderSpeed = GUICtrlCreateInput(".5", 378, 103, 33, 21)
GUICtrlSetOnEvent($Input_FaderSpeed, "Input_FaderSpeedChange")
Global $Radio_Fadertainer = GUICtrlCreateRadio("Activate", 339, 49, 64, 17)
GUICtrlSetOnEvent($Radio_Fadertainer, "Radio_FadertainerClick")
Global $Label_FaderLocation = GUICtrlCreateLabel("Location:", 336, 132, 48, 17, $SS_RIGHT)
GUICtrlSetOnEvent($Label_FaderLocation, "Label_FaderLocationClick")
Global $Input_FaderLocation = GUICtrlCreateInput("TR", 386, 129, 33, 21)
GUICtrlSetOnEvent($Input_FaderLocation, "Input_FaderLocationChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Label_Archive = GUICtrlCreateLabel("Archive:", 5, 8, 43, 17, $SS_RIGHT)
GUICtrlSetOnEvent($Label_Archive, "Label_ArchiveClick")
Global $Group_Options = GUICtrlCreateGroup("Options", 424, 33, 95, 54)
Global $Radio_Append = GUICtrlCreateRadio("Append", 432, 49, 64, 17)
GUICtrlSetState($Radio_Append, $GUI_DISABLE)
GUICtrlSetOnEvent($Radio_Append, "Radio_AppendClick")
Global $Radio_Recompress = GUICtrlCreateRadio("Recompress", 432, 65, 78, 17)
GUICtrlSetOnEvent($Radio_Recompress, "Radio_RecompressClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Label_CheckForUpdate = GUICtrlCreateLabel("Check for update...", 404, 163, 114, 17, $SS_RIGHT)
GUICtrlSetFont($Label_CheckForUpdate, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($Label_CheckForUpdate, 0x0000FF)
GUICtrlSetOnEvent($Label_CheckForUpdate, "Label_CheckForUpdateClick")
Global $Label_ResetINI = GUICtrlCreateLabel("Restore Defaults", 5, 163, 99, 17)
GUICtrlSetFont($Label_ResetINI, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor($Label_ResetINI, 0x0000FF)
GUICtrlSetOnEvent($Label_ResetINI, "Label_ResetINIClick")
#endregion ### END Koda GUI section ###

;Detail form
ControlSetText('', '', $frm_MakeSFX, $ThisAppTitle)
Radio_TrayonlyClick()
Radio_RecompressClick()
Radio_FadertainerClick()
If $CLIparameters[0] > 0 Then Button_BrowseForFileClick()
GUISetState(@SW_SHOW, $frm_MakeSFX)
GUICtrlSetCursor($Label_CheckForUpdate, 0) ; hand-hover
GUICtrlSetCursor($Label_ResetINI, 0) ; hand-hover
If $NoUpdate Then GUICtrlSetState($Label_CheckForUpdate, $GUI_DISABLE)

;------------------------------------------------------ Begin --------------------------------------------------------------------
CheckAvailable()
If $AutoBuild Then
	Button_MakeSFXClick()
	frm_MakeSFXClose()
Else
	Do
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				frm_MakeSFXClose()
		EndSwitch
		Sleep(100)
	Until 0 ; Loop until user exits
EndIf
Exit

Func GetExtraAppOptions($ssExtraApp)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetExtraAppOptions(): $ssExtraApp=' & $ssExtraApp & @CRLF)
	Local $test, $parmlist, $i
	If FileExists($ssExtraApp) Then ;Get default settings
		$SFXMute = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'Mute', 'No')
		$SFXTrayOnly = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'TrayOnly', 'Yes')
		$SFXSplashOnTop = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'SplashOnly', 'No')
		$SFXSplashOnTop = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'SplashOnTop', 'No')
		$Debug = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'Debug', 'No')
		$Log = IniRead_Binary($ssExtraApp, 'SFX Reporting Mode', 'Log', 'No')
		$AutoUpdate = IniRead_Binary($ssExtraApp, 'Options', 'AutoUpdate', 'No')
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
EndFunc

Func SaveSettings()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|frm_MakeSFXClose()' & @CRLF)
	If FileExists($ssExtraApp) And Not $AutoBuild Then
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'Mute', $SFXMute)
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'TrayOnly', $SFXTrayOnly)
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'SplashOnly', $SFXSplashOnly)
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'SplashOnTop', $SFXSplashOnTop)
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'Debug', $Debug)
		NeoIniWrite($ssExtraApp, 'SFX Reporting Mode', 'Log', $Log)
		NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', $AutoUpdate)
	EndIf
EndFunc

Func WriteConfigSFX($what)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|WriteConfigSFX()' & @CRLF)
	Local $File, $i = ''
	Select
		Case $SFXVerbose
			$i = $i & ' -Verbose'
			If $SFXSplashOnTop Then $i = $i & ' -SplashOnTop'
		Case $SFXMute
			$i = $i & ' -Mute'
		Case $SFXTrayOnly
			$i = $i & ' -TrayOnly'
		Case $SFXSplashOnly
			$i = $i & ' -SplashOnly'
			If $SFXSplashOnTop Then $i = $i & ' -SplashOnTop'
	EndSelect
	If $SFXFadertainer Then
		$i = $i & ' -Fadertainer=On'
		If $SFXFaderOnTop Then
			$i = $i & ' -FaderOnTop=Yes'
		Else
			$i = $i & ' -FaderOnTop=No'
		EndIf
		If $SFXFaderSpeed > 0 Then $i = $i & ' -FaderSpeed=' & $SFXFaderSpeed
		If $FaderLocation <> '' Then $i = $i & ' -FaderLocation=' & $FaderLocation
	Else
		$i = $i & ' -Fadertainer=Off'
	EndIf
	$File = FileOpen($what, 10) ;Write mode (erase previous contents)
	FileWriteLine($File, ';!@Install@!UTF-8!')
	FileWriteLine($File, 'MiscFlags="4"')
	FileWriteLine($File, 'RunProgram="x86:SetupS.exe ' & StringStripWS($i, 3) & '"')
	FileWriteLine($File, 'RunProgram="x64:SetupS_x64.exe ' & StringStripWS($i, 3) & '"')
;~ 	FileWriteLine($File, 'ExecuteFile="SetupS.exe"')
;~ 	FileWriteLine($File, 'ExecuteParameters="' & StringStripWS($i, 3) & ' -Wait"')
	FileWriteLine($File, 'GUIMode="1"')
	FileWriteLine($File, ';!@InstallEnd@!')
	FileClose($File)
EndFunc
#region ;########################################## Form Controls ###############################################################

Func Button_BrowseForFileClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_BrowseForFileClick()' & @CRLF)
	Local $i, $var, $FileList, $ArchiveFound = False
	Cleanup()
	_AppReset()
	$Archive_Extracted = ''
	If $CLIparameters[0] > 0 Then
		$var = $CLIparameters[1]
		$CLIparameters[0] = 0
		ReDim $CLIparameters[1]
	Else
		$var = $Archive_Drive & $Archive_Dir
		If $var = '' Then $var = '.'
		$var = FileOpenDialog('Browse for archive to convert', $var, 'SetupS archives (*.apz;*.pgz)', 1)
	EndIf
	If Not @error Then
		$var = StringReplace($var, '|', @CRLF)
		Local $Array = _PathSplit($var, $Archive_Drive, $Archive_Dir, $Archive_FileName, $Archive_Ext);0 = original path, 1 = drive, 2 = directory, 3 = filename, 4 = extension
		GUICtrlSetData($Input_Filename, $Archive_FileName & $Archive_Ext)
		GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Switch $Archive_Ext
			Case '.apz', '.pgz'
				If GetFileFromArchive('*', $var) Then
					$Archive_Extracted = $TempDir
					$FileList = _FileListToArray($TempDir, '*.*', 1) ; Return files only
					If @error = 0 Then
						For $i = 1 To $FileList[0]
							Select
								Case StringInStr($FileList[$i], 'Patch.7z')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], GetAppTypeBase($App_Type) & '.7z')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], GetAppTypeBase($App_Type) & '.rar')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], GetAppTypeBase($App_Type) & '.zip')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], GetAppTypeBase($App_Type) & '.cab')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], '.apz') Or StringInStr($FileList[$i], '.pgz')
									$ArchiveFound = True
								Case StringInStr($FileList[$i], '.bat') Or StringInStr($FileList[$i], '.cmd')
									;Need a check for .bat/.cmd with %Components%
							EndSelect
							;If $ArchiveFound Then ExitLoop
						Next
					EndIf
					If $App_File = '' Then $App_File = _AppRead($TempDir, False, False)
					If $App_File <> '' Then ;Need a check for <Script> with %Components%
					EndIf
				EndIf
		EndSwitch
		If ($ArchiveFound And Not $7Zip) Or ($7Zip And Not $ArchiveFound) Then Checkbox_7zipClick()
	EndIf
EndFunc

Func Button_MakeSFXClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Button_MakeSFXClick()' & @CRLF)
	If $Archive_FileName <> '' Then
		Local $n, $AppTitle = $ThisAppTitle, $CurrentDir = @WorkingDir, $test
		If FileExists(FileGetShortName($Archive_Drive & $Archive_Dir & $Archive_FileName & $Archive_Ext)) Then
			Local $subtext = '... "' & StringReplace($Archive_FileName & '.7z', '&', '&&') & '"', $cutoff = 53
			If StringLen($subtext) > $cutoff Then $subtext = StringLeft($subtext, $cutoff - (5 + 11)) & ' ... ' & StringRight($subtext, 11)
			$subtext = $subtext & @CRLF & @CRLF & 'Press <Alt+Ctrl+ESC> to abort'
			If $AppTitle <> '' Then $AppTitle = ' (' & $AppTitle & ')'
			ProgressOn('7zip Progress' & $AppTitle, 'Creating archive...', $Archive_FileName & '.7z', -1, @DesktopHeight / 2 - 100, 16)
			ProgressSet(0, '0%' & $subtext, 'Compressing... ')
			HotKeySet('^!{ESC}', 'Stop7z')
			If $Recompress Then
				FileChangeDir(NoBackslash($Archive_Drive & $Archive_Dir))
				If $Archive_Extracted = '' Then
					_AppReset()
					$test = $CLIprefix & '7z x -y -aoa "' & $Archive_FileName & $Archive_Ext & '" -o"' & $TempDir & '"'
					RunWait($test, NoBackslash($Archive_Drive & $Archive_Dir), @SW_HIDE)
				EndIf
				If FileExists($ToolsPath & '\SetupS.exe') Then
					FileCopy($ToolsPath & '\SetupS.exe', $TempDir & '\SetupS.exe', 9)
				ElseIf FileExists($ToolsPath & '\_x86\SetupS.exe') Then
					FileCopy($ToolsPath & '\_x86\SetupS.exe', $TempDir & '\SetupS.exe', 9)
				EndIf
				If FileExists($ToolsPath & '\SetupS_x64.exe') Then
					FileCopy($ToolsPath & '\SetupS_x64.exe', $TempDir & '\SetupS_x64.exe', 9)
				ElseIf FileExists($ToolsPath & '\x64\SetupS.exe') Then
					FileCopy($ToolsPath & '\x64\SetupS.exe', $TempDir & '\SetupS_x64.exe', 9)
				EndIf
				If $7Zip Or $AddonInstaller Or $AddToHosts Or $ProcessKill Or $WaitForIt Or $Startmenus Or $FaderModules Or $FontReg Or $DefaultFaders Then FileCopy($ToolsPath & '\Tools.ico', $TempDir & '\Tools.ico', 9)
				If $7Zip Then
					FileCopy($ToolsPath & '\_x86\7z.exe', $TempDir & '\_x86\7z.exe', 9)
					FileCopy($ToolsPath & '\_x86\7z.dll', $TempDir & '\_x86\7z.dll', 9)
					FileCopy($ToolsPath & '\_x64\7z.exe', $TempDir & '\_x64\7z.exe', 9)
					FileCopy($ToolsPath & '\_x64\7z.dll', $TempDir & '\_x64\7z.dll', 9)
				EndIf
				If $AddonInstaller Then
					FileCopy($ToolsPath & '\_x86\AddonInstaller.exe', $TempDir & '\_x86\AddonInstaller.exe', 9)
					FileCopy($ToolsPath & '\_x64\AddonInstaller.exe', $TempDir & '\_x64\AddonInstaller.exe', 9)
				EndIf
				If $AddToHosts Then
					FileCopy($ToolsPath & '\_x86\AddToHosts.exe', $TempDir & '\_x86\AddToHosts.exe', 9)
					FileCopy($ToolsPath & '\_x64\AddToHosts.exe', $TempDir & '\_x64\AddToHosts.exe', 9)
				EndIf
				If $ProcessKill Then
					FileCopy($ToolsPath & '\_x86\ProcessKill.exe', $TempDir & '\_x86\ProcessKill.exe', 9)
					FileCopy($ToolsPath & '\_x64\ProcessKill.exe', $TempDir & '\_x64\ProcessKill.exe', 9)
				EndIf
				If $WaitForIt Then
					FileCopy($ToolsPath & '\_x86\WaitForIt.exe', $TempDir & '\_x86\WaitForIt.exe', 9)
					FileCopy($ToolsPath & '\_x64\WaitForIt.exe', $TempDir & '\_x64\WaitForIt.exe', 9)
				EndIf
				If $Startmenus Then NeoDirCopy($ToolsPath & '\Menus', $TempDir & '\Menus')
				If $FaderModules Then NeoDirCopy($ToolsPath & '\FaderModules', $TempDir & '\FaderModules')
				If $FontReg Then
					FileCopy($ToolsPath & '\_x86\FontReg.exe', $TempDir & '\_x86\FontReg.exe', 9)
					FileCopy($ToolsPath & '\_x64\FontReg.exe', $TempDir & '\_x64\FontReg.exe', 9)
				EndIf
				If $DefaultFaders Then
					NeoDirCopy($ToolsPath & '\Default\Faders', $TempDir & '\Default\Faders')
				EndIf
				FileChangeDir($TempDir)
				_7zRead('7z', ' a "' & $Archive_FileName & '.7z' & '"  -ms=on -mx=9 -m0=lzma2', 0, '', $subtext)
			Else
				FileChangeDir(NoBackslash($Archive_Drive & $Archive_Dir))
				FileCopy($Archive_FileName & $Archive_Ext, $TempDir & '\' & $Archive_FileName & '.7z', 9)
				FileCopy($ToolsPath & '\SetupS.exe', $TempDir & '\append\SetupS.exe', 9)
				FileCopy($ToolsPath & '\SetupS_x64.exe', $TempDir & '\append\SetupS_x64.exe', 9)
				If $7Zip Then
					FileCopy($ToolsPath & '\Tools.ico', $TempDir & '\append\Tools.ico', 9)
					FileCopy($ToolsPath & '\_x86\7z.exe', $TempDir & '\append\_x86\7z.exe', 9)
					FileCopy($ToolsPath & '\_x86\7z.dll', $TempDir & '\append\_x86\7z.dll', 9)
					FileCopy($ToolsPath & '\_x64\7z.exe', $TempDir & '\append\_x64\7z.exe', 9)
					FileCopy($ToolsPath & '\_x64\7z.dll', $TempDir & '\append\_x64\7z.dll', 9)
				EndIf
				FileChangeDir($TempDir)
				$test = $CLIprefix & '7z a "' & $Archive_FileName & '.7z' & '" .\append\* -ms=on -mx=9 -m0=lzma2'
				RunWait($test, $TempDir, @SW_SHOW)
			EndIf
		Else
		EndIf
		WriteConfigSFX(@ScriptDir & '\sfx\Config.txt')
		$test = $CLIprefix & 'copy /b "' & @ScriptDir & '\sfx\7zSD.sfx" + "' & @ScriptDir & '\sfx\Config.txt" + "' & $Archive_FileName & '.7z' & '" "' & $Archive_Drive & $Archive_Dir & $Archive_FileName & '.exe" /y >nul:'
		RunWait($test, $TempDir, @SW_HIDE)
		FileChangeDir($CurrentDir)
		frm_MakeSFXClose()
	EndIf
EndFunc

Func CheckAvailable()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|CheckAvailable()' & @CRLF)
	If FileExists($ToolsPath & '\SetupS.exe') Then
		If FileExists($ToolsPath & '\SetupS_x64.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		EndIf
	ElseIf FileExists($ToolsPath & '\_x86\SetupS.exe') Then
		If FileExists($ToolsPath & '\_x64\SetupS.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		EndIf
	Else
		GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
	EndIf
	If $7Zip Then
		If FileExists($ToolsPath & '\_x86\7z.exe') And FileExists($ToolsPath & '\_x64\7z.exe') And FileExists($ToolsPath & '\_x86\7z.dll') And FileExists($ToolsPath & '\_x64\7z.dll') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $AddonInstaller Then
		If FileExists($ToolsPath & '\_x86\AddonInstaller.exe') And FileExists($ToolsPath & '\_x64\AddonInstaller.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $AddToHosts Then
		If FileExists($ToolsPath & '\_x86\AddToHosts.exe') And FileExists($ToolsPath & '\_x64\AddToHosts.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $ProcessKill Then
		If FileExists($ToolsPath & '\_x86\ProcessKill.exe') And FileExists($ToolsPath & '\_x64\ProcessKill.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $WaitForIt Then
		If FileExists($ToolsPath & '\_x86\WaitForIt.exe') And FileExists($ToolsPath & '\_x64\WaitForIt.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $Startmenus Then
		If FileExists($ToolsPath & '\Menus') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $FaderModules Then
		If FileExists($ToolsPath & '\FaderModules') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $FontReg Then
		If FileExists($ToolsPath & '\_x86\FontReg.exe') And FileExists($ToolsPath & '\_x64\FontReg.exe') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
	If $DefaultFaders Then
		If FileExists($ToolsPath & '\Default\Faders') Then
			GUICtrlSetState($Button_MakeSFX, $GUI_ENABLE)
		Else
			GUICtrlSetState($Button_MakeSFX, $GUI_DISABLE)
		EndIf
	EndIf
EndFunc

Func Checkbox_7zipClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_7zipClick()' & @CRLF)
	$7Zip = Not $7Zip
	If $7Zip Then
		GUICtrlSetState($Checkbox_7zip, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_7zip, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_AddonInstallerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AddonInstallerClick()' & @CRLF)
	$AddonInstaller = Not $AddonInstaller
	If $AddonInstaller Then
		GUICtrlSetState($Checkbox_AddonInstaller, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_AddonInstaller, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_AddToHostsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AddToHostsClick()' & @CRLF)
	$AddToHosts = Not $AddToHosts
	If $AddToHosts Then
		GUICtrlSetState($Checkbox_AddToHosts, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_AddToHosts, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_AllToolsClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_AllToolsClick()' & @CRLF)
	$7Zip = Not $7Zip
	If $7Zip Then
		GUICtrlSetState($Checkbox_7zip, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_7zip, $GUI_UNCHECKED)
	EndIf
	$AddonInstaller = Not $AddonInstaller
	If $AddonInstaller Then
		GUICtrlSetState($Checkbox_AddonInstaller, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_AddonInstaller, $GUI_UNCHECKED)
	EndIf
	$AddToHosts = Not $AddToHosts
	If $AddToHosts Then
		GUICtrlSetState($Checkbox_AddToHosts, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_AddToHosts, $GUI_UNCHECKED)
	EndIf
	$DefaultFaders = Not $DefaultFaders
	If $DefaultFaders Then
		GUICtrlSetState($Checkbox_DefaultFaders, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_DefaultFaders, $GUI_UNCHECKED)
	EndIf
	$FaderModules = Not $FaderModules
	If $FaderModules Then
		GUICtrlSetState($Checkbox_FaderModules, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FaderModules, $GUI_UNCHECKED)
	EndIf
	$FontReg = Not $FontReg
	If $FontReg Then
		GUICtrlSetState($Checkbox_FontReg, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FontReg, $GUI_UNCHECKED)
	EndIf
	$ProcessKill = Not $ProcessKill
	If $ProcessKill Then
		GUICtrlSetState($Checkbox_ProcessKill, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ProcessKill, $GUI_UNCHECKED)
	EndIf
	$Startmenus = Not $Startmenus
	If $Startmenus Then
		GUICtrlSetState($Checkbox_Startmenus, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_Startmenus, $GUI_UNCHECKED)
	EndIf
	$WaitForIt = Not $WaitForIt
	If $WaitForIt Then
		GUICtrlSetState($Checkbox_WaitForIt, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_WaitForIt, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_DefaultFadersClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_DefaultFadersClick()' & @CRLF)
	$DefaultFaders = Not $DefaultFaders
	If $DefaultFaders Then
		GUICtrlSetState($Checkbox_DefaultFaders, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_DefaultFaders, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc
Func Checkbox_FaderModulesClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FaderModulesClick()' & @CRLF)
	$FaderModules = Not $FaderModules
	If $FaderModules Then
		GUICtrlSetState($Checkbox_FaderModules, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FaderModules, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_FaderOnTopClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FaderOnTopClick()' & @CRLF)
	$SFXFaderOnTop = Not $SFXFaderOnTop
	If $SFXFaderOnTop Then
		GUICtrlSetState($Checkbox_FaderOnTop, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FaderOnTop, $GUI_UNCHECKED)
	EndIf
EndFunc
Func Checkbox_FontRegClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_FontRegClick()' & @CRLF)
	$FontReg = Not $FontReg
	If $FontReg Then
		GUICtrlSetState($Checkbox_FontReg, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_FontReg, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_ProcessKillClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_ProcessKillClick()' & @CRLF)
	$ProcessKill = Not $ProcessKill
	If $ProcessKill Then
		GUICtrlSetState($Checkbox_ProcessKill, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ProcessKill, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_SplashOnTopClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_SplashOnTopClick()' & @CRLF)
	$SFXSplashOnTop = Not $SFXSplashOnTop
	If $SFXSplashOnTop Then
		GUICtrlSetState($Checkbox_SplashOnTop, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_SplashOnTop, $GUI_UNCHECKED)
	EndIf
EndFunc

Func Checkbox_StartmenusClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_StartmenusClick()' & @CRLF)
	$Startmenus = Not $Startmenus
	If $Startmenus Then
		GUICtrlSetState($Checkbox_Startmenus, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_Startmenus, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func Checkbox_WaitForItClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Checkbox_WaitForItClick()' & @CRLF)
	$WaitForIt = Not $WaitForIt
	If $WaitForIt Then
		GUICtrlSetState($Checkbox_WaitForIt, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_WaitForIt, $GUI_UNCHECKED)
	EndIf
	CheckAvailable()
EndFunc

Func frm_MakeSFXClose()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|frm_MakeSFXClose()' & @CRLF)
	SaveSettings()
	Cleanup()
	Exit
EndFunc

Func frm_MakeSFXMaximize()
EndFunc
Func frm_MakeSFXMinimize()
EndFunc
Func frm_MakeSFXRestore()
EndFunc
Func Input_FaderLocationChange()
EndFunc
Func Input_FaderSpeedChange()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Input_FaderSpeedChange()' & @CRLF)
	If GUICtrlRead($Input_FaderSpeed) <> $SFXFaderSpeed Then $SFXFaderSpeed = GUICtrlRead($Input_FaderSpeed)
EndFunc
Func Input_FilenameChange()
EndFunc
Func Label_ArchiveClick()
EndFunc

Func Label_CheckForUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CheckForUpdateClick()' & @CRLF)
	UpdateMe('update.ini', @ScriptDir, True, $UseGUI)
EndFunc

Func Label_FaderLocationClick()
EndFunc
Func Label_FaderSpeedClick()
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

Func Radio_AppendClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_AppendClick()' & @CRLF)
	$Recompress = False
	$Append = True
	GUICtrlSetState($Radio_Append, $GUI_CHECKED)
EndFunc

Func Radio_FadertainerClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_FadertainerClick()' & @CRLF)
	$SFXFadertainer = Not $SFXFadertainer
	If $SFXFadertainer Then
		GUICtrlSetState($Radio_Fadertainer, $GUI_CHECKED)
		GUICtrlSetState($Checkbox_FaderOnTop, $GUI_ENABLE)
		GUICtrlSetState($Label_FaderSpeed, $GUI_ENABLE)
		GUICtrlSetState($Input_FaderSpeed, $GUI_ENABLE)
		GUICtrlSetState($Label_FaderLocation, $GUI_ENABLE)
		GUICtrlSetState($Input_FaderLocation, $GUI_ENABLE)
	Else
		GUICtrlSetState($Radio_Fadertainer, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_FaderOnTop, $GUI_DISABLE)
		GUICtrlSetState($Label_FaderSpeed, $GUI_DISABLE)
		GUICtrlSetState($Input_FaderSpeed, $GUI_DISABLE)
		GUICtrlSetState($Label_FaderLocation, $GUI_DISABLE)
		GUICtrlSetState($Input_FaderLocation, $GUI_DISABLE)
	EndIf
EndFunc

Func Radio_MuteClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_MuteClick()' & @CRLF)
	$SFXVerbose = False
	$SFXMute = True
	$SFXTrayOnly = False
	$SFXSplashOnly = False
	GUICtrlSetState($Radio_Mute, $GUI_CHECKED)
	GUICtrlSetState($Checkbox_SplashOnTop, $GUI_DISABLE)
EndFunc

Func Radio_RecompressClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_RecompressClick()' & @CRLF)
	$Recompress = True
	$Append = False
	GUICtrlSetState($Radio_Recompress, $GUI_CHECKED)
EndFunc

Func Radio_SplashonlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_SplashonlyClick()' & @CRLF)
	$SFXVerbose = False
	$SFXMute = False
	$SFXTrayOnly = False
	$SFXSplashOnly = True
	GUICtrlSetState($Radio_Splashonly, $GUI_CHECKED)
	GUICtrlSetState($Checkbox_SplashOnTop, $GUI_ENABLE)
EndFunc

Func Radio_TrayonlyClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_TrayonlyClick()' & @CRLF)
	$SFXVerbose = False
	$SFXMute = False
	$SFXTrayOnly = True
	$SFXSplashOnly = False
	GUICtrlSetState($Radio_Trayonly, $GUI_CHECKED)
	GUICtrlSetState($Checkbox_SplashOnTop, $GUI_DISABLE)
EndFunc

Func Radio_VerboseClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Radio_VerboseClick()' & @CRLF)
	$SFXVerbose = True
	$SFXMute = False
	$SFXTrayOnly = False
	$SFXSplashOnly = False
	GUICtrlSetState($Radio_Verbose, $GUI_CHECKED)
	GUICtrlSetState($Checkbox_SplashOnTop, $GUI_ENABLE)
EndFunc
#endregion
;~
