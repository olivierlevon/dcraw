@echo off

echo making dcraw for imagemagick



rem --------------------------------------------------------------------------------------------------
echo downloading sources...

wget http://www.ijg.org/files/jpegsr8b.zip
wget http://downloads.sourceforge.net/project/lcms/lcms/1.19/lcms-1.19.zip?use_mirror=freefr
wget http://www.cybercom.net/~dcoffin/dcraw/dcraw.c


rem --------------------------------------------------------------------------------------------------
echo extracting sources...

.\bin\unzip lcms-1.19.zip
.\bin\unzip jpegsr8b.zip
ren lcms-1.19 lcms
ren jpeg-8b jpeg
move  jpeg libjpeg\
rem mkdir dcraw
move  dcraw.c dcraw\


rem --------------------------------------------------------------------------------------------------
echo configuring build env...

rem pas nécessaire si tout par devenv

rem %comspec% /k ""c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"" x86
rem "c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86
call "c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86


rem --------------------------------------------------------------------------------------------------
echo starting build...

rem ****************************************************************************
echo building libjpeg...

echo configuring...

cd libjpeg\jpeg
rem C:\Program Files\Microsoft Visual Studio 9.0\VC\bin\nmake.exe
nmake -f makefile.vc setup-vc6


echo building...

rem APPVER = 5.01 
rem TARGETOS = WINNT 
rem _WIN32_IE = 0x0600

nmake -f makefile.vc nodebug=1  libjpeg.lib 
cd ..\..

rem devenv /build Release dcraw.sln  /project ".\libjpeg\jpeg.vcproj /projectconfig Release|Win32


rem ****************************************************************************
echo building lcms...

devenv /build Release dcraw.sln  /project ".\lcms\Projects\VC2008\lcms.vcproj /projectconfig Release|Win32


rem ****************************************************************************
echo building dcraw...

echo patching...

copy dcraw.c dcraw_im.c

.\bin\patch -p0 dcraw_im.c < dcraw900_1433im_diff.txt


echo building...

cl /MT /nologo /O2 /Ox -c /arch:SSE2  -D_X86_=1  /D_WINDOWS /D_WIN32_WINDOWS=0x0601 /DWINVER=0x0601  /D_WIN32 /DWIN32  /I ./lcms/include /I ./libjpeg/jpeg  dcraw_im.c 
rc.exe /l 0x809 /fo"dcraw.res" /d "NDEBUG" dcraw.rc 
link dcraw_im.obj dcraw.res User32.lib .\lcms\Lib\MS\lcms.lib .\libjpeg\jpeg\libjpeg.lib  /RELEASE /subsystem:console,6.01

rem devenv /build Release dcraw.sln  /project "dcraw\dcraw.vcproj /projectconfig Release |Win32


echo diffing...

.\bin\diff -ru  dcraw.c dcraw_im.c  > dcraw_im_diff.txt


echo testing...

dcraw_im.exe

dcraw_im.exe -v -i _OLE0543.NEF

dcraw_im.exe -4 -w -O _OLE0543-900.ppm _OLE0543.NEF

dcraw_im.exe -4 -w -T  _OLE0543.NEF

dcraw_im.exe -4 -w -T -O _OLE0543-900.jpg _OLE0543.NEF

dcraw_im.exe -4 -w -T -O _OLE0543-900.tif _OLE0543.NEF

dcraw_im.exe -e _OLE0543.NEF


echo dcraw build successfull

copy dcraw_im.exe dcraw.exe

pause