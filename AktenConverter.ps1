# ------------------------------------------------------------------------------------------------- #
# Dateiname:   AktenConverter                                                                       #
# Autor:       Bastian Bischof																		                                  #
# Erstellt am: [20180903]																			                                      #
#																									                                                  #
# Beschreibung:																						                                          #
#	Dieses kleine Script ermöglicht es eine Akte von HTML in PDF zu wandeln und 					            #
#	dabei Anker an die entsprechende Stelle zu setzen.												                        #
#																									                                                  #
# Hinweis:																				                                                  #
#	Die ExecutionPolicies müssen vor dem Start auf ByPass gesetzt werden							                #
#																									                                                  #
# Changelog:																			                                                  #
#	[20180903]	0.01	Bastian Bischof		initiale Erstellung                                           #
# ------------------------------------------------------------------------------------------------- #

[void] [System.Reflection.Assembly]::LoadWithPartialName("System")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# **********************************************************************
# Globale Variablen
# **********************************************************************
# Pfad + Name der HTML-Datei
$global:strFilePath = "C:"
$global:strTempFilePath = "C:"
$global:strNewFilePath = "C:"
$global:content = ""

# **********************************************************************
# Funktion getFileName
# * Lässt den Benutzer die HTML-Datei auswählen
# <- Pfad zur ausgewählten Akte
# **********************************************************************
function getFileName
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "HTML (*.html)| *.html"
    $OpenFileDialog.ShowHelp = $true
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
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
    $SaveFileDialog.filename
}

# **********************************************************************
# Funktion removeAndSetAnchor
# * x
# **********************************************************************
function removeAndSetAnchor
{
    Get-Content $global:strFilePath -Encoding UTF8 | 
	  Foreach-Object {$_ -replace '<a.*a>', ''} | 
	  Foreach-Object {$_ -replace '(<td colspan=.+ style="padding-top: 10px;.+">(.+)<\/s.+)', '<a name="$2"></a>$1'} | 
	  Out-File $global:strTempFilePath -Encoding Utf8
}

# **********************************************************************
# Funktion convertToPDF
# * x
# <- y
# **********************************************************************
function convertToPDF ($Source, $Destination) 
{      
  $word = new-object -com "Word.Application"
	$word.visible = $false
	$doc = $word.documents.open($global:strTempFilePath,$false,$true)
	$doc.PageSetup.LeftMargin = 36
	$doc.PageSetup.RightMargin = 36
	$doc.PageSetup.TopMargin = 36
	$doc.PageSetup.BottomMargin = 45
	$doc.saveas([ref] $global:strNewFilePath, [ref] 17)
	$doc.close([ref] [Microsoft.Office.Interop.Word.WdSaveOptions]::wdDoNotSaveChanges)
	$word.quit()
} 

$global:strFilePath = "C:\Users\bischof\Desktop\Akte\gesamte_akte.html"
$global:strNewFilePath = "C:\Users\bischof\Desktop\Akte\PDF.pdf"

# 1. Datei auswählen
$global:strFilePath = getFileName
$global:strTempFilePath = $global:strFilePath.Insert($global:strFilePath.Length - 5,'_Temp')
# 2. Auswahl Pfad + Name der Ausgabedatei
$global:strNewFilePath = newFileName
# 3. Anker entfernen und neu setzen
removeAndSetAnchor
# 4. wandeln HTML -> PDF und Ausgabe
convertToPDF $global:strTempFilePath $global:strNewFilePath
# 5. PDF öffnen
Start-Process ((Resolve-Path $global:strNewFilePath).Path)
