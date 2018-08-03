@echo Off

@rem Aufruf: lauris_systeminfo <sqlserver>

@rem Wert von Variablen zur Laufzeit ermitteln, nicht zur Startzeit des Skriptes; eigener Namensraum
setlocal EnableDelayedExpansion

@rem isql-Skript ausführen und alles außer den "(x rows affected)" Zeilen an die Ausgabedatei anhängen
echo Password:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %1 -U swissdbo -i lauris_Systeminfo_mit_oe.isq -o lauris_Systeminfo_mit_oe.txt -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%~2"
    )
)

