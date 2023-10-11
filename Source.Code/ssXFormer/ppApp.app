[SetupS]
Title=#ExtraApp#
Version=v#ProjectVersion#
Description=Convert SetupS archives (.apz/.pgz)  to stand-alone self-extracting executables (SFX) using the latest SetupS components (v#CoreVersion#).
URL=http://#WebLink1#|http://#WebLink2#
Category=System
BuildType=ppApp
App-File Format=v9.14.1.1.0
App-File Style=2 (INI)
AppPath=%ppApps%\#ExtraApp#
StartMenuSourcePath=#ExtraApp#
Catalog=Installing
StartMenuLegacyPrimary=- System\- Add, Install, & Setup
StartMenuLegacySecondary=4 System\0 Installers & Setups
[#ExtraApp#.lnk]
Target=#ExtraApp#.exe
Comment=Convert SetupS archives to SFX
