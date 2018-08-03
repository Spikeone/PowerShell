@echo off &setlocal
:: ***************************************************************************
:: *FILENAME : Lauris_Systeminfo.cmd  
:: ***************************************************************************
:: *AUTOR    : lis
:: *KURZINFO : Lauris Systeminfo ermitteln (mit Lauris_Systeminfo.isq)
:: *TIMESTAMP: <20150604.0000>                                                
:: *$Revision: 1.0 $                                                          
:: ***************************************************************************
:: *AENDERUNG   
:: *[011113] 1.0  lis:  Erstellt
:: ***************************************************************************

:: *** Vorbereitungen
::  ** Variablen einlesen
    if #%SWLCLIENTDRIVE%#==##  set SWLCLIENTDRIVE=C:
    if #%SWLMASTERDRIVE%#==##  set SWLMASTERDRIVE=h:
    if exist %SWLCLIENTDRIVE%\worknt\app\setkunde.cmd  call %SWLCLIENTDRIVE%\worknt\app\setkunde.cmd

::  ** SQL-Server DB-Name
    if /i #%isql_server%#==##  (
      set isql_server=SQLSERVER
      for /f "tokens=1 delims=[]" %%a in ('type %SYBASE%\ini\sql.ini ^| findstr /R \[') do (
        if not defined _i_server (
          set _i_server=%%a
        )
      )
      if not #%_i_server%#==##  set isql_server=%_i_server%
      if not #%SQLSERVER%#==##  set isql_server=%SQLSERVER%
    )

::  ** SQL-Server Benutzer
    if /i #%isql_user%#==##  set isql_user=swissdbo

::  ** Parameter
    set "_p=-w999 -iLauris_Systeminfo.isq -oLauris_Systeminfo.txt"

::    if not #%1#==##   set "_p=-i %1 -w 9999"
::    if     #%1#==#@#  set "_p=-w 9999"
::    if not #%2#==##   set "_p=%_p% -o %2 -n -w 9999  %3"

:: *** ISQL aufrufen
@echo isql -S%isql_server% -U%isql_user%  %_p%
    del Lauris_Systeminfo.txt
    if NOT #%KUNDE%#==## del %KUNDE%_Lauris_Systeminfo.txt
    isql -S%isql_server% -U%isql_user%  %_p%
  goto ende


:fehler
   @echo Starten des isql fuer %isql_server% 
   @echo isql -S%isql_server% -U%isql_user%  %_p%
    goto :ende

:: *** Ende
:ende
   @set isql_server=
   @set isql_user=
   @set _i_server=
   @set _p=
   @set _t=


:: *** Gatewayversion ermitteln
set "DateiGW=%SWLMASTERDRIVE%\swlbasis.nt\Gateway\bin\Gateway.exe"
(
  echo Set objFSO = CreateObject^("Scripting.FileSystemObject"^)
  echo Set objShell = CreateObject^("Shell.Application"^)
  echo Set objFolder = objShell.NameSpace^(objFSO.GetParentFolderName^(WScript.Arguments^(0^)^)^)
  echo WScript.Echo objFolder.ParseName^(objFSO.GetFileName^(WScript.Arguments^(0^)^)^).ExtendedProperty^("fileversion"^)
)>"%temp%\getPV.vbs"

rem for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiGW%"') do set "ProdVersion=%%i"
for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiGW%"') do set "Version=%%i"
del "%temp%\getPV.vbs"

(
  echo Set objFSO = CreateObject^("Scripting.FileSystemObject"^)
  echo Set objShell = CreateObject^("Shell.Application"^)
  echo Set objFolder = objShell.NameSpace^(objFSO.GetParentFolderName^(WScript.Arguments^(0^)^)^)
  echo WScript.Echo objFolder.ParseName^(objFSO.GetFileName^(WScript.Arguments^(0^)^)^).ExtendedProperty^("productversion"^)
)>"%temp%\getPV.vbs"

for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiGW%"') do set "ProdVersion=%%i"
del "%temp%\getPV.vbs"

echo . >> Lauris_Systeminfo.txt
echo . >> Lauris_Systeminfo.txt
echo Gateway-Versionsinfo: >> Lauris_Systeminfo.txt
echo ---------------------
if defined Version echo %DateiGW% - Version %Version% >> Lauris_Systeminfo.txt
if defined ProdVersion echo %DateiGW% - ProduktVersion %ProdVersion% >> Lauris_Systeminfo.txt

:: *** Laurisversion ermitteln
set "DateiLA=%SWLMASTERDRIVE%\swlbasis.nt\Lauris2\bin\Swisslab.Lauris.Client.dll"
(
  echo Set objFSO = CreateObject^("Scripting.FileSystemObject"^)
  echo Set objShell = CreateObject^("Shell.Application"^)
  echo Set objFolder = objShell.NameSpace^(objFSO.GetParentFolderName^(WScript.Arguments^(0^)^)^)
  echo WScript.Echo objFolder.ParseName^(objFSO.GetFileName^(WScript.Arguments^(0^)^)^).ExtendedProperty^("fileversion"^)
)>"%temp%\getPV.vbs"

rem for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiLA%"') do set "ProdVersion=%%i"
for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiLA%"') do set "Version=%%i"
del "%temp%\getPV.vbs"

(
  echo Set objFSO = CreateObject^("Scripting.FileSystemObject"^)
  echo Set objShell = CreateObject^("Shell.Application"^)
  echo Set objFolder = objShell.NameSpace^(objFSO.GetParentFolderName^(WScript.Arguments^(0^)^)^)
  echo WScript.Echo objFolder.ParseName^(objFSO.GetFileName^(WScript.Arguments^(0^)^)^).ExtendedProperty^("productversion"^)
)>"%temp%\getPV.vbs"

for /f %%i in ('cscript //nologo "%temp%\getPV.vbs" "%DateiLA%"') do set "ProdVersion=%%i"
del "%temp%\getPV.vbs"

echo . >> Lauris_Systeminfo.txt
echo . >> Lauris_Systeminfo.txt
echo Lauris-Versionsinfo: >> Lauris_Systeminfo.txt
echo ---------------------
if defined Version echo %DateiLA% - Version %Version% >> Lauris_Systeminfo.txt
if defined ProdVersion echo %DateiLA% - ProduktVersion %ProdVersion% >> Lauris_Systeminfo.txt

if NOT #%KUNDE%#==## rename Lauris_Systeminfo.txt %KUNDE%_Lauris_Systeminfo.txt
endlocal
