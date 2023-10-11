@echo off

regedit /s %~dp0\MyOEM7\ssWPI\RunAsAdmin.reg

start %~dp0\MyOEM7\ssWPI\ssWPI.exe
