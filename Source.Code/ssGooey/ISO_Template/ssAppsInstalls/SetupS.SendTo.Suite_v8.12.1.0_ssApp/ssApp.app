<Title>
	SetupS SendTo Suite

<Version>
	v8.12.1.0

<Description>
Add SetupS to the SendTo Menu. Allows for easy installing of SetupS apps such as ssApp's, ppApp's, or ppGame's. Simply right-click on an archive or the entire folder and SendTo "SetupS" or double-click on the ".app" or ".ppg" file.

That's it!

Now, easily update existing applications to the current one(s)
-- especially ppApps and still keep all your settings!

To unininstall, simply use the Add/Remove applet in Control Panel or
if it's a ppApp/Game then simply delete the associated folder from the
ppApps/Games folder -- and don't forget to run 'Super LL Clean' ;-)

Don't need or want "SetupS" available all the time? Also use the
Add/Remove applet in Control Panel to uninstall it.

<URL>
	http://www.LastOS.org
	http://ssTek.Vergitek.com

<Category>
	Addon

<AppPath>
	%ProgramFiles%\SetupS.SendTo

<Assembly>
	ssUninstaller.exe -StartMenuOnly -TrayOnly #Is_x86#
	ssUninstaller_x64.exe -StartMenuOnly -TrayOnly #Is_x64#
	"Install.SetupS_v8.12.1.0.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-

<StartMenuSourcePath>
	SetupS SendTo

<Catalog>
	System Installing

<StartMenuDestPath>
	4 System\0 Installers & Setups
	- System\- Add, Install, & Setup

<ShortCutNamesKeep>
	SetupS Editor
	SetupS Control Panel
	Regenerator\All SetupS-tech Regenerator
	Regenerator\ppApps Regenerator
	Regenerator\ppGames Regenerator
	Regenerator\ssApps Regenerator
	Regenerator\All Drives\All SetupS-tech Regenerator (all drives)
	Regenerator\All Drives\ppApps Regenerator (all drives)
	Regenerator\All Drives\ppGames Regenerator (all drives)

<Flags>
	KeepInFolder = Yes
	KeepAll = Yes
	MakeSendTo = Yes

<BuildType>
	ssApp

<ShortcutS>
	Target="SetupScp.exe"
	Comment="Applet to select an Advanced StartMenu/Sorting Style, ppDrives, etc."
	Name="SetupS Control Panel"

	Target="ssEditor\ssEditor.exe"
	StartIn="ssEditor"
	Name="SetupS Editor"

	Target="Regenerator.exe"
	Arguments=-AllDrives=no
	Comment="Create StartMenu Shortcuts for all your ssApps, ppApps, & ppGames"
	Name="Regenerator\All SetupS-tech Regenerator"

	Target="Regenerator.exe"
	Arguments=-ppApps -AllDrives=no
	Comment="Create StartMenu Shortcuts for all your ppApps"
	Name="Regenerator\ppApps Regenerator"

	Target="Regenerator.exe"
	Arguments=-ppGames -AllDrives=no
	Comment="Create StartMenu Shortcuts for all your ppGames"
	Name="Regenerator\ppGames Regenerator"

	Target="Regenerator.exe"
	Arguments=-ssApps
	Comment="Create StartMenu Shortcuts for all your SetupS/ssApps"
	Name="Regenerator\ssApps Regenerator"

	Target="Regenerator.exe"
	Arguments=-AllDrives=yes
	Comment="Create StartMenu Shortcuts for all your ssApps, ppApps, & ppGames on all your drives"
	Name="Regenerator\All Drives\All SetupS-tech Regenerator (all drives)"

	Target="Regenerator.exe"
	Arguments=-ppApps -AllDrives=yes
	Comment="Create StartMenu Shortcuts for all your ppApps on all your drives"
	Name="Regenerator\All Drives\ppApps Regenerator (all drives)"

	Target="Regenerator.exe"
	Arguments=-ppGames -AllDrives=yes
	Comment="Create StartMenu Shortcuts for all your ppGames on all your drives"
	Name="Regenerator\All Drives\ppGames Regenerator (all drives)"

	Target="SetupScp.exe"
	Arguments=-Kazz
	Comment="Installs and resorts to the Kazz Advanced StartMenu sorting-structure."
	Name="StartMenu Resorting\Kazz"

	Target="SetupScp.exe"
	Arguments=-LastOS
	Comment="Installs and resorts to the LastOS Advanced StartMenu sorting-structure."
	Name="StartMenu Resorting\LastOS"

	Target="SetupScp.exe"
	Arguments=-Resort
	Comment="Resorts to the current StartMenu sorting-structure."
	Name="StartMenu Resorting\Resort"

	Target="SetupScp.exe"
	Arguments=-Standard
	Comment="Installs and resorts to the Standard StartMenu sorting-structure."
	Name="StartMenu Resorting\Standard"

<Script>
	:Create Folder Icon for Tools
	cd Tools
	attrib . +s
	attrib desktop.ini -h -s >nul:
	echo [.ShellClassInfo] >desktop.ini
	echo ConfirmFileOp=0 >>desktop.ini
	echo IconFile=.\Tools.ico >>desktop.ini
	echo IconIndex=0 >>desktop.ini
	attrib desktop.ini +h +s
	cd ..
	
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
	
	:Create Folder Icon for ssEditor
	cd ssEditor
	attrib . +s
	attrib desktop.ini -h -s >nul:
	echo [.ShellClassInfo] >desktop.ini
	echo ConfirmFileOp=0 >>desktop.ini
	echo IconFile=.\ssEditor.ico >>desktop.ini
	echo IconIndex=0 >>desktop.ini
	attrib desktop.ini +h +s

<End>
