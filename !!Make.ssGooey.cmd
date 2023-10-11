@echo off

:Set parameters
set ProjectVersion=14.6.30.1
set ProjectDate=2014-06-30
set Upload=Yes

:Begin
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssGooey

:Exit