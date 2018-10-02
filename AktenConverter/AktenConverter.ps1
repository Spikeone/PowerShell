# ------------------------------------------------------------------------------------------------- #
# Dateiname:   AktenConverter                                                                       #
# Autor:       Bastian Bischof                                                                      #
# Erstellt am: [20180912]                                                                           #
#                                                                                                   #
# Beschreibung:                                                                                     #
#   Dieses kleine Script ermöglicht es eine Akte von DOC in PDF zu wandeln und                      #
#   dabei Anker an die entsprechende Stelle zu setzen.                                              #
#                                                                                                   #
# Changelog:                                                                                        #
#   [20181001] 2.00  Bastian Bischof    Start über EXE, Filedialog als eigenes Fenster, Logging     #
#   [20180925] 1.00  Bastian Bischof    Aufteilen der Ausgabe-DOC und merge mittels PDFtk Server    #
#                                         bei großen Dateien sowie Aufräumen nach Bearbeitung       #
#   [20180918] 0.02  Bastian Bischof    automatischer Druck der Bookmarks & bei Abbruch der Wahl    #
#                                         zum Menü springen                                         #
#   [20180912] 0.01  Bastian Bischof    initiale Erstellung                                         #
# ------------------------------------------------------------------------------------------------- #

[void] [System.Reflection.Assembly]::LoadWithPartialName("System")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Add-Type -AssemblyName Microsoft.Office.Interop.Word

# **********************************************************************
# Globale Variablen
# **********************************************************************
# --- Dateien und Pfade ---
# Eingabe-Dateien (DOC)
$global:arrFilePath = New-Object System.Collections.ArrayList
# Ausgabe-Dateien (PDF)
$global:arrNewFilePath = New-Object System.Collections.ArrayList
# Pfad zur pdftk.exe
$global:pdftk = '"\\stringer\it\IT-DOKU\PDMS m.life\02_Routineaufgaben\Akten bereitstellen\Programmdateien\pdftk.exe" '
# Pfad, in welchem Temporäre Dateien liegen
$global:workingDir = 'C:\Temp\AktenConverter\' + $(Get-Date -Uformat "%Y%m%d%H%M%S")

# --- Regex ---
# Regex für Header-Zeile (wird zum Bookmark)
$global:regHeader = "({\\shp\\shpbxpage\\shpbypage\\shpwr5\\shpfhdr0\\shpfblwtxt0\\shpz\d+\\shpleft400\\shpright11500\\shptop\d+\\shpbottom\d+{\\sp{\\sn fFilled}{\\sv 0}}{\\shpinst{\\sp{\\sn dyTextTop}{\\sv 127000}}{\\sp{\\sn dxTextLeft}{\\sv 0}}{\\sp{\\sn dyTextBottom}{\\sv 0}}{\\sp{\\sn dxTextRight}{\\sv 0}}{\\sp{\\sn fLine}{\\sv 0}}{\\shptxt{\\pard \\fi0 \\li0 \\ri0 \\sb0 \\sa0 \\cb1 \\ql\\sl240 \\slmult1 \\f0\\fs18\\b\\cf2 ([^\n]+)\\plain\\par}}}})"
# Regex für altes Bookmark
$global:regOldBookmark = "{\\\*\\bkmkstart [^\n]+}{\\\*\\bkmkend [^\n]+}"
# Regex für neues Bookmark
$global:regNewBookmark = "{\*\bkmkstart $2}{\*\bkmkend $2}$1"
# Regex für Ende des PDF-Headers
$global:regPDFHeaderEnd = "\viewkind1\paperw11900\paperh16840\marglsxn400\margrsxn400\margtsxn400\margbsxn400\deftab800"

# --- Suffixe ---
# Step 1 (Bookmarks setzen und entfernen)
$global:suffixStep1 = [string] ".txt"
# Step 2 (wandle mittels Word zu PDF)
$global:suffixStep2 = [string] ".pdf"
# Step 3 (setze zusammen)
$global:suffixStep3 = [string] ".pdf"

# --- Konfig ---
# Anzahl Zeilen, welche mindestens in einer Datei sind beim Split
$global:linesPerFile = 5000
# Pfad zur Log-Datei (wenn nicht gesetzt, dann nicht loggen)
$global:logFile = $env:AClogFile
# zeige Informationen während der Verarbeitung
$global:showMessages = $env:ACshowMessages
# zeige Informationen während der Verarbeitung
$global:debugMode = $env:ACdebug

# --- Massages ---
$global:messageModi = @{}
# Modus 1 - Programmeckpunkte
$global:messageModi[1] = @{}
$global:messageModi[1]["fore"] = "black"
$global:messageModi[1]["back"] = "green"
# Modus 2 - Dateiverarbeitungen
$global:messageModi[2] = @{}
$global:messageModi[2]["fore"] = "yellow"
$global:messageModi[2]["back"] = "black"
# Modus 3 - andere Verarbeitung
$global:messageModi[3] = @{}
$global:messageModi[3]["fore"] = "green" 
$global:messageModi[3]["back"] = "blue"
# Modus 4 - Probleme bei Verarbeitung
$global:messageModi[4] = @{} 
$global:messageModi[4]["fore"] = "yellow"
$global:messageModi[4]["back"] = "red"

# --- Sonstige ---
# Anzahl Dateien aus Step 1
$global:intFilesInStep1 = 0


# Log/Message/Debug-Parameter Definition (bei Debug alles ausgeben)
if ( $global:debugMode -ne $null)
{
  $global:showMessages = $true
  if ( $global:logFile -eq $null )
  {
    $global:logFile = $global:workingDir + "\log.txt"
  }
}
else
{
  if ( $global:showMessages -eq $null ) { $global:showMessages = $false }
  else { $global:showMessages = $true }
}


# **********************************************************************
# GUI - Form
# **********************************************************************
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size(800, 200)
$objForm.MinimumSize = New-Object System.Drawing.Size(800, 200)
$objForm.MaximumSize = New-Object System.Drawing.Size(800, 200)
$objForm.Text = "AC: Weitere Datei umwandeln?"
$objForm.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",18)
$objForm.MaximizeBox = $False;
$objForm.MinimizeBox = $False;
$objForm.SizeGripStyle = "Hide";
$objForm.Topmost = $True

# **********************************************************************
# GUI - Buttons
# **********************************************************************
# Beendet das Script
$btnFinish = New-Object System.Windows.Forms.Button
$btnFinish.Location = New-Object System.Drawing.Size(10,20)
$btnFinish.Size = New-Object System.Drawing.Size(760,120)
$btnFinish.Text = "beende Script"
$btnFinish.Hide()
$btnFinish.DialogResult = 'Cancel'
$objForm.Controls.Add($btnFinish) 

# Lässt den Benutzer ein weiteres DOC hinzufügen
$btnNew = New-Object System.Windows.Forms.Button
$btnNew.Location = New-Object System.Drawing.Size(10,20)
$btnNew.Size = New-Object System.Drawing.Size(760,50)
$btnNew.Text = "weitere Datei zum Umwandeln auswählen"
$btnNew.Show()
$btnNew.Add_Click({
  writeMessage "weitere Datei wird gewählt" 1
  writeLog $("--- nächste Auswahl")
  
  # verstecke das Form und lasse Benutzer weitere Datei auswählen
  $objForm.Hide()
  chooseFile
  $objForm.Show()
})
$objForm.Controls.Add($btnNew)

# Beendet die Auswahl und geht zur Verarbeitung über
$btnEnd = New-Object System.Windows.Forms.Button
$btnEnd.Location = New-Object System.Drawing.Size(10,90)
$btnEnd.Size = New-Object System.Drawing.Size(760,50)
$btnEnd.Text = "Verarbeite ausgewählte Datei(en)"
$btnEnd.Show()
$btnEnd.Add_Click({
  writeMessage "Verarbeitung beginnt" 1
  writeLog $("---------- Verarbeitung beginnt")
  
  # verstecke das Form und beginne mit Verarbeitung
  $objForm.Hide()
  
  # für alle ausgewählten Dateien
  For ($i = 0;$i -lt $global:arrFilePath.Count;$i++)
  {    
    writeMessage $("Verarbeite " + $($i + 1) + ". Datei: " + $global:arrFilePath[$i]) 2
    writeLog $("--- Datei " + $i)
    # Pfad zum Ordner für die Verarbeitung dieser Datei
    $strFileWorkingDir = $global:workingDir + "\" + $i
    writeLog $("Arbeitsverzeichnis der Datei: " + $strFileWorkingDir)
    
    # Pfade zu Ausgabe-Verzeichnissen
    $strDestinationDirStep1 = [string] $strFileWorkingDir + '\Step1\'
    $strDestinationDirStep2 = [string] $strFileWorkingDir + '\Step2\'
    $strDestinationDirStep3 = [string] $strFileWorkingDir + '\Step3\'
    
    # erstelle die Verzeichnisse für die Verarbeitung, wenn noch nicht vorhanden
    New-Item -ItemType Directory -Force -Path $strDestinationDirStep1
    New-Item -ItemType Directory -Force -Path $strDestinationDirStep2
    New-Item -ItemType Directory -Force -Path $strDestinationDirStep3
  
    # setze die Bookmarks und splitte die Datei, wenn nötig
    removeAndSetAnchor $global:arrFilePath[$i] $strDestinationDirStep1
    
    writeMessage "Konvertiere Dateien in PDF" 2
    # gehe jede Ausgabe-Datei aus dem vorherigen Schritt durch und konvertiere diese in PDF
    For ($j = 0; $j -le $global:intFilesInStep1; $j++)
    {
      convertToPDF $strDestinationDirStep1 $j $strDestinationDirStep2
    }
    
    # setze die PDF's wieder zusammen
    mergeFile $strDestinationDirStep2 $global:intFilesInStep1 $global:arrNewFilePath[$i] $strDestinationDirStep3
  }
  
  # Abschluss-Screen anzeigen
  $btnEnd.Hide()
  $btnNew.Hide()
  $btnFinish.Show()
  $objForm.Text = "Umwandlung abgeschlossen, Script kann beendet werden"
  $objForm.Show()
  
  writeMessage "Umwandlung beendet, beende Programm" 1
  writeLog "--- Umwandlung beendet"
  
  if ($global:debugMode -eq $null)
  {
    # lösche alle temporären Dateien
    writeLog $("lösche Verzeichnis" + $global:workingDir)
    Remove-Item -Force -Recurse -Path $global:workingDir -ErrorAction SilentlyContinue
  }
  
  writeLog $("---------------------------------------------------------------------------------------------")
  writeLog $("Programm endet um " + $(Get-Date -Uformat "%H:%M:%S") + " am " + $(Get-Date -Uformat "%d.%m.%Y"))
  writeLog $("---------------------------------------------------------------------------------------------")
})
$objForm.Controls.Add($btnEnd)

# **********************************************************************
# Funktion getFileName
# * Lässt den Benutzer die DOC-Datei auswählen
# <- Meldung, ob erfolgreich ("Cancel" = erfolgreich; "Cancel notOk" = nicht erfolgreich)
# **********************************************************************
function getFileName
{  
  # öffne den Dialog
  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.filter = "DOC (*.doc)| *.doc"
  
  # öffne ein Form
  $outerForm = New-Object System.Windows.Forms.Form
  $outerForm.StartPosition = [Windows.Forms.FormStartPosition] "Manual"
  $outerForm.Text = "AC: Aktenauswahl"
  $outerForm.Location = New-Object System.Drawing.Point -100, -100
  $outerForm.Size = New-Object System.Drawing.Size 10, 10
  $outerForm.add_Shown( { 
   $outerForm.Activate();
   $OpenFileDialog.ShowDialog( $outerForm );
   $outerForm.Close();
  } )
  $outerForm.ShowDialog()
  
  # wenn ein Name vorhanden ist, dann wurde er richtig gewählt, ansonsten wurde abgebrochen
  If($OpenFileDialog.filename) {
    writeLog $("Datei 1 (Eingangsdatei):  " + $OpenFileDialog.filename)
    writeMessage $("Datei gewählt: " + $OpenFileDialog.filename) 2
    
    $global:arrFilePath.Add($OpenFileDialog.filename) > $null
    return
  }
  else {
    writeLog "Auswahl abgebrochen"
    writeMessage "Auswahl abgebrochen" 4
    return "notOK"
  }
}

# **********************************************************************
# Funktion newFileName
# * Lässt den Benutzer den Speicherort und Namen der Konfigurationsdatei auswählen
# <- Meldung, ob erfolgreich ("Cancel" = erfolgreich; "Cancel notOk" = nicht erfolgreich)
# **********************************************************************
function newFileName
{
  # öffne den Dialog
  $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
  $SaveFileDialog.filter = "PDF (*.pdf)| *.pdf"
  
  # öffne ein Form
  $outerForm = New-Object System.Windows.Forms.Form
  $outerForm.StartPosition = [Windows.Forms.FormStartPosition] "Manual"
  $outerForm.Text = "AC: Speicherort wählen"
  $outerForm.Location = New-Object System.Drawing.Point -100, -100
  $outerForm.Size = New-Object System.Drawing.Size 10, 10
  $outerForm.add_Shown( { 
   $outerForm.Activate();
   $SaveFileDialog.ShowDialog( $outerForm );
   $outerForm.Close();
  } )
  $outerForm.ShowDialog()
  
  # wenn ein Name vorhanden ist, dann wurde er richtig gewählt, ansonsten wurde abgebrochen
  If($SaveFileDialog.filename) {
    writeLog $("Datei 1 (Ausgangsdatei):  " + $SaveFileDialog.filename)
    writeMessage $("Dateiziel gewählt: " + $SaveFileDialog.filename) 2
    
    $global:arrNewFilePath.Add($SaveFileDialog.filename) > $null
    return
  }
  else {
    writeLog "Auswahl abgebrochen"
    writeMessage "Auswahl abgebrochen" 4
    
    $global:arrFilePath.RemoveAt($($global:arrFilePath.Count - 1))
    return "notOK"
  }
}

# **********************************************************************
# Funktion convertToPDF
# * konvertiert die Datei von DOC zu PDF
# -> Dateinamen für Eingabe (DOC) und Ausgabe (PDF)
# -> Name/Nummer der Verarbeiteten Datei
# -> Pfad zur Ausgabe der Dateien
# **********************************************************************
function convertToPDF ($strSourceDir, $fileName, $strDestinationDir) 
{        
  #
  $strSourceFilename = $strSourceDir + $fileName + $global:suffixStep1
  writeLog $("Konvertiere Datei " + $strSourceFilename)
  # Ausgabe-Datei
  $strDestinationFilename = $strDestinationDir + $fileName + $global:suffixStep2
  writeLog $("Konvertiere nach  " + $strDestinationFilename)
  
  # Default-Wert in Funktionen
  $def = [Type]::Missing
  
  
  # öffne Word unsichtbar
  $word = new-object -com "Word.Application"
  $word.visible = $false
  
  # öffne Dokument in Word
  $doc = $word.documents.open($strSourceFilename,$false,$true,$false,$def,$def,$def,$def,$def,[Microsoft.Office.Interop.Word.WdOpenFormat]::wdOpenFormatRTF,$def,$def,$true,$false)
  
  # speichere Dokument als PDF mit Bookmarks
  $doc.ExportAsFixedFormat($strDestinationFilename, 17,$false,[Microsoft.Office.Interop.Word.wdExportOptimizeFor]::wdExportOptimizeForOnScreen,[Microsoft.Office.Interop.Word.WdExportRange]::wdExportAllDocument,1,$doc.Pages.Count,[Microsoft.Office.Interop.Word.WdExportItem]::wdExportDocumentWithMarkup,$true,$true,[Microsoft.Office.Interop.Word.WdExportCreateBookmarks]::wdExportCreateWordBookmarks)
  
  # schließe Dokument
  $doc.close([ref] [Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges)
  
  # schließe Word
  $word.quit()
} 

# **********************************************************************
# Funktion chooseFile
# * Auswahl der Dateien
# **********************************************************************
function chooseFile
{
  # speichere Namen der Quell-DOC-Datei (bei Wahl kommt Cancel, bei Abbruch "Cancel notOK")
  $return = getFileName
  # wenn cancel zurück kam wurde der Dialog abgebrochen
  if ($return -contains "notOK") { return }
  
  # speichere Namen der Ziel-PDF-Datei (bei Wahl kommt Cancel, bei Abbruch "Cancel notOK")
  $return = newFileName
  # wenn cancel zurück kam wurde der Dialog abgebrochen
  if ($return -contains "notOK") { return }
} 

# **********************************************************************
# Funktion removeAndSetAnchor
# * liest Dateien ein, löscht alte Bookmarks und setzt neue. Speichert anschließend in Datei(en) (Splittet bei zu langen Dateien)
# -> Pfad zur Source-Datei
# -> Pfad für temporäre Speicherung der Zwischendateien
# **********************************************************************
function removeAndSetAnchor ($Source, $strDestinationDir)
{
  writeMessage "Setze neue Lesezeichen und entferne alte" 2
  writeLog $("Bookmarks setzen für Datei:      " + $Source)
  writeLog $("Bookmarks setzen in Verzeichnis: " + $strDestinationDir)
    
  # lese den Kopf des PDF's ein (muss am Anfang jeder Datei stehen)
  $strDocHeader = getPDFHeader $Source
  
  # DateiNummer
  $intFileNumber = 0
  # ZeilenNummer
  $intLinesInFile = 0
  # voller Dateiname
  $strDestinationFilename = $strDestinationDir + [string] $intFileNumber + $global:suffixStep1
  
  # erstelle die Datei
  "" > $strDestinationFilename
  
  # Hilfsvariablen für den Stream
  $fileMode = [System.IO.FileMode]::Open
  $fileAccess = [System.IO.FileAccess]::ReadWrite
  $fileShare = [System.IO.FileShare]::None
  $encoding = [System.Text.Encoding]::ASCII       
  # DateiStream
  $fileStream = New-Object -TypeName System.IO.FileStream $strDestinationFilename, $fileMode, $fileAccess, $fileShare         
  # Schreib-Objekt für den Stream
  $writer = New-Object System.IO.StreamWriter $fileStream, $encoding

  
  # Starte Verarbeitung der Datei
  ForEach ($line in [System.IO.File]::ReadLines($Source))
  {    
    # wenn minimale Zeilenanzahl erreicht prüfe, ob Seitenende
    if ($intLinesInFile -gt $global:linesPerFile)
    {
      if ($line -contains "\page")
      {      
        # Seite beenden
        $writer.WriteLine("}")
      
        # DateiNummer hochzählen und Zeilenzahl auf Null setzen
        $intFileNumber = $intFileNumber + 1
        $intLinesInFile = 0
    
        # neuen Dateinamen zusammensetzen und Datei erstellen
        $strDestinationFilename = $strDestinationDir + [string] $intFileNumber + $global:suffixStep1
        "" > $strDestinationFilename
        
        # altes Schreibobjekt und alten Filestream schließen
        $writer.Dispose()
        $fileStream.Dispose()
        
        # neuen Filestream und neues Schreibobjekt öffnen
        $fileStream = New-Object -TypeName System.IO.FileStream $strDestinationFilename, $fileMode, $fileAccess, $fileShare
        $writer = New-Object System.IO.StreamWriter $fileStream, $encoding
        
        # PDFHeader in Datei schreiben
        $writer.WriteLine($strDocHeader)
        
        # gehe zur nächsten Zeile
        Continue
      }
    }
    
    # ersetze alte Bookmarks, setze neue Bookmarks und schreibe Zeile in Datei
    $writer.WriteLine($(replaceInFile($line)))
    
    # zähle Zeilennummer hoch
    $intLinesInFile = $intLinesInFile + 1
  }
  
  # Schreibobjekt und Filestream schließen
  $writer.Dispose()
  $fileStream.Dispose()
  
  $global:intFilesInStep1 = $intFileNumber
  
  writeLog $("es wurden " + $($global:intFilesInStep1 + 1) + " Dateien geschrieben")
} 

# **********************************************************************
# Funktion replaceInFile
# * entfernt alte Bookmarks und fügt neue ein
# -> Zeile, welche bearbeitet wird
# <- Zeile, welche bearbeitet wurde
# **********************************************************************
function replaceInFile ($line)
{
  $strTempLine = $line -replace $global:regOldBookmark, ""
  return $strTempLine -replace $global:regHeader,$global:regNewBookmark
}

# **********************************************************************
# Funktion getPDFHeader
# * lese den PDF-Header aus der Datei aus
# -> Pfad zur Datei
# <- PDF-Header der Datei
# **********************************************************************
function getPDFHeader ($Source)
{
  $strDocHeader = ""

  ForEach ($line in [System.IO.File]::ReadLines($Source))
  {
    $strDocHeader += $line + "`r`n"
    if ($line -eq $global:regPDFHeaderEnd) { return $strDocHeader }
  }
}

# **********************************************************************
# Funktion writeLog
# * schreibt in Log-Datei, wenn diese festgelegt ist
# ->
# **********************************************************************
function writeLog ($text)
{
  if ( $global:logFile -eq $null) { return }
  Add-content $global:logFile -value $text
}

# **********************************************************************
# Funktion writeMessage
# * 
# ->
# **********************************************************************
function writeMessage ($text, $mode)
{
  if ( $showMessages -eq $false) { return }
  write-host $text -ForeGroundColor $($global:messageModi[$mode]["fore"]) -BackgroundColor $($global:messageModi[$mode]["back"])
}

# **********************************************************************
# Funktion mergeFile
# *
# ->
# ->
# ->
# ->
# **********************************************************************
function mergeFile ($strSourceDir, $intFiles, $Destination, $strDestinationDir)
{
  writeMessage $("vereine die Dateien und gebe die fertige PDF aus unter: " + $Destination) 2
  writeLog $("vereine " + $intFiles + "Dateien aus: " + $strSourceDir)
  writeLog $("vereine Dateien nach: " + $Destination)
  
  # Befehl mit den Dateien
  $strFiles = ""
  
  # 2 Buchstaben als Prefix -> 26*26 Möglichkeiten -> 676 Möglichkeiten
  $letter1 = 65 #65 = A
  $letter2 = 65 #65 = A
  
  # Array, falls mehrere Befehle notwendig sind (Zeilenlänge der Befehlszeile ist begrenzt)
  $arrFiles = @()
  # bezeichnet, ob mehrere Befehle verfügbar sind
  $multipleStatements = $false
  
  # für jede PDF-Datei
  for ($i=0;$i -le $intFiles;$i++) 
  {
    #
    $strFileName = $strSourceDir + $i + $global:suffixStep2
  
    # benutze die Datei im Befehl
    $strFiles += [char]$letter1 + [char]$letter2 + "=" + $strFileName + " "
    
    # zähle den zweiten Buchstaben hoch
    $letter2 = $letter2 + 1
    
    # wenn über 90(Z), dann kein Buchstabe mehr, also ersten Buchstaben hochzählen und wieder mit A beginnen beim zweiten
    if ($letter2 -gt 90) 
    {
      $letter1 = $letter1 + 1
      $letter2 = 65
    }
    
    # wenn der erste Buchstabe C ist, sind bereits 52 Dateien in der Auswahl, damit die Befehlszeile nicht zu lang wird, speichere Befehl, starte einen neuen Befehl und beginne wieder bei AA
    if ($letter1 -gt 66)
    {
      $arrFiles += $strFiles
      $letter1 = 65
      $letter2 = 65
      $multipleStatements = $true
      
      # Befehl mit den Dateien wieder leeren
      $strFiles = ""
      
      writeLog $("zu viele Dateien, füge weiteren Schritt ein")
    }
  }
  
  # wenn mehrere Befehle durchgeführt werden müssen
  if ($multipleStatements -eq $true) 
  {  
    # füge auch den letzten Befehl hinzu
    $arrFiles += $strFiles
    $intFileNumber = 0
    
    writeLog $("führe erste Merge-Runde durch")
    # führe jedes einzelne Kommando im Array aus
    ForEach ($strCommandFiles in $arrFiles)
    {
      # voller Dateiname
      $strDestinationFilename = $strDestinationDir + [string] $intFileNumber + $global:suffixStep3
      
      writeLog $("führe Befehl aus: cmd /c " + $global:pdftk + $strCommandFiles + "cat output " + $strDestinationFilename)
      cmd /c $( $global:pdftk + $strCommandFiles + "cat output " + $strDestinationFilename)
      $intFileNumber = $intFileNumber + 1
    }
    
    # 2 Buchstaben als Prefix -> 26*26 Möglichkeiten -> 676 Möglichkeiten
    $letter1 = 65 #65 = A
    $letter2 = 65 #65 = A
    
    # Befehl mit den Dateien wieder leeren
    $strFiles = ""
    
    writeLog $("suche Dateien für zweite Merge-Runde")
    # zweites Kommando zusammensetzen, um die bereits zusammengesetzten PDF's auch zusammenzusetzen
    for($i = 0; $i -le $intFileNumber;$i++) 
    {
      #
      $strFileName = $strDestinationDir + $i + $global:suffixStep3
    
      $strFiles += [char]$letter1 + [char]$letter2 + "=" + $strFileName + " "
    
      # zähle den zweiten Buchstaben hoch
      $letter2 = $letter2 + 1
    
      # wenn über 90(Z), dann kein Buchstabe mehr, also ersten Buchstaben hochzählen und wieder mit A beginnen beim zweiten
      if ($letter2 -gt 90) 
      {
        $letter1 = $letter1 + 1
        $letter2 = 65
      }
    }
  }
  writeLog $("setze alles Final zusammen mit dem Befehl: cmd /c" + $global:pdftk + $strFiles + "cat output " + $Destination)
  
  # setze alle zusammen
  cmd /c $($global:pdftk + $strFiles + "cat output " + $Destination)
} 


$global:debugMode = $true
$global:logFile = $global:workingDir + "\log.txt"
$global:showMessages = $true
writeMessage "Dies ist eine Testversion -> Logging und Nachrichten sind automatisch aktiv" 4


# erstelle das Verzeichnis für das Log, wenn noch nicht vorhanden
New-Item -ItemType Directory -Force -Path $global:logFile.Substring(0,$global:logFile.LastIndexOf("\")) > $null

writeMessage "Starte Programm" 1
writeLog $("---------------------------------------------------------------------------------------------")
writeLog $("Programm startet um " + $(Get-Date -Uformat "%H:%M:%S") + " am " + $(Get-Date -Uformat "%d.%m.%Y"))
if ($global:debugMode = $true) { writeLog $("Programm startet im Debug-Modus") }
if ($global:showMessages = $true) { writeLog $("Programm zeigt Meldungen während des Betriebs") }
writeLog $("---------------------------------------------------------------------------------------------")
writeLog $("Arbeitsverzeichnis:                        " + $global:workingDir)
writeLog $("PDFtk-Verzeichnis:                         " + $global:pdftk)
writeLog $("Anzahl Zeilen pro Datei nach Verarbeitung: " + $global:linesPerFile)
writeLog $("---------------------------------------------------------------------------------------------")

# wähle die erste Datei
chooseFile

# öffne den Dialog für weitere Auswahl oder Verarbeiten der ausgewählten Dateien
[void] $objForm.ShowDialog()