@echo off
setlocal
echo ^;SWCLIENT-ID     ^;%swclient%^; >> Lauris_GW_SystemInfo.txt
echo ^;Computername    ^;%COMPUTERNAME%^; >> Lauris_GW_SystemInfo.txt
FOR /F "tokens=4 delims= " %%A IN ('VER') DO SET winver=%%A
echo ^;Windows Version ^;%winver%^; >> Lauris_GW_SystemInfo.txt
FOR /F "tokens=5 delims= " %%A IN ('PING -a 127.0.0.1 -n 1 ^| FIND "[" ^| FIND /V "TTL="') DO SET hostname=%%A
echo ^;DNS-Name        ^;%hostname%^; >> Lauris_GW_SystemInfo.txt
FOR /F "tokens=13 delims= " %%A IN ('ipconfig ^| FIND "IPv4" ') DO SET ipaddr=%%A
echo ^;IP Adresse      ^;%ipaddr%^; >> Lauris_GW_SystemInfo.txt
ENDLOCAL
pause