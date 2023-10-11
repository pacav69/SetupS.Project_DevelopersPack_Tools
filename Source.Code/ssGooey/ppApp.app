[SetupS]
Title=#ExtraApp#
Version=v#ProjectVersion#
Description=A new standalone front-end devoted to showcasing some of the best features of SetupS. This Three-In-One app will act as:1. a traditional Windows Post Installer (WPI).2. a ppLauncher (both ppApps and/or ppGames).3. and an ISO-maker to inject selected packages into a template ISO.
URL=http://#WebLink1#|http://#WebLink2#
Category=Development|Addon
BuildType=ppApp
App-File Format=v9.14.1.1.0
App-File Style=2 (INI)
AppPath=%ppApps%\#ExtraApp#
StartMenuSourcePath=#ExtraApp#
Catalog=System Installing|System Launching
StartMenuLegacyPrimary=- System\- Add, Install, & Setup|- System\- Launching, Context Menu & Tray
StartMenuLegacySecondary=4 System\0 Installers & Setups|4 System\3 Task Services
ShortCutNamesKeep=#ExtraApp# Installer|ppLauncher
Flags=KeepInFolder|KeepAll
[#ExtraApp#.lnk]
Target=#ExtraApp#.exe
[ppApps Launcher.lnk]
Target=#ExtraApp#.exe
Arguments=-ppAppsOnly=Yes -Launcher=Yes
[ppGames Launcher.lnk]
Target=#ExtraApp#.exe
Arguments=-ppGamesOnly=Yes -Launcher=Yes
