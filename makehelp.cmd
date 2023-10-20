

@REM #######################################################
@REM ###  WebLink1=sstek.vergitek.com
@REM #######################################################

set WebSite1=ssTek Forum
set WebLink1=sstek.vergitek.com
set domain1=dev@lastos.org
set ftp1=ftp.vergitek.com
set Webfolder1=
set filesini1=filesvergitek.ini
set mvfilesini1=mvfiles1.ini


@REM  get the path from command line else set the default
:getPath
if [%1]==[] goto setPath
set HelpPath=%1
set HelpFile=%2
goto Begin

:setPath
set HelpPath=Source.Code
set HelpFile=ssTek

@REM create script file for upload
echo creating %filesini1% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%filesini1%" del /F /Q "%filesini1%" >nul:
@REM echo ; connect to ftp server  >>%filesini1%
echo open ftp://%domain2%:#Password#@%ftp2%/%Webfolder2%>>%filesini1%


echo put "%HelpPath%\files\*.*">>%filesini1%
echo put "%HelpPath%\%HelpFile%.html">>%filesini1%
echo put "%HelpPath%\favicon.ico">>%filesini1%

@REM "%HelpPath%\%HelpFile%.html" "%ssTekFTP%\help\%HelpFile%.html" /y >nul:



@REM echo put .\files\Development.Tools*.exe>>%filesini1%
@REM echo put .\files\Development.Tools*.md5>>%filesini1%
@REM echo put .\files\Development.Tools*.htm>>%filesini1%

@REM echo put .\files\ss*.apz>>%filesini1%
@REM echo put .\files\ss*.md5>>%filesini1%
@REM echo put .\files\ss*.htm>>%filesini1%

echo exit >>%filesini1%


@REM xcopy "%HelpPath%\files\*.*" "%ssTekFTP%\help\files\*.*" /s/e/y >nul:
@REM copy "%HelpPath%\%HelpFile%.html" "%ssTekFTP%\help\%HelpFile%.html" /y >nul:
@REM copy "%HelpPath%\favicon.ico" "%ssTekFTP%\help\favicon.ico" /y >nul:
