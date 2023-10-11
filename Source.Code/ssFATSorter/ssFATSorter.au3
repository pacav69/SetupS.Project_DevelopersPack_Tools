#NoTrayIcon
#region
#AutoIt3Wrapper_Icon=ppApp.ico
#AutoIt3Wrapper_Outfile=#ExtraApp#.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Res_Description=ssFATSorter. Sort drives alphanumerically that use a FAT File System
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
	Alphanumerically sort files on drives that use a FAT File System
	
#ce ##################################################################################
#include <..\SetupS.Core.au3>
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
Opt("GUIOnEventMode", 0)

;------------------------------------------------------ Debug & Testing -----------------------------------------------------------
If Not @Compiled Then
	;Some examples of how to use this:
;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = '-SourceDrive=f:'

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = '-Descending=Yes'

;~ 	ReDim $CLIparameters[UBound($CLIparameters) + 1]
;~ 	$CLIparameters[0] = $CLIparameters[0] + 1
;~ 	$CLIparameters[$CLIparameters[0]] = '-help'

	Opt('TrayIconDebug', 1)
Else
	Opt('TrayAutoPause', 0) ;Turn off autopause
EndIf
Opt('TrayIconHide', 0) ;Show tray icon

;------------------------------------------------------ Declarations -------------------------------------------------------------
SetThisApp() ; Sets $ThisAppTitle, $ThisAppVersion, & $ThisAppFilename; plus DualArch

Global $LastFolder, $RememberLastFolder = True
Local $SrcDrv, $Comp1, $btn, $var, $i, $fs, $Checked = 0, $TitleMsg, $UpperMsg, $Recurse = False, $Descending = False
Dim $szDrive, $szDir, $szFName, $szExt
Local $AutoClose = 3, $MyName = _PathSplit(@ScriptFullPath, $szDrive, $szDir, $szFName, $szExt), $CLIparametersCount = $CLIparameters[0]
Local $App_Title_ExtraApp, $App_BuildType_ExtraApp, $App_Version_ExtraApp, $App_InstallPath_ExtraApp
Local $ssUpdateINI = CheckINI('ssUpdate.ini'), $ssExtraApp = CheckINI($ThisAppFilename & '.ini')
;~ If $MakeDefaultINI Then SetExtraAppDefaults($ssExtraApp)
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

;----------------------------------------------------- Get Parameters -------------------------------------------------------------
If GetParameter('Help') Or GetParameter('?') Then EndGame('Help requested', 'See displayed', True)
GetExtraAppOptions($ssExtraApp)
GetReportingMode($ssExtraApp)
GetAlternateDistribution($ssUpdateINI)
Local $UseGUI = ($CLIparametersCount = $AutoUpdateReturn), $Test
If $AutoUpdate And Not $NoUpdate Then UpdateMe('update.ini', @ScriptDir, $UseGUI)

If $LastFolder <> $Comp1 Then
	$RememberLastFolder = True
	$SrcDrv = $LastFolder
Else
	$SrcDrv = $Comp1
EndIf

; Get User sorting prefs
If $UseGUI Then
	Do
		$btn = GetDrive($TitleMsg, $UpperMsg, $SrcDrv)
	Until $btn = 2 Or ($btn = 1 And $SrcDrv <> $Comp1 And $SrcDrv <> '')
	If $btn <> 1 Then Exit
Else
	If GetParameterMulti('Descending', $Test) Then $Descending = $Test
	If GetParameterMulti('Recurse', $Test) Then $Recurse = $Test
	$Test = GetParameter('SourceDrive', '=')
	If $Test <> '' And FileExists($Test) Then $SrcDrv = $Test
EndIf

;Check File System
$fs = DriveGetFileSystem($SrcDrv)
Select
	Case $fs = 'NTFS'
		EndGame('File System Type: ' & $fs, 'This file system does not require sorting.', False, $AutoClose)
	Case $fs = 'UDF' Or $fs = 'CDFS'
		EndGame('File System Type: ' & $fs, 'This file system cannot be sorted!', False, $AutoClose)
	Case $fs = 1
		EndGame('File System Type: No Media', 'Nothing to sort!', False, $AutoClose)
EndSelect

;Save Prefs
IniWrite($ssExtraApp, 'Info', 'Recurse', $Recurse)
IniWrite($ssExtraApp, 'Info', 'Descending', $Descending)
If $RememberLastFolder = 1 Then IniWrite($ssExtraApp, 'Info', 'LastFolder', $SrcDrv)

;------------------------------------------------------ Begin -------------------------------------------------------------
Local $i, $uDir, $sDir, $identical, $iFlag = 4, $sOrder = 'GN', $pass = 0, $AbortSort = False
Local $Iterations = Int(DriveSpaceTotal($SrcDrv) / 1024 + .5)
If $Iterations = 0 Then $Iterations = 1
$Iterations *= 3
If $Recurse Then $iFlag = BitOR($iFlag, 8)
If $Descending Then $sOrder = 'G-N'
HotKeySet('{ESC}', 'AbortSort')
Do
	$pass += 1
	If $BalloonTips Then _TrayTip('Sorting', 'Pass #' & $pass & ' (Press Esc to Abort)', 300, 16)
	If $SplashTips Then SplashThis('Sorting', 'Pass #' & $pass & ' (Press Esc to Abort)')
	$Checked = SortFATDir($SrcDrv, $Descending, $Recurse)
	$uDir = _FileListToArrayPlus($SrcDrv, '*.*', $iFlag)
	$sDir = _FileListToArrayPlus($SrcDrv, '*.*', $iFlag, $sOrder)
	$identical = True
	If $uDir[0] = $sDir[0] Then
		For $i = 1 To $uDir[0]
			If $uDir[$i] <> $sDir[$i] Then
				$identical = False
				ExitLoop
			EndIf
		Next
	Else
		$identical = False
	EndIf
	Sleep(100)
Until $identical Or $AbortSort Or $pass > $Iterations

;---------------------------------------------------- Finished ------------------------------------------------------------------
SaveSettings()
EndGame('Finished...', $Checked & ' Items Sorted', False, $AutoClose)

Func AbortSort()
	$AbortSort = True
EndFunc

Func GetDrive($TitleMsg, $UpperMsg, ByRef $SrcDrv)
	Local $ibb_file1, $ibb_file2, $btn, $iOldOpt
	Local $Button_1, $Button_2, $Button_3, $msg
	Local $Radio_Ascending, $Radio_Descending, $Checkbox_Recurse
	Local $GUIWidth = 150 + 60 + 50, $GUIHeight = 6 * 20 + 5 * 5 + 32 + 20, $ButtonWidth = 60
	Local $InsideWidth = $GUIWidth - 20, $InputBoxWidth = $InsideWidth - $ButtonWidth - 5
	GUICreate($TitleMsg, $GUIWidth, $GUIHeight, (@DesktopWidth - $GUIWidth) / 2, (@DesktopHeight - $GUIHeight) / 3, -1);w,h,l,t
	$iOldOpt = Opt("GUICoordMode", 2)
	GUICtrlCreateLabel($UpperMsg, 10, 5, $InsideWidth, 20)
	$ibb_file1 = GUICtrlCreateInput($SrcDrv, -$InsideWidth, 0, $InputBoxWidth, 20)
	$Button_3 = GUICtrlCreateButton("Browse", 5, -1, $ButtonWidth, 20)
	GUICtrlCreateGroup("Sort order", -$InsideWidth + 5, 5, $InsideWidth - 10, 40)
	$Radio_Ascending = GUICtrlCreateRadio("Ascending", -($InsideWidth - 25), -24, 80, 20)
	$Radio_Descending = GUICtrlCreateRadio("Descending", 10, -1, 80, 20)
	$Checkbox_Recurse = GUICtrlCreateCheckbox("Sort Sub-folders", -135, 10, $InsideWidth - 20, 20)
	$Button_1 = GUICtrlCreateButton("Ok", -$InsideWidth, 10, $ButtonWidth, 20, $BS_DEFPUSHBUTTON)
	$Button_2 = GUICtrlCreateButton("Cancel", 20, -1, $ButtonWidth)
	GUICtrlCreateLabel($ThisAppTitle, -($InsideWidth - 75), 15, $InsideWidth, 20);l,t,w,h
	If $Descending Then
		GUICtrlSetState($Radio_Descending, $GUI_CHECKED)
		GUICtrlSetState($Radio_Ascending, $GUI_UNCHECKED)
	Else
		GUICtrlSetState($Radio_Ascending, $GUI_CHECKED)
		GUICtrlSetState($Radio_Descending, $GUI_UNCHECKED)
	EndIf
	If $Recurse Then
		GUICtrlSetState($Checkbox_Recurse, $GUI_CHECKED)
	Else
		GUICtrlSetState($Checkbox_Recurse, $GUI_UNCHECKED)
	EndIf
	$iOldOpt = Opt("GUICoordMode", 1)
	Local $Label_CheckForUpdate = GUICtrlCreateLabel("Check for Update...", 80, 175, 157, 17, $SS_RIGHT);l,t,w,h
	GUICtrlSetFont(-1, 8, 800, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	;GUICtrlSetOnEvent(-1, "Label_CheckForUpdateClick")
	GUICtrlSetCursor($Label_CheckForUpdate, 0) ; hand-hover
	If $NoUpdate Then GUICtrlSetState($Label_CheckForUpdate, $GUI_DISABLE)

	GUISetState()
	Do
		$msg = GUIGetMsg()
		Select
			Case $msg = $Checkbox_Recurse
				If BitAND(GUICtrlRead($Checkbox_Recurse), $GUI_CHECKED) = $GUI_CHECKED Then
					$Recurse = True
				EndIf
				If BitAND(GUICtrlRead($Checkbox_Recurse), $GUI_UNCHECKED) = $GUI_UNCHECKED Then
					$Recurse = False
				EndIf
			Case $msg = $Radio_Ascending Or $msg = $Radio_Descending
				If BitAND(GUICtrlRead($Radio_Ascending), $GUI_CHECKED) = $GUI_CHECKED Then
					$Descending = False
				EndIf
				If BitAND(GUICtrlRead($Radio_Descending), $GUI_CHECKED) = $GUI_CHECKED Then
					$Descending = True
				EndIf
			Case $msg = $Label_CheckForUpdate
				Label_CheckForUpdateClick()
		EndSelect
	Until $msg = $GUI_EVENT_CLOSE Or $msg = $Button_1 Or $msg = $Button_2 Or $msg = $Button_3
	$SrcDrv = GUICtrlRead($ibb_file1)
	GUIDelete()
	Select
		Case $msg = $GUI_EVENT_CLOSE Or $msg = $Button_2
			Return 2 ; Cancel
		Case $msg = $Button_1
			Return 1 ; Ok
		Case $msg = $Button_3
			$SrcDrv = FileSelectFolder("Choose a folder.", "")
			Return 3
	EndSelect
EndFunc

Func GetExtraAppOptions($Defaults)
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) SetupS.Core|GetExtraAppOptions(): $Defaults=' & $Defaults & @CRLF)
	Local $Test, $parmlist, $i
	If FileExists($Defaults) Then ;Get default settings
		$AutoUpdate = IniRead_Binary($Defaults, 'Options', 'AutoUpdate', 'No')
		; Get GUI info
		$TitleMsg = IniRead($ssExtraApp, 'Info', 'TitleMsg', 'Choose a folder to sort:')
		$UpperMsg = IniRead($ssExtraApp, 'Info', 'UpperLabel', 'This is only useful on (writable) FAT drives')
		$Comp1 = IniRead($ssExtraApp, 'Info', 'SourceDrive', 'type folder or browse -->')
		$LastFolder = IniRead($ssExtraApp, 'Info', 'LastFolder', $Comp1)
		$Descending = IniRead($ssExtraApp, 'Info', 'Descending', 'No')
		$Descending = ($Descending = 'Yes') Or ($Descending = '1') Or ($Descending = 'True') Or ($Descending = 'On')
		$Recurse = IniRead($ssExtraApp, 'Info', 'Recurse', 'No')
		$Recurse = ($Recurse = 'Yes') Or ($Recurse = '1') Or ($Recurse = 'True') Or ($Recurse = 'On')
	EndIf
	$Test = GetParameter('AutoUpdate', '=')
	If $Test <> '' Then
		If FileExists($Test) Then
			DeleteMe($Test)
			$AutoUpdate = False
			$AutoUpdateReturn = 1
		Else
			$AutoUpdate = ($Test = 'Yes') Or ($Test = '1') Or ($Test = 'True') Or ($Test = 'On')
		EndIf
	EndIf
EndFunc

;################################################## FUNCTIONS BELOW #############################################################

Func GetParameterMulti($What, ByRef $Value)
	Local $Found = False, $Test = GetParameter($What, '=')
	If $Test <> '' Then
		Switch $Test
			Case 'No', '0', 'False', 'Off'
				$Value = False
				$Found = True
			Case 'Yes', '1', 'True', 'On'
				$Value = True
				$Found = True
		EndSwitch
	Else
		If GetParameter($What) Then
			$Value = True
			$Found = True
		Else
			$Value = False
			$Found = True
		EndIf
	EndIf
	Return $Found
EndFunc

Func Label_CheckForUpdateClick()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|Label_CheckForUpdateClick()' & @CRLF)
	UpdateMe('update.ini', @ScriptDir, True, $UseGUI)
EndFunc

Func SaveSettings()
	If $Debug Then _ConsoleWriteDebug('@@ Debug(Trace) ' & @ScriptName & '|frm_MakeSFXClose()' & @CRLF)
	If FileExists($ssExtraApp) And Not $AutoBuild Then
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Mute', $SFXMute)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'TrayOnly', $SFXTrayOnly)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnly', $SFXSplashOnly)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'SplashOnTop', $SFXSplashOnTop)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Debug', $Debug)
		NeoIniWrite($ssExtraApp, 'Reporting Mode', 'Log', $Log)
		NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', $AutoUpdate)
		NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', $AutoUpdate)
		NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', $AutoUpdate)
		NeoIniWrite($ssExtraApp, 'Options', 'AutoUpdate', $AutoUpdate)
		NeoIniWrite($ssExtraApp, 'Info', 'Descending', $Descending)
		NeoIniWrite($ssExtraApp, 'Info', 'Recurse', $Recurse)
	EndIf
EndFunc

Func SortFATDir($Dir, $Descending = False, $Recurse = False)
	Local $DirArray[1], $FileArray[1], $i, $Checked = 0, $CurrentWorkingDir = @WorkingDir
	Local $d_DirName = '', $d_FileName = '', $DirCount = 0, $FileCount = 0, $TempArray[1], $Test
	$TempArray[0] = 0
	FileChangeDir($Dir)
	$DirArray = _FileListToArray(@WorkingDir, '*.*', 2) ; folders only
	If @error = 0 Then $DirCount = $DirArray[0]
	If $Recurse Then ;recurse thru subdirectories
		For $i = 1 To $DirCount
			$Checked = $Checked + SortFATDir($DirArray[$i], $Descending, $Recurse)
		Next
	EndIf
	$FileArray = _FileListToArray(@WorkingDir, '*.*', 1) ; files only
	If @error = 0 Then $FileCount = $FileArray[0]
	$Checked = $DirCount + $FileCount
	If $DirCount + $FileCount > 1 Then
		$d_DirName = _PathFull(StringMid(_TempFile(@WorkingDir, '', '', 8), 3))
		If DirCreate($d_DirName) = 0 Then Exit

		;Move 'em to temp folder
		For $i = 1 To $DirCount
			DirMove($DirArray[$i], $d_DirName & '\' & $DirArray[$i])
			$TempArray[0] += 1
			ReDim $TempArray[$TempArray[0] + 1]
			$TempArray[$TempArray[0]] = _PathFull(StringMid(_TempFile(@WorkingDir, '', '', 8), 3))
			If FileExists($DirArray[$i]) Then
				If Not DeleteMe($DirArray[$i]) Then
				EndIf
			EndIf
		Next
		For $i = 1 To $FileCount
			FileMove($FileArray[$i], $d_DirName & '\' & $FileArray[$i])
			$TempArray[0] += 1
			ReDim $TempArray[$TempArray[0] + 1]
			$TempArray[$TempArray[0]] = _PathFull(StringMid(_TempFile(@WorkingDir, '', '', 8), 3))
			FileClose(FileOpen($TempArray[$TempArray[0]], 2))
		Next

		;Sort 'em
		If $Descending Then
			_ArraySort($DirArray, 1, 1)
			_ArraySort($FileArray, 1, 1)
		Else
			_ArraySort($DirArray, 0, 1)
			_ArraySort($FileArray, 0, 1)
		EndIf

		;move 'em back
		For $i = 1 To $DirCount
			DirMove($d_DirName & '\' & $DirArray[$i], $DirArray[$i])
		Next
		For $i = 1 To $FileCount
			FileMove($d_DirName & '\' & $FileArray[$i], $FileArray[$i])
		Next
;~ 		$Test = _FileListToArrayPlus(@WorkingDir, '*.*', 2)
;~ 		If $Test[0] > 0 Then _ArrayDisplay($Test, '$Test')

		;delete temp files/folders
		DirRemove($d_DirName)
		For $i = 1 To $TempArray[0]
			If StringInStr(FileGetAttrib($TempArray[$i]), 'D') Then
				DirRemove($TempArray[$i])
			Else
				FileDelete($TempArray[$i])
			EndIf
		Next
	EndIf
	FileChangeDir($CurrentWorkingDir)
	Return $Checked
EndFunc
