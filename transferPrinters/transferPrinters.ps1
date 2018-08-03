# ------------------------------------------------------------------------------------------------- #
# Dateiname:	transferPrinters																	#
# Autor:		Bastian Bischof																		#
# Erstellt am:	[20180716]																			#
#																									#
# Beschreibung:																						#
#	Dieses kleine Script ermöglicht es die Druckereinstellungen auf einem 							#
#	PC zu ex- und auf einem anderen zu importieren.													#
#																									#
# Hinweis:																							#
#	Die ExecutionPolicies müssen vor dem Start auf ByPass gesetzt werden							#
#																									#
# Changelog:																						#
#	[20180717]	0.02	Bastian Bischof		Möglichkeit die Speicherorte auszuwählen				#
#	[20180716]	0.01	Bastian Bischof		initiale Erstellung										#
# ------------------------------------------------------------------------------------------------- #

[void] [System.Reflection.Assembly]::LoadWithPartialName("System")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# **********************************************************************
# Globale Variablen
# **********************************************************************
# Name des Haupt-Servers für Druckershare
$global:strPrimaryServerShare = "\\oma\"
# Name und Pfad, wo die KonfigurationsDatei liegt
$global:strConfigPath = "C:\Temp\Printer.CSV"

# **********************************************************************
# Funktion exportPrintersToFile
# * Exportiert Datei mit Druckernamen, Freigabenamen und Treibernamen
#   des PC's
# -> Dateiname (strFileName)
# **********************************************************************
function exportPrintersToFile ($strFileName)
{
	Get-Printer | Select Name, PortName, DriverName | Export-CSV -path $strFileName
}


# **********************************************************************
# Funktion parseFile
# * Verarbeitet Datei für Druckernamen, Freigabenamen und Treibernamen
# -> Dateiname (strFileName)
# -> check, ob Datei für Oma-Server erstellt wurde (isOma)
# <- Array mit Druckern, Freigaben und Treibern
# **********************************************************************
function parseFile ($strFileName, $isOma)
{
    $strSeperator = ","
	$arrlPrinters = New-Object System.Collections.ArrayList
	$intRow = 0
	
	ForEach ($line in Get-Content -Path $strFileName) 
	{
		# Zeile um 1 erhöhen
	    $intRow++
		# Wenn 1. oder 2. Zeile, dann weiter (CSV-Header)
		if ($intRow -lt 3) {Continue}
		
	    # Zeile aufteilen (0=Name, 1=PortName, 2=TreiberName)
		$Name   = $line.Split($strSeperator)[0]
	    $Port   = $line.Split($strSeperator)[1]
		$Driver = $line.Split($strSeperator)[2]
		
		# Anführungszeichen entfernen
		$Name = $Name.Trim('"')
		$Port = $Port.Trim('"')
		$Driver = $Driver.Trim('"')
		
		# wenn keine Freigabe, dann ignorieren
		if (! $Port) {Continue}
		# wenn Port nicht mit Oma beginnt, dann ist es keine Freigabe, also ignorieren
		if (! $Port.StartsWith($global:strPrimaryServerShare)) {Continue}
		
		# Drucker-Infos in Arraylist schreiben
		$arrlPrinters += ,@($Name,$Port,$Driver)#
		
	}
	
	return $arrlPrinters
}
		
		
# **********************************************************************
# Funktion addPrinters
# * Fügt den Drucker auf dem PC hinzu
# -> ArrayList mit den Druckern (arrlPrinters)
# **********************************************************************
function addPrinters ($arrlPrinters)
{
	# jeden Drucker aus ArrayList durchgehen
    ForEach ($printer in $arrlPrinters)
	{
		#wenn der Drucker bereits vorhanden ist, gehe zum Nächsten
		if (isPrinterAlreadyThere($printer[1])) {Continue}
		
		# Druckertreiber hinzufügen zum PC
	    Add-PrinterDriver $printer[2]
		# Druckerport hinzufügen zum PC
		Add-PrinterPort -Name $printer[1]
		# Drucker einrichten
		Add-Printer -Name $printer[0] -PortName $printer[1] -DriverName $printer[2]
	}
}


# **********************************************************************
# Funktion newFileName
# * Lässt den Benutzer den Speicherort und Namen der Konfigurationsdatei auswählen
# <- Pfad zur zu speichernden Drucker-Konfigurations-Datei
# **********************************************************************
function newFileName
{
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.filter = "CSV (*.csv)| *.csv"
    $SaveFileDialog.ShowDialog() | Out-Null
    $SaveFileDialog.filename
}


# **********************************************************************
# Funktion getFileName
# * Lässt den Benutzer die Konfigurationsdatei auswählen
# <- Pfad zur Ausgewählten Drucker-Konfigurations-Datei
# **********************************************************************
function getFileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}


# **********************************************************************
# Hilfs-Funktion isPrinterAlreadyThere
# * Prüft, ob der Drucker bereits vorhanden ist
# -> PortName des neuen Druckers (strPort)
# <- true  (Drucker bereits vorhanden)
# <- false (Drucker noch nicht vorhanden)
# **********************************************************************
function isPrinterAlreadyThere ($strPort)
{
	# Hole alle Installierten Drucker
	$arrAvailablePrinters = Get-Printer | Select-Object -ExpandProperty PortName
	
	# Prüfe, ob bereits ein Drucker auf dem Port läuft
	return $arrAvailablePrinters.Contains($strPort)
}

# **********************************************************************
# Main
# * Läuft automatisch beim Start des Scripts ab
# **********************************************************************

$intMode = Read-Host -Prompt "Sollen Drucker exportiert (0) oder importiert (1) werden?"

if ($intMode -eq 0 )
{
	# Hole Pfad zur Speicherung der Konfigurations-Datei
	$global:strConfigPath = getFileName
	
	# Speichere die Drucker-Konfiguration
	exportPrintersToFile $global:strConfigPath
}
else
{
	# Hole Pfad zur Konfigurations-Datei
	$global:strConfigPath = getFileName

	# Hole Drucker aus Datei für CSV von anderem PC (nicht Haupt-Server!)
	$arrlPrinters = parseFile $global:strConfigPath $FALSE
	
	# Richte Drucker vollständig ein
	addPrinters $arrlPrinters
}
