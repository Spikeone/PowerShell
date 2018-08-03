@echo Off

@rem Aufruf: lauris_systeminfo <sqlserver> <Ausgabedatei>

@rem Wert von Variablen zur Laufzeit ermitteln, nicht zur Startzeit des Skriptes; eigener Namensraum
setlocal EnableDelayedExpansion

SET /P SRVNameTMP=Bitte SQL-Servernamen eingeben:
::SET /P AusgabeDateiname=Bitten Ausgabe Dateinamen eingeben:

set AusgabeDateiName=Lauris_Info.txt

@rem Ausgabedatei leeren/erzeugen
echo: > "%AusgabeDateiname%"

@rem isql-Skript ausführen und alles außer den "(x rows affected)" Zeilen an die Ausgabedatei anhängen
echo Password:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %SRVNameTMP% -U swissdbo -i lauris_info.isq -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%AusgabeDateiname%"
    )
)
echo Nochmal das Passwort:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %SRVNameTMP% -U swissdbo -i lauris_Systeminfo.isq -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%AusgabeDateiname%"
    )
)
for /F "usebackq eol=( delims=" %%A IN (`isql -S %SRVNameTMP% -U swissdbo -i lauris_info_csv.isq -s";" -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%AusgabeDateiname%"
    )
)
echo. >> Lauris_Info.txt
echo. >> Lauris_Info.txt
echo ------------------------------------------- >> Lauris_Info.txt
echo Gateway Infos >> Lauris_Info.txt
echo ------------------------------------------- >> Lauris_Info.txt
echo. >> Lauris_Info.txt
ipconfig /all | find "Hostname" >> Lauris_Info.txt
echo Computername: %COMPUTERNAME% >> Lauris_Info.txt
echo SWL-Client-ID: %SWCLIENT% >> Lauris_Info.txt



