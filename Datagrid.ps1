[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Text.Encoding") 

$objFormHighscore = New-Object System.Windows.Forms.Form 
$objFormHighscore.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
$objFormHighscore.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
$objFormHighscore.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
$objFormHighscore.Text = ("Highscore")
$objFormHighscore.MaximizeBox = $False;
$objFormHighscore.MinimizeBox = $False;
#$objFormHighscore.ControlBox = $False;
$objFormHighscore.Icon = [System.Drawing.SystemIcons]::WinLogo
$objFormHighscore.Topmost = $True
$objFormHighscore.Size = New-Object System.Drawing.Size(600,400)

##### DATAGRID
####$objDataGrid = New-Object System.Windows.Forms.DataGrid
####$objDataGrid.Location = New-Object System.Drawing.Size(8,8)
####$objDataGrid.Size = New-Object System.Drawing.Size(120,120)
#####$objDataGrid.VisibleRowCount = 10
####$objFormHighscore.Controls.Add($objDataGrid)
####
####
####$objDataGridView = New-Object System.Windows.Forms.DataGridView
####$objDataGridView.Location = New-Object System.Drawing.Size(128,8)
####$objDataGridView.Size = New-Object System.Drawing.Size(120,120)
#####$objDataGrid.VisibleRowCount = 10
######$objDataGridView.Rows.Add("five", "six", "seven","eight");
######$objDataGridView.Rows.Insert(0, "one", "two", "three", "four");
####
####$objDataGridView.Columns.Add();
####$objDataGridView.Rows.Add();
####$objDataGridView.Columns[0].Name = "column2";
####$objDataGridView.Columns[1].Name = "column6";


$dataGrid1 = New-Object System.Windows.Forms.DataGridView
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 492
$System_Drawing_Size.Height = 308
$dataGrid1.Size = $System_Drawing_Size
$dataGrid1.DataBindings.DefaultDataSourceUpdateMode = 0
#$dataGrid1.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
$dataGrid1.Name = "dataGrid1"
$dataGrid1.DataMember = ""
$dataGrid1.TabIndex = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 8
$System_Drawing_Point.Y = 8
$dataGrid1.Location = $System_Drawing_Point

$dataGrid1.AllowUserToResizeRows = $False;
$dataGrid1.AllowUserToResizeColumns = $False;
$dataGrid1.MultiSelect = $False;

$dataGrid1.SelectionMode = "FullRowSelect";
$dataGrid1.ReadOnly = $True;

$dataGrid1.RowHeadersWidthSizeMode = "DisableResizing"
$dataGrid1.ColumnHeadersHeightSizeMode = "DisableResizing"

$objFormHighscore.Controls.Add($dataGrid1)

$objFormHighscore.Add_Click({

###$people=@()
###$people+=New-Object PsObject -property @{ A = "1"; B = "Agata Krasowski"; C = "Hi"; D = "Hi"}
###$people+=New-Object PsObject -property @{ A = "2"; B = "Sascha Sonneborn"; C = "Hi"; D = "Hi"}
###$people+=New-Object PsObject -property @{ A = "3"; B = "Boris Krause"; C = "Hi"; D = "Hi"}
###$people+=New-Object PsObject -property @{ A = "4"; B = "Knut Arbeiter"; C = "Hi"; D = "Hi"}
###$people+=New-Object PsObject -property @{ A = "5"; B = "Keks"; C = "Hi"; D = "Hi"}
#####$people+=New-Object PsObject -property @{ Name = "Keks"; Short = "kekss"; ID = 5}
####$people

$people=@()
$people+= New-Object PsObject -property ([ordered]@{ ID = 5; Name = "Keks"; Short = "kekss"})

#$people=@()
#$a = New-Object PSObject
#$a | add-member Noteproperty ID 5                                   
#$a | add-member Noteproperty Name "Kekasdasdasdasdasdasdasdasds"                 
#$a | add-member Noteproperty Short "kekss"            
#$people+= $a
#$a = New-Object PSObject
#$a | add-member Noteproperty ID 1                                   
#$a | add-member Noteproperty Name "Jssssssssssssssssssssssssssssssssssssssssssssssssssssssssssa"                 
#$a | add-member Noteproperty Short "Nä"            
#$people+= $a

$array = New-Object System.Collections.ArrayList
$array.AddRange($people)
$dataGrid1.DataSource = $array
$dataGrid1.Columns[0].Width = 40;
$dataGrid1.Columns[1].Width = 160;
$objFormHighscore.refresh()

$dataGrid1.Add_Click({
})

##$array = New-Object System.Collections.ArrayList
##$Script:procInfo = Get-Process | Select Id,Name,Path,Description,VM,WS,CPU,Company | sort -Property Name
##$array.AddRange($procInfo)
##$dataGrid1.DataSource = $array
##$objFormHighscore.refresh()

})

####$objFormHighscore.Controls.Add($objDataGridView)




$objFormHighscore.Add_Shown({$objFormHighscore.Activate()})
[void] $objFormHighscore.ShowDialog()

#$objFormHighscore.Controls.Add($btnCloseHighscore)