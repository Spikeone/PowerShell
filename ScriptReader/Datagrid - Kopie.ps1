[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 

$arrIDToString = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "bb", "cc", "dd", "ee", "ff")
$global:arrScript
$global:people=@()
$global:parameter=@()
$global:lastScript = 0
$global:gridDoubleClick = $True;
$global:readingParameter = $False;
$global:strPrevComment = "";
$global:strDeclares = "";

$global:size_X = 1024
$global:size_Y = 480

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size($global:size_X, $global:size_Y)
$objForm.minimumSize = New-Object System.Drawing.Size($global:size_X, $global:size_Y)
#$objForm.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
$objForm.Text = "Service Script Loader"
#$objForm.MaximizeBox = $False;
#$objForm.MinimizeBox = $False;
$objForm.Icon = [System.Drawing.SystemIcons]::WinLogo
#$objForm.Topmost = $True
#$objForm.Size = New-Object System.Drawing.Size(1024,480)
$objForm.Icon = New-Object system.drawing.icon (".\favicon.ico") 

$lblScripts = New-Object System.Windows.Forms.Label
$lblScripts.Location = New-Object System.Drawing.Size(8,50)
$lblScripts.Size = New-Object System.Drawing.Size(270,16)
$lblScripts.Text = "Gefundene Scripte (Doppelklicken zum Auswählen):"
$objForm.Controls.Add($lblScripts)

$btnBack = New-Object System.Windows.Forms.Button
$btnBack.Location = New-Object System.Drawing.Size(896,8)
$btnBack.Size = New-Object System.Drawing.Size(96,24)
$btnBack.Text = "Zurück"
$btnBack.Hide();
$btnBack.Add_Click({
$global:gridDoubleClick = $True;
$btnTest.Hide();
$btnCheckAndCreate.Hide();
$btnBack.Hide();
$btnRun.Hide();
$global:people=@()
$global:parameter=@()
buildScriptsDataGridView
})
$objForm.Controls.Add($btnBack)

$lblServerAlias = New-Object System.Windows.Forms.Label
$lblServerAlias.Location = New-Object System.Drawing.Size(120,12)
$lblServerAlias.Size = New-Object System.Drawing.Size(80,16)
$lblServerAlias.Text = "Server Alias:"
#$lblServerAlias.BackColor = "Red"
$objForm.Controls.Add($lblServerAlias)

$txfServer = New-Object System.Windows.Forms.TextBox
$txfServer.Location = New-Object System.Drawing.Size(200,10)
$txfServer.Size = New-Object System.Drawing.Size(160,26)
$txfServer.Text = "SQLSERVER"
$objForm.Controls.Add($txfServer)

$lblDBUser = New-Object System.Windows.Forms.Label
$lblDBUser.Location = New-Object System.Drawing.Size(420,12)
$lblDBUser.Size = New-Object System.Drawing.Size(80,16)
$lblDBUser.Text = "DB Benutzer:"
#$lblDBUser.BackColor = "Red"
$objForm.Controls.Add($lblDBUser)

$txfUser = New-Object System.Windows.Forms.TextBox
$txfUser.Location = New-Object System.Drawing.Size(500,10)
$txfUser.Size = New-Object System.Drawing.Size(160,26)
$txfUser.Text = "swissdbo"
$objForm.Controls.Add($txfUser)

$lblDBUser = New-Object System.Windows.Forms.Label
$lblDBUser.Location = New-Object System.Drawing.Size(420,42)
$lblDBUser.Size = New-Object System.Drawing.Size(80,16)
$lblDBUser.Text = "DB Passwort:"
#$lblDBUser.BackColor = "Red"
$objForm.Controls.Add($lblDBUser)

$txfPW = New-Object System.Windows.Forms.TextBox
$txfPW.Location = New-Object System.Drawing.Size(500,40)
$txfPW.Size = New-Object System.Drawing.Size(160,26)
$txfPW.Text = ""
$txfPW.PasswordChar = "*"
$objForm.Controls.Add($txfPW)

$btnTest = New-Object System.Windows.Forms.Button
$btnTest.Location = New-Object System.Drawing.Size(800,8)
$btnTest.Size = New-Object System.Drawing.Size(96,24)
$btnTest.Text = "Test"
$btnTest.Hide();
$btnTest.Add_Click({
checkParameterValues
})
$objForm.Controls.Add($btnTest)

$btnCheckAndCreate = New-Object System.Windows.Forms.Button
$btnCheckAndCreate.Location = New-Object System.Drawing.Size(800,38)
$btnCheckAndCreate.Size = New-Object System.Drawing.Size(96,24)
$btnCheckAndCreate.Text = "Test and Create"
$btnCheckAndCreate.Hide();
$btnCheckAndCreate.Add_Click({



$check = checkParameterValues

Write-Host $check




If(!$check)
{
    Write-Host "Returning... not creating!"
    return;
}
Write-Host "wird trotzdem gemacht"

createSelectedScript
})
$objForm.Controls.Add($btnCheckAndCreate)

$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Location = New-Object System.Drawing.Size(896,38)
$btnRun.Size = New-Object System.Drawing.Size(96,24)
$btnRun.Text = "Starten"
$btnRun.Hide();
$btnRun.Add_Click({
$check = checkParameterValues

If(!$check)
{
    Write-Host "Returning... not creating!"
    return;
}

createSelectedScript
startSelectedScript
})
$objForm.Controls.Add($btnRun)

$dataGrid1 = New-Object System.Windows.Forms.DataGridView
$dataGrid1.Size = New-Object System.Drawing.Size(992,360)
$dataGrid1.DataBindings.DefaultDataSourceUpdateMode = 0
$dataGrid1.Name = "dataGrid1"
$dataGrid1.DataMember = ""
$dataGrid1.TabIndex = 0
$dataGrid1.Location = New-Object System.Drawing.Point(8,72) #32

$dataGrid1.Add_Click({
    #Write-Host $dataGrid1.CurrentCell.RowIndex
    #$dataGrid1.CurrentCell = $dataGrid1[1,2]
    
    if($global:gridDoubleClick)
    {
        return;
    }
    
    $dataGrid1.CurrentCell = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells[1]
    $dataGrid1.BeginEdit($True)
})

$dataGrid1.Add_DoubleClick({
    if(!$global:gridDoubleClick)
    {
        $dataGrid1.CurrentCell = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells[1]
        $dataGrid1.BeginEdit($True)
        return;
    }
    $val1 = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells["Typ"].Value
    $val2 = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells["Script"].Value
    $global:lastScript = $dataGrid1.CurrentCell.RowIndex
    Write-Host "Lese: .\Scripte\$val1\$val2"
    
    $filename = (Get-Item -Path ".\" -Verbose).FullName
    $filename = $filename + "\Scripte\$val1\$val2"
    $lblScripts.Text = $filename
    
    $global:arrScript = Get-Content ".\Scripte\$val1\$val2"
    
    $btnTest.Show();
    $btnCheckAndCreate.Show();
    $btnBack.Show();
    $btnRun.Show();
    $global:gridDoubleClick = $False;
    
    splitContent
})

$dataGrid1.AllowUserToResizeRows = $False;
$dataGrid1.AllowUserToResizeColumns = $False;
$dataGrid1.MultiSelect = $False;
$dataGrid1.SelectionMode = "FullRowSelect";
#$dataGrid1.ReadOnly = $True;
$dataGrid1.RowHeadersWidthSizeMode = "DisableResizing"
$dataGrid1.ColumnHeadersHeightSizeMode = "DisableResizing"
$dataGrid1.AutoSizeRowsMode = "AllCells"
#$dataGrid1.AutoSizeRowsMode = "AllCellsExceptHeaders"
##$dataGrid1.AutoSizeRowsMode = "DisplayedCells"
$dataGrid1.DefaultCellStyle.WrapMode = 1

$objForm.Controls.Add($dataGrid1)

function createSelectedScript{
#&isql -SSQLSERVER -Uswissdbo -Puseuse

#& "C:\worknt\App\isql.exe"

#Start-Process -FilePath "C:\Windows\System32\cmd.exe" -ArgumentList "isql -SSQLSERVER -Uswissdbo"

#Working
##Start-Process -FilePath "C:\worknt\App\isql.exe" -ArgumentList "-SSQLSERVER -Uswissdbo -Puseuse"
##Start-Process "isql.exe" -ArgumentList "-SSQLSERVER -Uswissdbo -Puseuse"

#Start-Process "isql.exe" -ArgumentList ("-S" + $txfServer.Text + " -U" + $txfUser.Text + " -P" + $txfPW.Text)

$workdir = (Get-Item -Path ".\" -Verbose).FullName

#$ScriptIN = $workdir + "\Workdir\TEST.isq"

$ScriptIN = $lblScripts.Text
Copy-Item $lblScripts.Text ($workdir + "\Workdir\tmp.isq")

$ScriptIN = $workdir + "\Workdir\tmp.isq"

$ScriptOUT = $workdir + "\Workdir\out.txt"

$s = [IO.File]::ReadAllText($ScriptIN)

$rows = $dataGrid1.BindingContext[$dataGrid1.DataSource].Count
for($i=0; $i -lt $rows; $i++)
{
    $Parameter  = ""
    $Value      = ""
    $Type       = ""
    $Parameter  = $dataGrid1.Rows[$i].Cells["Parameter"].Value
    $Value      = $dataGrid1.Rows[$i].Cells["Value"].Value
    $Type       = $dataGrid1.Rows[$i].Cells["Datentyp"].Value
    
    Write-Host "$Parameter $Value"
    
    #$val = ""
    #$val1 = $matches[1]
    ## Parametername
    #$val2 = $matches[2]
    #$val3 = $matches[3]
    ## Typ
    #$val4 = $matches[4]
    #$val5 = $matches[5]
    
    #if($Type -eq "String" -or $Type -eq "Date")
    #{
    #    $Parameter = "\'" + $Parameter + "\'"
    #}
    
    Write-Host "^(SET|set\s+\@)$Parameter(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+.+)(.+)"
    
                        #"^(SET|set\s+\@)(\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+.+)(.+)"
    #$s = $s -replace "(SET|set\s+\@)$Parameter(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+.+)(.+)",('$1'+$Parameter+'$2' + $Value + '$4$5')
    #$s = $s -replace "(SET|set\s+\@)$Parameter(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\')",('$1'+$Parameter+'$2' + $Value + '$4$5')
    if($Type -eq "String" -or $Type -eq "Date")
    {
        $s = $s -replace "(SELECT|select|SET|set\s+\@)($Parameter)(\s+\=\s+)(\'\w+\'|\'\'|0|\'\d+\'|\d+|\-\d+|\'[\d\.\s\:]+\'|\'\s*\d\d\.\d\d\.\d\d\s*\')(\s+\-\-\s+|\s+)(.+)",('$1' + $Parameter + ' = ''' + $Value + '''$5$6')
        #$s = $s -replace "(SET|set\s+\@)($Parameter)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d+|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+)(.+)",('$1' + $Parameter + ' = ''' + $Value + '''$5$6')
    }
    else
    {
        $s = $s -replace "(SELECT|select|SET|set\s+\@)($Parameter)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d+|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+)(.+)",('$1' + $Parameter + ' = ' + $Value + '$5$6')
        #$s = $s -replace "(SET|set\s+\@)($Parameter)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d+|\'[\d\.\s\:]+\')(\s+\-\-\s+|\s+)(.+)",('$1' + $Parameter + ' = ' + $Value + '$5$6')
    }
    #$s = $s -replace "--ABC" , "--DEF"
    
    #$hasCorrectType = checkType $Value $Type
    
    #if(!$hasCorrectType)
    #{
    #    [System.Windows.Forms.MessageBox]::Show("Paramter $Parameter is wrong. Type is $Type.")
    #    forceSelectRow($i)
    #    $dataGrid1.CurrentCell = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells[1]
    #    $dataGrid1.BeginEdit($True)
    #    return;
    #}
}

$s | sc ($ScriptIN + ".sql")


if([System.Windows.Forms.MessageBox]::Show("Open file? (With default program)", "", 4) -eq "Yes")
{
    Invoke-Item ($ScriptIN + ".sql")
}

#+ " -s'|'"

#######Start-Process "isql.exe" -ArgumentList ("-S" + $txfServer.Text + " -U" + $txfUser.Text + " -P" + $txfPW.Text + " -i""" + $ScriptIN + """ -o""" + $ScriptOUT + """" + " -w32000" + " -s""|""")

#Write-Host ("-S" + $txfServer.Text + " -U" + $txfUser.Text + " -P" + $txfPW.Text + " -i""" + $ScriptIN + """ -o""" + $ScriptOUT + """")

#Write-Host "Workdir: $workdir"

}

function checkParameterValues{
    $rows = $dataGrid1.BindingContext[$dataGrid1.DataSource].Count
    $type2 = $False;
    
    for($i=0; $i -lt $rows; $i++)
    {
        $Parameter  = ""
        $Value      = ""
        $Type       = ""
        $Parameter  = $dataGrid1.Rows[$i].Cells["Parameter"].Value
        $Value      = $dataGrid1.Rows[$i].Cells["Value"].Value
        $Type       = $dataGrid1.Rows[$i].Cells["Datentyp"].Value
        
        $hasCorrectType = checkType $Value $Type
        
        if(!$hasCorrectType)
        {
            #$tmp = [System.Windows.Forms.MessageBox]::Show("Paramter $Parameter is wrong. Type is $Type.", "", 4)
            $tmp = [System.Windows.Forms.MessageBox]::Show("Paramter $Parameter is wrong. Type is $Type.")
            forceSelectRow($i)
            $dataGrid1.CurrentCell = $dataGrid1.Rows[$dataGrid1.CurrentCell.RowIndex].Cells[1]
            $tmp = $dataGrid1.BeginEdit($True)
            $type2 = $False;
            $type2
            return;
        }
    }
    
    $tmp = [System.Windows.Forms.MessageBox]::Show("No faulty parameter")
    $type2 = $True;
    $type2
    return;
}

function forceSelectRow($rowID)
{
    $dataGrid1.ClearSelection();
    $dataGrid1.CurrentCell = $dataGrid1.Rows[$rowID].Cells[0]
    $dataGrid1.Rows[$rowID].Selected = $True;
}

function checkType($strValue, $strType)
{
    If($strType -eq "String")
    {
        return Is-String $strValue
    }
    elseif($strType -eq "Integer")
    {
        return Is-Numeric $strValue
    }
    elseif($strType -eq "Date")
    {
        return Is-Date $strValue
    }
    return $True
}

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$|^\-[\d\.]+$"
}

function Is-Date ($Value){
    #return $Value -match "^[\d\.\s\:]+$"
    return $Value -match "^\d\d\.\d\d\.\d\d\d\d\s\d\d\:\d\d\:\d\d$|^\s*\d\d\.\d\d\.\d\d\d\d\s*$"
}

function Is-String ($Value) {
    return ($Value -match "^[\w]+$")
}

function splitContent{
    for($i=0; $i -lt $global:arrScript.Length; $i++)
    {
        $arrLine = $global:arrScript[$i].split("|")
        $line = $global:arrScript[$i]
        
        $isMatch = $line -match "^(SET|set\s+\@)(\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\'|\'[\s\d\w]+\')(\s+\-\-\s*|\s+$|\s+\/\*\s*)(.+)"
        
        if(!$isMatch)
        {
            $isMatch = $line -match "^(SET|set\s+\@)(\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\')"
        }
        else
        {
            Write-Host "Match1 $line"
        }
        
        if(!$isMatch)
        {                           #"^(SET|set\s+\@)      (\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\'|\'[\s\d\w]+\')(\s+\-\-\s*|\s+$|\s+\/\*\s*)(.+)"
            $isMatch = $line -match "^(SELECT|select\s+\@)(\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\'|\'[\s\d\w]+\')(\s+\-\-\s*|\s+$|\s+\/\*\s*)(.+)"
        }
        else
        {
            Write-Host "Match2 $line"
        }
        
        #if(!$isMatch)
        #{
        #    $isMatch = $line -match "^(SET|set\s+\@)(\w+)(\s+\=\s+)(\'\'|0|\'\d+\'|\d+|\-\d|\'[\d\.\s\:]+\'|\'[\s\dA-Za-z]+\')(\s+\-\-\s+|\s+.+)(.+)"
        #}
        
        if(!$isMatch)
        {
            $isMatchComment = $line -match "^[\s\t]*$"
            if($isMatchComment)
            {
                Write-Host "Leerzeile"
                $global:strPrevComment = ""
            }
            else
            {
                $isMatchComment = $line -match "^[\s\t]*\-\-[\s\t]*(.+)$"
                if($isMatchComment)
                {
                    $linenew = $line -replace "--[\s\t]*", ""
                    $linenew = $linenew -replace "--", ""
                
                    Write-Host "Kommentar"
                    if($global:strPrevComment -ne "")
                    {
                        $global:strPrevComment = $global:strPrevComment + "`r`n" + $linenew
                    }
                    else
                    {
                        $global:strPrevComment = $linenew
                    }

                }
            }
            
        }
        else
        {
            Write-Host "Match3 $line"
        }
        
        if($isMatch)
        {
            $global:readingParameter = $True;
        
            $val = ""
            $val1 = $matches[1]
            # Parametername
            $val2 = $matches[2]
            $val3 = $matches[3]
            # Typ
            $val4 = $matches[4]
            $val5 = $matches[5]
            # Beschreibung
            ##$val6 = '|'
            ##$val6 += $matches[6]
            ##$val6 += '|'
            
            if($val6 -eq '||')
            {
                #$val6 = "No description found!"
            }
            else
            {
                $val6 = $matches[6]
            }
            
            
            # String
            $isType = $matches[4] -match "\'([\s\d\w]+)\'|\'\'"
            $match = $matches[1]
            
            if($isType)
            {
                Write-Host "It's a String1 ($match)!"
                $val4 = "String"
                $val = $match
            }
            else
            {
                $isType = $matches[4] -match "^\d+|\-\d+$"
                $match = $matches[0]
                if($isType)
                {
                    Write-Host "It's a Number! ($match)"
                    $val4 = "Integer"
                    $val = $match
                }
                else
                {
                    $isType = $matches[4] -match "^\'([\s\d\.\:]+)\'$"
                    $match = $matches[1]
                    
                    if($isType)
                    {
                        Write-Host "It's a Date! ($match)"
                        $val4 = "Date"
                        $val = $match
                    }
                    else
                    {
                        Write-Host "Unknown Type"
                        $val4 = "Unbekannt"
                        $val = ""
                    }
                }
            }
            
            if($global:strPrevComment -ne "")
            {
                $val6 = $val6 + "`r`n" + $global:strPrevComment
            }
            
            $a = New-Object PSObject
            $a | add-member Noteproperty Parameter $val2
            $a | add-member Noteproperty Value $val
            $a | add-member Noteproperty Datentyp $val4
            $a | add-member Noteproperty Beschreibung $val6
            $global:parameter+= $a
            
            $global:strPrevComment = ""
        }
    }
    
    if($global:parameter.Count -eq 0)
    {
        $a = New-Object PSObject
        $a | add-member Noteproperty Parameter ""
        $a | add-member Noteproperty Value ""
        $a | add-member Noteproperty Datentyp ""
        $a | add-member Noteproperty Beschreibung ""
        $global:parameter+= $a
        
        #$dataGrid1.Enabled = $False;
        #$dataGrid1.ForeColor = "Gray";
        #$dataGrid1.ColumnHeadersDefaultCellStyle.ForeColor = "Gray";
        #$dataGrid1.EnableHeadersVisualStyles = $False;
    }

    $array = New-Object System.Collections.ArrayList
    $array.AddRange($global:parameter)
    $dataGrid1.DataSource = $array
    $dataGrid1.Columns[0].Width = 150;
    $dataGrid1.Columns[0].ReadOnly = $True;
    $dataGrid1.Columns[1].Width = 150;
    $dataGrid1.Columns[1].ReadOnly = $False;
    $dataGrid1.Columns[2].Width = 75;
    $dataGrid1.Columns[2].ReadOnly = $True;
    $dataGrid1.Columns[3].Width = 1925;
    $dataGrid1.Columns[3].ReadOnly = $True;
    #$dataGrid1.Columns[3].DefaultCellStyle.WrapMode = 1
    #$dataGrid1.Columns[3].Height = 200;
    
    $objForm.refresh()
}


function getTypes{
    $Types = Get-ChildItem -Path ".\Scripte"
    $arrTypes = @()

    foreach($item in $Types)
    {
        $arrTypes += $item.name
    }

    for($i = 0; $i -lt $arrTypes.Length; $i++)
    {
        $Types2 = Get-ChildItem *.isq -Path (".\Scripte\" + $arrTypes[$i])
        $arrTypes2 = @()
        foreach($item in $Types2)
        {
            $arrTypes2 += $item.name
        }
        
        for($j = 0; $j -lt $arrTypes2.Length; $j++)
        {
            $a = New-Object PSObject
            $a | add-member Noteproperty Typ $arrTypes[$i]
            $a | add-member Noteproperty Script $arrTypes2[$j]
            $global:people+= $a
    
        }
    }
}

function buildScriptsDataGridView
{
getTypes

$array = New-Object System.Collections.ArrayList
$array.AddRange($global:people)
$dataGrid1.DataSource = $array
$dataGrid1.Columns[0].Width = 300;
$dataGrid1.Columns[0].ReadOnly = $True;
$dataGrid1.Columns[1].Width = 2000;
$dataGrid1.Columns[1].ReadOnly = $True;

Write-Host $global:lastScript
forceSelectRow($global:lastScript)
}

$objForm.Add_Click({

})

#$objForm.Add_ResizeEnd({
#    
#    # Make sure minsize is required (or set it for form)
#    if($objForm.Size.Width -lt $global:size_X)
#    {
#        Write-Host "Resize!"
#        $objForm.Size = New-Object System.Drawing.Size($global:size_X,$objForm.Size.Height)
#    }
#    
#    if($objForm.Size.Height -lt $global:size_Y)
#    {
#        Write-Host "Resize!"
#        $objForm.Size = New-Object System.Drawing.Size($objForm.Size.Width,$global:size_Y)
#    }
#    
#    # calc view size (dg not possible because it might be invalid)
#    $val_x = $objForm.Size.Width - 32
#    $val_y = $objForm.Size.Height - 120
#
#    $dataGrid1.Size = New-Object System.Drawing.Size($val_x, $val_y)
#})

$objForm.Add_Resize({
    
    # calc view size (dg not possible because it might be invalid)
    $val_x = $objForm.Size.Width - 32
    $val_y = $objForm.Size.Height - 120

    $dataGrid1.Size = New-Object System.Drawing.Size($val_x, $val_y)
})

buildScriptsDataGridView

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()
