<Title>
	SetupS SFX

<Version>
	v8.12.1.0

<Description>
Convert SetupS archives (.apz/.pgz)  to stand-alone self-extracting executables (SFX) using the latest SetupS components (v8.12.1.0).

<URL>
	http://www.LastOS.org
	http://ssTek.Vergitek.com

<Category>
	System

<BuildType>
	ppApp

<AppPath>
	%ppApps%\SetupS.SFX

<StartMenuSourcePath>
	SetupS SFX

<Catalog>
	Installing

<StartMenuDestPath>
	4 System\0 Installers & Setups
	- System\- Add, Install, & Setup

<Flags>
	KeepAll = No

<ShortcutS>
	Target="ssSFX.exe"
	Comment="Convert SetupS archives to SFX."
	Name="SetupS SFX"

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

<End>
