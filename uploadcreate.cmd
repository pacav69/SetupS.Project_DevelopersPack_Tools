@echo off

@REM @REM #######################################################
@REM @REM ###  WebLink2=www.lastos.org
@REM @REM #######################################################
@REM set WebSite2=LastOS Forum
@REM set WebLink2=www.lastos.org
@REM set domain2=setups@lastos.org
@REM set ftp2=ftp.lastos.org
@REM set Webfolder2=
set filesini2=fileslastos.ini
@REM set mvfilesini2=mvfiles.ini


@REM #######################################################
@REM ### LastOS ftp upload create list
@REM #######################################################
@REM refer to set filesini2
:LastOSftp
@REM set oldfies = SetupSoldfies
echo creating %filesini2% for upload...
cd "%~dp0"
@REM create files to upload script for winscp useage
@REM ref: https://winscp.net/eng/docs/commandline
@REM https://winscp.net/eng/docs/scripting
@REM To insert comments into the script file, start the line with # (hash):
if exist "%filesini2%" del /F /Q "%filesini2%" >nul:
@REM echo ; connect to ftp server  >>%filesini2%
echo open ftp://%domain2%:#Password#@%ftp2%/%Webfolder2%>>%filesini2%
@REM echo # files to move >>%filesini2%
@REM if file does not exist then mv will fail terminating session
@REM it can be achieved by using ,net assembly refer to ref
@REM ref: https://winscp.net/eng/docs/library_session_fileexists
@REM add list of files to move to oldfies/
@REM echo echo moving files on ftp server
@REM if remote directory does not exist then session will fail and terminate
@REM set oldfies = SetupSoldfies\
@REM echo mkdir %oldfies%/>>%filesini2%

@REM add files for upload
@REM echo echo uploading files
@REM echo ; files to upload >>%filesini2%
@REM echo put .\files\update.ini>>%filesini2%
@REM echo put .\files\checksums_v%ProjectVersion%.md5>>%filesini2%
echo put .\files\Development.Tools*.exe>>%filesini2%
echo put .\files\Development.Tools*.md5>>%filesini2%
echo put .\files\Development.Tools*.htm>>%filesini2%


@REM echo put .\files\%ssApp%.apz>>%filesini2%
@REM echo put .\files\%ppApp%.7z>>%filesini2%
@REM echo put .\files\%ssUI%.exe>>%filesini2%
@REM echo put .\files\%scp%.7z>>%filesini2%
@REM echo put .\files\%devpack%.7z>>%filesini2%
@REM echo put .\files\%ssII%.exe>>%filesini2%

@REM echo put .\files\ChangeLog.txt>>%filesini2%
@REM echo put .\files\SetupS-files.htm>>%filesini2%
@REM echo put .\files\SetupS-title.png>>%filesini2%
echo exit >>%filesini2%

type %filesini2%
@REM pause


@REM echo end uploadcreate command