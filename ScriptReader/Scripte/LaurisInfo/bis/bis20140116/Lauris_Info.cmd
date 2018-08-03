@echo OFF

@rem Wert von Variablen zur Laufzeit ermitteln, nicht zur Startzeit des Skriptes; eigener Namensraum
setlocal EnableDelayedExpansion

@rem Ausgabedatei leeren/erzeugen
echo: > "%~2"

@rem isql-Skript ausführen und alles außer den "(x rows affected)" Zeilen an die Ausgabedatei anhängen
echo Password:
for /F "usebackq eol=( delims=" %%A IN (`isql -S %1 -U swissdbo -i lauris_info.isq -w 4096`) DO (
    if "%%A" NEQ "Password: " (
        echo: %%A >> "%~2"
    )
)