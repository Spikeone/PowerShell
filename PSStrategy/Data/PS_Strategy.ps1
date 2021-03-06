#http://www.techotopia.com/index.php/Drawing_Graphics_using_PowerShell_1.0_and_GDI%2B

# load forms (GUI)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles() 
# STA Modus (Single Threading Apartment) - benötigt für OpenFileDialog
[threading.thread]::CurrentThread.SetApartmentState(2)

$arrInfos = @{}
#$arrInfos["a"] = @{}
#$arrInfos["a"]["a"] = @{}
#$arrInfos["a"]["a"]["name"] = "None"

$arrIDToString = ("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "aa", "bb", "cc", "dd", "ee", "ff")


function createArray
{
    for($i = 0; $i -lt 32; $i++)
    {
        $valI = $arrIDToString[$i];
        $arrInfos[$valI] = @{}
        for($j = 0; $j -lt 16; $j++)
        {
        
        $valJ = $arrIDToString[$j];
        
        $arrInfos[$valI][$valJ] = @{}
        $arrInfos[$valI][$valJ]["farming_cur"] = 0          # Production Speed
        $arrInfos[$valI][$valJ]["fortification_cur"] = 0    # Attack Soldier Lose chances
        $arrInfos[$valI][$valJ]["housing_cur"] = 0          # Max armies
        $arrInfos[$valI][$valJ]["trade_cur"] = 0            # Gold +
        $arrInfos[$valI][$valJ]["soldiers_cur"] = 0         # Current armies
        $arrInfos[$valI][$valJ]["owner"] = "none"           # Current owner
        
        $arrInfos[$valI][$valJ]["attack_north"] = 0         # can attack north?
        $arrInfos[$valI][$valJ]["attack_east"] = 0          # can attack east?
        $arrInfos[$valI][$valJ]["attack_south"] = 0         # can attack south?
        $arrInfos[$valI][$valJ]["attack_west"] = 0          # can attack west?
        $arrInfos[$valI][$valJ]["inhabitable"] = 0          # can occupied by player?
        
        $arrInfos[$valI][$valJ]["lblSoldiers"] = New-Object System.Windows.Forms.Label
        $arrInfos.$valI.$valJ.lblSoldiers.Location = New-Object System.Drawing.Size(($i * 32) ,($j * 32 + 8) )
        $arrInfos.$valI.$valJ.lblSoldiers.Size = New-Object System.Drawing.Size(32,16)
        $arrInfos.$valI.$valJ.lblSoldiers.ForeColor="Black"
        $arrInfos.$valI.$valJ.lblSoldiers.BackColor="Transparent"
        $arrInfos.$valI.$valJ.lblSoldiers.Text=""
        $arrInfos.$valI.$valJ.lblSoldiers.TextAlign="TopCenter"
        $arrInfos.$valI.$valJ.lblSoldiers.Add_Click({onMouseClick "pictureBox"})
        
        #Write-Host $arrInfos.$valI.$valJ.lblSoldiers.Text
        $pictureBox.Controls.Add($arrInfos.$valI.$valJ.lblSoldiers)
        #$lblSoldiers = New-Object System.Windows.Forms.Label
        #$lblSoldiers.Location = New-Object System.Drawing.Size(32,40)
        #$lblSoldiers.Size = New-Object System.Drawing.Size(32,16)
        #$lblSoldiers.ForeColor="Red"
        #$lblSoldiers.BackColor="Transparent"
        #$lblSoldiers.Text = "100"
    
        #Write-Host "$valI $valJ"
        }
        
        #[System.Windows.Forms.MessageBox]::Show("PictureBox clicked, calculating clicked box...","Config File",0)
    }
}

function onLoadSetting
{
    Write-Host "Loading Config..."

    $strFileName = ".\Map.cfg"
    $arrConfig

    If (Test-Path $strFileName)
    {
        $arrConfig = Get-Content $strFileName
        Write-Host "File exists"
    }
    
    for($i = 0; $i -lt $arrConfig.Length; $i++)
    {
        $arrSettings = $arrConfig[$i].split("|")
        
        $valI = $arrSettings[0]
        $valJ = $arrSettings[1]
        
        $arrInfos.$valI.$valJ.farming_cur = $arrSettings[2]
        $arrInfos.$valI.$valJ.fortification_cur = $arrSettings[3]
        $arrInfos.$valI.$valJ.housing_cur = $arrSettings[4]
        $arrInfos.$valI.$valJ.trade_cur = $arrSettings[5]
        $arrInfos.$valI.$valJ.soldiers_cur = $arrSettings[6]
        $arrInfos.$valI.$valJ.owner = $arrSettings[7]
        
        $arrInfos.$valI.$valJ.attack_north = $arrSettings[8]
        $arrInfos.$valI.$valJ.attack_east = $arrSettings[9]
        $arrInfos.$valI.$valJ.attack_south = $arrSettings[10]
        $arrInfos.$valI.$valJ.attack_west = $arrSettings[11]
        $arrInfos.$valI.$valJ.inhabitable = $arrSettings[12]
        
        if([int] $arrInfos.$valI.$valJ.inhabitable -eq 1)
        {
            $arrInfos.$valI.$valJ.lblSoldiers.Text = $arrInfos.$valI.$valJ.soldiers_cur
        }
    }
    
    Write-Host "... done!"
}

function onSaveSettings
    {
        $strFileName = ".\Map.cfg"
    
        Write-Host "Saving Config... `r`n"
        
        If (Test-Path $strFileName){
            Remove-Item $strFileName
        }
        
        for($i = 0; $i -lt 32; $i++)
        {
            $valI = $arrIDToString[$i];
            for($j = 0; $j -lt 16; $j++)
            {
                $valJ = $arrIDToString[$j];
                
                $strOutput = $valI + "|" + $valJ
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.farming_cur
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.fortification_cur
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.housing_cur
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.trade_cur
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.soldiers_cur
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.owner
                
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.attack_north
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.attack_east
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.attack_south
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.attack_west
                $strOutput = $strOutput + "|" + $arrInfos.$valI.$valJ.inhabitable
                
                $strOutput | Out-File -FilePath $strFileName -Append
                
                #Write-Host "$valI $valJ"
            }
            
            #[System.Windows.Forms.MessageBox]::Show("PictureBox clicked, calculating clicked box...","Config File",0)
        
        }
        
        
        #out-file -filepath ".\Map.cfg" -inputobject $arrInfos
        Write-Host "... done! `r`n"
    }

function setAttackButtonState($up, $right, $down, $left)
{
    If($up)
    {
        $btnAttackUp.Show();
    }
    Else
    {
        $btnAttackUp.Hide();
    }
    
    If($right)
    {
        $btnAttackRight.Show();
    }
    Else
    {
        $btnAttackRight.Hide();
    }
    
    If($down)
    {
        $btnAttackDown.Show();
    }
    Else
    {
        $btnAttackDown.Hide();
    }
    
    If($left)
    {
        $btnAttackLeft.Show();
    }
    Else
    {
        $btnAttackLeft.Hide();
    }
    
}
        
function onApplySetting
{
    Write-Host "Applying settings"
    $valI                                   = $txbX.Text
    $valJ                                   = $txbY.Text
    
    $arrInfos.$valI.$valJ.farming_cur       = $txbFarmingCur.Text
    $arrInfos.$valI.$valJ.fortification_cur = $txbFortificationCur.Text
    $arrInfos.$valI.$valJ.housing_cur       = $txbHousingCur.Text
    $arrInfos.$valI.$valJ.trade_cur         = $txbTradeCur.Text
    $arrInfos.$valI.$valJ.soldiers_cur      = $txbSoldiersCur.Text
    $arrInfos.$valI.$valJ.owner             = $txbOwner.Text

    $arrInfos.$valI.$valJ.attack_north      = $txbAttackNorth.Text
    $arrInfos.$valI.$valJ.attack_east       = $txbAttackEast.Text
    $arrInfos.$valI.$valJ.attack_south      = $txbAttackSouth.Text
    $arrInfos.$valI.$valJ.attack_west       = $txbAttackWest.Text
    $arrInfos.$valI.$valJ.inhabitable       = $txbInhabitable.Text
    
    if([int] $arrInfos.$valI.$valJ.inhabitable -eq 1)
    {
        $arrInfos.$valI.$valJ.lblSoldiers.Text = $arrInfos.$valI.$valJ.soldiers_cur
    }
}
    

function onMouseClick($strNameSender)
{
    $relX = [System.Windows.Forms.Cursor]::Position.X - $objForm.Location.X - 8 # 8 = left border
    $relY = [System.Windows.Forms.Cursor]::Position.Y - $objForm.Location.Y - 30 # 30 = upper border
    
    switch($strNameSender)
    {
        
        "pictureBox" {
            $boxX = [math]::floor($relX / 32)
            $boxY = [math]::floor($relY / 32)
            
            Write-Host "X -> Rel: $relX Box: $boxX"
            Write-Host "Y -> Rel: $relY Box: $boxY"
            
            $valI = $arrIDToString[$boxX];
            $valJ = $arrIDToString[$boxY];
            
            $txbX.Text                  = $valI
            $txbY.Text                  = $valJ
            
            $txbFarmingCur.Text         = $arrInfos.$valI.$valJ.farming_cur
            $txbFortificationCur.Text   = $arrInfos.$valI.$valJ.fortification_cur
            $txbHousingCur.Text         = $arrInfos.$valI.$valJ.housing_cur
            $txbTradeCur.Text           = $arrInfos.$valI.$valJ.trade_cur
            $txbSoldiersCur.Text        = $arrInfos.$valI.$valJ.soldiers_cur
            $txbOwner.Text              = $arrInfos.$valI.$valJ.owner
            
            $txbAttackNorth.Text        = $arrInfos.$valI.$valJ.attack_north
            $txbAttackEast.Text         = $arrInfos.$valI.$valJ.attack_east
            $txbAttackSouth.Text        = $arrInfos.$valI.$valJ.attack_south
            $txbAttackWest.Text         = $arrInfos.$valI.$valJ.attack_west
            $txbInhabitable.Text        = $arrInfos.$valI.$valJ.inhabitable
            
            $pictureBox_select.Location = New-Object System.Drawing.Size(($boxX * 32), ($boxY * 32))
            
            if($arrInfos.$valI.$valJ.inhabitable -eq 0 )
            {
                $pictureBox_select.Image = $img_selectUnhabitable
                Write-Host "Uninhabitable"
                # even if attack directions are set - don't apply them
                
                setAttackButtonState $False $False $False $False
            }
            else
            {
                if([int]$arrInfos.$valI.$valJ.attack_north -eq 1)
                {
                    #1XXX
                    if([int] $arrInfos.$valI.$valJ.attack_east -eq 1)
                    {
                        #11XX
                        if([int] $arrInfos.$valI.$valJ.attack_south -eq 1)
                        {
                            #111X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #1111
                                $pictureBox_select.Image = $img_select_1111
                                setAttackButtonState $True $True $True $True
                            }
                            else
                            {
                                #1110
                                $pictureBox_select.Image = $img_select_1110
                                setAttackButtonState $True $True $True $False
                            }
                        }
                        else
                        {
                            #110X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #1101
                                $pictureBox_select.Image = $img_select_1101
                                setAttackButtonState $True $True $False $True
                            }
                            else
                            {
                                #1100
                                $pictureBox_select.Image = $img_select_1100
                                setAttackButtonState $True $True $False $False
                            }
                        }
                    }
                    else
                    {
                        #10XX
                        if([int] $arrInfos.$valI.$valJ.attack_south -eq 1)
                        {
                            #101X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #1011
                                $pictureBox_select.Image = $img_select_1011
                                setAttackButtonState $True $False $True $True
                            }
                            else
                            {
                                #1010
                                $pictureBox_select.Image = $img_select_1010
                                setAttackButtonState $True $False $True $False
                            }
                        }
                        else
                        {
                            #100X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #1001
                                $pictureBox_select.Image = $img_select_1001
                                setAttackButtonState $True $False $False $True
                            }
                            else
                            {
                                #1000
                                $pictureBox_select.Image = $img_select_1000
                                setAttackButtonState $True $False $False $False
                            }
                        }
                    }
                }
                else
                {
                    #0XXX
                    if([int] $arrInfos.$valI.$valJ.attack_east -eq 1)
                    {
                        #01XX
                        if([int] $arrInfos.$valI.$valJ.attack_south -eq 1)
                        {
                            #011X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #0111
                                $pictureBox_select.Image = $img_select_0111
                                setAttackButtonState $False $True $True $True
                            }
                            else
                            {
                                #0110
                                $pictureBox_select.Image = $img_select_0110
                                setAttackButtonState $False $True $True $False
                            }
                        }
                        else
                        {
                            #010X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #0101
                                $pictureBox_select.Image = $img_select_0101
                                setAttackButtonState $False $True $False $True
                            }
                            else
                            {
                                #0100
                                $pictureBox_select.Image = $img_select_0100
                                setAttackButtonState $False $True $False $False
                            }
                        }
                    }
                    else
                    {
                        #00XX
                        if([int] $arrInfos.$valI.$valJ.attack_south -eq 1)
                        {
                            #001X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #0011
                                $pictureBox_select.Image = $img_select_0011
                                setAttackButtonState $False $False $True $True
                            }
                            else
                            {
                                #0010
                                $pictureBox_select.Image = $img_select_0010
                                setAttackButtonState $False $False $True $False
                            }
                        }
                        else
                        {
                            #000X
                            if([int] $arrInfos.$valI.$valJ.attack_west -eq 1)
                            {
                                #0001
                                $pictureBox_select.Image = $img_select_0001
                                setAttackButtonState $False $False $False $True
                            }
                            else
                            {
                                #0000
                                $pictureBox_select.Image = $img_selectHabitable
                                setAttackButtonState $False $False $False $False
                            }
                        }
                    }
                }
            
                #$pictureBox_select.Image = $img_selectHabitable
                Write-Host "Habitable"
            }
            
            If($arrInfos[$valI][$valJ].owner -eq "none")
            {
                setAttackButtonState $False $False $False $False
            }
        }
    
        default {
            Write-Host "Unhandled Click ($strNameSender)"
        }
    }
}



### Arrays ###

$revision       = "0.8.15"
$AppName        = "FourTheWin"
$AppSizeX       = 1040
$AppSizeY       = 800

# Create the form
$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
# Get the form's graphics object
$objFormGraphics = $objForm.createGraphics()

# Define the paint handler
$objForm.add_paint({

})

$objForm.Text = ($AppName + " - " + $revision)

#$objForm.StartPosition = "CenterScreen"
$objForm.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY) 
$objForm.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
$objForm.MaximizeBox = $False;
$objForm.MinimizeBox = $False;
#https://i-msdn.sec.s-msft.com/dynimg/IC24340.jpeg
$objForm.BackColor = "SlateGray"
#$objForm.ControlBox = $False;

#[System.Windows.Forms.Application]::EnableVisualStyles();

$file = (get-item '.\world_512_linesAnchorGrid.png')
$img = [System.Drawing.Image]::Fromfile($file);

$file_selectHabitable = (get-item '.\selected_inhabitable.png')
$file_selectUnhabitable = (get-item '.\selected_uninhabitable.png')
$file_selectNothing = (get-item '.\selected_empty.png')

# 0000 -> nothing
$file_select_none = (get-item '.\selected_attack_none.png')
$img_select_none = [System.Drawing.Image]::Fromfile($file_select_none);
# 1000
$file_select_1000 = (get-item '.\selected_attack_1000.png')
$img_select_1000 = [System.Drawing.Image]::Fromfile($file_select_1000);
# 0100
$file_select_0100 = (get-item '.\selected_attack_0100.png')
$img_select_0100 = [System.Drawing.Image]::Fromfile($file_select_0100);
# 0010
$file_select_0010 = (get-item '.\selected_attack_0010.png')
$img_select_0010 = [System.Drawing.Image]::Fromfile($file_select_0010);
# 0001
$file_select_0001 = (get-item '.\selected_attack_0001.png')
$img_select_0001 = [System.Drawing.Image]::Fromfile($file_select_0001);
# 1100
$file_select_1100 = (get-item '.\selected_attack_1100.png')
$img_select_1100 = [System.Drawing.Image]::Fromfile($file_select_1100);
# 0110
$file_select_0110 = (get-item '.\selected_attack_0110.png')
$img_select_0110 = [System.Drawing.Image]::Fromfile($file_select_0110);
# 0011
$file_select_0011 = (get-item '.\selected_attack_0011.png')
$img_select_0011 = [System.Drawing.Image]::Fromfile($file_select_0011);
# 1001
$file_select_1001 = (get-item '.\selected_attack_1001.png')
$img_select_1001 = [System.Drawing.Image]::Fromfile($file_select_1001);
# 1110
$file_select_1110 = (get-item '.\selected_attack_1110.png')
$img_select_1110 = [System.Drawing.Image]::Fromfile($file_select_1110);
# 0111
$file_select_0111 = (get-item '.\selected_attack_0111.png')
$img_select_0111 = [System.Drawing.Image]::Fromfile($file_select_0111);
# 1011
$file_select_1011 = (get-item '.\selected_attack_1011.png')
$img_select_1011 = [System.Drawing.Image]::Fromfile($file_select_1011);
# 1101
$file_select_1101 = (get-item '.\selected_attack_1101.png')
$img_select_1101 = [System.Drawing.Image]::Fromfile($file_select_1101);
# 1111
$file_select_1111 = (get-item '.\selected_attack_1111.png')
$img_select_1111 = [System.Drawing.Image]::Fromfile($file_select_1111);
# 1010
$file_select_1010 = (get-item '.\selected_attack_1010.png')
$img_select_1010 = [System.Drawing.Image]::Fromfile($file_select_1010);
# 0101
$file_select_0101 = (get-item '.\selected_attack_0101.png')
$img_select_0101 = [System.Drawing.Image]::Fromfile($file_select_0101);

$img_selectHabitable = [System.Drawing.Image]::Fromfile($file_selectHabitable);
$img_selectUnhabitable = [System.Drawing.Image]::Fromfile($file_selectUnhabitable);
$img_selectNothing = [System.Drawing.Image]::Fromfile($file_selectNothing);

$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Width =  $img.Size.Width;
$pictureBox.Height =  $img.Size.Height;
$pictureBox.Image = $img;

$pictureBox_select = new-object Windows.Forms.PictureBox
$pictureBox_select.Width = 32
$pictureBox_select.Height = 32
$pictureBox_select.BackColor = "Transparent"
$pictureBox_select.Image = $img_selectNothing;
$pictureBox_select.Add_Click({onMouseClick "pictureBox"})

$pictureBox.controls.add($pictureBox_select)

createArray

$pictureBox.Add_Click({onMouseClick "pictureBox"})
$objForm.controls.add($pictureBox)

$lblXY = New-Object System.Windows.Forms.Label
$lblXY.Location = New-Object System.Drawing.Size(8,526)
$lblXY.Size = New-Object System.Drawing.Size(92,26)
$lblXY.ForeColor="Black"
$lblXY.Text = "Position X:Y"
$objForm.Controls.Add($lblXY)

$txbX = New-Object System.Windows.Forms.TextBox
$txbX.Location = New-Object System.Drawing.Size(100,524)
$txbX.Size = New-Object System.Drawing.Size(46,26)
$txbX.Text = ""
$txbX.Enabled = $False
$objForm.Controls.Add($txbX)

$txbY = New-Object System.Windows.Forms.TextBox
$txbY.Location = New-Object System.Drawing.Size(146,524)
$txbY.Size = New-Object System.Drawing.Size(46,26)
$txbY.Text = ""
$txbY.Enabled = $False
$objForm.Controls.Add($txbY)

$lblFarmingCur = New-Object System.Windows.Forms.Label
$lblFarmingCur.Location = New-Object System.Drawing.Size(8,558)
$lblFarmingCur.Size = New-Object System.Drawing.Size(92,26)
$lblFarmingCur.ForeColor="Black"
$lblFarmingCur.Text = "Farming Current"
$objForm.Controls.Add($lblFarmingCur)

$txbFarmingCur = New-Object System.Windows.Forms.TextBox
$txbFarmingCur.Location = New-Object System.Drawing.Size(100,554)
$txbFarmingCur.Size = New-Object System.Drawing.Size(92,26)
$txbFarmingCur.Text = ""
$objForm.Controls.Add($txbFarmingCur)

$lblFortificationCur = New-Object System.Windows.Forms.Label
$lblFortificationCur.Location = New-Object System.Drawing.Size(8,588)
$lblFortificationCur.Size = New-Object System.Drawing.Size(92,26)
$lblFortificationCur.ForeColor="Black"
$lblFortificationCur.Text = "Fortification Cur."
$objForm.Controls.Add($lblFortificationCur)

$txbFortificationCur = New-Object System.Windows.Forms.TextBox
$txbFortificationCur.Location = New-Object System.Drawing.Size(100,584)
$txbFortificationCur.Size = New-Object System.Drawing.Size(92,26)
$txbFortificationCur.Text = ""
$objForm.Controls.Add($txbFortificationCur)

$lblHousingCur = New-Object System.Windows.Forms.Label
$lblHousingCur.Location = New-Object System.Drawing.Size(8,618)
$lblHousingCur.Size = New-Object System.Drawing.Size(92,26)
$lblHousingCur.ForeColor="Black"
$lblHousingCur.Text = "Housing Current"
$objForm.Controls.Add($lblHousingCur)

$txbHousingCur = New-Object System.Windows.Forms.TextBox
$txbHousingCur.Location = New-Object System.Drawing.Size(100,614)
$txbHousingCur.Size = New-Object System.Drawing.Size(92,26)
$txbHousingCur.Text = ""
$objForm.Controls.Add($txbHousingCur)

$lblTradeCur = New-Object System.Windows.Forms.Label
$lblTradeCur.Location = New-Object System.Drawing.Size(8,648)
$lblTradeCur.Size = New-Object System.Drawing.Size(92,26)
$lblTradeCur.ForeColor="Black"
$lblTradeCur.Text = "Trade Current"
$objForm.Controls.Add($lblTradeCur)

$txbTradeCur = New-Object System.Windows.Forms.TextBox
$txbTradeCur.Location = New-Object System.Drawing.Size(100,644)
$txbTradeCur.Size = New-Object System.Drawing.Size(92,26)
$txbTradeCur.Text = ""
$objForm.Controls.Add($txbTradeCur)

$lblSoldiersCur = New-Object System.Windows.Forms.Label
$lblSoldiersCur.Location = New-Object System.Drawing.Size(8,678)
$lblSoldiersCur.Size = New-Object System.Drawing.Size(92,26)
$lblSoldiersCur.ForeColor="Black"
$lblSoldiersCur.Text = "Soldiers Current"
$objForm.Controls.Add($lblSoldiersCur)

$txbSoldiersCur = New-Object System.Windows.Forms.TextBox
$txbSoldiersCur.Location = New-Object System.Drawing.Size(100,674)
$txbSoldiersCur.Size = New-Object System.Drawing.Size(92,26)
$txbSoldiersCur.Text = ""
$objForm.Controls.Add($txbSoldiersCur)

$lblOwner = New-Object System.Windows.Forms.Label
$lblOwner.Location = New-Object System.Drawing.Size(8,708)
$lblOwner.Size = New-Object System.Drawing.Size(92,26)
$lblOwner.ForeColor="Black"
$lblOwner.Text = "Owner"
$objForm.Controls.Add($lblOwner)

$txbOwner = New-Object System.Windows.Forms.TextBox
$txbOwner.Location = New-Object System.Drawing.Size(100,704)
$txbOwner.Size = New-Object System.Drawing.Size(92,26)
$txbOwner.Text = ""
$objForm.Controls.Add($txbOwner)

$lblAttackNorth = New-Object System.Windows.Forms.Label
$lblAttackNorth.Location = New-Object System.Drawing.Size(192,528)
$lblAttackNorth.Size = New-Object System.Drawing.Size(92,26)
$lblAttackNorth.ForeColor="Black"
$lblAttackNorth.Text = "Attack North"
$objForm.Controls.Add($lblAttackNorth)

$txbAttackNorth = New-Object System.Windows.Forms.TextBox
$txbAttackNorth.Location = New-Object System.Drawing.Size(284,524)
$txbAttackNorth.Size = New-Object System.Drawing.Size(92,26)
$txbAttackNorth.Text = ""
$objForm.Controls.Add($txbAttackNorth)

$lblAttackEast = New-Object System.Windows.Forms.Label
$lblAttackEast.Location = New-Object System.Drawing.Size(192,558)
$lblAttackEast.Size = New-Object System.Drawing.Size(92,26)
$lblAttackEast.ForeColor="Black"
$lblAttackEast.Text = "Attack East"
$objForm.Controls.Add($lblAttackEast)

$txbAttackEast = New-Object System.Windows.Forms.TextBox
$txbAttackEast.Location = New-Object System.Drawing.Size(284,554)
$txbAttackEast.Size = New-Object System.Drawing.Size(92,26)
$txbAttackEast.Text = ""
$objForm.Controls.Add($txbAttackEast)

$lblAttackSouth = New-Object System.Windows.Forms.Label
$lblAttackSouth.Location = New-Object System.Drawing.Size(192,588)
$lblAttackSouth.Size = New-Object System.Drawing.Size(92,26)
$lblAttackSouth.ForeColor="Black"
$lblAttackSouth.Text = "Attack South"
$objForm.Controls.Add($lblAttackSouth)

$txbAttackSouth = New-Object System.Windows.Forms.TextBox
$txbAttackSouth.Location = New-Object System.Drawing.Size(284,584)
$txbAttackSouth.Size = New-Object System.Drawing.Size(92,26)
$txbAttackSouth.Text = ""
$objForm.Controls.Add($txbAttackSouth)

$lblAttackWest = New-Object System.Windows.Forms.Label
$lblAttackWest.Location = New-Object System.Drawing.Size(192,618)
$lblAttackWest.Size = New-Object System.Drawing.Size(92,26)
$lblAttackWest.ForeColor="Black"
$lblAttackWest.Text = "Attack West"
$objForm.Controls.Add($lblAttackWest)

$txbAttackWest = New-Object System.Windows.Forms.TextBox
$txbAttackWest.Location = New-Object System.Drawing.Size(284,614)
$txbAttackWest.Size = New-Object System.Drawing.Size(92,26)
$txbAttackWest.Text = ""
$objForm.Controls.Add($txbAttackWest)

$lblInhabitable = New-Object System.Windows.Forms.Label
$lblInhabitable.Location = New-Object System.Drawing.Size(192,648)
$lblInhabitable.Size = New-Object System.Drawing.Size(92,26)
$lblInhabitable.ForeColor="Black"
$lblInhabitable.Text = "Inhabitable"
$objForm.Controls.Add($lblInhabitable)

$txbInhabitable = New-Object System.Windows.Forms.TextBox
$txbInhabitable.Location = New-Object System.Drawing.Size(284,644)
$txbInhabitable.Size = New-Object System.Drawing.Size(92,26)
$txbInhabitable.Text = ""
$objForm.Controls.Add($txbInhabitable)

$btnAttackUp = New-Object System.Windows.Forms.Button
$btnAttackUp.Location = New-Object System.Drawing.Size(600,524)
$btnAttackUp.Size = New-Object System.Drawing.Size(92,26)
$btnAttackUp.Text = "^"
$btnAttackUp.Hide();
$btnAttackUp.Add_Click({
})
$objForm.Controls.Add($btnAttackUp)

$btnAttackLeft = New-Object System.Windows.Forms.Button
$btnAttackLeft.Location = New-Object System.Drawing.Size(550,554)
$btnAttackLeft.Size = New-Object System.Drawing.Size(92,26)
$btnAttackLeft.Text = "<"
$btnAttackLeft.Hide();
$btnAttackLeft.Add_Click({
})
$objForm.Controls.Add($btnAttackLeft)

$btnAttackRight = New-Object System.Windows.Forms.Button
$btnAttackRight.Location = New-Object System.Drawing.Size(650,554)
$btnAttackRight.Size = New-Object System.Drawing.Size(92,26)
$btnAttackRight.Text = ">"
$btnAttackRight.Hide();
$btnAttackRight.Add_Click({
})
$objForm.Controls.Add($btnAttackRight)

$btnAttackDown = New-Object System.Windows.Forms.Button
$btnAttackDown.Location = New-Object System.Drawing.Size(600,584)
$btnAttackDown.Size = New-Object System.Drawing.Size(92,26)
$btnAttackDown.Text = "v"
$btnAttackDown.Hide();
$btnAttackDown.Add_Click({
})
$objForm.Controls.Add($btnAttackDown)


$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Location = New-Object System.Drawing.Size(800,524)
$btnSave.Size = New-Object System.Drawing.Size(92,26)
$btnSave.Text = "Save"
$btnSave.Add_Click({
onSaveSettings
})
$objForm.Controls.Add($btnSave)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Location = New-Object System.Drawing.Size(800,554)
$btnApply.Size = New-Object System.Drawing.Size(92,26)
$btnApply.Text = "Apply"
$btnApply.Add_Click({
onApplySetting
})
$objForm.Controls.Add($btnApply)

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Location = New-Object System.Drawing.Size(800,584)
$btnApply.Size = New-Object System.Drawing.Size(92,26)
$btnApply.Text = "Load"
$btnApply.Add_Click({
onLoadSetting
})
$objForm.Controls.Add($btnApply)

$objForm.Add_Shown({$objForm.Activate()})

$objForm.Add_Click({onMouseClick "Form"})

###Window Settings###
#$objForm.Topmost = $True
[void] $objForm.ShowDialog()