@echo off

echo ____________________________________________
echo making dcraw for imagemagick with deps

rem 20171228 13:42
rem 20100606 05:03



rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo downloading sources...

wget http://www.ijg.org/files/jpegsr9b.zip
rem wget http://downloads.sourceforge.net/project/lcms/lcms/1.19/lcms-1.19.zip?use_mirror=freefr
rem https://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.zip?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Flcms%2Ffiles%2Flcms%2F2.9%2F&ts=1514453051&use_mirror=freefr
wget http://downloads.sourceforge.net/project/lcms/lcms/2.9/lcms2-2.9.zip?use_mirror=freefr
wget http://www.ece.uvic.ca/~frodo/jasper/software/jasper-2.0.14.tar.gz
wget http://www.cybercom.net/~dcoffin/dcraw/dcraw.c


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo extracting sources...

.\bin\unzip lcms2-2.9.zip
.\bin\unzip jpegsr9b.zip

ren lcms2-2.9 lcms
ren jpeg-9b jpeg
move jpeg libjpeg\


rem mkdir dcraw
move  dcraw.c dcraw\


rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo configuring build env...

rem pas nécessaire si tout par devenv

rem call "c:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86

rem call "C:\Program Files\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86

set src=%~dp0

call "C:\Program Files\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat"

cd /D %src%

rem --------------------------------------------------------------------------------------------------
echo ____________________________________________
echo starting build...

rem ****************************************************************************
echo ____________________________________________
echo building libjpeg...

echo configuring...

cd libjpeg\jpeg
rem C:\Program Files\Microsoft Visual Studio 9.0\VC\bin\nmake.exe
rem nmake -f makefile.vc setup-vc6
nmake -f makefile.vc setup-v10

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

rem MSBuild /nologo .\mDNSWindows\SystemService\Service.vcxproj /t:rebuild /p:Configuration=Debug;Platform=x86

rem ".\lcms2-2.9\Projects\VC2017\lcms2.sln"

rem ****************************************************************************
echo ____________________________________________
echo building jasper...

echo configuring...

cmake -G "Visual Studio 15 2017" -H%SOURCE_DIR% -B%BUILD_DIR% -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DCMAKE_BUILD_TYPE=release -DJAS_ENABLE_SHARED=true -DJAS_ENABLE_STRICT=true -DJAS_ENABLE_OPENGL=false -DJAS_ENABLE_LIBJPEG=false


if not errorlevel 0 goto fin


echo building...


msbuild %build_dir%\INSTALL.vcxproj


if not errorlevel 0 goto fin





rem ****************************************************************************
echo ____________________________________________
echo building dcraw...

echo patching...

cd dcraw\
copy dcraw.c dcraw_im.c

..\bin\patch -p0 dcraw_im.c < dcraw900_1433im_diff.txt


echo building...

cl /MT /nologo /O2 /Ox -c /arch:SSE2  -D_X86_=1  /D_WINDOWS /D_WIN32_WINDOWS=0x0601 /DWINVER=0x0601 /D_CRT_SECURE_NO_WARNINGS /D_WIN32 /DWIN32  /I ../lcms/include /I ../libjpeg/jpeg  dcraw_im.c 
rc.exe /l 0x809 /fo"dcraw.res" /d "NDEBUG" dcraw.rc 
link dcraw_im.obj dcraw.res User32.lib ..\lcms\Lib\MS\lcms.lib ..\libjpeg\jpeg\libjpeg.lib /LTCG /RELEASE /subsystem:console,6.01

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