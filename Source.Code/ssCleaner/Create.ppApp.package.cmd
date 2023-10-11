@echo off

:Begin
set sc=Source.Code
cd "%~dp0"
if exist "%1_ppApp" rd /s /q "%1_ppApp" >nul:
md "%1_ppApp" >nul:
cd "%1_ppApp" >nul:
copy ..\%1.exe /y >nul:
copy ..\%1_x64.exe /y >nul:
copy ..\%1.ini /y >nul:
copy ..\%1.hlp /y >nul:
copy ..\ppApp.* /y >nul:
if exist ..\folder.* copy ..\folder.* /y >nul:
if exist ..\ChangeLog.txt copy ..\ChangeLog.txt /y >nul:

md %sc%\%1
cd %sc%
copy ..\..\..\SetupS.Core.au3 /y >nul:
cd %1
copy ..\..\..\%1.au3 /y >nul:
cd ..
md UDFs
cd UDFs
copy ..\..\..\..\UDFs\APIConstants.au3 /y >nul:
copy ..\..\..\..\UDFs\StringSize.au3 /y >nul:
cd ..
cd ..

md Licenses
cd Licenses
copy ..\..\..\Licenses\GNU.General.Public.License_GPLv3.txt /y >nul:
copy ..\..\..\Licenses\OSI.ico /y >nul:
cd ..

goto exit
:Exit