:Create Folder Icon for Licenses
cd Licenses
attrib . +s
attrib desktop.ini -h -s >nul:
echo [.ShellClassInfo] >desktop.ini
echo ConfirmFileOp=0 >>desktop.ini
echo IconFile=.\OSI.ico >>desktop.ini
echo IconIndex=0 >>desktop.ini
attrib desktop.ini +h +s
cd ..