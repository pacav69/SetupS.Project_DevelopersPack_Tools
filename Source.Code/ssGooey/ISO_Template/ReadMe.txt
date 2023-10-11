
~-------------~+~-------------~
 LastOS Tech -- www.LastOS.org
~-------------~+~-------------~


~-- Important Tools --~

> ssWPI - an automated installer that allows you to select the application or tweaks you want on your OS, this is available to run from the LivePE to select the apps you want to have installed along side the LastOS installed OS, Just run it from the icon on the desktop, select your applications and press done, run the Installer for x86 or x64 to install the OS and it will install the applications at the end of the OS install.

There's lots you can do in the apps menu screen but the main thing you need to know is the difference between "ssApp" apps and "ppApp" apps. The main difference is that ssApps are installed onto your machine in the standard way; i.e., the programs are usually installed into your Program Files folder (c:\program files) and you should be able to see the app in the list of apps that are possible to remove/uninstall. The installation of a ssApp happens without you having to do anything, of course, as they are Silent. ppApps are best thought of as portable apps ('pp' stands for Permanent Portable) that are designed in such a way as to make life much easier with regard to your favorite apps -- you can keep ppApps on a partition or drive that is not your system drive, and you can keep them there even when you reinstall your PC. The information stored in the ppApp.app files of these apps allow for these apps to be all 're-installed' in one action -- shortcuts and settings and all -- by running the "ppApps Regenerator" (included with Setups). To put it a different way, ppApps are more OS-independent than ssApps and can be kept on a PC even when the OS is reinstalled on it. 

ssApps are coloured white in the list of apps, and they appear first in alphabetical order. The ppApps are coloured yellow and are next. There is a special type of ppApp that is designed to be used on Live OS discs and they live in a folder called 'ppAppsLive'. These can also be used on a machine with a standard OS and so they are also listed in the Apps menu. The difference between the normal ppApps and the ones designed to be used on a LivePE are minimal, although some sorting locations will be different to the standard and some of these may use a SFX (Self Extracting Archive) to extract and then run from the temp folder of your PC.


> Settings - This allows fast access to Computer Management tools as well as setting some options for your installed OS, such as being able to move all your Documents, Pictures, Music, Videos and Favorites on to another Drive (so the next time you have to re-install you pick the same drive again and they will all still be there ready to access from your freshly installed OS). It also allows you to enter your name and a PC name, and it lets you choose on which drive or partition you would like to install your ppApps. 


> AutoStart Menu - This is included in the root of the DVD/USB install media to allow quick access to the tools above as well as other tools you might need.


> SetupS - An central part of the LastOS experience is to be able to install applications in an easy, sorted, and automated way. "SendTo SetupS" will install your applications without requiring you to run the ssWPI to do so. Many new and updated applications can be found on the www.LastOS.org website. SetupS has undergone major development during 2010 and 2011 and now it has integrated Start Menu sorting options and allows for automatic icon allocation to app folder, and many things more. SetupS allows you to install the ppApps and ssApps (portable and installer type apps) that install silently and produce start menu shortcuts (whether you like using standard start menu sorting or advanced start menu sorting (such as the "LastOS Menu Sorting" option that SetupS provides). 




~---------------~+~---------------~

Some additional information about SetupS, ppApps/ssApps, and ssWPI:

"SetupS" is central to the pp/ssApps and ppGames. SetupS is responsible for installing the apps and games, allows for start menu sorting methods (for neatly, categorized menus), works in conjunction with a highly modded WPI (Windows Post Installer) called "ssWPI" that will allow you to install many pp/ssApps and/or ppGames at once, and more.

So, for example, the Mega Game Packs you came across are basically collections of ppGames that are presented to you by means of an ssWPI. ssWPI lets you click on each app or game in a list which will produce descriptions and screenshot/previews of the same. Furthermore, ssWPI will let you install a large number of games (or apps, in case of pp/ssApps) at the same time. So you just select the apps/games you want to install, say, 134 of them, and they will all install in 1 go, without requiring any interaction from you.

Anyway, to give a quick description of what ssApps and ppApps are:
- ssApps: installer based apps, installed silently
- ppApps: portable apps (or semi-portable, as *true* portables don't use reg entries, etc.)
(- ppGames basically are just like ppApps, but they are games, not applications)

Each ss/ppApp contains a file with the .app extension, which contains all the install info, description and url of the app, start menu sorting options, shortcut names, etc. This .app file basically tells SetupS how to install the app.

So if you want to take a look at the apps provided here on LastOS.org, just download some from the "Apps and Games Packages Section". As you'll notice, they are in the .apz format, which is really an archive (.7z) renamed to .apz. So you can right-click the apps in .apz format by right-clicking and 'extract to folder' via 7-zip. The .apz format is recognized by SetupS, which is why you can just double-click the .apz files and this will install the respective app silently (provided, of course, that you have SetupS already installed).

In the folder thus extracted you will find several things: the above mentioned .app files that direct what SetupS will do with the app in question; an .exe or .msi (in case of ssApps), or archives (.7z) in case of ppApps; graphics files (usually: a .jpg, a .png, and a .ico file). The graphics files are not essential to the apps' installations, but are added to provide screenshots of the apps when used through ssWPI, and some other, fun things.

As you'll know, many installer type apps can install via switches. A common switch for many applications is /S, which will install an app silently. When dealing with .msi's the switches for silent installation are usually along the lines of /q (/qn, /qb, etc.). You can enter those switches in the .app files inside the ssApps, which, like I said, contain all the install info that SetupS uses to install and configure the app. So instead of having to work with cmd's and sfx installers all the time, you can make silent apps easily. The .app files are basically text files (open them in Notepad) and so are an easy and central way to install and configure your app. It also allows you to include registry entries for the app, which SetupS will then apply for you too. It can also register .dll's and .ocx files, etc.

As for ppApps, these are not in installer .exe or .msi form to begin with, but are archives of an app's actual program files. So for example, take an app like ImgBurn. The installer of that program will install that app to C:\Program Files\ImgBurn. But we may prefer to make a ppApp out of it instead (installs faster, plus we may not want all ImgBurn's context menu stuff installed, etc.). So we can archive the actual app files, and tell SetupS where to write/install the files to (ppApps folder on any drive/partition of your choice). ppApps are also a good option for many apps that don't come with silent switches for installation, and therefore can't be made into ssApps. The "pp" in "ppApps" stand for "permanent portable". The reason it is called "permanent" is that you can install them to a partition other than your system drive, then reinstall your PC, and have SetupS re-generate the ppApps on your other drive with a matter of seconds, and you'll have all those ppApps installed on your freshly installed system again, just as you had them before your OS re-install.

Just remember, SetupS is the central tool for all ppApps, ssApps, and ppGames. It is the central engine that installs and configures them, creates and/or manages their shortcuts and menu sorting methods, etc.

So far this has just been about SetupS and the pp/ss apps and games.

We also have a "LastOS7 Builder", which is a program that will allow you to build a customized Windows 7 image that includes a PE (we call it: LivePE), can integrate Windows updates, can overlay files to the WIM and the ISO, and more.

It also lets you add ssApps and ppApps to your image, so you can include your essential apps and also ssWPI to install them from, conveniently. So when you burn a disc (or save to your usb drive to install from), you will have an up-to-date Windows, integrated reg tweaks, themes, etc., and apps, all in one image. The Builder basically gives you the option of creating your own completely customized install disc/image.

~---------------~+~---------------~

