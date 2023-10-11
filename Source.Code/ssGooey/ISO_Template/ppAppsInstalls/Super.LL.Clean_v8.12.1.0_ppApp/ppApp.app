<Title>
	Super LL Clean

<Version>
	v8.12.1.0

<Description>
Deep clean your dud links automatically & safely. Removes all the dead shortcuts & empty folders from your Start Menu, Desktop, SendTo, and QuickLaunch. Now cleans the unused Programs Files folders and SetupS remnants as well. Safely deletes everything to the Recycle Bin. (Inspired by the original "Link Luster Clean" by AnneAadrvark)

The following are some of the parameters/switches it recognizes (for the CLI Junkies):
-StartMenuOnly: Cleans only the StartMenu dud shortcuts.
-Mute|Silent|Quiet: Totally silent running (including system tray).
-TrayOnly: Show progress only as balloon tips from the tray. Must have balloon tips enabled!
-SplashOnly: Show progress only as splash text/message boxes and hides both the tray icon and any balloon tips from the tray.

Usage example: SuperLLClean.exe -StartMenuOnly

<URL>
	http://www.LastOS.org
	http://ssTek.Vergitek.com

<Category>
	Disk

<BuildType>
	ppApp

<AppPath>
	%ppApps%\SuperLLClean

<StartMenuSourcePath>
	SuperLLClean

<Catalog>
	System

<StartMenuDestPath>
	4 System|4 System
	- System|- System

<Flags>
	KeepInFolder = Yes
	KeepAll = Yes

<ShortcutS>
	Target="SuperLLClean.exe"
	Arguments=-NoWait
	Comment="Deep clean all your dud links automatically & safely"
	Name="Clean ALL dud Shortcuts"

	Target="SuperLLClean.exe"
	Arguments=-NoWait -StartMenuOnly
	Comment="Deep clean your StartMenu dud links automatically & safely"
	Name="Clean StartMenu only"

<Script>
	:Create Folder Icon for Licenses
	cd Licenses
	attrib . +s
	attrib desktop.ini -h -s >nul:
	echo [.ShellClassInfo] >desktop.ini
	echo ConfirmFileOp=0 >>desktop.ini
	echo IconFile=.\OSI.ico >>desktop.ini
	echo IconIndex=0 >>desktop.ini
	attrib desktop.ini +h +s
	cd ..

<End>
