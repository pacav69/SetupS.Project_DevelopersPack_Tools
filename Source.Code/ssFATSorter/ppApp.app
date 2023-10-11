[SetupS]
Title=#ExtraApp#
Version=v#ProjectVersion#
Description=Alphanumerically sort files on drives that use a FAT file system. Especially useful to sort the files and folders on a USB flash drive or other portable media having a FAT12, FAT16, or FAT32 formatted disk. This works well on the devices that read them such as MP3 players, DivX/Xvid Video set-tops, Lynx, Muro, I-Bead, or your mobile phone flash card, etc.Useful to sort these FAT drives before using ssWPI/ssGooey.
URL=http://sstek.vergitek.com|http://sstek.googlecode.com
Category=Addon
BuildType=ppApp
App-File Format=v9.14.1.1.0
App-File Style=2 (INI)
AppPath=%ppApps%\#ExtraApp#
StartMenuSourcePath=#ExtraApp#
Catalog=Disk Directory|File Utility
StartMenuLegacyPrimary=- Disk\- Directory & File Utilities
StartMenuLegacySecondary=0 Disk\4 Directory & File Utilities
Flags=CurrentUserOnly
[#ExtraApp#.lnk]
Target=#ExtraApp#.exe
Comment=Sort FAT drives
