[SetupS]
Title=#ExtraApp#
Version=v#ProjectVersion#
Description=Deep clean your dud links automatically & safely. Removes all the dead shortcuts & empty folders from your Start Menu, Desktop, SendTo, and QuickLaunch. Now cleans the unused Programs Files folders and SetupS remnants as well. Safely deletes everything to the Recycle Bin. (Inspired by the original "Link Luster Clean" by AnneAardvark)The following are some of the parameters/switches it recognizes (for the CLI Junkies):-StartMenuOnly=Yes|No: Determines whether to limit the cleaning to only the StartMenu dud shortcuts or to include all shortcut locations such as Desktop, Sendto, & Quicklaunch. (Default=Yes)-Mute|Silent|Quiet: Totally silent running (including system tray).-TrayOnly: Show progress only as balloon tips from the tray. Must have balloon tips enabled!-SplashOnly: Show progress only as splash text/message boxes and hides both the tray icon and any balloon tips from the tray.Usage example: #ExtraApp#.exe -StartMenuOnly=No
URL=http://#WebLink1#|http://#WebLink2#
Category=Disk
BuildType=ppApp
App-File Style=2 (INI)
AppPath=%ppApps%\#ExtraApp#
StartMenuSourcePath=#ExtraApp#
Catalog=Disk Cleaning|System
StartMenuLegacyPrimary=- Disk\- Clean, Defrag & Uninstall|- System
StartMenuLegacySecondary=0 Disk\1 Management|4 System
Flags=KeepInFolder|KeepAll
App-File Version=v9.16.5.8.0
[#ExtraApp# (GUI).lnk]
Target=#ExtraApp#.exe
Comment=Deep clean your StartMenu dud links automatically & safely
[Clean StartMenu only (Immediate).lnk]
Target=#ExtraApp#.exe
Arguments=-StartMenuOnly,NotDudInstallPaths,NoDeepScan
Comment=Deep clean your StartMenu dud links automatically & safely
[Clean ALL dud Shortcuts (Immediate).lnk]
Target=#ExtraApp#.exe
Arguments=-AllShortcuts,DudInstallPaths,DeepScan
Comment=Deep clean all your dud links automatically & safely
