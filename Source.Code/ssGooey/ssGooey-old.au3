#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ppApp.ico
#AutoIt3Wrapper_Outfile=ssGooey.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=SetupS Gooey.
#AutoIt3Wrapper_Res_Fileversion=15.12.21.0
#AutoIt3Wrapper_Res_LegalCopyright=© 2015 Vergitek Solutions
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_Field=Release Date|2015-12-21
#AutoIt3Wrapper_Res_Field=ssTek Forum|http://sstek.vergitek.com
#AutoIt3Wrapper_Res_Field=ssTek Development|http://www.lastos.org
#AutoIt3Wrapper_Res_Field=LastOS Team|http://dl.bintray.com/sstek
#AutoIt3Wrapper_Au3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#Tidy_Parameters=/pr=1 /uv=3 /tc=0 /sf /reel /refc /rerc /kv=100
#AutoIt3Wrapper_UseX64=n
#endregion

#cs ##################################################################################
	
	ssGooey v15.12.21.0
	Copyright © 2015, Vergitek Solutions
	All rights reserved.
	
	ssGooey is open-source software: you can redistribute it and/or
	modify it under the terms of the GNU General Public License as published
	by the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version of the License.
	
	DISCLAIMER:
	ssGooey is distributed in the hope that it will be useful, but
	is provided by Vergitek Solutions "AS IS", without warranty of any kind,
	express or implied, including but not limited to the warranties of
	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE and NON-INFRINGEMENT.
	In no event shall the authors or Vergitek Solutions be liable for any direct,
	indirect, incidental, special, exemplary, or consequential damages
	(including, but not limited to, procurement of substitute goods or
	services; loss of use, data, or profits; or business interruption)
	however caused and on any theory of liability, whether in an action of
	contract, strict liability, or tort (including negligence or otherwise)
	arising from, out of or in connection with the software or the use or
	other dealings in the software, even if advised of the possibility of
	such damage.
	
	See the GNU General Public License for more details. You should have received a
	copy of the GNU General Public License along with ssGooey. If not,
	see <http://www.gnu.org/licenses/>.
	
#ce ##################################################################################
#cs ##################################################################################
	
	Script Function:
	
	
#ce ##################################################################################
#include <..\SetupS.Core.au3>

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then

	$CLIparameters[0] += 1
	ReDim $CLIparameters[$CLIparameters[0] + 1]
	$CLIparameters[$CLIparameters[0]] = '--Installer=Yes'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--Injector=Yes'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--Launcher=Yes'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--AllDrives' ;'--CurrentDriveOnly' ;'--AllDrives'

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--ppGamesOnly=Yes' ;'--ppAppsOnly' ;'--ppGamesOnly' ;'--NossApps' ; Switches

;~ 	$CLIparameters[0] += 1
;~ 	ReDim $CLIparameters[$CLIparameters[0] + 1]
;~ 	$CLIparameters[$CLIparameters[0]] = '--Help' ; '?' ;Help
;~ 	Opt('TrayIconDebug', 1)

	Opt('TrayIconDebug', 1)
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------Local $App_Title_ExtraApp, $App_BuildType_ExtraApp, $App_Version_ExtraApp, $App_InstallPath_ExtraApp
#include <GUIConstantsEx.au3>
#include <GUIListBox.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <TreeViewConstants.au3>
#include <GuiTreeView.au3>
#include <EditConstants.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <TabConstants.au3>
#include <..\UDFs\icons.au3>

Local $App_Title_ExtraApp, $App_BuildType_ExtraApp, $App_Version_ExtraApp, $App_InstallPath_ExtraApp
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch
Local $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssExtraApp = CheckINI($ThisAppFilename & '.ini')
If $MakeDefaultINI Then SetExtraAppDefaults($ssExtraApp)
Global $Timer1, $ItemsCount = 0, $ssGooeyQuit
Local $Drive, $TargetISO, $TemplateISO, $CopyTemplateISO, $VolumeData, $Source, $FirstScan = True, $DoNotPopulate = False
Local $InstallerMode = GetParameter('Installer'), $LauncherMode = GetParameter('Launcher'), $ISOMakerMode = GetParameter('ISOMaker') Or GetParameter('Injector')
Local $OnlineLibrary, $OnlineLibraryLink ;= 'http://sstek.vergitek.com/library'
Local $CheckOnlineLibrary, $CheckForLocal
Local $OfflineLibraryFolder = $ssTekResources & '\oll'
Global $HideInstalled = False, $ScanAllDrives = False, $CurrentDriveOnly = False, $OSFriendly = True, $ArchFriendly = True
Global $ssAppsOnly = False, $ssAppsExclude = False, $ppAppsOnly = False, $ppAppsExclude = False, $ppGamesOnly = False, $ppGamesExclude = False
Local $SplashTemp, $CurrentDrive, $ItemsList[1][1], $SelectionChanged = False ;, $Drives[1], $DrivesCount = 0
Dim $szDrive, $szDir, $szFName, $szExt
Local $MyName = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt), $SetupS_Args
Local $Intro, $TextWidth, $Category[1][3], $RestartMe = False
Local $hOrigCur = CursorWait(), $CLIparametersCount = $CLIparameters[0]
If $App_File = '' Then ;obtain update info
	_AppReset()
	$App_File = _AppRead(@ScriptDir, False, True)
	$App_Version_ExtraApp = $App_Version
	If StringInStr($App_Version_ExtraApp, '15.12.21.0') Then $App_Version_ExtraApp = 'v' & $SetupS_CoreVer
	While StringInStr($App_Version_ExtraApp, 'v')
		$App_Version_ExtraApp = StringReplace($App_Version_ExtraApp, 'v', '')
	WEnd
	$App_InstallPath_ExtraApp = ConvertFromVars($App_InstallPath)
	$App_Title_ExtraApp = $App_Title
	If StringInStr($App_Title_ExtraApp, 'ssGooey') Then $App_Title_ExtraApp = $ThisAppFilename
	$App_BuildType_ExtraApp = $App_BuildType
EndIf
$HelpFile = '';FindMe('ssTek.chm')
$ssCleaner = 0

;----------------------------------------------------- Get Parameters ------------------------------------------------------------
GetExtraAppOptions($ssExtraApp)
GetReportingMode($ssExtraApp)
If $OS_NT5 Or Not $OS_NT5 Then
	$SplashTips = False
	$BalloonTips = True
Else
	$SplashTips = True
	$BalloonTips = False
EndIf
$SplashOnTop = True
If $BalloonTips Then
	RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '2')
	Opt('TrayIconHide', 0) ;Show tray icon
	Opt('TrayAutoPause', 0) ;Turn off autopause
	TrayTip($ThisAppTitle, 'Scanning...', 300, 16)
Else
	;RegWrite('HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced', 'EnableBalloonTips', 'REG_DWORD', '0')
	Opt('TrayIconHide', 1) ;Hide tray icon
EndIf
If $SplashTips Then SplashThis($ThisAppFilename, 'Scanning...');SplashTextOn($ThisAppTitle, 'Initializing...', -1, 42, -1, -1, 4, 'Arial', 10);
GetFaderMode($ssExtraApp)
If GetParameter('Help') Or GetParameter('?') Or GetParameter('About') Then EndGame('Help requested', 'See displayed', True)

;------------------------------------------------------ Get System Info ----------------------------------------------------------
GetppDrives()
If $ToolsPath = '' Then GetToolsFolder() ;$ToolsPath ;EnvGet('Path')
GetMenuStyle()
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn), $OnlineLibraryFolder = $RepoFolder

If $AutoUpdate And Not $NoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)
Global $ppAppsDriveChoices = StringUpper($ppAppsDrive)
Global $ppGamesDriveChoices = StringUpper($ppGamesDrive)
Global $CDDriveChoices = StringUpper($CDDrive)
Local $AllDrivesList = DriveGetDrive('ALL'), $FileList
Local $ThisDrive = StringLeft(@ScriptDir, 2)
If Not @error Then
	For $i = 1 To $AllDrivesList[0]
		If ($AllDrivesList[$i] <> $ppAppsDrive) Then $ppAppsDriveChoices = $ppAppsDriveChoices & '|' & StringUpper($AllDrivesList[$i])
		If ($AllDrivesList[$i] <> $ppGamesDrive) Then $ppGamesDriveChoices = $ppGamesDriveChoices & '|' & StringUpper($AllDrivesList[$i])
		If ($AllDrivesList[$i] <> $CDDrive) Then $CDDriveChoices = $CDDriveChoices & '|' & StringUpper($AllDrivesList[$i])
	Next
EndIf
Global $MenuStyleChoices = 'Standard (Uninstall Advanced StartMenu)'
For $i = 1 To $MenuStyles[0][0]
	;MsgBox(4096, '', 'Key: ' & $MenuStyles[$i][0] & @CRLF & 'Value: ' & $MenuStyles[$i][1])
	$MenuStyleChoices = $MenuStyleChoices & '|' & $MenuStyles[$i][1]
Next

;------------------------------------------------------ Mode? ----------------------------------------------------------
ModeScan()
Select
	Case $LauncherMode
		$ISOMakerMode = False
		$InstallerMode = False
	Case $ISOMakerMode
		$LauncherMode = False
		$InstallerMode = False
	Case $InstallerMode
		$LauncherMode = False
		$ISOMakerMode = False
EndSelect

#cs ##################################################################################
	# Don't change anything between Koda Gui Section Regions!
	# It will be over-written by any changes made to the .kxf file.
	# Use Ctrl+U from the Form=[see below] to update and save both files.
#ce ##################################################################################

#region ### START Koda GUI section ### Form=ssGooey.kxf
Global $Form_ssGooey = GUICreate("ssGooey", 796, 574, -1, -1, $WS_POPUP)
GUISetBkColor(0x000000)
Global $Label_Items = GUICtrlCreateLabel("Items", 143, 482, 41, 20)
GUICtrlSetFont($Label_Items, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor($Label_Items, 0xFFFFFF)
Global $Button_Start = GUICtrlCreateButton("Please wait.", 274, 524, 75, 25, $BS_DEFPUSHBUTTON)
Global $Label_Item = GUICtrlCreateLabel("About", 565, 0, 52, 24)
GUICtrlSetFont($Label_Item, 12, 800, 0, "MS Sans Serif")
GUICtrlSetColor($Label_Item, 0xFFFFFF)
Global $Button_Options = GUICtrlCreateButton("Options", 161, 524, 75, 25)
Global $Group_Selections = GUICtrlCreateGroup("Mark", 6, 500, 65, 69, BitOR($GUI_SS_DEFAULT_GROUP, $WS_CLIPSIBLINGS))
GUICtrlSetColor($Group_Selections, 0xFFFFFF)
Global $Checkbox_AllSelect = GUICtrlCreateCheckbox("All", 14, 515, 50, 17)
Global $Checkbox_NoneSelect = GUICtrlCreateCheckbox("None", 14, 531, 50, 17)
Global $Checkbox_InvertSelect = GUICtrlCreateCheckbox("Invert", 14, 547, 50, 17)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Item = GUICtrlCreateGroup("", 385, 17, 406, 550)
GUICtrlSetColor($Group_Item, 0xFFFFFF)
Global $Pic_ScreenShot = GUICtrlCreatePic("", 388, 27, 400, 300)
Global $Edit_Item = GUICtrlCreateEdit("", 388, 329, 400, 234, BitOR($ES_WANTRETURN, $WS_VSCROLL), 0)
GUICtrlSetColor($Edit_Item, 0x000000)
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Items = GUICtrlCreateGroup("", 3, 17, 380, 460)
GUICtrlSetColor($Group_Items, 0xFFFFFF)
Global $TreeView_Category = GUICtrlCreateTreeView(6, 27, 119, 447, BitOR($TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES))
Global $TreeView_Items = GUICtrlCreateTreeView(126, 27, 255, 447, BitOR($TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES))
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Label_CategoryList = GUICtrlCreateLabel("Categories", 21, 0, 91, 24)
GUICtrlSetFont($Label_CategoryList, 12, 800, 0, "MS Sans Serif")
GUICtrlSetColor($Label_CategoryList, 0xFFFFFF)
Global $Label_ItemsList = GUICtrlCreateLabel("Items", 228, 0, 49, 24)
GUICtrlSetFont($Label_ItemsList, 12, 800, 0, "MS Sans Serif")
GUICtrlSetColor($Label_ItemsList, 0xFFFFFF)
Global $Button_Rescan = GUICtrlCreateButton("Re-scan", 79, 524, 75, 25)
Global $Button_Close = GUICtrlCreateButton("X", 775, 4, 17, 17)
GUICtrlSetFont($Button_Close, 10, 800, 0, "MS Sans Serif")
GUICtrlSetColor($Button_Close, 0xFF0000)
#endregion ### END Koda GUI section ###

;------------------------------------------------------ Detail ssGooey form ----------------------------------------------
ControlSetText('', '', $Form_ssGooey, $ThisAppTitle)
GUISetBkColor(0x202020)
Local $aForm_ssGooey = ControlGetPos('', '', $Form_ssGooey)
Global $Form_ssGooey_Width = $aForm_ssGooey[2]
Global $Form_ssGooey_Height = $aForm_ssGooey[3]

;------------------------------------------------------
;For some reason we can only do this once with TreeView, so make it count...
_GUICtrlTreeView_Destroy($TreeView_Items);GUICtrlDelete ?
If $LauncherMode Then
	$TreeView_Items = GUICtrlCreateTreeView(126, 27, 255, 430, BitOR($TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS))
Else
	$TreeView_Items = GUICtrlCreateTreeView(126, 27, 255, 430, BitOR($TVS_DISABLEDRAGDROP, $TVS_SHOWSELALWAYS, $TVS_CHECKBOXES))
EndIf
GUICtrlSetBkColor($TreeView_Items, 0x202020)
;------------------------------------------------------
GUICtrlSetColor($Button_Start, 0xFFFFFF)
GUICtrlSetBkColor($Button_Start, 0x202020)
GUICtrlSetColor($Button_Options, 0xFFFFFF)
GUICtrlSetBkColor($Button_Options, 0x202020)
GUICtrlSetColor($Button_Rescan, 0xFFFFFF)
GUICtrlSetBkColor($Button_Rescan, 0x202020)
GUICtrlSetBkColor($TreeView_Items, 0x202020)
GUICtrlSetBkColor($TreeView_Category, 0x202020)
GUICtrlSetColor($Checkbox_AllSelect, 0xFFFFFF)
GUICtrlSetColor($Checkbox_NoneSelect, 0xFFFFFF)
GUICtrlSetColor($Checkbox_InvertSelect, 0xFFFFFF)
GUICtrlSetColor($Edit_Item, 0xFFFFFF)
GUICtrlSetBkColor($Edit_Item, 0x202020)

UpdateItemLabel($ThisAppTitle)

#region ### START Koda GUI section ### Form=ssGooey_Options.kxf
Global $Form_ssGooey_Options = GUICreate("Settings & Options", 471, 256, -1, -1, BitOR($WS_SIZEBOX, $WS_THICKFRAME, $WS_SYSMENU, $WS_POPUP), BitOR($WS_EX_TOPMOST, $WS_EX_WINDOWEDGE))
GUISetOnEvent($GUI_EVENT_CLOSE, "Form_ssGooey_OptionsClose")
GUISetOnEvent($GUI_EVENT_MINIMIZE, "Form_ssGooey_OptionsMinimize")
GUISetOnEvent($GUI_EVENT_MAXIMIZE, "Form_ssGooey_OptionsMaximize")
GUISetOnEvent($GUI_EVENT_RESTORE, "Form_ssGooey_OptionsRestore")
Global $Button_OptionsClose = GUICtrlCreateButton("Done", 249, 224, 75, 25)
GUICtrlSetOnEvent(-1, "Button_OptionsCloseClick")
Global $Button_Load_Preset = GUICtrlCreateButton("Load Preset", 18, 224, 75, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_Load_PresetClick")
Global $Button_SavePreset = GUICtrlCreateButton("Save Preset", 108, 224, 75, 25)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_SavePresetClick")
Global $PageControl_Options = GUICtrlCreateTab(1, 1, 468, 217)
GUICtrlSetFont(-1, 8, 400, 0, "MS Sans Serif")
GUICtrlSetOnEvent(-1, "PageControl_OptionsChange")
Global $TabSheet_Filters = GUICtrlCreateTabItem("ssGooey Options")
Global $Group_Preferences = GUICtrlCreateGroup("Preferences:", 346, 30, 112, 73)
Global $Checkbox_HideScreenShot = GUICtrlCreateCheckbox("Hide Screenshot", 352, 47, 104, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Checkbox_HideScreenShotClick")
Global $Checkbox_RebootPC = GUICtrlCreateCheckbox("Reboot PC", 352, 63, 104, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Checkbox_RebootPCClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Filters = GUICtrlCreateGroup("Filters:", 10, 30, 235, 73)
Global $Checkbox_Hide_Installed = GUICtrlCreateCheckbox("Hide Installed", 111, 45, 89, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Checkbox_Hide_InstalledClick")
Global $Checkbox_OS_Friendly = GUICtrlCreateCheckbox("OS Friendly", 111, 61, 85, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Checkbox_OS_FriendlyClick")
Global $Checkbox_Arch_Friendly = GUICtrlCreateCheckbox("Architecture Friendly", 111, 77, 123, 17)
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Checkbox_Arch_FriendlyClick")
Global $Checkbox_ppGamesSelect = GUICtrlCreateCheckbox("ppGames", 18, 77, 66, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Checkbox_ppGamesSelectClick")
Global $Checkbox_ppAppsSelect = GUICtrlCreateCheckbox("ppApps", 18, 61, 66, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Checkbox_ppAppsSelectClick")
Global $Checkbox_ssAppsSelect = GUICtrlCreateCheckbox("ssApps", 18, 45, 66, 17)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetOnEvent(-1, "Checkbox_ssAppsSelectClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_ISO = GUICtrlCreateGroup("ISO", 10, 110, 283, 96)
Global $Label_TargetISO = GUICtrlCreateLabel("Target ISO:", 25, 177, 60, 17, $SS_RIGHT)
GUICtrlSetOnEvent(-1, "Label_TargetISOClick")
Global $Input_TargetISO = GUICtrlCreateInput("", 88, 174, 172, 21)
GUICtrlSetOnEvent(-1, "Input_TargetISOChange")
Global $BtnTarget = GUICtrlCreateButton("···", 265, 175, 20, 20)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
GUICtrlSetOnEvent(-1, "BtnTargetClick")
Global $Button_BrowseForTemplateISO = GUICtrlCreateButton("···", 265, 151, 20, 20)
GUICtrlSetFont(-1, 12, 800, 0, "MS Sans Serif")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetOnEvent(-1, "Button_BrowseForTemplateISOClick")
Global $Input_TemplateISO = GUICtrlCreateInput("", 88, 150, 172, 21)
GUICtrlSetOnEvent(-1, "Input_TemplateISOChange")
GUICtrlSetState(-1, $GUI_DISABLE)
Global $Checkbox_CopyTemplateISO = GUICtrlCreateCheckbox("Template:", 20, 152, 65, 17, BitOR($GUI_SS_DEFAULT_CHECKBOX, $BS_RIGHT))
GUICtrlSetOnEvent(-1, "Checkbox_CopyTemplateISOClick")
Global $Label_Volume = GUICtrlCreateLabel("Volume Label:", 15, 128, 70, 17, $SS_RIGHT)
GUICtrlSetOnEvent(-1, "Label_VolumeClick")
Global $Input_Volume = GUICtrlCreateInput("", 88, 126, 197, 21)
GUICtrlSetOnEvent(-1, "Input_VolumeChange")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group_Scan = GUICtrlCreateGroup("Scan:", 257, 30, 79, 73)
Global $Checkbox_ScanLocal = GUICtrlCreateCheckbox("Local", 263, 63, 66, 17)
GUICtrlSetOnEvent(-1, "Checkbox_ScanLocalClick")
Global $Checkbox_ScanOnline = GUICtrlCreateCheckbox("Online", 263, 47, 66, 17)
GUICtrlSetOnEvent(-1, "Checkbox_ScanOnlineClick")
Global $Checkbox_ScanAllDrives = GUICtrlCreateCheckbox("All Drives", 263, 79, 66, 17)
GUICtrlSetOnEvent(-1, "Checkbox_ScanAllDrivesClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $Group1 = GUICtrlCreateGroup("Mode:", 331, 123, 88, 73)
Global $Radio_InstallerMode = GUICtrlCreateRadio("Installer", 337, 140, 73, 17)
GUICtrlSetOnEvent(-1, "Radio_InstallerModeClick")
Global $Radio_LauncherMode = GUICtrlCreateRadio("Launcher", 337, 156, 77, 17)
GUICtrlSetOnEvent(-1, "Radio_LauncherModeClick")
Global $Radio_ISOMakerMode = GUICtrlCreateRadio("ISO Maker", 337, 172, 74, 17)
GUICtrlSetOnEvent(-1, "Radio_ISOMakerModeClick")
GUICtrlCreateGroup("", -99, -99, 1, 1)
Global $TabSheet_About = GUICtrlCreateTabItem("About")
GUICtrlCreateTabItem("")
Global $Label_CheckForUpdate = GUICtrlCreateLabel("Check for update...", 348, 230, 114, 17, $SS_RIGHT)
GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
GUICtrlSetColor(-1, 0x0000FF)
GUICtrlSetOnEvent(-1, "Label_CheckForUpdateClick")
#endregion ### END Koda GUI section ###

DetailOptions()

;------------------------------------------------------ Begin --------------------------------------------------------------------
FileInstall(".\bin\mkisofs.exe", @TempDir & "\mkisofs.exe")
FileInstall(".\bin\cygwin1.dll", @TempDir & "\cygwin1.dll")
FileInstall(".\bin\7z.exe", @TempDir & "\7z.exe")
FileInstall(".\bin\7z.dll", @TempDir & "\7z.dll")

$Category[0][0] = 1
ReDim $Category[UBound($Category) + 1][3] ;text, ID
$Category[$Category[0][0]][0] = 'All'
$Category[$Category[0][0]][1] = GUICtrlCreateTreeViewItem($Category[1][0], $TreeView_Category)
$Category[$Category[0][0]][2] = True
GUICtrlSetColor(-1, 0xffffff) ;White
GUICtrlSetState(-1, $GUI_CHECKED)

;Timer($Timer1)
UberScan()
;Timer($Timer1, 'Post-processing done!', True)
FileChangeDir(@ScriptDir)

; Loop until user exits
Local $item, $text, $msg, $state, $found, $i, $j, $ArchiveMode, $FileList
While 1
	$found = False
	$msg = GUIGetMsg()
	If $msg <> 0 Then
		Select
			Case $msg = $GUI_EVENT_CLOSE Or $ssGooeyQuit
				ExitLoop
			Case $msg = $Category[1][1]
				$found = True
				If $Category[1][2] Then
					GUICtrlSetState($Category[1][1], $GUI_UNCHECKED)
				Else
					For $i = 2 To $Category[0][0]
						GUICtrlSetState($Category[$i][1], $GUI_UNCHECKED)
						$Category[$i][2] = False
					Next
					GUICtrlSetState($Category[1][1], $GUI_CHECKED)
				EndIf
				$Category[1][2] = Not $Category[1][2]
				_PinsClear()
				If $Category[1][2] Then _PinsSetAll()
			Case $msg = $Checkbox_ssAppsSelect Or $msg = $Checkbox_ppAppsSelect Or $msg = $Checkbox_ppGamesSelect Or $msg = $Checkbox_Hide_Installed Or $msg = $Checkbox_OS_Friendly Or $msg = $Checkbox_Arch_Friendly
				$found = True
				SetGooeyOptions($ssExtraApp)
				_PinsClear()
				$SelectionChanged = True
				$DoNotPopulate = True
;~ 				If $Category[1][2] Then
;~ 					_PinsSetAll()
;~ 				Else
;~ 					_PinsSetByCategory()
;~ 				EndIf
			Case $msg = $Checkbox_ScanOnline Or $msg = $Checkbox_ScanLocal Or $msg = $Checkbox_ScanAllDrives Or $msg = $Button_Rescan
				$found = True
				SetGooeyOptions($ssExtraApp)
				UberScan()
			Case $msg = $Button_Options
				$found = True
				GUISetState(@SW_SHOW, $Form_ssGooey_Options)
				GUICtrlSetState($TabSheet_Filters, $GUI_SHOW)
			Case $msg = $Button_OptionsClose
				$found = True
				Button_OptionsCloseClick()
			Case $msg = $Button_Start
				Start()
				_PinsClear()
				$SelectionChanged = True
				$FirstScan = True
;~ 				If $Category[1][2] Then
;~ 					_PinsSetAll()
;~ 				Else
;~ 					_PinsSetByCategory()
;~ 				EndIf
			Case $msg = $Checkbox_AllSelect
				GUICtrlSetState($Checkbox_AllSelect, $GUI_CHECKED)
				GUICtrlSetState($Checkbox_NoneSelect, $GUI_UNCHECKED)
				GUICtrlSetState($Checkbox_InvertSelect, $GUI_UNCHECKED)
				For $i = 1 To $ItemsList[0][0]
					GUICtrlSetState($ItemsList[$i][12], $GUI_CHECKED)
				Next
				UpdateItemsCount()
				GUICtrlSetState($Checkbox_AllSelect, $GUI_UNCHECKED)
			Case $msg = $Checkbox_NoneSelect
				GUICtrlSetState($Checkbox_AllSelect, $GUI_UNCHECKED)
				GUICtrlSetState($Checkbox_NoneSelect, $GUI_CHECKED)
				GUICtrlSetState($Checkbox_InvertSelect, $GUI_UNCHECKED)
				For $i = 1 To $ItemsList[0][0]
					GUICtrlSetState($ItemsList[$i][12], $GUI_UNCHECKED)
				Next
				UpdateItemsCount()
				GUICtrlSetState($Checkbox_NoneSelect, $GUI_UNCHECKED)
			Case $msg = $Checkbox_InvertSelect
				GUICtrlSetState($Checkbox_AllSelect, $GUI_UNCHECKED)
				GUICtrlSetState($Checkbox_NoneSelect, $GUI_UNCHECKED)
				GUICtrlSetState($Checkbox_InvertSelect, $GUI_CHECKED)
				For $i = 1 To $ItemsList[0][0]
					Switch GUICtrlRead($ItemsList[$i][12], 0)
						Case 1, 256, 257
							GUICtrlSetState($ItemsList[$i][12], $GUI_UNCHECKED)
						Case Else
							GUICtrlSetState($ItemsList[$i][12], $GUI_CHECKED)
					EndSwitch
				Next
				UpdateItemsCount()
				GUICtrlSetState($Checkbox_InvertSelect, $GUI_UNCHECKED)
			Case $msg = $Label_CheckForUpdate
				GUISetState(@SW_HIDE, $Form_ssGooey_Options)
				Label_CheckForUpdateClick()
			Case $msg = $Button_Close
				ExitLoop
		EndSelect
		If Not $found Then
			For $i = 2 To $Category[0][0]
				If $msg = $Category[$i][1] Then
					$found = True
					If $Category[$i][2] Then
						GUICtrlSetState($Category[$i][1], $GUI_UNCHECKED)
					Else
						GUICtrlSetState($Category[$i][1], $GUI_CHECKED)
						GUICtrlSetState($Category[1][1], $GUI_UNCHECKED)
						$Category[1][2] = False
					EndIf
					$Category[$i][2] = Not $Category[$i][2]
					_PinsClear()
					_PinsSetByCategory()
					ExitLoop
				EndIf
			Next
		EndIf
		If Not $found Then
			For $i = 1 To $ItemsList[0][0]
				If $msg = $ItemsList[$i][12] Then
					_AppReset()
					$ArchiveMode = ''
					If StringInStr(FileGetAttrib($ItemsList[$i][1]), 'D') = 0 Then ; a file
						Switch StringRight($ItemsList[$i][1], 4)
							Case '.apz', '.pgz'
								If $ArchiveMode = '' And $ToolsPath <> '' Then
									If GetFileFromArchive('*' & StringLeft(StringLower(StringRight($ItemsList[$i][1], 4)), 2) & 'p' & StringMid(StringLower(StringRight($ItemsList[$i][1], 4)), 3, 1), $ItemsList[$i][1]) Then
										GetFileFromArchive('*.jpg', $ItemsList[$i][1])
										;GetFileFromArchive('*.ico', $PathIn)
										;GetFileFromArchive('*.png', $PathIn)
										$ArchiveMode = $ItemsList[$i][1]
										$ItemsList[$i][1] = $TempDir
									EndIf
								EndIf
						EndSwitch
					EndIf
					Select
						Case FileExists($ItemsList[$i][1] & '\' & GetAppTypeBase($ItemsList[$i][8]) & '.jpg')
							_SetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & GetAppTypeBase($ItemsList[$i][8]) & '.jpg')
;~ 							GUICtrlSetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & GetAppTypeBase($ItemsList[$i][8]) & '.jpg')
;~ 							ResizePic($ItemsList[$i][1] & '\' & GetAppTypeBase($ItemsList[$i][8]) & '.jpg', $Pic_ScreenShot)
						Case FileExists($ItemsList[$i][1] & '\' & GetFilename($ItemsList[$i][1]) & '.jpg')
							_SetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & GetFilename($ItemsList[$i][1]) & '.jpg')
;~ 							GUICtrlSetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & GetFilename($ItemsList[$i][1]) & '.jpg')
;~ 							ResizePic($ItemsList[$i][1] & '\' & GetFilename($ItemsList[$i][1]) & '.jpg', $Pic_ScreenShot)
						Case Else
							$FileList = _FileListToArray($ItemsList[$i][1], '*.jpg', 1) ; Return files only
							If @error = 0 Then
								_SetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & $FileList[1])
;~ 								GUICtrlSetImage($Pic_ScreenShot, $ItemsList[$i][1] & '\' & $FileList[1])
;~ 								ResizePic($ItemsList[$i][1] & '\' & $FileList[1], $Pic_ScreenShot)
							Else
								BlankScreenShot()
							EndIf
					EndSelect
					$App_File = _AppRead($ItemsList[$i][1], True, False)
					If $ArchiveMode <> '' Then
						DirRemove($ItemsList[$i][1], 1)
						$ItemsList[$i][1] = $ArchiveMode
					EndIf
					$ItemsList[$i][11] = ''
					For $j = 1 To $App_Description[0]
						If $ItemsList[$i][11] <> '' Then $ItemsList[$i][11] = $ItemsList[$i][11] & @CRLF
						$ItemsList[$i][11] = $ItemsList[$i][11] & $App_Description[$j]
					Next
					$ItemsList[$i][11] = $ItemsList[$i][11] & @CRLF
					For $j = 1 To $App_URL[0]
						If $ItemsList[$i][11] <> '' Then $ItemsList[$i][11] = $ItemsList[$i][11] & @CRLF
						$ItemsList[$i][11] = $ItemsList[$i][11] & 'REF: ' & $App_URL[$j]
					Next
					GUICtrlSetData($Edit_Item, $ItemsList[$i][11])
					If $LauncherMode Then
						If $App_Type = 5 Then
							GUICtrlSetData($Button_Start, 'Play!')
						Else
							GUICtrlSetData($Button_Start, 'Launch!')
						EndIf
					EndIf
;~ 					GUICtrlSetState($Button_Start, $GUI_FOCUS)
					UpdateItemLabel($ItemsList[$i][2])
					UpdateItemsCount()
					ExitLoop
				EndIf
			Next
		EndIf
	Else
		If $SelectionChanged Then
			If $Category[1][2] Then
				_PinsSetAll()
			Else
				_PinsSetByCategory()
			EndIf
			$SelectionChanged = False
		EndIf
	EndIf
WEnd

Cleanup()
;~ EndGame('SetupS Installs', 'Done!')
Exit

Func DetailOptions()
	;------------------------------------------------------ Detail ssGooey_Options form ----------------------------------------------
;~ GUICtrlSetBkColor($PageControl_Options, 0x202020)
;~ GUICtrlSetBkColor($TabSheet_Filters, 0x202020)
	BlankScreenShot()
	GUISetState(@SW_SHOW, $Form_ssGooey)

	If $HideInstalled Then
		GUICtrlSetState($Checkbox_Hide_Installed, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_Hide_Installed, $GUI_UNCHECKED)
	EndIf
	If $ScanAllDrives Then
		GUICtrlSetState($Checkbox_ScanAllDrives, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ScanAllDrives, $GUI_UNCHECKED)
	EndIf
	If $CheckForLocal Then
		GUICtrlSetState($Checkbox_ScanLocal, $GUI_CHECKED)
		GUICtrlSetState($Checkbox_ScanAllDrives, $GUI_Enable)
	Else
		GUICtrlSetState($Checkbox_ScanLocal, $GUI_UNCHECKED)
		GUICtrlSetState($Checkbox_ScanAllDrives, $GUI_DISABLE)
	EndIf
	If $CheckOnlineLibrary Then
		GUICtrlSetState($Checkbox_ScanOnline, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_ScanOnline, $GUI_UNCHECKED)
	EndIf
	If $OSFriendly Then
		GUICtrlSetState($Checkbox_OS_Friendly, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_OS_Friendly, $GUI_UNCHECKED)
	EndIf
	If $ArchFriendly Then
		GUICtrlSetState($Checkbox_Arch_Friendly, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_Arch_Friendly, $GUI_UNCHECKED)
	EndIf
	Select
		Case $ssAppsOnly
			GUICtrlSetState($Checkbox_ssAppsSelect, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ppAppsSelect, $GUI_UNCHECKED)
			GUICtrlSetState($Checkbox_ppGamesSelect, $GUI_UNCHECKED)
		Case $ppAppsOnly
			GUICtrlSetState($Checkbox_ssAppsSelect, $GUI_UNCHECKED)
			GUICtrlSetState($Checkbox_ppAppsSelect, $GUI_CHECKED)
			GUICtrlSetState($Checkbox_ppGamesSelect, $GUI_UNCHECKED)
		Case $ppGamesOnly
			GUICtrlSetState($Checkbox_ssAppsSelect, $GUI_UNCHECKED)
			GUICtrlSetState($Checkbox_ppAppsSelect, $GUI_UNCHECKED)
			GUICtrlSetState($Checkbox_ppGamesSelect, $GUI_CHECKED)
		Case Else
			If $ssAppsExclude Then
				GUICtrlSetState($Checkbox_ssAppsSelect, $GUI_UNCHECKED)
			Else
				GUICtrlSetState($Checkbox_ssAppsSelect, $GUI_CHECKED)
			EndIf
			If $ppAppsExclude Then
				GUICtrlSetState($Checkbox_ppAppsSelect, $GUI_UNCHECKED)
			Else
				GUICtrlSetState($Checkbox_ppAppsSelect, $GUI_CHECKED)
			EndIf
			If $ppGamesExclude Then
				GUICtrlSetState($Checkbox_ppGamesSelect, $GUI_UNCHECKED)
			Else
				GUICtrlSetState($Checkbox_ppGamesSelect, $GUI_CHECKED)
			EndIf
	EndSelect
	GUICtrlSetCursor($Label_CheckForUpdate, 0) ; hand-hover
	If $NoUpdate Then GUICtrlSetState($Label_CheckForUpdate, $GUI_DISABLE)
;~ GUICtrlSetData($Combo_ppAppsDrive, $ppAppsDriveChoices, $ppAppsDrive)
;~ GUICtrlSetData($Combo_ppGamesDrive, $ppGamesDriveChoices, $ppGamesDrive)
;~ GUICtrlSetData($Combo_CDDrive, $CDDriveChoices, $CDDrive)
EndFunc
#region ;########################################## FUNCTIONS BELOW #############################################################

Func _PinsClear()
	Local $i
	GUICtrlSetState($TreeView_Items, $GUI_HIDE)
	For $i = 1 To $ItemsList[0][0]
		_GUICtrlTreeView_Delete($TreeView_Items, $ItemsList[$i][12])
		$ItemsList[$i][12] = 0
	Next
	GUICtrlSetState($TreeView_Items, $GUI_SHOW)
	BlankScreenShot()
EndFunc

Func _PinsSetAll()
	Local $i, $OSArchGate, $OSVersionGate, $ShowGate
	Local $ssAppsSelect = GUICtrlRead($Checkbox_ssAppsSelect, 0) = 1
	Local $ppAppsSelect = GUICtrlRead($Checkbox_ppAppsSelect, 0) = 1
	Local $ppGamesSelect = GUICtrlRead($Checkbox_ppGamesSelect, 0) = 1
	Local $RedPins = 0, $YellowPins = 0, $GreenPins = 0
	$HideInstalled = GUICtrlRead($Checkbox_Hide_Installed, 0) = 1
	$ArchFriendly = GUICtrlRead($Checkbox_Arch_Friendly, 0) = 1
	$OSFriendly = GUICtrlRead($Checkbox_OS_Friendly, 0) = 1
	GUICtrlSetState($TreeView_Items, $GUI_HIDE)
	$ItemsCount = 0
	For $i = 1 To $ItemsList[0][0]
		$ShowGate = $LauncherMode Or (Not $LauncherMode And Not ($HideInstalled And $ItemsList[$i][13]))
		$OSArchGate = True ;Any
		If $ArchFriendly Then
			Switch $ItemsList[$i][6]
				Case 1 ;x86 (32-bit)
					$OSArchGate = Not $OSArch64
				Case 2 ;x64 (64-bit)
					$OSArchGate = $OSArch64
			EndSwitch
		EndIf
		$OSVersionGate = True ;All
		If $OSFriendly Then
			Switch $ItemsList[$i][7]
				Case 1 ;NT5.x (2K/XP/2K3)
					$OSVersionGate = $OS_NT5
				Case 2 ;NT6.x (Vista/7)
					$OSVersionGate = Not $OS_NT5
			EndSwitch
		EndIf
		If $OSArchGate And $OSVersionGate And $ShowGate Then
			Switch $ItemsList[$i][8] ; BuildType Filter
				Case 1, 2
					If $ssAppsSelect And Not $LauncherMode Then
						$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
						GUICtrlSetColor($ItemsList[$i][12], 0xff0000) ;Red
						$ItemsCount += 1
						$RedPins += 1
					EndIf
				Case 3
					If $ppAppsSelect Then
						$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
						GUICtrlSetColor($ItemsList[$i][12], 0xffff50) ;Yellow
						$ItemsCount += 1
						$YellowPins += 1
					EndIf
				Case 4
					If $ppAppsSelect And Not $LauncherMode Then
						$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
						GUICtrlSetColor($ItemsList[$i][12], 0xffff50) ;Yellow
						$ItemsCount += 1
						$YellowPins += 1
					EndIf
				Case 5
					If $ppGamesSelect Then
						$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
						GUICtrlSetColor($ItemsList[$i][12], 0x00ff00) ;Green
						$ItemsCount += 1
						$GreenPins += 1
					EndIf
			EndSwitch
		EndIf
	Next
	GUICtrlSetState($TreeView_Items, $GUI_SHOW)
	Select
		Case $LauncherMode
			If $GreenPins > 0 And $RedPins = 0 And $YellowPins = 0 Then
				GUICtrlSetData($Button_Start, 'Play!')
				$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF & 'Pick your ppGame and Press "Play!"' & @CRLF & @CRLF & 'Enjoy!'
			Else
				GUICtrlSetData($Button_Start, 'Launch!')
				$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF & 'Pick your ppApp or ppGame and Press "Launch!"' & @CRLF & @CRLF & 'Enjoy!'
			EndIf
		Case $InstallerMode
			GUICtrlSetData($Button_Start, 'Install!')
			$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF
			$Intro = $Intro & 'Pick your selection of Apps and/or Games then press "Install!" to install them.' & @CRLF & @CRLF
			$Intro = $Intro & 'Use "Options" to: ' & @CRLF
			$Intro = $Intro & '     Chose your ppApps + ppGames drive letters.' & @CRLF
			$Intro = $Intro & '     To Hide any installed Apps or ppGames found on this PC system' & @CRLF
			$Intro = $Intro & '     Or to hide any Apps or ppGames that are not friendly with this PC system.' & @CRLF & @CRLF
			$Intro = $Intro & 'Legend: ' & @CRLF
			$Intro = $Intro & '     ssApps are Red' & @CRLF
			$Intro = $Intro & '     ppApps are Yellow' & @CRLF
			$Intro = $Intro & '     ppGames are Green'
		Case $ISOMakerMode
			GUICtrlSetData($Button_Start, 'Insert!')
			$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF
			$Intro = $Intro & 'Pick your selection of Apps and/or Games then press "Insert!"to copy them to your new ISO.' & @CRLF & @CRLF
			$Intro = $Intro & 'Legend: ' & @CRLF
			$Intro = $Intro & '     ssApps are Red' & @CRLF
			$Intro = $Intro & '     ppApps are Yellow' & @CRLF
			$Intro = $Intro & '     ppGames are Green'
	EndSelect
	GUICtrlSetData($Edit_Item, $Intro)
	UpdateItemsCount()
EndFunc

Func _PinsSetByCategory()
	Local $i, $j, $k, $ItemsListCategory, $OSArchGate, $OSVersionGate, $ShowGate
	Local $ssAppsSelect = GUICtrlRead($Checkbox_ssAppsSelect, 0) = 1
	Local $ppAppsSelect = GUICtrlRead($Checkbox_ppAppsSelect, 0) = 1
	Local $ppGamesSelect = GUICtrlRead($Checkbox_ppGamesSelect, 0) = 1
	Local $RedPins = 0, $YellowPins = 0, $GreenPins = 0
	$HideInstalled = GUICtrlRead($Checkbox_Hide_Installed, 0) = 1
	$ArchFriendly = GUICtrlRead($Checkbox_Arch_Friendly, 0) = 1
	$OSFriendly = GUICtrlRead($Checkbox_OS_Friendly, 0) = 1
	GUICtrlSetState($TreeView_Items, $GUI_HIDE)
	$ItemsCount = 0
	For $i = 1 To $ItemsList[0][0]
		$ShowGate = Not $LauncherMode And Not ($HideInstalled And $ItemsList[$i][13])
		$OSArchGate = True ;Any
		If $ArchFriendly Then
			Switch $ItemsList[$i][6]
				Case 1 ;x86 (32-bit)
					$OSArchGate = Not $OSArch64
				Case 2 ;x64 (64-bit)
					$OSArchGate = $OSArch64
			EndSwitch
		EndIf
		$OSVersionGate = True ;All
		If $OSFriendly Then
			Switch $ItemsList[$i][7]
				Case 1 ;NT5.x (2K/XP/2K3)
					$OSVersionGate = $OS_NT5
				Case 2 ;NT6.x (Vista/7)
					$OSVersionGate = Not $OS_NT5
			EndSwitch
		EndIf
		If $OSArchGate And $OSVersionGate And $ShowGate Then
			$ItemsListCategory = StringSplit($ItemsList[$i][5], '|')
			For $k = 1 To $ItemsListCategory[0]
				For $j = 1 To $Category[0][0]
					If $Category[$j][2] Then
						If ($ItemsListCategory[$k] = $Category[$j][0]) Then
							Switch $ItemsList[$i][8]
								Case 1, 2
									If $ssAppsSelect And Not $LauncherMode Then
										$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
										GUICtrlSetColor($ItemsList[$i][12], 0xff0000) ;Red
										$ItemsCount += 1
										$RedPins += 1
									EndIf
								Case 3
									If $ppAppsSelect Then
										$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
										GUICtrlSetColor($ItemsList[$i][12], 0xffff50) ;Yellow
										$ItemsCount += 1
										$YellowPins += 1
									EndIf
								Case 4
									If $ppAppsSelect And Not $LauncherMode Then
										$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
										GUICtrlSetColor($ItemsList[$i][12], 0xffff50) ;Yellow
										$ItemsCount += 1
										$YellowPins += 1
									EndIf
								Case 5
									If $ppGamesSelect Then
										$ItemsList[$i][12] = GUICtrlCreateTreeViewItem($ItemsList[$i][2], $TreeView_Items)
										GUICtrlSetColor($ItemsList[$i][12], 0x00ff00) ;Green
										$ItemsCount += 1
										$GreenPins += 1
									EndIf
							EndSwitch
						EndIf
					EndIf
				Next
			Next
		EndIf
	Next
	GUICtrlSetState($TreeView_Items, $GUI_SHOW)
	Select
		Case $LauncherMode
			If $GreenPins > 0 And $RedPins = 0 And $YellowPins = 0 Then
				GUICtrlSetData($Button_Start, 'Play!')
				$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF & 'Pick your ppGame and Press "Play!"' & @CRLF & @CRLF & 'Enjoy!'
			Else
				GUICtrlSetData($Button_Start, 'Launch!')
				$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF & 'Pick your ppApp and Press "Launch!"' & @CRLF & @CRLF & 'Enjoy!'
			EndIf
		Case $InstallerMode
			GUICtrlSetData($Button_Start, 'Install!')
			$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF
			$Intro = $Intro & 'Pick your selection of Apps and/or Games then press "Install!" to install them.' & @CRLF & @CRLF
			$Intro = $Intro & 'Use "Options" to: ' & @CRLF
			$Intro = $Intro & '     Chose your ppApps + ppGames drive letters.' & @CRLF
			$Intro = $Intro & '     To Hide any installed Apps or ppGames found on this PC system' & @CRLF
			$Intro = $Intro & '     Or to hide any Apps or ppGames that are not friendly with this PC system.' & @CRLF & @CRLF
			$Intro = $Intro & 'Legend: ' & @CRLF
			$Intro = $Intro & '     ssApps are Red' & @CRLF
			$Intro = $Intro & '     ppApps are Yellow' & @CRLF
			$Intro = $Intro & '     ppGames are Green'
		Case $ISOMakerMode
			GUICtrlSetData($Button_Start, 'Insert!')
			$Intro = 'Welcome to ssGooey v15.12.21.0!' & @CRLF & @CRLF
			$Intro = $Intro & 'Pick your selection of Apps and/or Games then press "Insert! to copy them to your new ISO".' & @CRLF & @CRLF
;~ 		$Intro = $Intro & 'Use "Options" to: ' & @CRLF
;~ 		$Intro = $Intro & '     Chose your ppApps + ppGames drive letters.' & @CRLF
;~ 		$Intro = $Intro & '     To Hide any installed Apps or ppGames found on this PC system' & @CRLF
;~ 		$Intro = $Intro & '     Or to hide any Apps or ppGames that are not friendly with this PC system.' & @CRLF & @CRLF
			$Intro = $Intro & 'Legend: ' & @CRLF
			$Intro = $Intro & '     ssApps are Red' & @CRLF
			$Intro = $Intro & '     ppApps are Yellow' & @CRLF
			$Intro = $Intro & '     ppGames are Green'
	EndSelect
	GUICtrlSetData($Edit_Item, $Intro)
	UpdateItemsCount()
EndFunc

Func BlankScreenShot()
	If $TempPixDir = '' Then
		$TempPixDir = GenerateTempFolder()
		DirCreate($TempPixDir)
	EndIf
	If Not FileExists($TempPixDir & '\wallpaper.jpg') Then FileInstall('.\wallpaper.jpg', $TempPixDir & '\wallpaper.jpg')
	_SetImage($Pic_ScreenShot, $TempPixDir & '\wallpaper.jpg')
;~ 	GUICtrlSetImage($Pic_ScreenShot, $TempPixDir & '\wallpaper.jpg')
;~ 	ResizePic($TempPixDir & '\wallpaper.jpg', $Pic_ScreenShot)
	GUICtrlSetData($Edit_Item, $Intro)
EndFunc

Func GetExtraAppOptions($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetExtraAppOptions(): $Defaults=' & $Defaults & @CRLF)
	Local $test, $parmlist, $i
	If FileExists($Defaults) Then ;Get default settings
		$AutoUpdate = IniRead_Binary($Defaults, 'Options', 'AutoUpdate', 'No')
		$HideInstalled = IniRead_Binary($Defaults, 'Options', 'HideInstalled', 'No')
		$OSFriendly = IniRead_Binary($Defaults, 'Options', 'OSFriendly', 'Yes')
		$ArchFriendly = IniRead_Binary($Defaults, 'Options', 'ArchFriendly', 'Yes')
		$ppAppsExclude = IniRead_Binary($Defaults, 'Options', 'ppAppsExclude', 'No')
		$ppGamesExclude = IniRead_Binary($Defaults, 'Options', 'ppGamesExclude', 'No')
		$ssAppsExclude = IniRead_Binary($Defaults, 'Options', 'ssAppsExclude', 'No')
		$VolumeData = IniRead($Defaults, 'Inserts', 'VolumeData', '')
		$TemplateISO = IniRead($Defaults, 'Inserts', 'TemplateISO', '')
		$TargetISO = IniRead($Defaults, 'Inserts', 'TargetISO', '')
		$ScanAllDrives = IniRead_Binary($Defaults, 'Scan', 'AllDrives', 'No') ; Default=CurrentDriveOnly
		$CheckOnlineLibrary = IniRead_Binary($Defaults, 'Scan', 'Online', 'No')
		$CheckForLocal = IniRead_Binary($Defaults, 'Scan', 'Local', 'Yes')
		;$OnlineLibraryFolder = IniRead($Defaults, 'Scan', 'OnlineFolder', '')
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
	$test = GetParameter('HideInstalled', '=')
	If $test <> '' Then $HideInstalled = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	$test = GetParameter('ScanAllDrives', '=')
	If $test <> '' Then $ScanAllDrives = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	$CurrentDriveOnly = Not $ScanAllDrives
	If $CurrentDriveOnly Then $CurrentDrive = StringLeft(@ScriptDir, 2)
	$test = GetParameter('ppAppsExclude', '=')
	If $test <> '' Then $ppAppsExclude = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	If $ppAppsExclude Then
		$ppAppsOnly = False
	Else
		If FileExists($Defaults) Then
			$ppAppsOnly = IniRead($Defaults, 'Options', 'ppAppsOnly', 'No')
			$ppAppsOnly = ($ppAppsOnly = 'Yes') Or ($ppAppsOnly = '1') Or ($ppAppsOnly = 'True') Or ($ppAppsOnly = 'On')
		EndIf
		$test = GetParameter('ppAppsOnly', '=')
		If $test <> '' Then $ppAppsOnly = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('ppGamesExclude', '=')
	If $test <> '' Then $ppGamesExclude = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	If $ppGamesExclude Then
		$ppGamesOnly = False
	Else
		If FileExists($Defaults) Then
			$ppGamesOnly = IniRead($Defaults, 'Options', 'ppGamesOnly', 'No')
			$ppGamesOnly = ($ppGamesOnly = 'Yes') Or ($ppGamesOnly = '1') Or ($ppGamesOnly = 'True') Or ($ppGamesOnly = 'On')
		EndIf
		$test = GetParameter('ppGamesOnly', '=')
		If $test <> '' Then $ppGamesOnly = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
	$test = GetParameter('ssAppsExclude', '=')
	If $test <> '' Then $ssAppsExclude = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	If $ssAppsExclude Then
		$ssAppsOnly = False
	Else
		If FileExists($Defaults) Then
			$ssAppsOnly = IniRead($Defaults, 'Options', 'ssAppsOnly', 'No')
			$ssAppsOnly = ($ssAppsOnly = 'Yes') Or ($ssAppsOnly = '1') Or ($ssAppsOnly = 'True') Or ($ssAppsOnly = 'On')
		EndIf
		$test = GetParameter('ssAppsOnly', '=')
		If $test <> '' Then $ssAppsOnly = ($test = 'Yes') Or ($test = '1') Or ($test = 'True') Or ($test = 'On')
	EndIf
EndFunc

Func GetOnlineLibraryNFO() ;Sync info from online repos
	Local $found = False, $i, $FileList
	Local $BaseApp, $BaseJpg, $BaseFolder
	Local $SplashTips_Temp = $SplashTips, $BalloonTips_Temp = $BalloonTips
	DirCreate($OfflineLibraryFolder)
	$OnlineLibraryLink = $RepoLink & '/' & $OnlineLibraryFolder
	Local $aData = DownloadFile($OnlineLibraryLink & '/list/index.ini', $OfflineLibraryFolder & '\temp.ini')
	If Not (IsArray($aData) And $aData[3]) Then
		$OnlineLibraryLink = $BackupRepoLink & '/' & $OnlineLibraryFolder
		$aData = DownloadFile($OnlineLibraryLink & '/list/index.ini', $OfflineLibraryFolder & '\temp.ini')
	EndIf
	If IsArray($aData) And $aData[3] Then $OnlineLibrary = IniReadSection($OfflineLibraryFolder & '\temp.ini', 'Library')
	DeleteMe($OfflineLibraryFolder & '\temp.ini')
	If IsArray($OnlineLibrary) Then
		$found = True
		For $i = 1 To $OnlineLibrary[0][0]
			$BaseFolder = $OnlineLibrary[$i][0]
			If IniRead($OfflineLibraryFolder & '\index.ini', 'Library', $BaseFolder, '') <> $OnlineLibrary[$i][1] Then DeleteMe($OfflineLibraryFolder & '\' & $BaseFolder)
			If Not FileExists($OfflineLibraryFolder & '\' & $BaseFolder) Then
				DirCreate($OfflineLibraryFolder & '\' & $BaseFolder)
				Select
					Case StringInStr($BaseFolder, '_ssApp')
						$BaseApp = 'ssApp.app'
						$BaseJpg = 'ssApp.jpg'
					Case StringInStr($BaseFolder, '_ppApp')
						$BaseApp = 'ppApp.app'
						$BaseJpg = 'ppApp.jpg'
					Case StringInStr($BaseFolder, '_ppGame')
						$BaseApp = 'ppGame.ppg'
						$BaseJpg = 'ppGame.jpg'
				EndSelect
				If $SplashTips Then SplashThis('Syncing --> ', $BaseFolder)
				If $BalloonTips Then TrayTip($ThisAppTitle, 'Syncing --> ' & $BaseFolder, 300, 16)
				$aData = DownloadFile($OnlineLibraryLink & '/list/' & $BaseFolder & '/' & $BaseApp, $OfflineLibraryFolder & '\' & $BaseFolder & '\' & $BaseApp)
				If IsArray($aData) And $aData[3] Then DownloadFile($OnlineLibraryLink & '/list/' & $BaseFolder & '/' & $BaseJpg, $OfflineLibraryFolder & '\' & $BaseFolder & '\' & $BaseJpg)
				If $BalloonTips Then TrayTip($ThisAppTitle, '', 300, 16)
			EndIf
		Next
		IniWriteSection($OfflineLibraryFolder & '\index.ini', 'Library', $OnlineLibrary)
		$FileList = _FileListToArray($OfflineLibraryFolder, '*.*', 2) ; Return folders only
		If IsArray($FileList) Then
			;_ArrayDisplay($FileList)
			If $SplashTips Then SplashThis($ThisAppFilename, 'Syncing...')
			If $BalloonTips Then TrayTip($ThisAppTitle, 'Syncing ...', 300, 16)
			For $i = 1 To $FileList[0]
				If IniRead($OfflineLibraryFolder & '\index.ini', 'Library', $FileList[$i], '') = '' Then DeleteMe($OfflineLibraryFolder & '\' & $FileList[$i])
			Next
		EndIf
	EndIf
	$SplashTips = $SplashTips_Temp
	$BalloonTips = $BalloonTips_Temp
	Return $found
EndFunc

Func IsInstalled($InstalledTo, $ItemsCount)
	Local $Installed = False, $Temp1 = $App_Title, $Temp2 = $ItemsList[$ItemsCount][3]
	_AppReset()
	$App_File = _AppRead($InstalledTo, True, False)
	If FileExists($App_File) Then
		If $App_Version <> '' Then $Temp1 = $Temp1 & ' ' & $App_Version
		If $ItemsList[$ItemsCount][4] <> '' Then $Temp2 = $Temp2 & ' ' & $ItemsList[$ItemsCount][4]
		If $Temp1 = $Temp2 Then $Installed = True
	EndIf
	Return $Installed
EndFunc

Func ModeScan()
	Local $Drive
	$ExpressInstall[0] = 0
	ReDim $ExpressInstall[$ExpressInstall[0] + 1]
	If Not $LauncherMode Then
		If $CheckOnlineLibrary And GetOnlineLibraryNFO() Then
			If $SplashTips Then SplashThis($ThisAppFilename, 'Scanning...');SplashTextOn($ThisAppTitle, 'Initializing...', -1, 42, -1, -1, 4, 'Arial', 10);
			If $BalloonTips Then TrayTip($ThisAppTitle, 'Scanning...', 300, 16)
			If IsArray($OnlineLibrary) Then
				$ExpressInstall[0] = $OnlineLibrary[0][0]
				ReDim $ExpressInstall[$ExpressInstall[0] + 1]
				For $Drive = 1 To $OnlineLibrary[0][0]
					$ExpressInstall[$Drive] = $OfflineLibraryFolder & '\' & $OnlineLibrary[$Drive][0]
				Next
			EndIf
		EndIf
		If $CheckForLocal Then
			Select
				Case $ScanAllDrives ;Get All Drives with a "Installs" folder
					For $Drive = 1 To $AllDrivesList[0]
						Process_Drive($AllDrivesList[$Drive], 'ssInstalls')
						Process_Drive($AllDrivesList[$Drive], 'SetupSApps')
						Process_Drive($AllDrivesList[$Drive], 'ppAppsInstalls')
						Process_Drive($AllDrivesList[$Drive], 'ppGamesInstalls')
						Process_Drive($AllDrivesList[$Drive], 'ssAppsInstalls')
					Next
				Case Else
					Process_Drive($CurrentDrive, 'ssInstalls')
					Process_Drive($CurrentDrive, 'SetupSApps')
					Process_Drive($CurrentDrive, 'ppAppsInstalls')
					Process_Drive($CurrentDrive, 'ppGamesInstalls')
					Process_Drive($CurrentDrive, 'ssAppsInstalls')
			EndSelect
		EndIf
		If $ExpressInstall[0] = 0 Then $LauncherMode = True
	EndIf
	;_ArrayDisplay($ExpressInstall)
	If $LauncherMode Then
		Select
			Case $ScanAllDrives ;Get All Drives with a ppFolder
				For $Drive = 1 To $AllDrivesList[0]
					Select
						Case $ppAppsOnly
							Process_Drive($AllDrivesList[$Drive], 'ppApps')
							Process_Drive($AllDrivesList[$Drive], 'ppAppsLive')
						Case $ppGamesOnly
							Process_Drive($AllDrivesList[$Drive], 'ppGames')
							Process_Drive($AllDrivesList[$Drive], 'ppGamesLive')
						Case $ssAppsExclude
							Process_Drive($AllDrivesList[$Drive], 'ppApps')
							Process_Drive($AllDrivesList[$Drive], 'ppGames')
							Process_Drive($AllDrivesList[$Drive], 'ppAppsLive')
							Process_Drive($AllDrivesList[$Drive], 'ppGamesLive')
						Case $ppAppsExclude
							Process_Drive($AllDrivesList[$Drive], 'ppGames')
							Process_Drive($AllDrivesList[$Drive], 'ppGamesLive')
						Case $ppGamesExclude
							Process_Drive($AllDrivesList[$Drive], 'ppApps')
							Process_Drive($AllDrivesList[$Drive], 'ppAppsLive')
						Case Else
							Process_Drive($AllDrivesList[$Drive], 'ppApps')
							Process_Drive($AllDrivesList[$Drive], 'ppGames')
							Process_Drive($AllDrivesList[$Drive], 'ppAppsLive')
							Process_Drive($AllDrivesList[$Drive], 'ppGamesLive')
					EndSelect
				Next
			Case Else
				Select
					Case $ppAppsOnly
						Process_Drive($CurrentDrive, 'ppApps')
						Process_Drive($CurrentDrive, 'ppAppsLive')
					Case $ppGamesOnly
						Process_Drive($CurrentDrive, 'ppGames')
						Process_Drive($CurrentDrive, 'ppGamesLive')
					Case $ssAppsExclude
						Process_Drive($CurrentDrive, 'ppApps')
						Process_Drive($CurrentDrive, 'ppGames')
						Process_Drive($CurrentDrive, 'ppAppsLive')
						Process_Drive($CurrentDrive, 'ppGamesLive')
					Case $ppAppsExclude
						Process_Drive($CurrentDrive, 'ppGames')
						Process_Drive($CurrentDrive, 'ppGamesLive')
					Case $ppGamesExclude
						Process_Drive($CurrentDrive, 'ppApps')
						Process_Drive($CurrentDrive, 'ppAppsLive')
					Case Else
						Process_Drive($CurrentDrive, 'ppApps')
						Process_Drive($CurrentDrive, 'ppGames')
						Process_Drive($CurrentDrive, 'ppAppsLive')
						Process_Drive($CurrentDrive, 'ppGamesLive')
				EndSelect
		EndSelect
	EndIf
EndFunc

Func PopulateArray(ByRef $SourcePath)
	Local $i, $found = False, $App_Description_Data = '', $ArchiveMode = '', $SrcPath = $SourcePath
	Local $SplashTips_Temp = $SplashTips, $BalloonTips_Temp = $BalloonTips
	_AppReset()
	If StringInStr(FileGetAttrib($SrcPath), 'D') = 0 Then ; a file
		Switch StringRight($SrcPath, 4)
			Case '.apz', '.pgz'
				If $ArchiveMode = '' And $ToolsPath <> '' Then
					If GetFileFromArchive('*' & StringLeft(StringLower(StringRight($SrcPath, 4)), 2) & 'p' & StringMid(StringLower(StringRight($SrcPath, 4)), 3, 1), $SrcPath) Then
						$ArchiveMode = $SrcPath
						$SrcPath = $TempDir
					EndIf
				EndIf
		EndSwitch
	EndIf
	$App_File = _AppRead($SrcPath, True, False)
	If $ArchiveMode <> '' Then
		DirRemove($SrcPath, 1)
		$SrcPath = $ArchiveMode
	EndIf
	If $App_File <> '' Then
		$INIname = GetFilename($App_File)
		$SplashTemp = $App_Title
		If $App_Version <> '' And $App_Type < 5 Then $SplashTemp = $SplashTemp & ' ' & $App_Version
		If $App_Architecture > 0 Then
			Switch $App_Architecture
				Case 1 ; 'x86'
					$SplashTemp = $SplashTemp & ' (x86)'
				Case 2 ; 'x64'
					$SplashTemp = $SplashTemp & ' (x64)'
			EndSwitch
		EndIf
		Select
			Case $ssAppsOnly
				If $App_Type < 3 Then $found = True
			Case $ssAppsExclude
				If Not ($App_Type < 3) Then $found = True
			Case $ppAppsOnly
				If $App_Type = 3 Or $App_Type = 4 Then $found = True
			Case $ppAppsExclude
				If Not ($App_Type = 3 Or $App_Type = 4) Then $found = True
			Case $ppGamesOnly
				If $App_Type = 5 Then $found = True
			Case $ppGamesExclude
				If $App_Type <> 5 Then $found = True
			Case Else
				$found = True
		EndSelect
		If $found Then
			For $i = 1 To $ItemsCount ;Already in list?
				If $ItemsList[$i][0] = $SplashTemp & '|' & $App_Type Then
					$found = False
					ExitLoop
				EndIf
			Next
			If $found Then
				If $SplashTips Then
					SplashThis('Processing --> ', $App_Title)
					;TrayTip($ThisAppTitle, 'Processing ... ', 300, 16)
				EndIf
				If $BalloonTips Then TrayTip('Processing ', $App_Title, 300, 16)
				$ItemsCount += 1
				ReDim $ItemsList[UBound($ItemsList) + 1][16]
				$ItemsList[0][0] = $ItemsCount
				$ItemsList[$ItemsCount][0] = $SplashTemp & '|' & $App_Type ;Sortby
				If $LauncherMode Then
					$ItemsList[$ItemsCount][1] = $App_InstallPath
				Else
					$ItemsList[$ItemsCount][1] = $SrcPath
				EndIf
				$ItemsList[$ItemsCount][2] = $SplashTemp
				$ItemsList[$ItemsCount][3] = $App_Title
				$ItemsList[$ItemsCount][4] = $App_Version
				$ItemsList[$ItemsCount][5] = Multi2SingleLine($App_Category, '|')
				If $ItemsList[$ItemsCount][5] = '' Then $ItemsList[$ItemsCount][5] = 'N/A'
				$ItemsList[$ItemsCount][6] = $App_Architecture
				$ItemsList[$ItemsCount][7] = $App_OS
				$ItemsList[$ItemsCount][8] = $App_Type
				$ItemsList[$ItemsCount][9] = $App_smSource ;Startmenu
				If $App_scCount > 0 Then
					$ItemsList[$ItemsCount][10] = $App_scEXE[1]
					$ItemsList[$ItemsCount][14] = $App_scArgs[1]
					$ItemsList[$ItemsCount][15] = $App_scWorkDir[1]
				EndIf
				If Not $LauncherMode Then
					$ItemsList[$ItemsCount][13] = IsInstalled($App_InstallPath, $ItemsCount)
				EndIf
;~ 				TrayTip($ThisAppTitle, '', 1)
			EndIf
		EndIf
	EndIf
	$SplashTips = $SplashTips_Temp
	$BalloonTips = $BalloonTips_Temp
EndFunc

Func PopulateCategories()
	Local $i, $j, $found, $k, $ItemsListCategory
	Local $CategoriesStart = UBound($Category)
	For $i = 1 To $ItemsList[0][0]
		$ItemsListCategory = StringSplit($ItemsList[$i][5], '|')
		For $k = 1 To $ItemsListCategory[0]
			$found = False
			For $j = 1 To $Category[0][0]
				If ($ItemsListCategory[$k] = $Category[$j][0]) Then
					$found = True
					ExitLoop
				EndIf
			Next
			If Not $found Then
				ReDim $Category[UBound($Category) + 1][3] ;text, ID
				$Category[0][0] = UBound($Category) - 1
				$Category[$Category[0][0]][0] = $ItemsListCategory[$k]
			EndIf
		Next
	Next
	_ArraySort($Category, 0, $CategoriesStart, 0, 0)
	For $j = $CategoriesStart To $Category[0][0]
		$Category[$j][1] = GUICtrlCreateTreeViewItem($Category[$j][0], $TreeView_Category)
		GUICtrlSetColor($TreeView_Category, 0xffffff) ;white
		GUICtrlSetState($TreeView_Category, $GUI_UNCHECKED)
		$Category[$j][2] = False
	Next
EndFunc

Func Process_Drive($CurrentDrive, $InstallType) ;
	;No recursion required since xxAppsInstalls are always on one level
	Local $i, $found, $FileList
	;ErrorProtection('off')
	$found = FileExists($CurrentDrive & '\' & $InstallType)
	;ErrorProtection('on')
	If $found Then
		If $SplashTips Then SplashThis('Please wait...', 'Scanning Drive "' & StringUpper($CurrentDrive) & '" for ' & $InstallType)
		If $LauncherMode Then
			ScanForExpressInstall($CurrentDrive & '\' & $InstallType, True)
		Else
			ScanForExpressInstall($CurrentDrive & '\' & $InstallType)
			ScanForExpressInstall($CurrentDrive & '\' & $InstallType, True)
		EndIf
	EndIf
EndFunc

Func SetExtraAppDefaults($ssExtraApp)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|SetExtraAppDefaults(): $ssExtraApp = ' & $ssExtraApp & @CRLF)
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Mute', 'No')
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'TrayOnly', 'Yes')
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnly', 'No')
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnTop', 'No')
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Debug', 'No')
	NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Log', 'No')

	NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'HideInstalled', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'OSFriendly', 'Yes')
	NeoIniWrite($ssExtraApp, 'Options', 'ArchFriendly', 'Yes')
	NeoIniWrite($ssExtraApp, 'Options', 'ppAppsOnly', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'ppGamesOnly', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'ssAppsOnly', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'ppAppsExclude', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'ppGamesExclude', 'No')
	NeoIniWrite($ssExtraApp, 'Options', 'ssAppsExclude', 'No')

	NeoIniWrite($ssExtraApp, 'Fadertainer', 'Activate', 'No')
	NeoIniWrite($ssExtraApp, 'Fadertainer', 'Speed', '.5')
	NeoIniWrite($ssExtraApp, 'Fadertainer', 'Location', '')
	NeoIniWrite($ssExtraApp, 'Fadertainer', 'Module', '')
	NeoIniWrite($ssExtraApp, 'Fadertainer', 'AlwaysOnTop', 'Yes')
	NeoIniWrite($ssExtraApp, 'Fadertainer', 'DuringInstallsOnly', 'Yes')

	NeoIniWrite($ssExtraApp, 'Inserts', 'VolumeData', '')
	NeoIniWrite($ssExtraApp, 'Inserts', 'TemplateISO', '')
	NeoIniWrite($ssExtraApp, 'Inserts', 'TargetISO', '')

	NeoIniWrite($ssExtraApp, 'Scan', 'Online', 'No')
	NeoIniWrite($ssExtraApp, 'Scan', 'Local', 'Yes')
	NeoIniWrite($ssExtraApp, 'Scan', 'AllDrives', 'No') ; Default=CurrentDriveOnly
	NeoIniWrite($ssExtraApp, 'Scan', 'OnlineFolder', 'files')

EndFunc

Func SetGooeyOptions($Defaults)
	If FileExists($Defaults) Then
		NeoIniWrite($Defaults, 'Options', 'HideInstalled', GUICtrlRead($Checkbox_Hide_Installed) = $GUI_CHECKED)
		NeoIniWrite($Defaults, 'Options', 'OSFriendly', GUICtrlRead($Checkbox_OS_Friendly) = $GUI_CHECKED)
		NeoIniWrite($Defaults, 'Options', 'ArchFriendly', GUICtrlRead($Checkbox_Arch_Friendly) = $GUI_CHECKED)
		Select
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_UNCHECKED
				$ssAppsOnly = True
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = False
				$ppAppsExclude = False
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_UNCHECKED
				$ssAppsOnly = False
				$ppAppsOnly = True
				$ppGamesOnly = False
				$ssAppsExclude = False
				$ppAppsExclude = False
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_CHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = True
				$ssAppsExclude = False
				$ppAppsExclude = False
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_CHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = True
				$ppAppsExclude = False
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_UNCHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = False
				$ppAppsExclude = True
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_UNCHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = False
				$ppAppsExclude = False
				$ppGamesExclude = True
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_CHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_CHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = False
				$ppAppsExclude = False
				$ppGamesExclude = False
			Case GUICtrlRead($Checkbox_ssAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppAppsSelect) = $GUI_UNCHECKED And GUICtrlRead($Checkbox_ppGamesSelect) = $GUI_UNCHECKED
				$ssAppsOnly = False
				$ppAppsOnly = False
				$ppGamesOnly = False
				$ssAppsExclude = True
				$ppAppsExclude = True
				$ppGamesExclude = True
		EndSelect
		NeoIniWrite($Defaults, 'Options', 'ssAppsOnly', $ssAppsOnly)
		NeoIniWrite($Defaults, 'Options', 'ppAppsOnly', $ppAppsOnly)
		NeoIniWrite($Defaults, 'Options', 'ppGamesOnly', $ppGamesOnly)
		NeoIniWrite($Defaults, 'Options', 'ssAppsExclude', $ssAppsExclude)
		NeoIniWrite($Defaults, 'Options', 'ppAppsExclude', $ssAppsExclude)
		NeoIniWrite($Defaults, 'Options', 'ppGamesExclude', $ppGamesExclude)

		$ScanAllDrives = GUICtrlRead($Checkbox_ScanAllDrives) = $GUI_CHECKED
		$CheckForLocal = GUICtrlRead($Checkbox_ScanLocal) = $GUI_CHECKED
		$CheckOnlineLibrary = GUICtrlRead($Checkbox_ScanOnline) = $GUI_CHECKED
		If Not ($CheckForLocal Or $CheckOnlineLibrary) Then $CheckOnlineLibrary = True
		NeoIniWrite($Defaults, 'Scan', 'AllDrives', $ScanAllDrives);,GUICtrlRead($Checkbox_ScanAllDrives) = $GUI_CHECKED
		NeoIniWrite($Defaults, 'Scan', 'Local', $CheckForLocal);, GUICtrlRead($Checkbox_ScanAllDrives) = $GUI_CHECKED
		NeoIniWrite($Defaults, 'Scan', 'Online', $CheckOnlineLibrary);, GUICtrlRead($Checkbox_ScanAllDrives) = $GUI_CHECKED
		DetailOptions()
	EndIf
EndFunc

Func Start()
	Local $i, $sc_EXE, $sc_Args, $sc_WorkDir, $aData, $rDL, $InstallOk
	Local $Output, $tmpfile, $ISOProgress, $Totalerr, $Percentage, $line, $SetPercentage, $finished
	Select
		Case $ISOMakerMode ;Insert!
			$VolumeData = 'Test'
			$TemplateISO = @ScriptDir & '\ISO_Template.iso'
			$TargetISO = 'D:\Test'
			$Source = GetFilename($TargetISO)
			$CopyTemplateISO = True
			If $CopyTemplateISO Then
				$Output = @TempDir & '\7z x -y -aoa ' & FileGetShortName($TemplateISO) & ' -o"' & $Source & '"'
				RunWait($Output, @TempDir, @SW_HIDE)
			EndIf
			For $i = 1 To $ItemsList[0][0]
				Select
					Case BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_CHECKED) = $GUI_CHECKED Or BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_FOCUS) = $GUI_FOCUS
						GUISetState(@SW_HIDE, $Form_ssGooey)
						GUISetState(@SW_HIDE, $Form_ssGooey_Options)
						;copy (or extract) files to xxInstalls folders
				EndSelect;switch
			Next
			$tmpfile = FileOpen($TargetISO, 2)
			$ISOProgress = ProgressOn("Creating ISO", "Creating:  " & $VolumeData, "Percent Complete")
			FileClose($tmpfile)
			Sleep(1000)
			FileDelete($TargetISO)
			;@ComSpec & ' /c ' &
			$Output = @TempDir & '\mkisofs -o "' & $TargetISO & '.iso' & '" -J -R -V' & $VolumeData & ' ' & FileGetShortName($Source)
			$Output = Run($Output, @TempDir, @SW_HIDE, $STDERR_CHILD)
			$Totalerr = ""
			$Percentage = ""
			While 1
				$line = StderrRead($Output)
				If @error <> 0 Then ExitLoop
				$line = StringStripWS($line, 1)
				If StringInStr($line, "%") Then
					$SetPercentage = StringTrimRight($line, (StringLen($line) - 2))
					ProgressSet($SetPercentage)
				EndIf
				$Totalerr = $Totalerr & $line & @CRLF
			WEnd
			ProgressOff()
			$finished = MsgBox(4, "Finished", "The ISO file has been created as " & FileGetShortName($TargetISO) & @CRLF & @CRLF & "Would you like to open this location now?")
			If $finished = 6 Then Run("Explorer.exe " & StringLeft($TargetISO, StringInStr($TargetISO, "\", 0, -1)))
		Case $LauncherMode ; Launch! or Play!
			For $i = 1 To $ItemsList[0][0]
				Select
					Case BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_CHECKED) = $GUI_CHECKED Or BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_FOCUS) = $GUI_FOCUS
						GUISetState(@SW_HIDE, $Form_ssGooey)
						GUISetState(@SW_HIDE, $Form_ssGooey_Options)
						;$ItemsList[$i][1] = $App_InstallPath
						;$ItemsList[$i][2] = $SplashTemp
						;$ItemsList[$i][3] = $App_Title
						;$ItemsList[$i][4] = $App_Version
						;$ItemsList[$i][5] = Construct_AppCategory()
						;$ItemsList[$i][6] = $App_Architecture
						;$ItemsList[$i][7] = $App_OS
						;$ItemsList[$i][8] = $App_Type
						;$ItemsList[$i][9] = $App_smSource ;Startmenu
						;$ItemsList[$i][10] = $App_scEXE[1]
						;$ItemsList[$i][14] = $App_scArgs[1]
						;$ItemsList[$i][15] = $App_scWorkDir[1]
						$sc_EXE = ConvertFromVars(ConvertToVars($ItemsList[$i][10]))
						If $sc_EXE <> '' And StringInStr($sc_EXE, ':') = 0 Then $sc_EXE = $ItemsList[$i][1] & '\' & $sc_EXE
						$sc_Args = ConvertFromVars(ConvertToVars($ItemsList[$i][14]))
						If $sc_Args <> '' Then $sc_Args = ' ' & $sc_Args
						$sc_WorkDir = ConvertFromVars(ConvertToVars($ItemsList[$i][15]))
						If $sc_WorkDir = '' Or $sc_WorkDir = '.' Then
							$sc_WorkDir = $ItemsList[$i][1]
						Else
							If StringInStr($sc_WorkDir, ':') = 0 Then $sc_WorkDir = $ItemsList[$i][1] & '\' & $sc_WorkDir
						EndIf
						RunWait($sc_EXE & $sc_Args, $sc_WorkDir)
						ExitLoop
				EndSelect;switch
			Next
		Case $InstallerMode ;Install!
			For $i = 1 To $ItemsList[0][0]
				$InstallOk = True
				Select
					Case BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_CHECKED) = $GUI_CHECKED Or BitAND(GUICtrlRead($ItemsList[$i][12], 0), $GUI_FOCUS) = $GUI_FOCUS
						If StringInStr($ItemsList[$i][1], $ssTekResources & '\oll\') = 1 Then ;Download it
							$rDL = GetFolderPath($ItemsList[$i][1]) & '\dl\' & GetFilename($ItemsList[$i][1])
							$aData = DownloadFile($OnlineLibraryLink & '/' & GetFilename($ItemsList[$i][1]), $rDL, True, True, GetFilename($ItemsList[$i][1]))
							If IsArray($aData) And $aData[3] Then $ItemsList[$i][1] = $rDL
						EndIf
						GUISetState(@SW_HIDE, $Form_ssGooey)
						GUISetState(@SW_HIDE, $Form_ssGooey_Options)
						$SetupS_Args = ' -ssClean=off'
						If $Fadertainer Then
							$SetupS_Args = $SetupS_Args & ' -Fadertainer=On'
							If $FaderSpeed > 0 Then $SetupS_Args = $SetupS_Args & ' -FaderSpeed=' & $FaderSpeed
							If $FaderLocation <> '' Then $SetupS_Args = $SetupS_Args & ' -FaderLocation=' & $FaderLocation
						Else
							$SetupS_Args = $SetupS_Args & ' -Fadertainer=Off'
						EndIf
						Select
							Case StringInStr($ItemsList[$i][1], $ssTekResources & '\oll\') = 0
							Case StringInStr($ItemsList[$i][1], $ssTekResources & '\oll\dl\') = 1
							Case Else
								$InstallOk = False
						EndSelect
						If $InstallOk Then
							RunWait($SetupS & ' ' & FileGetShortName($ItemsList[$i][1]) & $SetupS_Args);
						EndIf
				EndSelect;switch
			Next
	EndSelect
	GUISetState(@SW_SHOW, $Form_ssGooey)
	Select
		Case $LauncherMode
			$ssGooeyQuit = True
		Case $InstallerMode
			UberScan()
		Case $ISOMakerMode
			UberScan()
	EndSelect
EndFunc

Func UberScan()
	HotKeySet('{F5}')
	_PinsClear()
	ReDim $ItemsList[1][16]
	$ItemsList[0][0] = 0
	$ItemsCount = 0
	If Not $FirstScan Then ModeScan()
	$FirstScan = False
	If Not $DoNotPopulate Then
		For $i = 1 To $ExpressInstall[0]
			PopulateArray($ExpressInstall[$i])
		Next
		$DoNotPopulate = False
	EndIf
	UpdateItemsCount()
	If $SplashTips Then SplashThis('Sorting ...', $ItemsCount & ' Items found')
	_ArraySort($ItemsList, 0, 1, 0, 0)
	PopulateCategories()
	;_ArrayDisplay($ItemsList, '$ItemsList')
	_PinsSetAll()
	SplashOff()
	TrayTip($ThisAppTitle, '', 1)
	HotKeySet('{F5}', 'UberScan')
EndFunc

Func UpdateItemLabel($What)
	GUICtrlSetData($Label_Item, $What)
	Local $sLabelMsg = $What
	Local $sFont = 'MS Sans Serif'
	Local $iSize = 12
	Local $iWeight = 800
	Local $iAttrib = 0
	Local $aCtrlSize = _StringSize($sLabelMsg, $iSize, $iWeight, $iAttrib, $sFont)
	Local $aCtrlPos = ControlGetPos($Form_ssGooey, GUICtrlRead($Label_Item), $Label_Item)
	;_ArrayDisplay($aForm_ssGooey, '$aForm_ssGooey')
	;_ArrayDisplay($aCtrlSize, '$aCtrlSize')
	;_ArrayDisplay($aCtrlPos, '$aCtrlPos')
	GUICtrlSetPos($Label_Item, $aCtrlPos[0], $aCtrlPos[1], $aCtrlSize[2], $aCtrlSize[1]);l,t,w,h
	CenterMe($Form_ssGooey, $Label_Item, $Form_ssGooey_Width, 385)
EndFunc

Func UpdateItemsCount()
	Local $i, $Selected = 0, $Hidden, $Total = $ItemsCount
	For $i = 1 To $ItemsList[0][0]
		Switch GUICtrlRead($ItemsList[$i][12], 0)
			Case 1, 256, 257
				$Selected += 1
		EndSwitch
	Next
	$Hidden = $ItemsList[0][0] - $ItemsCount
	Local $temp = $Selected & '/' & $Total & ' Items Selected plus ' & $Hidden & ' Items Hidden'
	GUICtrlSetData($Label_Items, $temp)
	Local $sLabelMsg = $temp
	Local $sFont = 'MS Sans Serif'
	Local $iSize = 10
	Local $iWeight = 800
	Local $iAttrib = 0
	Local $aCtrlSize = _StringSize($sLabelMsg, $iSize, $iWeight, $iAttrib, $sFont)
	Local $aCtrlPos = ControlGetPos($Form_ssGooey, GUICtrlRead($Label_Items), $Label_Items)
	;_ArrayDisplay($aForm_ssGooey, '$aForm_ssGooey')
	;_ArrayDisplay($aCtrlSize, '$aCtrlSize')
	;_ArrayDisplay($aCtrlPos, '$aCtrlPos')
	GUICtrlSetPos($Label_Items, $aCtrlPos[0], $aCtrlPos[1], $aCtrlSize[2], $aCtrlSize[1]);l,t,w,h
	CenterMe($Form_ssGooey, $Label_Items, $Form_ssGooey_Width / 2, 0)
EndFunc
#endregion
#region ; -- Options Form
Func BtnTargetClick()
	$TargetISO = FileSaveDialog('Target ISO file', '', 'IMAGE files (*.ISO)', 16)
	If Not @error Then
		If StringRight($TargetISO, 4) <> '.iso' Then $TargetISO = $TargetISO & '.iso'
		GUICtrlSetData($Input_TargetISO, $TargetISO)
		IsReady()
	EndIf
EndFunc

Func Button_BrowseForTemplateISOClick()
	$TemplateISO = FileOpenDialog('Browse for Template ISO to copy', @ScriptDir, 'Template ISO (*.iso)', 1)
	If Not @error Then
		GUICtrlSetData($Input_TemplateISO, $TemplateISO)
		IsReady()
	EndIf
EndFunc
Func Button_Load_PresetClick()
EndFunc
Func Button_OptionsCloseClick()
	GUISetState(@SW_HIDE, $Form_ssGooey_Options)
EndFunc
Func Button_SavePresetClick()
EndFunc
Func Checkbox_Arch_FriendlyClick()
EndFunc
Func Checkbox_CopyTemplateISOClick()
	$CopyTemplateISO = Not $CopyTemplateISO
	If $CopyTemplateISO Then
		If $TemplateISO = '' Then Button_BrowseForTemplateISOClick()
		GUICtrlSetState($Checkbox_CopyTemplateISO, $GUI_CHECKED)
		GUICtrlSetState($Input_TemplateISO, $GUI_Enable)
		GUICtrlSetState($Button_BrowseForTemplateISO, $GUI_Enable)
	Else
		GUICtrlSetState($Checkbox_CopyTemplateISO, $GUI_UNCHECKED)
		GUICtrlSetState($Input_TemplateISO, $GUI_DISABLE)
		GUICtrlSetState($Button_BrowseForTemplateISO, $GUI_DISABLE)
	EndIf
EndFunc

Func Checkbox_Hide_InstalledClick()
EndFunc
Func Checkbox_HideScreenShotClick()
EndFunc
Func Checkbox_OS_FriendlyClick()
EndFunc
Func Checkbox_ppAppsSelectClick()
EndFunc
Func Checkbox_ppGamesSelectClick()
EndFunc
Func Checkbox_RebootPCClick()
EndFunc

Func Checkbox_ScanAllDrivesClick()
EndFunc
Func Checkbox_ScanLocalClick()
EndFunc
Func Checkbox_ScanOnlineClick()
EndFunc

Func Checkbox_ssAppsSelectClick()
EndFunc
Func Form_ssGooey_OptionsClose()
	Button_OptionsCloseClick()
EndFunc
Func Form_ssGooey_OptionsMinimize()
EndFunc
Func Form_ssGooey_OptionsMaximize()
EndFunc
Func Form_ssGooey_OptionsRestore()
EndFunc
Func Input_TargetISOChange()
EndFunc
Func Input_TemplateISOChange()
EndFunc
Func Input_VolumeChange()
	IsReady()
EndFunc

Func IsReady()
;~ 	$VolumeData = StringReplace(GUICtrlRead($Input_Volume), ' ', '.')
;~ 	If $VolumeData <> '' And FileExists(FileGetShortName($Source)) <> '' And $TargetISO <> '' Then
;~ 		If $CopyTemplateISO And FileExists(FileGetShortName($TemplateISO)) Then
;~ 			GUICtrlSetState($Button_Start, $GUI_Enable)
;~ 		Else
;~ 			GUICtrlSetState($Button_Start, $GUI_DISABLE)
;~ 		EndIf
;~ 	Else
;~ 		If $CopyTemplateISO And FileExists(FileGetShortName($TemplateISO)) Then
;~ 			GUICtrlSetState($Button_Start, $GUI_Enable)
;~ 		Else
;~ 			GUICtrlSetState($Button_Start, $GUI_DISABLE)
;~ 		EndIf
;~ 	EndIf
EndFunc
Func Label_CheckForUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CheckForUpdateClick()' & @CRLF)
	UpdateMe('update.ini', @ScriptDir, True, $UseGUI)
EndFunc

Func Label_TargetISOClick()
EndFunc
Func Label_VolumeClick()
EndFunc
Func PageControl_OptionsChange()
EndFunc
Func Radio_InstallerModeClick()
EndFunc
Func Radio_ISOMakerModeClick()
EndFunc
Func Radio_LauncherModeClick()
EndFunc
#endregion
;~

