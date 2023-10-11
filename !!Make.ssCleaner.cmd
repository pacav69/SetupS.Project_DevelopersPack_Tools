@echo off

:Set parameters
set ProjectVersion=16.10.2.2
set ProjectDate=2016-10-02
set Upload=Yes

:Begin
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssCleaner

:Exit