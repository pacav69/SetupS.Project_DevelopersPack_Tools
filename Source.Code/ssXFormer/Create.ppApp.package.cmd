@echo off

:Begin
set sc=Source.Code
cd "%~dp0"

:UpdateTools
if exist "Tools" rd /s /q "Tools" >nul:
if exist "sfx" rd /s /q "sfx" >nul:
md Tools >nul:
md sfx >nul:
xcopy %~dp0..\Tools\*.* Tools\*.* /s/e/y >nul:
copy %~dp0..\Category.ini Tools\Category.ini /y >nul:
copy %~dp0..\MenuDefaults.ini Tools\MenuDefaults.ini /y >nul:
copy %~dp0..\ssConfig.ini Tools\ssConfig.ini /y >nul:
copy %~dp0..\..\sfx\7zSD.sfx sfx\7zSD.sfx /y >nul:

:ppApp
if exist "%1_ppApp" rd /s /q "%1_ppApp" >nul:
md "%1_ppApp" >nul:
cd "%1_ppApp" >nul:
copy ..\%1.exe /y >nul:
copy ..\%1_x64.exe /y >nul:
copy ..\%1.ini /y >nul:
copy ..\ppApp.* /y >nul:
if exist ..\folder.* copy ..\folder.* /y >nul:
if exist ..\ChangeLog.txt copy ..\ChangeLog.txt /y >nul:
md Tools >nul:
xcopy ..\Tools\*.* Tools\*.* /e/s/y >nul:
md sfx >nul:
xcopy ..\sfx\*.* sfx\*.* /e/s/y >nul:

:AddSourceCode
md %sc%\%1
cd %sc%
copy ..\..\..\SetupS.Core.au3 /y >nul:
cd %1
copy ..\..\..\%1.au3 /y >nul:
copy ..\..\..\%1.kxf /y >nul:
cd ..
md UDFs
cd UDFs
copy ..\..\..\..\UDFs\APIConstants.au3 /y >nul:
copy ..\..\..\..\UDFs\StringSize.au3 /y >nul:
copy ..\..\..\..\UDFs\7zRead.au3 /y >nul:
cd ..
cd ..

:AddLicenses
md Licenses
cd Licenses
copy ..\..\..\Licenses\GNU.General.Public.License_GPLv3.txt /y >nul:
copy ..\..\..\Licenses\OSI.ico /y >nul:
cd ..

goto exit
:Exit