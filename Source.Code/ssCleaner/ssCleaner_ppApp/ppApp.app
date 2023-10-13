[SetupS]
Title=ssCleaner
Version=v16.10.2.2
Description=Deep clean your dud links automatically & safely. Removes all the dead shortcuts & empty folders from your Start Menu, Desktop, SendTo, and QuickLaunch. Now cleans the unused Programs Files folders and SetupS remnants as well. Safely deletes everything to the Recycle Bin. (Inspired by the original "Link Luster Clean" by AnneAardvark)The following are some of the parameters/switches it recognizes (for the CLI Junkies):-StartMenuOnly=Yes|No: Determines whether to limit the cleaning to only the StartMenu dud shortcuts or to include all shortcut locations such as Desktop, Sendto, & Quicklaunch. (Default=Yes)-Mute|Silent|Quiet: Totally silent running (including system tray).-TrayOnly: Show progress only as balloon tips from the tray. Must have balloon tips enabled!-SplashOnly: Show progress only as splash text/message boxes and hides both the tray icon and any balloon tips from the tray.Usage example: ssCleaner.exe -StartMenuOnly=No
URL=http://sstek.vergitek.com|http://www.lastos.org
Category=Disk
BuildType=ppApp
App-File Style=2 (INI)
AppPath=%ppApps%\ssCleaner
StartMenuSourcePath=ssCleaner
Catalog=Disk Cleaning|System
StartMenuLegacyPrimary=- Disk\- Clean, Defrag & Uninstall|- System
StartMenuLegacySecondary=0 Disk\1 Management|4 System
Flags=KeepInFolder|KeepAll
App-File Version=v9.16.5.8.0
[ssCleaner (GUI).lnk]
Target=ssCleaner.exe
Comment=Deep clean your StartMenu dud links automatically & safely
[Clean StartMenu only (Immediate).lnk]
Target=ssCleaner.exe
Arguments=-StartMenuOnly,NotDudInstallPaths,NoDeepScan
Comment=Deep clean your StartMenu dud links automatically & safely
[Clean ALL dud Shortcuts (Immediate).lnk]
Target=ssCleaner.exe
Arguments=-AllShortcuts,DudInstallPaths,DeepScan
Comment=Deep clean all your dud links automatically & safely
