@echo Off

@rem Aufruf: lauris_systeminfo <sqlserver> <Ausgabedatei>

@rem Wert von Variablen zur Laufzeit ermitteln, nicht zur Startzeit des Skriptes; eigener Namensraum
setlocal EnableDelayedExpansion

SET /P SRVNameTMP=Bitte SQL-Servernamen eingeben:
::SET /P AusgabeDateiname=Bitten Ausgabe Dateinamen eingeben:

set AusgabeDateiName=Lauris_SystemInfo.txt

@rem Ausgabedatei leeren/erzeugen
echo: > "%AusgabeDateiname%"

@rem isql-Skript ausführen und alles außer den "(x rows affected)" Zeilen an die Ausgabedatei anhängen
echo Passwort:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %SRVNameTMP% -U swissdbo -i Lauris_SystemInfo.isq -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%AusgabeDateiname%"
    )
)
set AusgabeDateiName=Lauris_SystemInfo.csv
echo Nochmal das Passwort:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %SRVNameTMP% -U swissdbo -i Lauris_SystemInfo.isq -s";" -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%AusgabeDateiname%"
    )
)
pause



