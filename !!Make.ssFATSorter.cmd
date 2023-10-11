@echo off

:Set parameters
set ProjectVersion=15.4.10.0
set ProjectDate=2015-04-10
set Upload=Yes

:Begin
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssFATSorter

:Exit