[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

$objFormColor1 = New-Object System.Windows.Forms.ColorDialog
$objFormColor1.AllowFullOpen = $True;
$objFormColor1.ShowHelp = $True;
$objFormColor1.Color = "Orange";
[void] $objFormColor1.ShowDialog()

Write-Host $objFormColor1.Color

$color = $objFormColor1.Color
$type = $color.GetType()

Write-Host "Typ: $type"

$A = $color.A
$R = $color.R
$G = $color.G
$B = $color.B

Write-Host "A: $A R: $R G: $G B: $B"