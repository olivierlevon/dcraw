@echo off

echo ____________________________________________
echo making dcraw for imagemagick

rem 20100606 05:03



rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo downloading sources...

wget http://www.ijg.org/files/jpegsr8b.zip
wget http://downloads.sourceforge.net/project/lcms/lcms/1.19/lcms-1.19.zip?use_mirror=freefr
wget http://www.cybercom.net/~dcoffin/dcraw/dcraw.c


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo extracting sources...

.\bin\unzip lcms-1.19.zip
.\bin\unzip jpegsr8b.zip
ren lcms-1.19 lcms
ren jpeg-8b jpeg
move  jpeg libjpeg\
rem mkdir dcraw
move  dcraw.c dcraw\


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo configuring build env...

rem pas nécessaire si tout par devenv

call "c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo starting build...

rem ****************************************************************************
echo ____________________________________________
echo building libjpeg...

echo configuring...

cd libjpeg\jpeg
rem C:\Program Files\Microsoft Visual Studio 9.0\VC\bin\nmake.exe
nmake -f makefile.vc setup-vc6

if not errorlevel 0 goto fin


echo building...

nmake -f makefile.vc nodebug=1  libjpeg.lib 
cd ..\..

rem devenv .\dcraw.sln /build Release  /project "jpeg" /projectconfig "Release|Win32"

if not errorlevel 0 goto fin


rem ****************************************************************************
echo ____________________________________________
echo building lcms...

devenv .\dcraw.sln /build Release  /project "lcms" /projectconfig "Release|Win32"


rem ****************************************************************************
echo ____________________________________________
echo building dcraw...

echo patching...

cd dcraw\
copy dcraw.c dcraw_im.c

..\bin\patch -p0 dcraw_im.c < dcraw900_1433im_diff.txt


echo building...

cl /MT /nologo /O2 /Ox -c /arch:SSE2  -D_X86_=1  /D_WINDOWS /D_WIN32_WINDOWS=0x501 /DWINVER=0x501 /D_CRT_SECURE_NO_WARNINGS /D_WIN32 /DWIN32  /I ../lcms/include /I ../libjpeg/jpeg  dcraw_im.c 
rc.exe /l 0x809 /fo"dcraw.res" /d "NDEBUG" dcraw.rc 
link dcraw_im.obj dcraw.res User32.lib ..\lcms\Lib\MS\lcms.lib ..\libjpeg\jpeg\libjpeg.lib /LTCG /RELEASE /subsystem:console,5.01

rem devenv .\dcraw.sln /build Release  /project "dcraw" /projectconfig "Release|Win32"


echo diffing...

..\bin\diff -ru  dcraw.c dcraw_im.c  > dcraw_im_diff.txt


echo testing...

dcraw_im.exe

dcraw_im.exe -v -i _OLE0543.NEF

dcraw_im.exe -4 -w -O _OLE0543-900.ppm _OLE0543.NEF

dcraw_im.exe -4 -w -T  _OLE0543.NEF

dcraw_im.exe -4 -w -T -O _OLE0543-900.jpg _OLE0543.NEF

dcraw_im.exe -4 -w -T -O _OLE0543-900.tif _OLE0543.NEF

dcraw_im.exe -e _OLE0543.NEF


echo dcraw build successfull...

copy dcraw_im.exe ..\dcraw.exe
cd ..


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo nettoyage...


:fin

pause