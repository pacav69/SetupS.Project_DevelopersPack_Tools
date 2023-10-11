@echo off

:Set parameters
set ProjectVersion=16.7.6.4
set ProjectDate=2016-07-20
set Upload=No

:Begin
call !DistrPack.ExtraApp.cmd %ProjectVersion% %ProjectDate% %Upload% ssXFormer

:Exit