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
#   [20180912] 0.01  Bastian Bischof    initiale Erstellung                                         #
# ------------------------------------------------------------------------------------------------- #

[void] [System.Reflection.Assembly]::LoadWithPartialName("System")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# **********************************************************************
# Globale Variablen
# **********************************************************************
# Eingabe-Dateien (DOC)
$global:strFilePath = New-Object System.Collections.ArrayList
# Temporäre Dateien (enthalten die Bookmarks) (DOC)
$global:strTempFilePath = New-Object System.Collections.ArrayList
# Ausgabe-Dateien (PDF)
$global:strNewFilePath = New-Object System.Collections.ArrayList

# **********************************************************************
# GUI - Form
# **********************************************************************
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size(800, 200)
$objForm.MinimumSize = New-Object System.Drawing.Size(800, 200)
$objForm.MaximumSize = New-Object System.Drawing.Size(800, 200)
$objForm.Text = "Weitere Datei umwandeln?"
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
  # verstecke das Form und beginne mit Verarbeitung
  $objForm.Hide()
  
  # für alle ausgewählten Dateien
  For ($i = 0;$i -lt $global:strFilePath.Count;$i++)
  {
    # Anker entfernen und neu setzen
    write-host "Setze Bookmarks für Datei $($global:strFilePath[$i])"
    removeAndSetAnchor $global:strFilePath[$i] $global:strTempFilePath[$i]
    
    # wandeln DOC -> PDF
    convertToPDF $global:strTempFilePath[$i] $global:strNewFilePath[$i]
  }
  
  # Abschluss-Screen anzeigen
  $btnEnd.Hide()
  $btnNew.Hide()
  $btnFinish.Show()
  $objForm.Text = "Umwandlung abgeschlossen, Script kann beendet werden"
  $objForm.Show()
})
$objForm.Controls.Add($btnEnd)

# **********************************************************************
# Funktion getFileName
# * Lässt den Benutzer die DOC-Datei auswählen
# <- Pfad zur ausgewählten Akte
# **********************************************************************
function getFileName
{
  [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
  $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
  $OpenFileDialog.filter = "DOC (*.doc)| *.doc"
  $OpenFileDialog.ShowHelp = $true
  $OpenFileDialog.ShowDialog() | Out-Null
  return $OpenFileDialog.filename
}

# **********************************************************************
# Funktion newFileName
# * Lässt den Benutzer den Speicherort und Namen der Konfigurationsdatei auswählen
# <- Pfad zur zu speichernden Drucker-Konfigurations-Datei
# **********************************************************************
function newFileName
{
  $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
  $SaveFileDialog.filter = "PDF (*.pdf)| *.pdf"
  $SaveFileDialog.ShowHelp = $true
  $SaveFileDialog.ShowDialog() | Out-Null
  return $SaveFileDialog.filename
}

# **********************************************************************
# Funktion removeAndSetAnchor
# * entfernt die alten Anker und setzt die neuen
# -> Dateinamen für Eingabe und Ausgabe
# **********************************************************************
function removeAndSetAnchor ($source, $destination)
{
  $search = "({\\shp\\shpbxpage\\shpbypage\\shpwr5\\shpfhdr0\\shpfblwtxt0\\shpz\d+\\shpleft400\\shpright11500\\shptop\d+\\shpbottom\d+{\\sp{\\sn fFilled}{\\sv 0}}{\\shpinst{\\sp{\\sn dyTextTop}{\\sv 127000}}{\\sp{\\sn dxTextLeft}{\\sv 0}}{\\sp{\\sn dyTextBottom}{\\sv 0}}{\\sp{\\sn dxTextRight}{\\sv 0}}{\\sp{\\sn fLine}{\\sv 0}}{\\shptxt{\\pard \\fi0 \\li0 \\ri0 \\sb0 \\sa0 \\cb1 \\ql\\sl240 \\slmult1 \\f0\\fs18\\b\\cf2 ([^\n]+)\\plain\\par}}}})"
  Get-Content -Path $source -Encoding ASCII |
    ForEach-Object {$_ -replace '{\\\*\\bkmkstart [^\n]+}{\\\*\\bkmkend [^\n]+}',''} |
    ForEach-Object {$_ -replace $search,'{\*\bkmkstart $2}{\*\bkmkend $2}$1'} |
    Out-File $destination -Append -Encoding ASCII
}

# **********************************************************************
# Funktion convertToPDF
# * konvertiert die Datei von DOC zu PDF
# -> Dateinamen für Eingabe (DOC) und Ausgabe (PDF)
# **********************************************************************
function convertToPDF ($Source, $Destination) 
{      
  write-host "Lese Datei $Source in Word ein"
  
  $word = new-object -com "Word.Application"
  $word.visible = $false
  $doc = $word.documents.open($Source,$false,$true)
  
  write-host "Speichere Datei $Source"
  
  $doc.saveas([ref] $Destination, [ref] 17)
  $doc.close([ref] [Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges)
  $word.quit()
} 

# **********************************************************************
# Funktion chooseFile
# * Auswahl der Dateien und befüllen der Variablen
# **********************************************************************
function chooseFile
{
  [string] $file = getFileName
  [string] $newFile = newFileName
  [string] $tempFile = $file.Insert($file.Length - 4,'_Temp')
  
  $global:strFilePath.Add($file) > $null
  $global:strTempFilePath.Add($tempFile) > $null
  $global:strNewFilePath.Add($newFile) > $null
} 


write-host "Starte Programm"

# wähle die erste Datei
chooseFile

# öffne den Dialog für weitere Auswahl oder Verarbeiten der ausgewählten Dateien
[void] $objForm.ShowDialog()