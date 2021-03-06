#http://www.techotopia.com/index.php/Drawing_Graphics_using_PowerShell_1.0_and_GDI%2B

# load forms (GUI)
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Media")

[void] [System.Reflection.Assembly]::LoadWithPartialName("microsoft.directx.audiovideoplayback")

Add-Type -AssemblyName PresentationCore
# load Database connector (MYSQL)
[void][system.reflection.Assembly]::LoadFrom(".\MySql.Data.dll")

# Is the game finished?
$global:bDoReallyLeave = $False;
# Gameport
$global:iPort = "8080";
# GameIP
$global:iIP = "127.0.0.1";
# Are sounds muted?
$global:bIsMuted = $True;
# ConfigFile
$global:arrConfig;
# Selected Index
$strSelectedIndex = (0, 0);

$global:WindowPosition = New-Object System.Drawing.Point(0,0)
### Arrays ###
Do {
    ### Varibles ###
    # Current Round
    $global:iCurrentRound   = 0;
    # Dimension of the game area
    $global:iDimension      = 7;
    $global:iDimension_Y    = 6;
    # Pieces placed in each row
    $global:iCountPiecesRow = (0, 0, 0, 0, 0, 0, 0);
    # Are sounds muted?
    #$global:bIsMuted = $True;
    # Is the game finished?
    $global:bIsFinished = $False;
    # Is it a local game?
    $global:bIsLokal = $True;
    # Am I a Server?
    $global:bIsServer = $True;
    # Is a Game in Progress?
    $global:bGameRunning = $False;
    # Previous message sent
    $global:strPrevMsg = "";
    # PlayerTypes
    $strPlayerTypes = ("none", "none");
    # For BlockAI
    $global:AIValueSelection = 0;
    # For Message over TCP
    $global:strChatMessage = "";

    # Array of placed pieces
    $global:arrPlaced = ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    $global:arrPlaced+= ,@("none", "none", "none", "none", "none", "none")
    
    # Color switch (needs improvement)
    $global:strCurrentColor = "none";
    
    # App Settings
    $revision       = "0.8.15"
    $AppName        = "FourTheWin"
    $AppSizeX       = 410
    $AppSizeY       = 350

    # Create pen and brush objects 
    $myBrushGreen = new-object Drawing.SolidBrush green
    $global:myBrushRed = new-object Drawing.SolidBrush red
    $myBrushYellow = new-object Drawing.SolidBrush yellow
    $myBrushBlue = new-object Drawing.SolidBrush blue
    $myBrushGray = new-object Drawing.SolidBrush lightgray
    $global:myBrushOrange = new-object Drawing.SolidBrush orange
    
    $global:Color1 = "Red"
    $global:Color2 = "Orange"

    # Create the form
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
    # Get the form's graphics object
    $objFormGraphics = $objForm.createGraphics()

    # Used for Saving game
    $global:strGameString = "";
    # Used for loaded games
    $global:strCurrentLoadedGameString = "";
    
    # Mysql conenction
    $global:MySQlServerName = "127.0.0.1"
    $global:MySQLDatenbankName = "t_schule"
    $global:UserName = "root"
    $global:Password = "s25"
    
    # Tournament or practice? (Write to DB or not)
    $global:bIsTournament = $False;
    
    # Load Sounds
    $arrSounds = ($(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer), $(New-Object System.Media.SoundPlayer));
    $arrSounds[0].SoundLocation = "..\Sound\button.wav";
    $arrSounds[1].SoundLocation = "..\Sound\dropDown.wav";
    $arrSounds[2].SoundLocation = "..\Sound\radioButton.wav";
    $arrSounds[3].SoundLocation = "..\Sound\chipLay1.wav";
    $arrSounds[4].SoundLocation = "..\Sound\chipLay2.wav";
    $arrSounds[5].SoundLocation = "..\Sound\chipsStack1.wav";
    $arrSounds[6].SoundLocation = "..\Sound\chipsStack2.wav";
    $arrSounds[7].SoundLocation = "..\Sound\lose.wav";
    $arrSounds[8].SoundLocation = "..\Sound\win.wav";
    $arrSounds[9].SoundLocation = "..\Sound\bell.wav";
    $arrSounds[10].SoundLocation = "..\Sound\receive.wav";
    
    #$uri = New-Object Uri("..\Sound\receive.wav", "System.UriKind.Relative")
    #
    #$sound = New-Object System.Windows.Media.Mediaplayer
    ##$sound.Open(([uri]"J:\\MySQL\Sound\bell.wav"))
    #$file = Get-Item "..\Sound\lose.wav"
    #Write-Host $file.FullName
    #
    ##$sound.Open(([uri]"..\Sound\lose.wav"))
    #$sound.Open(([uri]$file.FullName))
    #$sound.Volume = 1
    #$sound.Play()
    
    #$sound2 = New-Object System.Windows.Media.Mediaplayer
    #$sound2.Open(([uri]"J:\\MySQL\Sound\lose.wav"))
    #$sound2.Volume = 1
    #$sound2.Play()

    # Define the paint handler
    $objForm.add_paint({
    
        # Gamearea
        $objFormGraphics.FillRectangle($myBrushBlue, 200 ,35, 180, 155)
        
        # Player colors
        ####$objFormGraphics.FillRectangle($global:myBrushRed, 151 ,48, 16, 8)
        ####$objFormGraphics.FillRectangle($global:myBrushOrange, 151 ,68, 16, 8)
        
        # Draw empty or filled holes
        for($i=0; $i -lt $global:iDimension; $i++)
        {
            for($j=1; $j -lt $global:iDimension_Y+1; $j++)
            {
                # This makes sure, that redraw is working as intended!!! (no more disappearing coins)
                if($global:arrPlaced[$i][$global:iDimension - $j - 1 ] -eq "Orange")
                {
                    $objFormGraphics.FillEllipse($global:myBrushOrange, 205 + $i * 25, 15 + $j * 25, 20, 20)
                }
                elseif($global:arrPlaced[$i][$global:iDimension - $j - 1] -eq "Red")
                {
                    $objFormGraphics.FillEllipse($global:myBrushRed, 205 + $i * 25, 15 + $j * 25, 20, 20)
                }
                else
                {
                    $objFormGraphics.FillEllipse($myBrushGray, 205 + $i * 25, 15 + $j * 25, 20, 20)
                }
            }
        }
    })

    # FUNCTION
    
    function pickColor($color, $btnID)
    {
        Write-Host $color
        
        $objFormColor = New-Object System.Windows.Forms.ColorDialog
        $objFormColor.AllowFullOpen = $True;
        $objFormColor.ShowHelp = $True;
        $objFormColor.Color = $color;
        [void] $objFormColor.ShowDialog()
        
        if($btnID -eq 1)
        {
            $btnC1.BackColor = $objFormColor.Color
            $global:myBrushRed = new-object Drawing.SolidBrush $btnC1.BackColor
            $global:Color1 = $btnC1.BackColor
        }
        else
        {
            $btnC2.BackColor = $objFormColor.Color
            $global:myBrushOrange  = new-object Drawing.SolidBrush $btnC2.BackColor
            $global:Color2 = $btnC2.BackColor
        }
        
        Write-Host $objFormColor.Color
    }
    
    function doLoadGame($strEntry)
    {
        Write-Host "Game with entry $strEntry requested to Load"
        
        # Invalid input -> non numeric value
        if((Is-Numeric $strEntry) -ne $True)
        {
            [System.Windows.Forms.MessageBox]::Show("There is no Savegame with entry $strEntry!")
            return;
        }
        
        #select g.entry, g.date_played, p1.player_name, p2.player_name, g.game_string from t_games g 
        #join t_players p1 on g.name_player1 = p1.entry 
        #join t_players p2 on g.name_player2 = p2.entry
        #where g.entry = 4
        
        # Load Game Data for entry
        $strGameData = ""
        $strGameData = executeDBQuery "select p1.player_name, p2.player_name, g.game_string from t_games g join t_players p1 on g.name_player1 = p1.entry join t_players p2 on g.name_player2 = p2.entry where g.entry = $strEntry" "line"
        
        Write-Host "Gamedata is: $strGameData"
        
        if($strGameData -eq "")
        {
            # Savegame not found, invalid entry
            [System.Windows.Forms.MessageBox]::Show("There is no Savegame with entry $strEntry!")
            return;
        }
        elseif($strGameData -eq -1)
        {
            # No DB Connection
            #[System.Windows.Forms.MessageBox]::Show("Ooops, this shouldn't happen. Either DB not available or Query error!","Database Problem",0)
            return;
        }
        
        # Split the string (=array)
        $arrayGameData = $strGameData.split("|")
        
        # Set playernames and disable input boxes
        $txfNameP1.Enabled = $False;
        $txfNameP1.Text = $arrayGameData[0];
        
        $txfNameP2.Enabled = $False;
        $txfNameP2.Text = $arrayGameData[1];
        
        # disable all buttons and input boxes
        $btnStart.Enabled = $False;
        $btnLoadGames.Enabled = $False;
        $btnTournament.Enabled = $False;
        $btnMulti.Enabled = $False;
        $btnServer.Enabled = $False;
        $DropDown1.Enabled = $False;
        $DropDown2.Enabled = $False;
        $RadioButton1.Enabled = $False;
        $RadioButton2.Enabled = $False;
        $txfIP.Enabled = $False;
        $txfPort.Enabled = $False;
        # Game is local!
        $global:bIsLokal = $True;
        
        # Make sure the result isn't written to the DB
        $global:bIsTournament = $False;
        
        # Get the string representing the game
        $global:strCurrentLoadedGameString = $arrayGameData[2]
        
        # get the first char, it represents the original beginner
        $strStartColor = $strCurrentLoadedGameString.Substring(0,1)
        
        #Write-Host "Start colorcode: '$strStartColor'"
        
        # Set the color according to the code
        if($strStartColor -eq "R")
        {
            setBegin "Red"
        }
        else
        {
            setBegin "Orange"
        }
        
        # Show replay buttons
        $btnPlayStep.Show();
        $btnPlayAllSteps.Show();
        $btnPlayEnd.Show();
        
        # Remove the first letter in the game string (=remove colorcode)
        $global:strCurrentLoadedGameString = $global:strCurrentLoadedGameString.Substring(1, $global:strCurrentLoadedGameString.Length - 1)
    }
    
    # Game ended Tie, if it's a tournament, update Database
    function executeDBQuerysGameEndsTie
    {
        # get player names from form
        $str1 = ""
        $str2 = ""
        
        $str1 = $txfNameP1.Text;
        $str2 = $txfNameP2.Text;
        
        # get player entrys from db
        $entry1 = "";
        $entry2 = "";
        
        $entry1 = executeDBQuery "select entry from t_players where player_name = '$str1'" "single"
        
        if($entry1 -eq -1)
        {
            return;
        }
        
        $entry2 = executeDBQuery "select entry from t_players where player_name = '$str2'" "single"
        
        if($entry2 -eq -1)
        {
            return;
        }
        
        # first tie for the player
        if($str1 -eq "")
        {
            executeDBQuery "insert into t_players(player_name, games_won, games_lost, games_tie) values('$str1', 0, 0, 1)" "single"
        }
        else
        {
            executeDBQuery "update t_players set games_tie = games_tie + 1 where entry = $entry1" "single"
        }
        
        # first tie for the player
        if($str2 -eq "")
        {
            executeDBQuery "insert into t_players(player_name, games_won, games_lost, games_tie) values('$str2', 0, 0, 1)" "single"
        }
        else
        {
        executeDBQuery "update t_players set games_tie = games_tie + 1 where entry = $entry2" "single"
        }
    }
    
    # Game ends, update Database if its a contest
    function executeDBQuerysGameEnds
    {
        #get player names from form
        $strWinner = ""
        $strLoser = ""
        if ($global:strCurrentColor -eq "Red")
        {
            $strWinner = $txfNameP1.Text;
            $strLoser = $txfNameP2.Text;
        }
        else
        {
            $strWinner = $txfNameP2.Text;
            $strLoser = $txfNameP1.Text;
        }
        
        # get player entrys from db
        $entryWinner = "";
        $entryLoser = "";
        
        $entryWinner = executeDBQuery "select entry from t_players where player_name = '$strWinner'" "single"
        
        if($entryWinner -eq -1)
        {
            return;
        }
        
        $entryLoser = executeDBQuery "select entry from t_players where player_name = '$strLoser'" "single"
        
        if($entryLoser -eq -1)
        {
            return;
        }
        
        # first win for the player
        if($entryWinner -eq "")
        {
            executeDBQuery "insert into t_players(player_name, games_won, games_lost, games_tie) values('$strWinner', 1, 0, 0)" "single"
        }
        else
        {
            executeDBQuery "update t_players set games_won = games_won + 1 where entry = $entryWinner" "single"
        }
        
        if($entryLoser -eq "")
        {
            executeDBQuery "insert into t_players(player_name, games_won, games_lost, games_tie) values('$strLoser', 0, 1, 0)" "single"
        }
        else
        {
            executeDBQuery "update t_players set games_lost = games_lost + 1 where entry = $entryLoser" "single"
        }
        
        $strP1 = $txfNameP1.Text
        $strP2 = $txfNameP2.Text
        
        $datNow = Get-Date
        $iRoundsPlayed = $global:iCurrentRound + 1
        $entryP1 = executeDBQuery "select entry from t_players where player_name = '$strP1'" "single"
        $entryP2 = executeDBQuery "select entry from t_players where player_name = '$strP2'" "single"
        # if winner 1 then its the first player, if 0 then tie
        $winner = 0
        if($strWinner -eq $strP1)
        {
            $winner = 1
        }
        else
        {
            $winner = 2
        }
        
        $game_string = $global:strGameString
    
        executeDBQuery "insert into t_games(date_played, rounds_played, name_player1, name_player2, winner, game_string) values('$datNow', '$iRoundsPlayed', '$entryP1', '$entryP2', '$winner', '$game_string')" "single"
        
        #Write-Host "EntryWinner: $entryWinner , EntryLoser: $entryLoser`r`n"
        
    }
    
    # executes a db query
    function executeDBQuery($strQuery, $mode)
    {
        Try
        {
        
            # create database connection
            $MySqlConnection = New-Object MySql.Data.MySqlClient.MySqlConnection
            $MySqlConnection.ConnectionString = "server=$global:MySQLServerName;user id=$global:Username;password=$global:Password;database=$global:MySQLDatenbankName;pooling=false"
            $MySqlConnection.Open()
            $MySqlCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
            $MySqlCommand.Connection = $MySqlConnection
            
            $MySqlCommand.CommandText = $strQuery
            
            $strRead = ""
            
            $Reader = $MySqlCommand.ExecuteReader()
            
            
            # read statement from db
            While($Reader.Read()) {
                #"{0} {1} {2} {3} {4}" -f $Reader.GetValue(0),$Reader.GetValue(1),$Reader.GetValue(2),$Reader.GetValue(3),$Reader.GetValue(4)
                for ($i=0;$i -lt $Reader.FieldCount;$i++) 
                {
                    if($mode -eq "line" -or $mode -eq "table" -and $i -ne 0)
                    {
                        $strRead += "|"
                    }
                    $strRead += $Reader.GetValue($i)
                }
                if($mode -eq "table")
                {
                    $strRead += "|"
                }
            }
            
            $Reader.Close()
    
            $MySqlConnection.Close()
            
        }
        Catch [system.exception]
        {
            [System.Windows.Forms.MessageBox]::Show("Ooops, this shouldn't happen. Either DB not available or Query error!","Database Problem",0)
            
            return -1
        }
        
        return $strRead
    }
    
    # blocking AI
    function TestTempBlock($color, $iMode)
    {
        $ScoringForRows = (0, 0, 0, 0, 0, 0, 0);
    
        for($i = 0; $i -lt $global:iDimension; $i++)
        {
            Write-Host "`r`nButtonID: $i`r`n"
            $values_H = calcSameHorizontalBlock $i $global:iCountPiecesRow[$i] $color
            $values_V = calcSameVerticalBlock $i $global:iCountPiecesRow[$i] $color
            $values_S = calcSameSlashBlock $i $global:iCountPiecesRow[$i] $color
            $values_B = calcSameBackslashBlock $i $global:iCountPiecesRow[$i] $color
            Write-Host "For color: $color"
            ###Write-Host "Horizontal:  $values_H"
            ###Write-Host "`r`nVertical:    $values_V"
            ###Write-Host "`r`nSlash:       $values_S"
            ###Write-Host "`r`nBackslash:   $values_B"
            
            ## calculate a good scoring horizontal
            #connected (or connectable), left same connected, left empty, left same not connected, right same, right empty, right same not connected
            #0 = 1
            #1 = left same connected
            #2 = left emtpy 
            #3 = left same not connected
            #
            #4 = right same connected
            #5 = right emtpy
            #6 = right same not connected
            
            # idea: the more emtpy connected to the other side of the connected, the better the spot gets
            # 0 0 0 R 0 0 0
            # ->  G   G
            # Reason:
            # No win possible as connected left + connected right + connected != 3 (1+0+0)
            # First position: right 1 connected, left 2 emtpy
            # Second Position: left 1 connected, right 2 empty
            # Means, Side connected + other side empty = max
            # Connected: should be x3, not connected should be x2, emtpy should be x1
            
            #Write-Host "`r`nCalculating Horizontal scoring... `r`n"
            #Write-Host "Left connection: `r`n"
            ###$left_con = $values_H[4]*3 + $values_H[3]*2 + $values_H[2] - $values_H[6]*1.5 - $values_H[5]*1.25;
            ###$right_con = $values_H[1]*3 + $values_H[6]*2 + $values_H[5] - $values_H[3]*1.5 - $values_H[2]*1.25;
            
            #$left_con = $values_H[4]*3 + $values_H[3]*2 + $values_H[2] + $values_H[6]*1.5 + $values_H[5]*1.25 + [math]::min($values_H[2], $values_H[5])*0.25 + [math]::max($values_H[3],$values_H[6]);
            #$right_con = $values_H[1]*3 + $values_H[6]*2 + $values_H[5] + $values_H[3]*1.5 + $values_H[2]*1.25 + [math]::min($values_H[2], $values_H[5])*0.25 + [math]::max($values_H[3],$values_H[6]);
            #$left_con  = $values_H[4]*3 + $values_H[3]*2 + $values_H[2] + $values_H[6]*1.5 + $values_H[5]*1.25 + [math]::min($values_H[2], $values_H[5])*0.25 + [math]::max($values_H[3],$values_H[6]);
            #$right_con = $values_H[1]*3 + $values_H[6]*2 + $values_H[5] + $values_H[3]*1.5 + $values_H[2]*1.25 + [math]::min($values_H[2], $values_H[5])*0.25 + [math]::max($values_H[3],$values_H[6]);
            
            #				Minimum of empty fields				+	RightSame*3 +  RightSameNotConnected
            $left_con_H = [math]::min($values_H[2], $values_H[5])*0.5 + $values_H[4]*3 + $values_H[6]*2 + [math]::min($values_H[2], $values_H[5]) *  $values_H[4];
            $right_con_H = [math]::min($values_H[2], $values_H[5])*0.5 + $values_H[1]*3 + $values_H[3]*2+ [math]::min($values_H[2], $values_H[5]) * $values_H[1];
            
            
            $scoring_sum_H = $left_con_H + $right_con_H;
            
            #Write-Host "Scoring Left: $left_con_H and Scoring Right: $right_con_H Scoring Sum: $scoring_sum_H`r`n"
            
            $left_con_V = [math]::min($values_V[2], $values_V[5])*0.5 + $values_V[4]*3 + $values_V[6]*2 + [math]::min($values_V[2], $values_V[5]) *  $values_V[4];
            $right_con_V = [math]::min($values_V[2], $values_V[5])*0.5 + $values_V[1]*3 + $values_V[3]*2+ [math]::min($values_V[2], $values_V[5]) * $values_V[1];
            
            
            $scoring_sum_V = $left_con_V + $right_con_V;
            
            #Write-Host "Scoring Left: $left_con_V and Scoring Right: $right_con_V Scoring Sum: $scoring_sum_V`r`n"
            
            $left_con_S = [math]::min($values_S[2], $values_S[5])*0.5 + $values_S[4]*3 + $values_S[6]*2 + [math]::min($values_S[2], $values_S[5]) *  $values_S[4];
            $right_con_S = [math]::min($values_S[2], $values_S[5])*0.5 + $values_S[1]*3 + $values_S[3]*2+ [math]::min($values_S[2], $values_S[5]) * $values_S[1];
            
            
            $scoring_sum_S = $left_con_S + $right_con_S;
            
            #Write-Host "Scoring Left: $left_con_S and Scoring Right: $right_con_S Scoring Sum: $scoring_sum_S`r`n"
            
            $left_con_B = [math]::min($values_B[2], $values_B[5])*0.5 + $values_B[4]*3 + $values_B[6]*2 + [math]::min($values_B[2], $values_B[5]) *  $values_B[4];
            $right_con_B = [math]::min($values_B[2], $values_B[5])*0.5 + $values_B[1]*3 + $values_B[3]*2+ [math]::min($values_B[2], $values_B[5]) * $values_B[1];
            
            
            $scoring_sum_B = $left_con_B + $right_con_B;
            
            #Write-Host "Scoring Left: $left_con_B and Scoring Right: $right_con_B Scoring Sum: $scoring_sum_B`r`n"
            
            $scoring_sum = $scoring_sum_H + $scoring_sum_V + $scoring_sum_S*0.5 + $scoring_sum_B*0.5
            $ScoringForRows[$i] = $scoring_sum
            
            
            
            if($values_H[0] + $values_H[1] + $values_H[4] -eq 4)
            {
                $ScoringForRows[$i] = +50;
            }
            if($values_V[0] + $values_V[1] + $values_V[4] -eq 4)
            {
                $ScoringForRows[$i] = +50;
            }
            if($values_S[0] + $values_S[1] + $values_S[4] -eq 4)
            {
                $ScoringForRows[$i] = +50;
            }
            if($values_B[0] + $values_B[1] + $values_B[4] -eq 4)
            {
                $ScoringForRows[$i] = +50;
            }
            
            
            if($global:iCountPiecesRow[$i] -ge $global:iDimension_Y)
            {
                
                #Write-Host "Pieces in Row: $gobal:iDimension_Y"
                $ScoringForRows[$i] = -1000;
            }
            #Write-Host "ScoringOverall: $scoring_sum`r`n"
        }
        
        # BLOCK AI should just block
        if($iMode -eq 0)
        {
            return $ScoringForRows
        }
        
        for($i = 0; $i -lt $global:iDimension; $i++)
        {
            $iSamePieceCount_V = calcSameVertical $i $global:iCountPiecesRow[$i] $global:strCurrentColor $True
            
            $iSamePieceCount_H = calcSameHorizontal $i $global:iCountPiecesRow[$i] $global:strCurrentColor $True
           
            $iSamePieceCount_S = calcSameSlash $i $global:iCountPiecesRow[$i] $global:strCurrentColor $True
            
            $iSamePieceCount_B = calcSameBackslash $i $global:iCountPiecesRow[$i] $global:strCurrentColor $True
            
            if($iSamePieceCount_V[0] -gt 3 -or $iSamePieceCount_H[0] -gt 3 -or $iSamePieceCount_S[0] -gt 3 -or $iSamePieceCount_B[0] -gt 3)
            {
                Write-Host "BlockAI: I could win..."
                if($i -lt $global:iDimension_Y)
                {
                    $ScoringForRows[$i] += 300;
                }
            }
            else
            {
                Write-Host "BlockAI: Nah, I cant win..."
            }
        
        }
        
        # BLOCK AI should block and check if it could win
        if($iMode -eq 1)
        {
            return $ScoringForRows
        }
        
        for($i = 0; $i -lt $global:iDimension; $i++)
        {
            if($i -lt ($global:iDimension_Y - 1))
            {
                $iSamePieceCount_V = calcSameVertical $i ($global:iCountPiecesRow[$i]+1) $color $True
                
                $iSamePieceCount_H = calcSameHorizontal $i ($global:iCountPiecesRow[$i]+1) $color $True
            
                $iSamePieceCount_S = calcSameSlash $i ($global:iCountPiecesRow[$i]+1) $color $True
                
                $iSamePieceCount_B = calcSameBackslash $i ($global:iCountPiecesRow[$i]+1) $color $True
                
                if($iSamePieceCount_V[0] -gt 3 -or $iSamePieceCount_H[0] -gt 3 -or $iSamePieceCount_S[0] -gt 3 -or $iSamePieceCount_B[0] -gt 3)
                {
                    Write-Host "BlockAI: I should not take Row $i"
                    $ScoringForRows[$i] = -200
                    #[System.Windows.Forms.MessageBox]::Show("If I'd take Row $i the enemy could win next round")
                }
            }
        
        }
        
        return $ScoringForRows

    }
    
    function calcSameBackslashBlock($pos_X, $pos_Y, $color)
    {
        # Diagonal check
        $tmpX = $pos_X + 1;
        $tmpY = $pos_Y - 1;
        
        #Write-Host "calcSameBackslashBlock: x->$pos_X y->$pos_Y color->$color"
        
        # X
        #  X
        #   X
        #    X
        
        # connected (or connectable), left Same connected, left empty, left same not connected, right same, right empty, right same not connected
        # Those values should be used to calculate scoring
            $iSameOrEmpty = (1, 0, 0, 0, 0, 0, 0);
        $isInterrupted = $False;
        
        #check right bottom
        while($tmpX  -lt $global:iDimension -and $tmpY -ge 0 )
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[1] += 1;
                $tmpX += 1;
                $tmpY -= 1;
                #Write-Host "right bottom same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none")
            {
                $iSameOrEmpty[2] += 1;
                $tmpX += 1;
                $tmpY -= 1;
                $isInterrupted = $True;
                #Write-Host "right bottom empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[3] += 1;
                $tmpX += 1;
                $tmpY -= 1;
                #Write-Host "right bottom same disconnected`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
                $tmpY = -1;
            }
        }
        
        $tmpX = $pos_X - 1;
        $tmpY = $pos_Y + 1;
        $isInterrupted = $False;
        #check left top
        while($tmpX -ge 0 -and $tmpY -lt $global:iDimension_Y)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[4] += 1;
                $tmpX -= 1;
                $tmpY += 1;
                #Write-Host "left top same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none")
            {
                $iSameOrEmpty[5] += 1;
                $tmpX -= 1;
                $tmpY += 1;
                $isInterrupted = $True;
                #Write-Host "left top empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[6] += 1;
                $tmpX -= 1;
                $tmpY += 1;
                #Write-Host "left top same disconnected`r`n"
            }
            else
            {
                $tmpX = -1;
                $tmpY = $global:iDimension + 1;
            }
        }
        return $iSameOrEmpty
    }
    
    function calcSameSlashBlock($pos_X, $pos_Y, $color)
    {
        # Diagonal check
        $tmpX = $pos_X - 1;
        $tmpY = $pos_Y - 1;
        
        #Write-Host "calcSameSlashBlock: x->$pos_X y->$pos_Y color->$color"
        
        #    X
        #   X
        #  X
        # X
        
        # connected (or connectable), left Same connected, left empty, left same not connected, right same, right empty, right same not connected
        # Those values should be used to calculate scoring
        $iSameOrEmpty = (1, 0, 0, 0, 0, 0, 0);
        $isInterrupted = $False;
        
        #check left bottom
        while($tmpX -ge 0 -and $tmpY -ge 0)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[1] += 1;
                $tmpX -= 1;
                $tmpY -= 1;
                #Write-Host "left bottom same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none")
            {
                $iSameOrEmpty[2] += 1;
                $isInterrupted = $True;
                $tmpX -= 1;
                $tmpY -= 1;
                #Write-Host "left bottom empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[3] += 1;
                $tmpX -= 1;
                $tmpY -= 1;
                #Write-Host "left bottom same disconnected`r`n"
            }
            else
            {
                $tmpX = -1;
                $tmpY = -1;
            }
        }
        
        $tmpX = $pos_X + 1;
        $tmpY = $pos_Y + 1;
        $isInterrupted = $False;
        #check right top
        while($tmpX -lt $global:iDimension -and $tmpY -lt $global:iDimension_Y)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[4] += 1;
                $tmpX += 1;
                $tmpY += 1;
                #Write-Host "right top same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none")
            {
                $iSameOrEmpty[5] += 1;
                $tmpX += 1;
                $tmpY += 1;
                $isInterrupted = $True;
                #Write-Host "right top empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[6] += 1;
                $tmpX += 1;
                $tmpY += 1;
                #Write-Host "right top same disconnected`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
                $tmpY = $global:iDimension_Y + 1;
            }
        }
        
        return $iSameOrEmpty
    }
    
    
    function calcSameVerticalBlock($pos_X, $pos_Y, $color)
    {
        # connected (or connectable), left Same connected, left empty, left same not connected, right same, right empty, right same not connected
        # Those values should be used to calculate scoring
        $iSameOrEmpty = (1, 0, 0, 0, 0, 0, 0);
        
        #Write-Host "calcSameVerticalBlock: x->$pos_X y->$pos_Y color->$color"
        
        # Vertical check
        $tmpY = $pos_Y - 1;
        
        $isInterrupted = $False;
        #check under
        while($tmpY -ge 0)
        {
            if($global:arrPlaced[$pos_X][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[1] += 1;
                $tmpY -= 1;
                #Write-Host "bottom equal`r`n"
            }
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq "none")
            {
                $iSameOrEmpty[2] += 1;
                $tmpY -= 1;
                #Write-Host "bottom empty`r`n"
            }
            # can never happen
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq $color)
            {
                $iSameOrEmpty[3] += 1;
                $tmpX -= 1;
                #Write-Host "bottom same disconnected`r`n"
            }
            else
            {
                $tmpY = -1;
            }
        }
        
        $isInterrupted = $False;
        $tmpY = $pos_Y + 1;
        #check over
        while($tmpY -lt $global:iDimension_Y)
        {
            if($global:arrPlaced[$pos_X][$tmpY] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[4] += 1;
                $tmpY += 1;
                #Write-Host "top equal`r`n"
            }
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq "none")
            {
                $iSameOrEmpty[5] += 1;
                $tmpY += 1;
                #Write-Host "top empty`r`n"
            }
            # can never happen
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq $color)
            {
                $iSameOrEmpty[6] += 1;
                $tmpY += 1;
                #Write-Host "top equal disconnected`r`n"
            }
            else
            {
                $tmpY = $global:iDimension_Y + 1;
            }
        }
        
        return $iSameOrEmpty 
    }
    
    function calcSameHorizontalBlock($pos_X, $pos_Y, $color)
    {
        # Horizontal check
        $tmpX = $pos_X - 1;
        # connected (or connectable), left Same connected, left empty, left same not connected, right same, right empty, right same not connected
        # Those values should be used to calculate scoring
        $iSameOrEmpty = (1, 0, 0, 0, 0, 0, 0);
        
        #Write-Host "calcSameHorizontalBlock: x->$pos_X y->$pos_Y color->$color"
        
        $isInterrupted = $False;
        
        #check left
        while($tmpX -ge 0)
        {
            if($global:arrPlaced[$tmpX][$pos_Y] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[1] += 1;
                $tmpX -= 1;
                #Write-Host "left equal`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq "none")
            {
                $iSameOrEmpty[2] += 1;
                $tmpX -= 1;
                $isInterrupted = $True;
                #Write-Host "left empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq $color)
            {
                $iSameOrEmpty[3] += 1;
                $tmpX -= 1;
                #Write-Host "left same disconnected`r`n"
            }
            else
            {
                $tmpX = -1;
            }
        }
        
        $isInterrupted = $False;
        $tmpX = $pos_X + 1;
        #check right
        while($tmpX -lt $global:iDimension)
        {
            if($global:arrPlaced[$tmpX][$pos_Y] -eq $color -and !$isInterrupted)
            {
                $iSameOrEmpty[4] += 1;
                $tmpX += 1;
                #Write-Host "right equal`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq "none")
            {
                $iSameOrEmpty[5] += 1;
                $tmpX += 1;
                $isInterrupted = $True;
                #Write-Host "right empty`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq $color)
            {
                $iSameOrEmpty[6] += 1;
                $tmpX += 1;
                #Write-Host "right same disconnected`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
            }
        }
        
        return $iSameOrEmpty 
    }
    
    function AI_BlockAI_Wins
    {
        [int] $index = 0
        $ScoringRows = (0, 0, 0, 0, 0, 0, 0);
        
        if($global:strCurrentColor -eq "Red")
        {
            $ScoringRows = TestTempBlock "Orange" 1
        }
        else
        {
            $ScoringRows = TestTempBlock "Red" 1
        }
    
        $maximum = ($ScoringRows | Measure -Max).Maximum
    
        Write-Host "Maximum is: $maximum`r`n"
        Write-Host "Array is: $ScoringRows`r`n"
    
        for($j = 0; $j -lt $global:iDimension; $j++)
        {
            if($ScoringRows[$j] -eq $maximum)
            {
                $index = $j;
            }
        }
        
        return $index;
    }
    
    function AI_BlockAI_WinsII
    {
        [int] $index = 0
        $ScoringRows = (0, 0, 0, 0, 0, 0, 0);
        
        if($global:strCurrentColor -eq "Red")
        {
            $ScoringRows = TestTempBlock "Orange" 2
        }
        else
        {
            $ScoringRows = TestTempBlock "Red" 2
        }
    
        $maximum = ($ScoringRows | Measure -Max).Maximum
    
        Write-Host "Maximum is: $maximum`r`n"
        Write-Host "Array is: $ScoringRows`r`n"
    
        for($j = 0; $j -lt $global:iDimension; $j++)
        {
            if($ScoringRows[$j] -eq $maximum)
            {
                #return $j;
                $index = $j;
            }
        }
        
        return $index;
    }
    
    function AI_BlockAI
    {
        [int] $index = 0
        $ScoringRows = (0, 0, 0, 0, 0, 0, 0);
        
        if($global:strCurrentColor -eq "Red")
        {
            $ScoringRows = TestTempBlock "Orange" 0
        }
        else
        {
            $ScoringRows = TestTempBlock "Red" 0
        }
    
        $maximum = ($ScoringRows | Measure -Max).Maximum
    
        Write-Host "Maximum is: $maximum`r`n"
        Write-Host "Array is: $ScoringRows`r`n"
    
        for($j = 0; $j -lt $global:iDimension; $j++)
        {
            if($ScoringRows[$j] -eq $maximum)
            {
                #return $j;
                $index = $j;
            }
        }
        
        return $index;
    }
    
    function handleAITurn($strAIType)
    {
        Write-Host "Handling AI turn... (AI Type: $strAIType)`r`n"
        if($global:iCurrentRound -ge ($global:iDimension * $global:iDimension_Y) -or $global:bIsFinished)
        {
            $global:bIsFinished = $True;
            return;
        }
    
        if($global:bIsFinished)
        {
            Write-Host "... but Game is Finished!`r`n"
            return;
        }
    
        [int]$AIRowSelection = 0;
    
        switch($strAIType)
        {
            
            "Score AI" {
            Write-Host "... $strAIType taking Action...`r`n"
            $AIRowSelection = AI_SpotAI}
            "Block AI" {
            Write-Host "... $strAIType taking Action...`r`n"
            $AIRowSelection = AI_BlockAI;}
            "BlockWin AI" {
            Write-Host "... $strAIType taking Action...`r`n"
            $AIRowSelection = AI_BlockAI_Wins;}
            "BlockWinII AI" {
            Write-Host "... $strAIType taking Action...`r`n"
            $AIRowSelection = AI_BlockAI_WinsII;}
      
            
            default {
            Write-Host "... Invalid AI Type...`r`n"
            Write-Host "... AI_RandomAI taking Action...`r`n"
            $AIRowSelection = AI_RandomAI}
        }
        
        Write-Host "AI takes row: $AIRowSelection ($strAIType)"
        
        if($global:iCurrentRound -lt 42)
        {
            handleRowButtonClick $AIRowSelection
        }
    }
    
    function AI_BestSpotAI($color)
    {
        $iS_PossibleWins = (0, 0, 0, 0, 0, 0, 0);
        $returnValues = (0,0);
    
        for($i = 0; $i -lt $global:iDimension; $i++)
        {
            #$i = X
            #$global:iCountPiecesRow[$i] = Y
            $iSamePieceCount_V = calcSameVertical $i $global:iCountPiecesRow[$i] $color $True
            
            #Write-Host "iSamePieceCount_V: $iSamePieceCount_V`r`n"
            
            $iSamePieceCount_H = calcSameHorizontal $i $global:iCountPiecesRow[$i] $color $True
            
            #Write-Host "iSamePieceCount_H: $iSamePieceCount_H`r`n"
           
            $iSamePieceCount_S = calcSameSlash $i $global:iCountPiecesRow[$i] $color $True
            
            #Write-Host "iSamePieceCount_S: $iSamePieceCount_S`r`n"
            
            $iSamePieceCount_B = calcSameBackslash $i $global:iCountPiecesRow[$i] $color $True
            
            #Write-Host "iSamePieceCount_S: $iSamePieceCount_S`r`n"
            
            # This calculates the possible wins, if there are less than 3 empty spots plus connected around, this will fail
            #if(($iSamePieceCount_V[0] + $iSamePieceCount_V[1]) -gt 3) {$iS_PossibleWins[$i] += $iSamePieceCount_V[0] + $iSamePieceCount_V[1] - 3}

            if(($iSamePieceCount_V[0] + $iSamePieceCount_V[1] + $iSamePieceCount_V[2]) -gt 3 -and $global:iCountPiecesRow[$i] -ne $global:iDimension) 
            {
                $iS_PossibleWins[$i] += $iSamePieceCount_V[0] + $iSamePieceCount_V[1] + $iSamePieceCount_V[2]
                
                if($iSamePieceCount_V[1] -gt $iSamePieceCount_V[2])
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_V[2]
                }
                else
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_V[1]
                }
                
                if($iSamePieceCount_V[1] -eq $iSamePieceCount_V[2])
                {
                    $iS_PossibleWins[$i] += 1
                }
                
                $iS_PossibleWins[$i] += $iSamePieceCount_V[0] - 1
            }
            elseif($global:iCountPiecesRow[$i] -ne $global:iDimension)
            {
                $iS_PossibleWins[$i] = -1
            }
            
            if(($iSamePieceCount_H[0] + $iSamePieceCount_H[1] + $iSamePieceCount_H[2]) -gt 3 -and $global:iCountPiecesRow[$i] -ne $global:iDimension) 
            {
                $iS_PossibleWins[$i] += $iSamePieceCount_H[0] + $iSamePieceCount_H[1] + $iSamePieceCount_H[2]
                
                if($iSamePieceCount_H[1] -gt $iSamePieceCount_H[2])
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_H[2]
                }
                else
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_H[1]
                }
                
                if($iSamePieceCount_H[1] -eq $iSamePieceCount_H[2])
                {
                    $iS_PossibleWins[$i] += 1
                }
                
                $iS_PossibleWins[$i] += $iSamePieceCount_H[0] - 1
            }
            elseif($global:iCountPiecesRow[$i] -ne $global:iDimension)
            {
                $iS_PossibleWins[$i] = -1
            }
            
            if(($iSamePieceCount_S[0] + $iSamePieceCount_S[1] + $iSamePieceCount_S[2]) -gt 3 -and $global:iCountPiecesRow[$i] -ne $global:iDimension) 
            {
                $iS_PossibleWins[$i] += $iSamePieceCount_S[0] + $iSamePieceCount_S[1] + $iSamePieceCount_S[2]
                
                if($iSamePieceCount_S[1] -gt $iSamePieceCount_S[2])
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_S[2]
                }
                else
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_S[1]
                }
                
                if($iSamePieceCount_S[1] -eq $iSamePieceCount_S[2])
                {
                    $iS_PossibleWins[$i] += 1
                }
                
                $iS_PossibleWins[$i] += $iSamePieceCount_S[0] - 1
            }
            elseif($global:iCountPiecesRow[$i] -ne $global:iDimension)
            {
                $iS_PossibleWins[$i] = -1
            }
            
            if(($iSamePieceCount_B[0] + $iSamePieceCount_B[1] + $iSamePieceCount_B[2]) -gt 3 -and $global:iCountPiecesRow[$i] -ne $global:iDimension) 
            {
                $iS_PossibleWins[$i] += $iSamePieceCount_B[0] + $iSamePieceCount_B[1] + $iSamePieceCount_B[2]
                
                if($iSamePieceCount_B[1] -gt $iSamePieceCount_B[2])
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_B[2]
                }
                else
                {
                    $iS_PossibleWins[$i] += $iSamePieceCount_B[1]
                }
                
                if($iSamePieceCount_B[1] -eq $iSamePieceCount_B[2])
                {
                    $iS_PossibleWins[$i] += 1
                }
                
                $iS_PossibleWins[$i] += $iSamePieceCount_B[0] - 1
            }
            elseif($global:iCountPiecesRow[$i] -ne $global:iDimension)
            {
                $iS_PossibleWins[$i] = -1
            }
            
        }
        
        # calculate maximum
        $iMAX_SORT = $iS_PossibleWins | sort -Descending
        
        $iMAX_COUNT = 1
        for($j = 1; $j -lt $global:iDimension; $j++)
        {
            if($iMAX_SORT[$j] -eq $iMAX_SORT[0])
            {
                $iMAX_COUNT += 1;
            }
        }
        
        $rnd = Get-Random -maximum $iMAX_COUNT
        
        for($j = 0; $j -lt $global:iDimension; $j++)
        {
            if($iMAX_SORT[0] -eq $iS_PossibleWins[$j] -and $rnd -eq 0)
            {
                
                $returnValues[0] = $j
                $returnValues[1] = $iS_PossibleWins[$j]
                $rowIDCount = $global:iCountPiecesRow[$j]
                return $returnValues;
            }
            elseif($iMAX_SORT[0] -eq $iS_PossibleWins[$j])
            {
                $rnd -= 1;
            }
            
        }
        Write-Host "Returning invalid Value..."
        #Write-Host "Wins: $iS_PossibleWins"
    }
    
    function AI_SpotAI
    {
        $current = (0,0)
        $other = (0,0)
        
        $current = AI_BestSpotAI $global:strCurrentColor 
        if($global:strCurrentColor -eq "Red") {$other = AI_BestSpotAI "Orange"} else {$other = AI_BestSpotAI "Red"}
        
        if($current[1] -gt $other[1]){
        #if($global:iCountPiecesRow[$current[0]] -ge $global:iDimension) {[System.Windows.Forms.MessageBox]::Show("Invalid selection")} 
        } else {
        #if($global:iCountPiecesRow[$other[0]] -ge $global:iDimension) {[System.Windows.Forms.MessageBox]::Show("Invalid selection")} 
        }
        
        if($current[1] -gt $other[1]){
        if($global:iCountPiecesRow[$current[0]] -ge $global:iDimension){
        $value = AI_RandomAI
        return $value}
        #Write-Host "Returning: $current"
        return $current[0]} else {
        if($global:iCountPiecesRow[$other[0]] -ge $global:iDimension_Y){
        $value = AI_RandomAI
        return $value
        }
        #Write-Host "Returning: $other"
        return $other[0]}
    }
    
    function AI_RandomAI
    {
        Write-Host "AI_RandomAI taking Action...`r`n"
        $bIsInvalid = $True;
        $rnd = Get-Random -maximum 7
        
        if($global:iCurrentRound -ge $global:iDimension*$global:iDimension_Y)
        {
            $global:bIsFinished = $True;
            return;
        }
        
        while($bIsInvalid)
        {
            $rnd = Get-Random -maximum 7
            Write-Host "AI_RandomAI: $rnd `r`n"
            
            if($global:iCountPiecesRow[$rnd] -lt $global:iDimension_Y)
            {
                #$tmpNR = $global:iCountPiecesRow[$rnd]
                #Write-Host "AI_RandomAI: |$tmpNR|$global:Dimension|"+ $tmpNR -ge $global:Dimension +"|`r`n"
            
                Write-Host "AI_RandomAI: Valid Row!`r`n"
                $bIsInvalid = $False;
            }
        }
        
        Write-Host "AI_RandomAI:Returning Row $rnd `r`n"
        return $rnd
    }
    
    function saveToConfigFile
    {
        Write-Host "Saving Config... `r`n"
        $global:arrConfig[1] = $txfIP.Text
        $global:arrConfig[3] = $txfPort.Text
        if($global:bIsMuted){
            $global:arrConfig[5] = "True"
        }else{
            $global:arrConfig[5] = "False"
        }
        $global:arrConfig[7] = $objForm.Location.X
        $global:arrConfig[9] = $objForm.Location.Y
        
        out-file -filepath "..\Config\Game.cfg" -inputobject $global:arrConfig
        Write-Host "... done! `r`n"
    }
    
    function loadConfigFromFile
    {
        Write-Host "Loading Config... `r`n"
        If (Test-Path "..\Config\Game.cfg"){
            $global:arrConfig = Get-Content "..\Config\Game.cfg"
            $global:iIP = $global:arrConfig[1]
            $txfIP.Text = $global:arrConfig[1]
            $global:iPort = $global:arrConfig[3]
            $txfPort.Text = $global:arrConfig[3]
            if($global:arrConfig[5] -eq "False")
            {
                $global:bIsMuted = $False;
                $btnMute.Text = "Mute"
            }
            else
            {
                $global:bIsMuted = $True;
                $btnMute.Text = "Unmute"
            }
            Write-Host "... done! `r`n"
            #[System.Windows.Forms.MessageBox]::Show($global:arrConfig[1] + " " + $global:arrConfig[3] + " " + $global:arrConfig[5],"Config File",0)
        } else {
            Write-Host "... no config, creating new... `r`n"
            #[System.Windows.Forms.MessageBox]::Show("Config File not existing!","Config File",0)
            $strTempConfig = ("# GameIP (-> 127.0.0.1)", "255.255.255.255", "# Gameport (-> 8080)", "8080", "# Are sounds muted? (-> False / True)", "False", "# Last X (-> 0 = Center)", "0", "# Last Y (-> 0 = Center)", "0");
            out-file -filepath "..\Config\Game.cfg" -inputobject $strTempConfig
            $global:arrConfig = $strTempConfig
            
            $global:iIP = $global:arrConfig[1]
            $txfIP.Text = $global:arrConfig[1]
            $global:iPort = $global:arrConfig[3]
            $txfPort.Text = $global:arrConfig[3]
            if($global:arrConfig[5] -eq "False")
            {
                $global:bIsMuted = $False;
                $btnMute.Text = "Mute"
            }
            else
            {
                $global:bIsMuted = $True;
                $btnMute.Text = "Unmute"
            }
            Write-Host "... done! `r`n"
        }
    }
    
    
    # Sets the color of all "Add piece" buttons
    function setColorsButtonsPiece2($Color){
        Write-Host "Setting Color to: $Color`r`n"
    
        if($btnR1.Enabled){
        $btnR1.BackColor = $Color
        }
        if($btnR2.Enabled){
        $btnR2.BackColor = $Color
        }
        if($btnR3.Enabled){
        $btnR3.BackColor = $Color
        }
        if($btnR4.Enabled){
        $btnR4.BackColor = $Color
        }
        if($btnR5.Enabled){
        $btnR5.BackColor = $Color
        }
        if($btnR6.Enabled){
        $btnR6.BackColor = $Color
        }
        if($btnR7.Enabled){
        $btnR7.BackColor = $Color
        }
        
        # in a multiplayer session we need a redraw here
        if(!$global:bIsLokal)
        {
            $objForm.Refresh()
        }
    }

    # Hides all "Add Piece" buttons
    function hideButtonsPiece{
        Write-Host "Hiding buttons... `r`n"
        $btnR1.Hide();
        $btnR2.Hide();
        $btnR3.Hide();
        $btnR4.Hide();
        $btnR5.Hide();
        $btnR6.Hide();
        $btnR7.Hide();
        
        # in a multiplayer session we need a redraw here
        if(!$global:bIsLokal)
        {
            $objForm.Refresh()
        }
    }

    # Show all "Add Piece" buttons if they are enabled
    function showButtonsPiece{
        Write-Host "Showing buttons... `r`n"
    
        if($btnR1.Enabled){
            $btnR1.Show();
        }
        if($btnR2.Enabled){
            $btnR2.Show();
        }
        if($btnR3.Enabled){
            $btnR3.Show();
        }
        if($btnR4.Enabled){
            $btnR4.Show();
        }
        if($btnR5.Enabled){
            $btnR5.Show();
        }
        if($btnR6.Enabled){
            $btnR6.Show();
        }
        if($btnR7.Enabled){
            $btnR7.Show();
        }
        
        # in a multiplayer session we need a redraw here
        if(!$global:bIsLokal)
        {
            $objForm.Refresh()
        }
    }

    # sets the beginners color (and thus playerID)
    function setBegin($Color)
    {
        Write-Host "Begin color changed to $Color..."
        if($Color -eq "Red")
        {
            $RadioButton1.Checked = $True;
            setColorsButtonsPiece2($global:Color2)
        }
        else
        {
            $RadioButton2.Checked = $True;
            setColorsButtonsPiece2($global:Color1)
        }
        
        $global:strCurrentColor = $Color;
        #setColorsButtonsPiece2($global:strCurrentColor);
    }
    
    # Changes radio buttons state and global color
    function handleBeginChange{
        Write-Host "handleBeginChange`r`n"
        if ($global:iCurrentRound -eq 0)
        {
            if($RadioButton1.Checked)
            {
                $global:strCurrentColor = "Red";
                setColorsButtonsPiece2($global:Color1)
            }
            else
            {
                $global:strCurrentColor = "Orange";
                setColorsButtonsPiece2($global:Color2)
            }
    
            #setColorsButtonsPiece2($global:strCurrentColor)
        }
    }

    # Updates the label for round
    function updateRundeText{
        Write-Host "updateRundeText`r`n"
        if($global:iCurrentRound -ge $global:iDimension * $global:iDimension_Y + 1)
        {
            $global:bGameRunning = $False;
            $global:bIsFinished = $True;
            return;
        }
        
        $txtRunde.Text = "Round: " + $global:iCurrentRound + "/" + $global:iDimension * $global:iDimension_Y
    }

    # Plays a soundFX, if Range is 1, only that one sound is played
    # IMPORTANT: Random sounds need to be in order (eg, 7, 8, 9 not 7, 9, 10)
    function playSoundFXRandom($sfxID, $Range){
        Write-Host "playSoundFXRandom ( ID: $sfxID Range: $Range) `r`n"
        if($global:bIsMuted)
        {
            return;
        }
        
        $rnd = Get-Random -maximum $Range;
        $arrSounds[$sfxID + $rnd].Play();
    }

    function calcSameVertical($pos_X, $pos_Y, $color, $ignoreEmpty=$False)
    {
        # A piece has been placed, at least that one is... one
        $iSameOrEmpty = (1, 0, 0);
    
        # Vertical check
        $tmpY = $pos_Y - 1;
        
        #check under
        while($tmpY -ge 0)
        {
            if($global:arrPlaced[$pos_X][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpY -= 1;
                Write-Host "bottom equal`r`n"
            }
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq "none" -and $ignoreEmpty)
            {
                $iSameOrEmpty[1] += 1;
                $tmpY -= 1;
                #Write-Host "bottom empty`r`n"
            }
            else
            {
                $tmpY = -1;
            }
        }
        
        $tmpY = $pos_Y + 1;
        #check over
        while($tmpY -lt $global:iDimension)
        {
            if($global:arrPlaced[$pos_X][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpY += 1;
                Write-Host "top equal`r`n"
            }
            elseif($global:arrPlaced[$pos_X][$tmpY] -eq "none" -and $ignoreEmpty)
            {
                $iSameOrEmpty[2] += 1;
                $tmpY += 1;
                #Write-Host "top empty`r`n"
            }
            else
            {
                $tmpY = $global:iDimension + 1;
            }
        }
        
        return $iSameOrEmpty 
    }
    
    function calcSameHorizontal($pos_X, $pos_Y, $color, $ignoreEmpty=$False)
    {
        # Horizontal check
        $tmpX = $pos_X - 1;
        # connected (or connectable), left empty, right empty
        $iSameOrEmpty = (1, 0, 0);
        #check left
        while($tmpX -ge 0)
        {
            if($global:arrPlaced[$tmpX][$pos_Y] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX -= 1;
                Write-Host "left equal`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[1] += 1;
                $tmpX -= 1;
                #Write-Host "left empty`r`n"
            }
            else
            {
                $tmpX = -1;
            }
        }
        
        $tmpX = $pos_X + 1;
        #check right
        while($tmpX -lt $global:iDimension)
        {
            if($global:arrPlaced[$tmpX][$pos_Y] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX += 1;
                Write-Host "right equal`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$pos_Y] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[2] += 1;
                $tmpX += 1;
                #Write-Host "right empty`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
            }
        }
        
        #Write-Host "Returning: $iSameOrEmpty "
        return $iSameOrEmpty 
    }
    
    function calcSameSlash($pos_X, $pos_Y, $color, $ignoreEmpty=$False)
    {
        # Diagonal check
        $tmpX = $pos_X - 1;
        $tmpY = $pos_Y - 1;
        
        #   X
        #  X
        # X
        
        $iSameOrEmpty = (1, 0, 0);
        #check left bottom
        while($tmpX -ge 0 -and $tmpY -ge 0)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX -= 1;
                $tmpY -= 1;
                Write-Host "left bottom same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[1] += 1;
                $tmpX -= 1;
                $tmpY -= 1;
                #Write-Host "left bottom empty`r`n"
            }
            else
            {
                $tmpX = -1;
                $tmpY = -1;
            }
        }
        
        $tmpX = $pos_X + 1;
        $tmpY = $pos_Y + 1;
        #check right top
        while($tmpX  -lt $global:iDimension -and $tmpY -lt $global:iDimension_Y)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX += 1;
                $tmpY += 1;
                Write-Host "right top same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[2] += 1;
                $tmpX += 1;
                $tmpY += 1;
                #Write-Host "right top empty`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
                $tmpY = $global:iDimension + 1;
            }
        }
        
        return $iSameOrEmpty
    }
    
    function calcSameBackslash($pos_X, $pos_Y, $color, $ignoreEmpty=$False)
    {
        # Diagonal check
        $tmpX = $pos_X + 1;
        $tmpY = $pos_Y - 1;
        
        # X
        #  X
        #   X
        
        $iSameOrEmpty = (1, 0, 0);
        #check right bottom
        while($tmpX  -lt $global:iDimension -and $tmpY -ge 0 )
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX += 1;
                $tmpY -= 1;
                Write-Host "right bottom same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[1] += 1;
                $tmpX += 1;
                $tmpY -= 1;
                #Write-Host "right bottom empty`r`n"
            }
            else
            {
                $tmpX = $global:iDimension + 1;
                $tmpY = -1;
            }
        }
        
        $tmpX = $pos_X - 1;
        $tmpY = $pos_Y + 1;
        #check left top
        while($tmpX -ge 0 -and $tmpY -lt $global:iDimension_Y)
        {
            if($global:arrPlaced[$tmpX][$tmpY] -eq $color)
            {
                $iSameOrEmpty[0] += 1;
                $tmpX -= 1;
                $tmpY += 1;
                Write-Host "left top same`r`n"
            }
            elseif($global:arrPlaced[$tmpX][$tmpY] -eq "none" -and $ignoreEmpty -and $global:iCountPiecesRow[$pos_X] -eq $global:iCountPiecesRow[$tmpX])
            {
                $iSameOrEmpty[2] += 1;
                $tmpX -= 1;
                $tmpY += 1;
                #Write-Host "left top empty`r`n"
            }
            else
            {
                $tmpX = -1;
                $tmpY = $global:iDimension + 1;
            }
        }
        return $iSameOrEmpty
    }
    
    # guess this is slow as hell, could be improved by:
    # spot is a class
    # connection and color is saved
    # only compute connection once, then add connections together
    function checkWin($pos_X, $pos_Y)
    {
        Write-Host "Check for winner (X: $pos_X  Y: $pos_Y)...`r`n"
        # A piece has been placed, at least that one is... one
        $iSamePieceCount = calcSameVertical $pos_X $pos_Y $global:strCurrentColor
         
        if($iSamePieceCount[0] -gt 3)
        {
            handleWin
            return $True;
        }
        
        $iSamePieceCount = calcSameHorizontal $pos_X $pos_Y $global:strCurrentColor
        
        if($iSamePieceCount[0] -gt 3)
        {
            handleWin
            return $True;
        }
        
        $iSamePieceCount = calcSameSlash $pos_X $pos_Y $global:strCurrentColor
        
        if($iSamePieceCount[0] -gt 3)
        {
            handleWin
            return $True;
        }
        
        $iSamePieceCount = calcSameBackslash $pos_X $pos_Y $global:strCurrentColor
        
        # More than 3 pieces are equal? Handle win
        if($iSamePieceCount[0] -gt 3)
        {
            handleWin
            return $True;
        }
        Write-Host "...no winner`r`n"
    }

    # Sends a message to a remote pc by given port and address
    function send-msg ($message=$([char]4), $port=8989, $server="localhost", $chatmsg="") {
        # dont try sending anything if the game is finished
        Write-Host "Sending Message over TCP (message: $message port: $port address: $server chatmsg: $chatmsg)`r`n"
        if($global:bIsFinished)
        {
            return $False;
        }
        
        # used for reconnecting - maybe a question message would be better
        $reconTrys = 0;
        $recon = $False;
        
        Do{
            Try
            {
                $client = New-Object System.Net.Sockets.TcpClient $server, $port
                $stream = $client.GetStream()
                $writer = New-Object System.IO.StreamWriter $stream
                
                $writer.Write($message)
                $writer.Write($chatmsg)
                $chatmsg = "";
                # did I win?
                if($message -ne 9)
                {
                    checkWin $message $global:iCountPiecesRow[$message];
                }
                
                if($global:bIsFinished)
                {
                    hideButtonsPiece
                }
                
                $writer.Dispose()
                $stream.Dispose()
            }
            Catch [system.exception]
            {
                playSoundFXRandom 10 1
    
                $txfTextLog.Text = $txfTextLog.Text + "`r`n<Server> " + "Can't reach host... retrying in 3s!"
                $reconTrys += 1;
                $recon = $True;
                $objForm.Refresh();
                Start-Sleep 3
                if($reconTrys -ge 3)
                {
                    $txfTextLog.Text = $txfTextLog.Text + "`r`n<Server> " + "A network error occured, exiting!"
                    $global:bIsFinished = $True;
                    [System.Windows.Forms.MessageBox]::Show("Can't reach your opponent, game ends!","Network problem",0)
                }
            }
        }while($reconTrys -lt 3 -and $recon)
    }
#send-msg "Hallo`r`n" 8989 "localhost" "msg"

    function listen-port ($port=8989) {
    
        Write-Host "Listening for message (port: $port)...`r`n"
        $txfSendMsg.ReadOnly = $True
        $txfSendMsg.Enabled = $False;
        $btnSend.Enabled = $False;

        hideButtonsPiece

        if($global:bIsFinished)
        {
            return $False;
        }
    
        Start-Sleep -Milliseconds 50
    
        Try
        {
            $endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
            $listener = new-object System.Net.Sockets.TcpListener $endpoint
            $listener.start()
    
            $client = $listener.AcceptTcpClient() # will block here until connection
            $stream = $client.GetStream();
            $reader = New-Object System.IO.StreamReader $stream
        }
        Catch [system.exception]
        {
            $global:bIsFinished = $True;
            [System.Windows.Forms.MessageBox]::Show("Another Server is listening on that Port!","Network problem",0)
            
            $ErrorMessage = $_.Exception.Message
            
            Write-Host "Exception Message: $ErrorMessage"
            
            $objForm.Visible = $True;
            $objForm.Refresh();
            return;
        }
        
        do {
            $line = $reader.ReadLine()

            if($line -and $line -ne ([char]4))
            {
                $msgString = [system.String]::Join("", $line)
                $iButtonID = $msgString.Substring(0, 1)
                $strMessage = $msgString.Substring(1)

                Write-Host "ButtonID: |$iButtonID| Message: |$strMessage| Line: |$line|`r`n"

                if($strMessage -ne "" -and $strMessage -ne $global:strPrevMsg)
                {
                    $txfTextLog.Text = $txfTextLog.Text + "`r`n<Stranger> " + $strMessage
                    $global:strPrevMsg = $strMessage;
                }

                $lineAsNumber = ([convert]::ToInt32($iButtonID, 10))
                if($lineAsNumber -ne 9)
                {
                    handleRowButtonClick($lineAsNumber)
                }
                else
                {
                    playSoundFXRandom 10 1

                    $txfTextLog.Text = $txfTextLog.Text + "`r`n<Server> " + "Your opponent left the game."
                    $global:bIsFinished = $True;
                    $global:bGameRunning = $True;
                }
            }
            
        } while ($line -and $line -ne ([char]4))
        
        $reader.Dispose()
        $stream.Dispose()
        $listener.stop()
        #$client.stop()
        #$listener.Dispose()
        #$client.Dispose()
        playSoundFXRandom 9 1
        showButtonsPiece

        $txfSendMsg.ReadOnly = $False;
        $txfSendMsg.Enabled = $True;
        $btnSend.Enabled = $True;
    }
    #listen-port 8989

    function handleStartGame
    {
        Write-Host "Game starting...`r`n"
        
    
        # Disable Options
        $txfIP.Enabled = $False;
        $txfPort.Enabled = $False;
        $RadioButton1.Enabled = $False;
        $RadioButton2.Enabled = $False;
        $DropDown1.Enabled = $False;
        $DropDown2.Enabled = $False;
        $btnMulti.Enabled = $False;
        $btnServer.Enabled = $False;
        $btnStart.Enabled = $False;
        $strPlayerTypes[0] = $DropDown1.Text;
        $strPlayerTypes[1] = $DropDown2.Text;
        
        $strSelectedIndex[0] = $DropDown1.SelectedIndex;
        $strSelectedIndex[1] = $DropDown2.SelectedIndex;
        # Enable chat

        if($global:strCurrentColor -eq "Red")
        {
            setColorsButtonsPiece2($global:Color1)
        }
        else
        {
            setColorsButtonsPiece2($global:Color2)
        }
        
        if(!$global:bIsLokal -and !$global:bIsServer)
        {
            $txfSendMsg.ReadOnly = $False;
            $txfSendMsg.Enabled = $True;
            $btnSend.Enabled = $True;
            $txfTextLog.Enabled = $True;
        }
        
        $global:bGameRunning = $True;
        
        $global:iIP = $txfIP.Text;
        $global:iPort = $txfPort.Text;
        
        $global:bIsLokal = $global:bIsLokal;
        $global:bIsServer = $global:bIsServer;
        
        if($global:bIsLokal)
        {
            Write-Host "Local game...`r`n"
            # Who Starts?
            # Player 1
            if($global:strCurrentColor -eq "Red")
            {
                if($strPlayerTypes[0] -ne $global:PlayerTypes[0])
                {
                    Write-Host "Is AI(handle Start game)`r`n"
                    handleAITurn $strPlayerTypes[0]
                }
            }
            else # Player 2
            {
                if($strPlayerTypes[1] -ne $global:PlayerTypes[0])
                {
                    Write-Host "Is AI(handle Start game)`r`n"
                    handleAITurn $strPlayerTypes[1]
                }
            }
            return;
        }
        else
        {
            $AppSizeX   = 720
            $objForm.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
            $objForm.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY) 
            $objForm.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
        }
        
        if($global:bIsServer)
        {
            Write-Host "Waiting for Client...`r`n"
            
            listen-port $global:iPort
            
            $global:bIsServer = $False;
            
            $txfTextLog.Enabled = $True;

            #$global:bIsFinished
        }

        #Write-Host "But not Server..."
    }
    
    function handleTie
    {
        $txfSendMsg.ReadOnly = $True
        $txfSendMsg.Enabled = $False;
        $btnSend.Enabled = $False;
        
        Write-Host "...game ends tie - Yay!`r`n"
        
        $global:bIsFinished = $True;

        $lblWinner = New-Object System.Windows.Forms.Label
        $lblWinner.Location = New-Object System.Drawing.Size(8,160)
        $lblWinner.Size = New-Object System.Drawing.Size(180,70)
        $lblWinner.BackColor = "Blue"
        $lblWinner.TextAlign = "MiddleCenter";
        
        $lblWinner.Text = "Tie"
            #playSoundFXRandom 7 1;
        if($global:bIsTournament)
        {
            executeDBQuerysGameEndsTie
        }
        
        $lblWinner.Font = "Aerial,14"
        $objForm.Controls.Add($lblWinner)
    
    }
    
    function handleWin
    {
        if($global:bIsFinished)
        {
            return;
        }
        
        $txfSendMsg.ReadOnly = $True
        $txfSendMsg.Enabled = $False;
        $btnSend.Enabled = $False;
        
        Write-Host "...Someone won - Yay!`r`n"
        
        $global:bIsFinished = $True;

        $lblWinner = New-Object System.Windows.Forms.Label
        $lblWinner.Location = New-Object System.Drawing.Size(8,160)
        $lblWinner.Size = New-Object System.Drawing.Size(180,70)
        #$lblWinner.BackColor = $global:strCurrentColor
        $lblWinner.TextAlign = "MiddleCenter";
        if($global:bIsLokal)
        {
            #$lblWinner.Text = "Winner: " + $global:strCurrentColor
            if($global:strCurrentColor -eq "Red")
            {
                $lblWinner.Text = "Player 1 wins"
                $lblWinner.BackColor = $global:Color1;
            }
            else
            {
                $lblWinner.Text = "Player 2 wins"
                $lblWinner.BackColor = $global:Color2;
            }
            
            
            playSoundFXRandom 7 1;
            if($global:bIsTournament)
            {
                executeDBQuerysGameEnds
            }
        }
        else
        {
            if(!$global:bIsServer -and $global:strCurrentColor -eq "Red")
            {
                $lblWinner.Text = "You won!"
            }
            elseif($global:bIsServer -and $global:strCurrentColor -eq "Red")
            {
                $lblWinner.Text = "You lost!"
            }
            elseif(!$global:bIsServer -and $global:strCurrentColor -eq "Orange")
            {
                $lblWinner.Text = "You won!"
            }
            elseif($global:bIsServer -and $global:strCurrentColor -eq "Orange")
            {
                $lblWinner.Text = "You lost!"
            }
        }
        
        $lblWinner.Font = "Aerial,14"
        $objForm.Controls.Add($lblWinner)
        
        
        #if(!$global:bIsLokal)
    }

    function handleRowButtonClick([int]$ButtonID)
    {
        #AI_BestOwnSpotAI
    
        #Start-Sleep 1
    
        Write-Host "handleRowButtonClick`r`n"
        
        $bJumpIntoStartGame = $False;
        
        if(!$global:bIsLokal -and !$global:bIsServer -and $global:strCurrentLoadedGameString -eq "")
        {
            send-msg $ButtonID $global:iPort $global:iIP $global:strChatMessage
            $global:strChatMessage = "";

            Start-Sleep -Milliseconds 50;
            
            $global:bIsServer = $True;
            $bJumpIntoStartGame = $True;
            
            #handleStartGame
        }
        elseif(!$global:bIsLokal -and $global:bIsServer)
        {
            hideButtonsPiece
        }
        
        if( $global:iCountPiecesRow[$ButtonID] -eq $global:iDimension_Y )
        {
            return $False;
            Write-Host "Returning (There are more than 6 pieces in a row)..."
        }
        
        if($global:iCountPiecesRow[$ButtonID] -eq 0)
        {
            playSoundFXRandom 3 2;
        }
        else
        {
            playSoundFXRandom 5 2;
        }
    
        $value = $global:iCountPiecesRow[$ButtonID]
        $type = $value.GetType()
        $type2 = $global:iCountPiecesRow[3]
        Write-Host "Value: $value Type1: $type Typ2: $type2`r`n"
    
        $global:arrPlaced[$ButtonID][$global:iCountPiecesRow[$ButtonID]] = $global:strCurrentColor;
        
        $global:strGameString = $global:strGameString + $ButtonID
        
        # checkwin x y;
        checkWin $ButtonID $global:iCountPiecesRow[$ButtonID];
        
        $global:iCountPiecesRow[$ButtonID] += 1;
        
        # Disables buttons
        if($global:iCountPiecesRow[$ButtonID] -ge $global:iDimension_Y)
        {
            $strButtonName = "btnR" + ($ButtonID + 1)
            
            Write-Host "ButtonName is: $strButtonName"
            
            $objForm.Controls[$strButtonName].Enabled = $False;
            $objForm.Controls[$strButtonName].Hide();
            $objForm.Controls[$strButtonName].BackColor = "Transparent";
        }
        
        if($global:strCurrentColor -eq "Red")
        {
            $objFormGraphics.FillEllipse($global:myBrushRed, 205 + $ButtonID * 25, 190 - $global:iCountPiecesRow[$ButtonID] * 25, 20, 20)
            
            $global:strCurrentColor = "Orange"
            
            setColorsButtonsPiece2($global:Color2)
        }
        else
        {
            $objFormGraphics.FillEllipse($global:myBrushOrange, 205 + $ButtonID * 25, 190 - $global:iCountPiecesRow[$ButtonID] * 25, 20, 20)
            $global:strCurrentColor = "Red"
            
            setColorsButtonsPiece2($global:Color1)
        }
    
        #setColorsButtonsPiece2($global:strCurrentColor)
        
        $global:iCurrentRound += 1;
        updateRundeText
        
        if($global:iCurrentRound -eq 42)
        {
            handleTie
        }
        
        if($bJumpIntoStartGame)
        {
            #Write-Host "Jump into start game"
            handleStartGame
        }
        
        if($global:bIsFinished)
        {
            hideButtonsPiece
            $objForm.Refresh()
            return;
        }
        
        if($global:strCurrentLoadedGameString -ne "")
        {
            return;
        }
        
        Write-Host "Checking AI Turn..."
        
        if($global:strCurrentColor -eq "Red")
        {
            if($strPlayerTypes[0] -ne $global:PlayerTypes[0])
            {
                #if($global:iCurrentRound -gt 41)
                #{
                #    return;
                #}
            
                if($global:iCurrentRound -lt 42)
                {
                handleAITurn $strPlayerTypes[0]
                #Write-Host "Is AI(handleRowButtonClick)p1 - round: $global:iCurrentRound`r`n"
                }
                
            }
        }
        else # Player 2
        {
            if($strPlayerTypes[1] -ne $global:PlayerTypes[0])
            {
                #if($global:iCurrentRound -gt 41)
                #{
                #    return;
                #}
            
                if($global:iCurrentRound -lt 42)
                {
                    handleAITurn $strPlayerTypes[1]
                    #Write-Host "Is AI(handleRowButtonClick)p2 - round: $global:iCurrentRound`r`n"
                }
                
            }
        }
        
        #if($global:iCurrentRound -lt 42)
        #{
        #    $objForm.Refresh()
        #}
    }
    
    function Is-Numeric ($Value) {
        return $Value -match "^[\d\.]+$"
    }
    
#Form

$objForm.Text = ($AppName + " - " + $revision)

$objForm.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY) 
$objForm.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
$objForm.MaximizeBox = $False;
$objForm.MinimizeBox = $False;
$objForm.ControlBox = $False;

#Button: Close
$btnMulti = New-Object System.Windows.Forms.Button
$btnMulti.Location = New-Object System.Drawing.Size(8,100)
$btnMulti.Size = New-Object System.Drawing.Size(72,26)
$btnMulti.Text = "Single"
$btnMulti.Add_Click({
    playSoundFXRandom 0 1
    if($global:bIsLokal)
    {
        $btnMulti.Text = "Multi";
        $global:bIsLokal = !$global:bIsLokal;
        $RadioButton1.Enabled = $False;
        $RadioButton2.Enabled = $False;
        setBegin "Orange"
        $RadioButton2.Checked = $True;
        $RadioButton1.Checked = $False;
        $btnTournament.Enabled = $False;
        $btnTournament.Text = "Training";
        $global:bIsTournament = $False;
    }
    else
    {
        $btnMulti.Text = "Single";
        $global:bIsLokal = !$global:bIsLokal;
        $RadioButton1.Enabled = $True;
        $RadioButton2.Enabled = $True;
        $btnTournament.Enabled = $True;
    }

})
$objForm.Controls.Add($btnMulti)

#Button: Close
$btnServer = New-Object System.Windows.Forms.Button
$btnServer.Location = New-Object System.Drawing.Size(78,100)
$btnServer.Size = New-Object System.Drawing.Size(72,26)
$btnServer.Text = "Server"
$btnServer.Add_Click({
    playSoundFXRandom 0 1
    if($global:bIsServer)
    {
        $btnServer.Text = "Client";
        $global:bIsServer = !$global:bIsServer;
        $RadioButton2.Checked = $True;
        $RadioButton1.Checked = $False;
        setBegin "Orange"
    }
    else
    {
        $btnServer.Text = "Server";
        $global:bIsServer = !$global:bIsServer;
        ##setBegin "Red"
        ##$RadioButton1.Checked = $True;
        ##$RadioButton2.Checked = $False;
        setBegin "Orange"
        $RadioButton2.Checked = $True;
        $RadioButton1.Checked = $False;
    }

})
$objForm.Controls.Add($btnServer)

#$global:iPort = "8989";
#$global:iIP = "127.0.0.1";

$txfIP = New-Object System.Windows.Forms.TextBox
$txfIP.Location = New-Object System.Drawing.Size(8,130)
$txfIP.Size = New-Object System.Drawing.Size(92,26)
$txfIP.Text = $global:iIP #"127.0.0.1"
$txfIP.MaxLength = 15
$objForm.Controls.Add($txfIP)

$txfPort = New-Object System.Windows.Forms.TextBox
$txfPort.Location = New-Object System.Drawing.Size(108,130)
$txfPort.Size = New-Object System.Drawing.Size(62,26)
$txfPort.Text = $global:iPort #"8080"
$txfPort.MaxLength = 5
$objForm.Controls.Add($txfPort)

#Button: Row1
$btnR1 = New-Object System.Windows.Forms.Button
$btnR1.Location = New-Object System.Drawing.Size(205,195)
$btnR1.Size = New-Object System.Drawing.Size(20,20)
$btnR1.Text = "^"
$btnR1.Name = "btnR1"
$btnR1.Hide();
$btnR1.Add_Click({

    if($global:iCountPiecesRow[0] + 1 -ge $global:iDimension_Y)
    {
        $btnR1.Enabled = $False;
        $btnR1.Hide();
        $btnR1.BackColor = "Transparent";
    }
    handleRowButtonClick(0);
})
$objForm.Controls.Add($btnR1)

#Button: Row2
$btnR2 = New-Object System.Windows.Forms.Button
$btnR2.Location = New-Object System.Drawing.Size(230,195)
$btnR2.Size = New-Object System.Drawing.Size(20,20)
$btnR2.Text = "^"
$btnR2.Name = "btnR2"
$btnR2.Hide();
$btnR2.Add_Click({
    if($global:iCountPiecesRow[1] + 1 -ge $global:iDimension_Y)
    {
        $btnR2.Enabled = $False;
        $btnR2.Hide();
        $btnR2.BackColor = "Transparent";
    }
    handleRowButtonClick(1);
})
$objForm.Controls.Add($btnR2)

#Button: Row3
$btnR3 = New-Object System.Windows.Forms.Button
$btnR3.Location = New-Object System.Drawing.Size(255,195)
$btnR3.Size = New-Object System.Drawing.Size(20,20)
$btnR3.Text = "^"
$btnR3.Name = "btnR3"
$btnR3.Hide();
$btnR3.Add_Click({
    if($global:iCountPiecesRow[2] + 1 -ge $global:iDimension_Y)
    {
        $btnR3.Enabled = $False;
        $btnR3.Hide();
        $btnR3.BackColor = "Transparent";
    }
    handleRowButtonClick(2);
})
$objForm.Controls.Add($btnR3)

#Button: Row4
$btnR4 = New-Object System.Windows.Forms.Button
$btnR4.Location = New-Object System.Drawing.Size(280,195)
$btnR4.Size = New-Object System.Drawing.Size(20,20)
$btnR4.Text = "^"
$btnR4.Name = "btnR4"
$btnR4.Hide();
$btnR4.Add_Click({
    if($global:iCountPiecesRow[3] + 1 -ge $global:iDimension_Y)
    {
        $btnR4.Enabled = $False;
        $btnR4.Hide();
        $btnR4.BackColor = "Transparent";
    }
    handleRowButtonClick(3);
})
$objForm.Controls.Add($btnR4)

#Button: Row5
$btnR5 = New-Object System.Windows.Forms.Button
$btnR5.Location = New-Object System.Drawing.Size(305,195)
$btnR5.Size = New-Object System.Drawing.Size(20,20)
$btnR5.Text = "^"
$btnR5.Name = "btnR5"
$btnR5.Hide();
$btnR5.Add_Click({
    if($global:iCountPiecesRow[4] + 1 -ge $global:iDimension_Y)
    {
        $btnR5.Enabled = $False;
        $btnR5.Hide();
        $btnR5.BackColor = "Transparent";
    }
    handleRowButtonClick(4);
})
$objForm.Controls.Add($btnR5)

#Button: Row6
$btnR6 = New-Object System.Windows.Forms.Button
$btnR6.Location = New-Object System.Drawing.Size(330,195)
$btnR6.Size = New-Object System.Drawing.Size(20,20)
$btnR6.Text = "^"
$btnR6.Name = "btnR6"
$btnR6.Hide();
$btnR6.Add_Click({
    if($global:iCountPiecesRow[5] + 1 -ge $global:iDimension_Y)
    {
        $btnR6.Enabled = $False;
        $btnR6.Hide();
        $btnR6.BackColor = "Transparent";
    }
    handleRowButtonClick(5);
})
$objForm.Controls.Add($btnR6)


#Button: Row7
$btnR7 = New-Object System.Windows.Forms.Button
$btnR7.Location = New-Object System.Drawing.Size(355,195)
$btnR7.Size = New-Object System.Drawing.Size(20,20)
$btnR7.Text = "^"
$btnR7.Name = "btnR7"
$btnR7.Hide();
$btnR7.Add_Click({
    if($global:iCountPiecesRow[6] + 1 -ge $global:iDimension_Y)
    {
        $btnR7.Enabled = $False;
        $btnR7.Hide();
        $btnR7.BackColor = "Transparent";
    }
    handleRowButtonClick(6);
})
$objForm.Controls.Add($btnR7)

#Button: Mute
$btnMute = New-Object System.Windows.Forms.Button
$btnMute.Location = New-Object System.Drawing.Size(8,240)
$btnMute.Size = New-Object System.Drawing.Size(72,26)
if($global:bIsMuted)
{
    $btnMute.Text = "Unmute"
}
else
{
    $btnMute.Text = "Mute"
}
$btnMute.Add_Click({
    playSoundFXRandom 0 1
    if($global:bIsMuted)
    {
        $btnMute.Text = "Mute";
        $global:bIsMuted = !$global:bIsMuted;
    }
    else
    {
        $btnMute.Text = "Unmute";
        $global:bIsMuted = !$global:bIsMuted;
    }

})
$objForm.Controls.Add($btnMute)

#Button: Restart
$btnRestart = New-Object System.Windows.Forms.Button
$btnRestart.Location = New-Object System.Drawing.Size(78,240)
$btnRestart.Size = New-Object System.Drawing.Size(72,26)
$btnRestart.Text = "Restart"
$btnRestart.Add_Click({
    playSoundFXRandom 0 1
    $global:iIP = $txfIP.Text;
    $global:iPort = $txfPort.Text;

    Write-Host "Restarting...`r`n"
    if(!$global:bIsLokal -and !$global:bIsServer -and $global:bGameRunning -and !$global:bIsFinished)
    {
        send-msg 9 $global:iPort $global:iIP ""
    }
    #$global:WindowPosition = $objForm.Location
    $global:arrConfig[7] = $objForm.Location.X
    $global:arrConfig[9] = $objForm.Location.Y
    $global:WindowPosition.X = $global:arrConfig[7];
    $global:WindowPosition.Y = $global:arrConfig[9];
    saveToConfigFile
    $objForm.Close()
})
$objForm.Controls.Add($btnRestart)

#Button: Start
$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Location = New-Object System.Drawing.Size(148,240)
$btnStart.Size = New-Object System.Drawing.Size(72,26)
$btnStart.Text = "Start"
$btnStart.Add_Click({
    playSoundFXRandom 0 1
    #AI_BestOwnSpotAI
    
    if($global:bIsTournament)
    {
        if($txfNameP1.Text -eq "" -or $txfNameP2.Text -eq "")
        {
            [System.Windows.Forms.MessageBox]::Show("Invalid player names. Please enter valid player names!","Name problem",0)
            return;
        }
    }
    
    $global:iIP = $txfIP.Text;
    $global:iPort = $txfPort.Text;
    
    $global:bIsLokal = $global:bIsLokal;
    $global:bIsServer = $global:bIsServer;
    
	
    if(!$global:bIsLokal)
    {
        Try
        {
            [ipaddress]$global:iIP
        }
        Catch [system.exception]
        {
            [System.Windows.Forms.MessageBox]::Show("Invalid IP Adress!","Start game",0)
            $global:iIP = "127.0.0.1"
            $txfIP.Text = "127.0.0.1"
            #$objForm.Close();
            return;
        }
        
        if(Is-Numeric $global:iPort)
        {
            if(([convert]::ToInt32($global:iPort, 10)) -le 0 -or ([convert]::ToInt32($global:iPort, 10)) -ge 65535)
            {
                [System.Windows.Forms.MessageBox]::Show("Invalid Port! (smaller than 0 or larger than 65535)","Start game",0)
                $global:iPort = "8080"
                $txfPort.Text = "8080"
                return;
            }
        }
        else
        {
            [System.Windows.Forms.MessageBox]::Show("Invalid Port! (contains non numeric values)","Start game",0)
            $global:iPort = "8080"
            $txfPort.Text = "8080"
            return;
        }
    }
    
    if($global:strCurrentColor -eq "Red")
    {
        $global:strGameString += "R"
    }
    else
    {
        $global:strGameString += "O"
    }
    
    #$btnLoadGame.Enabled = $False;
    
    $txfNameP1.Enabled = $False;
	$txfNameP2.Enabled = $False;
	$btnTournament.Enabled = $False;
	
	if($DropDown1.Text -ne "Human") {$txfNameP1.Text = $DropDown1.Text}
	if($DropDown2.Text -ne "Human") {$txfNameP2.Text = $DropDown2.Text}
	
	
	
    showButtonsPiece
    handleStartGame
})
$objForm.Controls.Add($btnStart)

#Button: Testen
$btnTest = New-Object System.Windows.Forms.Button
$btnTest.Location = New-Object System.Drawing.Size(218,240)
$btnTest.Size = New-Object System.Drawing.Size(72,26)
$btnTest.Text = "Test"
$btnTest.Add_Click({
    playSoundFXRandom 0 1
    Write-Host "Highscore:`r`n"
    $DBexec = executeDBQuery "select * from t_players order by games_won desc limit 10" "table"#"select player_name, 1 + ((games_won) / (games_won + games_lost))*1000  as 'Score' from t_players order by Score desc limit 10"#"select * from t_players order by games_won desc limit 10"
    Write-Host $DBexec
    
    if($DBexec -eq -1)
    {
        return;
    }
    
    Write-Host "PlayerEntry SPIKETWO: `r`n"
    $DBexec = executeDBQuery "select entry from t_players where player_name = 'SPIKETWO'" "none"
    Write-Host $DBexec
    
    ## Punktestand
    ## $MySqlCommand.CommandText = "update t_players set games_won = games_won + 1 where entry = 4"
    
    ## Neuer Spieler
    ## $MySqlCommand.CommandText = "insert into t_players(player_name) values('SPIKETEN')"
    
})
#$objForm.Controls.Add($btnTest)

#Button: Close
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Location = New-Object System.Drawing.Size(288,240)
$btnClose.Size = New-Object System.Drawing.Size(72,26)
$btnClose.Text = "Exit"
#$btnClose.Add_Click({$objForm.Close()})
$btnClose.Add_Click({
playSoundFXRandom 0 1
if(!$global:bIsLokal -and !$global:bIsServer -and $global:bGameRunning -and !$global:bIsFinished)
{
    send-msg 9 $global:iPort $global:iIP ""
}
saveToConfigFile
$global:bDoReallyLeave = $True
Write-Host "leaving...`r`n"
$objForm.Close()
})
$objForm.Controls.Add($btnClose)

#Button: Tournament
$btnTournament = New-Object System.Windows.Forms.Button
$btnTournament.Location = New-Object System.Drawing.Size(8,276)
$btnTournament.Size = New-Object System.Drawing.Size(72,26)
$btnTournament.Text = "Training"
$btnTournament.Add_Click({
    playSoundFXRandom 0 1
    if($global:bIsTournament)
    {
        $btnTournament.Text = "Training";
        $global:bIsTournament = $False;
    }
    else
    {
        $btnTournament.Text = "Contest";
        $global:bIsTournament = $True;
    }

})
$objForm.Controls.Add($btnTournament)

#Button: Highscore
$btnHighscore = New-Object System.Windows.Forms.Button
$btnHighscore.Location = New-Object System.Drawing.Size(80,276)
$btnHighscore.Size = New-Object System.Drawing.Size(72,26)
$btnHighscore.Text = "Highscore"
$btnHighscore.Add_Click({
    playSoundFXRandom 0 1
    $objFormHighscore = New-Object System.Windows.Forms.Form 
    $objFormHighscore.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
    $objFormHighscore.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
    $objFormHighscore.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
    $objFormHighscore.Text = ("Highscore")
    $objFormHighscore.MaximizeBox = $False;
    $objFormHighscore.MinimizeBox = $False;
    $objFormHighscore.ControlBox = $False;
    $objFormHighscore.Icon = [System.Drawing.SystemIcons]::WinLogo
    $objFormHighscore.Topmost = $True
    
    #Button: Close
    $btnCloseHighscore = New-Object System.Windows.Forms.Button
    $btnCloseHighscore.Location = New-Object System.Drawing.Size(288,240)
    $btnCloseHighscore.Size = New-Object System.Drawing.Size(72,26)
    $btnCloseHighscore.Text = "Okay"
    $btnCloseHighscore.Add_Click(
    {
        playSoundFXRandom 0 1
        $objFormHighscore.Close()
    })
    $objFormHighscore.Controls.Add($btnCloseHighscore)
    
    $lblHighscorePlayer = New-Object System.Windows.Forms.Label
    $lblHighscorePlayer.Location = New-Object System.Drawing.Size(8,8)
    $lblHighscorePlayer.Size = New-Object System.Drawing.Size(128,256)
    $lblHighscorePlayer.ForeColor="Black"
    #$lblHighscore.Tabstop = $True;
    $objFormHighscore.Controls.Add($lblHighscorePlayer)
    
    $lblHighscoreWins = New-Object System.Windows.Forms.Label
    $lblHighscoreWins.Location = New-Object System.Drawing.Size(136,8)
    $lblHighscoreWins.Size = New-Object System.Drawing.Size(64,256)
    $lblHighscoreWins.ForeColor="Black"
    #$lblHighscore.Tabstop = $True;
    $objFormHighscore.Controls.Add($lblHighscoreWins)
    
    $lblHighscoreDefeats = New-Object System.Windows.Forms.Label
    $lblHighscoreDefeats.Location = New-Object System.Drawing.Size(200,8)
    $lblHighscoreDefeats.Size = New-Object System.Drawing.Size(64,256)
    $lblHighscoreDefeats.ForeColor="Black"
    #$lblHighscore.Tabstop = $True;
    $objFormHighscore.Controls.Add($lblHighscoreDefeats)
    
    $strHighscore = ""
    $strHighscore = executeDBQuery "select player_name, games_won, games_lost from t_players order by games_won desc limit 10" "table"
    
    Write-Host "Highscore:`r`n$strHighscore"
    
    
    
    if($strHighscore -eq "" -or $strHighscore -eq -1)
    {
        $lblHighscorePlayer.Text = "Error: No Database connection or no games played"
        $lblHighscoreWins.Text = "Error: No Database connection or no games played"
        $lblHighscoreDefeats.Text = "Error: No Database connection or no games played"
        return;
    }
    else
    {
        $lblHighscorePlayer.Text = "Name`r`n`r`n"
        $lblHighscoreWins.Text = "Wins`r`n`r`n"
        $lblHighscoreDefeats.Text = "Defeats`r`n`r`n"
    
        $arrayHighscore = $strHighscore.split("|")
        
        for($i = 0; $i -lt $arrayHighscore.Length;$i+=3)
        {
            Write-Host $arrayHighscore[$i] $arrayHighscore[$i+1] $arrayHighscore[$i+2] 
        
            $lblHighscorePlayer.Text += $arrayHighscore[$i] + "`r`n"
            $lblHighscoreWins.Text += $arrayHighscore[$i+1] + "`r`n"
            $lblHighscoreDefeats.Text += $arrayHighscore[$i+2] + "`r`n"
        }
    }
    
    [void] $objFormHighscore.ShowDialog()
})
$objForm.Controls.Add($btnHighscore)

#Button: Load
# create object
$btnLoadGames = New-Object System.Windows.Forms.Button
# set location
$btnLoadGames.Location = New-Object System.Drawing.Size(148,276)
# set size
$btnLoadGames.Size = New-Object System.Drawing.Size(72,26)
# set text to "Load"
$btnLoadGames.Text = "Load"
# set function on click
$btnLoadGames.Add_Click({
    # play "click button" sound
    playSoundFXRandom 0 1
    # Create a form
    # create object
    $objFormLoad = New-Object System.Windows.Forms.Form
    # set form size
    $objFormLoad.Size = New-Object System.Drawing.Size($AppSizeX, $AppSizeY)
    # set minimumSize
    $objFormLoad.minimumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
    # set maximumSize
    $objFormLoad.maximumSize = New-Object System.Drawing.Size($AppSizeX,$AppSizeY)
    # set toolbar text
    $objFormLoad.Text = ("Load Game")
    # disable close button
    $objFormLoad.MaximizeBox = $False;
    # disable minimize button
    $objFormLoad.MinimizeBox = $False;
    # disable close button
    $objFormLoad.ControlBox = $False;
    # set icon
    $objFormLoad.Icon = [System.Drawing.SystemIcons]::WinLogo
    # set topmost (always in front of everything) to true
    $objFormLoad.Topmost = $True
    
    # Button: Close
    # create object
    $btnCloseLoad = New-Object System.Windows.Forms.Button
    # set button location
    $btnCloseLoad.Location = New-Object System.Drawing.Size(288,276)
    # set button size
    $btnCloseLoad.Size = New-Object System.Drawing.Size(72,26)
    # set button text to "Close"
    $btnCloseLoad.Text = "Close"
    # add button function
    $btnCloseLoad.Add_Click(
    {
        # play button click sound
        playSoundFXRandom 0 1
        # close the form
        $objFormLoad.Close()
    })
    # add control to form
    $objFormLoad.Controls.Add($btnCloseLoad)
    
    # Textbox displaying Savegames
    # create object
    $txbSaveGame = New-Object System.Windows.Forms.TextBox
    # set box location
    $txbSaveGame.Location = New-Object System.Drawing.Size(8,8)
    # set box size
    $txbSaveGame.Size = New-Object System.Drawing.Size(348,256)
    # set text color
    $txbSaveGame.ForeColor="Black"
    # set multiline (linebreaks) to true
    $txbSaveGame.Multiline = $True
    # enable scrolling (if there are more entrys than lines)
    $txbSaveGame.Scrollbars = "Vertical"
    # user should only read (mark and copy) the text
    $txbSaveGame.ReadOnly = $True
    # add control to load form
    $objFormLoad.Controls.Add($txbSaveGame)
    
    # Label saying "Load Entry:"
    # create object
    $lblEntry = New-Object System.Windows.Forms.Label
    # set label location
    $lblEntry.Location = New-Object System.Drawing.Size(8,282)
    # set label size
    $lblEntry.Size = New-Object System.Drawing.Size(70,16)
    # set text color to black
    $lblEntry.ForeColor="Black"
    # set text to "Load Entry:"
    $lblEntry.Text = "Load Entry:"
    # add label to load form
    $objFormLoad.Controls.Add($lblEntry)
    
    # Textbox for Savegame Entry input
    # create object
    $txbLoadEntry = New-Object System.Windows.Forms.TextBox
    # set box location
    $txbLoadEntry.Location = New-Object System.Drawing.Size(80,280)
    # set box size
    $txbLoadEntry.Size = New-Object System.Drawing.Size(64,26)
    # set text to "nothing"
    $txbLoadEntry.Text = ""
    # max input length set to 10
    # (effectively limiting savegames from 1 to 1000000000)
    $txbLoadEntry.MaxLength = 10
    # add control to load form
    $objFormLoad.Controls.Add($txbLoadEntry)
    
    # Button triggering loading
    # create object
    $btnLoadGame = New-Object System.Windows.Forms.Button
    # set button location
    $btnLoadGame.Location = New-Object System.Drawing.Size(148,276)
    # set button size
    $btnLoadGame.Size = New-Object System.Drawing.Size(72,26)
    # set button text to "Load"
    $btnLoadGame.Text = "Load"
    # add function for button
    $btnLoadGame.Add_Click(
    {
        # play click sound
        playSoundFXRandom 0 1
        # close the load form
        $objFormLoad.Close()
        # call function which handles loading a game
        doLoadGame $txbLoadEntry.Text
    })
    # add control to form
    $objFormLoad.Controls.Add($btnLoadGame)
    
    # savegame string
    $strHighscore = ""
    # get savegames from db (entry + date played + name_p1 + name_p2)
    $strHighscore = executeDBQuery "select g.entry, g.date_played, p1.player_name, p2.player_name from t_games g join t_players p1 on  g.name_player1 = p1.entry join t_players p2 on  g.name_player2 = p2.entry" "table"
    
    # Log loaded games
    Write-Host $strHighscore

    # db error
    if($strHighscore -eq -1)
    {
        # abort everything (no savegames or connections)
        # message is shown by executeDBQuery
        return;
    }
    # no savegames
    elseif($strHighscore -eq "")
    {
        # no db error but we don't have savegames
        $txbSaveGame.Text = "No Savegames!"
    }
    else
    {
        # no error and data
        # create an array containing saved games
        $arrayHighscore = $strHighscore.split("|")
        
        # as long as there is data
        for($i = 0; $i -lt $arrayHighscore.Length;$i+=4)
        {
            # if there is an entry (valid data)
            if($arrayHighscore[$i] -ne "")
            {
                # set text of textbox to: Entry + -> + Date + : + Name1 + vs + Name2
                # e.g. 1 -> 1/2/2017: BLOCKAI vs HUMAN
                $txbSaveGame.Text += $arrayHighscore[$i] + " -> "
                $txbSaveGame.Text += $arrayHighscore[$i+1] + ": "
                $txbSaveGame.Text += $arrayHighscore[$i+2] + " vs "
                $txbSaveGame.Text += $arrayHighscore[$i+3] + "`r`n"
            }
        }
    }

    # show the load form
    [void] $objFormLoad.ShowDialog()
})
# add load button control to form
$objForm.Controls.Add($btnLoadGames)

#Label: Runde
#Text
$txtRunde = New-Object System.Windows.Forms.Label
$txtRunde.Location = New-Object System.Drawing.Size(8,8)
$txtRunde.Name = "txtRunde"
$txtRunde.Size = New-Object System.Drawing.Size(80,16)
$txtRunde.ForeColor="Black"
$txtRunde.Text = "Round: " + $global:iCurrentRound + "/" + $global:iDimension * $global:iDimension_Y
$objForm.Controls.Add($txtRunde)

#
$txfNameP1 = New-Object System.Windows.Forms.TextBox
$txfNameP1.Location = New-Object System.Drawing.Size(200,10)
$txfNameP1.Size = New-Object System.Drawing.Size(70,26)
$txfNameP1.Text = "Human"
$txfNameP1.CharacterCasing = "Upper"
$txfNameP1.MaxLength = 60
$objForm.Controls.Add($txfNameP1)

$lblVS = New-Object System.Windows.Forms.Label
$lblVS.Location = New-Object System.Drawing.Size(280,12)
$lblVS.Size = New-Object System.Drawing.Size(25,16)
$lblVS.ForeColor="Black"
$lblVS.Text = "vs"
$objForm.Controls.Add($lblVS)

$txfNameP2 = New-Object System.Windows.Forms.TextBox
$txfNameP2.Location = New-Object System.Drawing.Size(310,10)
$txfNameP2.Size = New-Object System.Drawing.Size(70,26)
$txfNameP2.Text = "Human"
$txfNameP2.CharacterCasing = "Upper"
$txfNameP1.MaxLength = 60
$objForm.Controls.Add($txfNameP2)

$txtPlayerType = New-Object System.Windows.Forms.Label
$txtPlayerType.Location = New-Object System.Drawing.Size(36,27) 
$txtPlayerType.Size = New-Object System.Drawing.Size(64,16)
$txtPlayerType.ForeColor="Black"
$txtPlayerType.Text = "Playertype"
$objForm.Controls.Add($txtPlayerType)

$txtBegins = New-Object System.Windows.Forms.Label
$txtBegins.Location = New-Object System.Drawing.Size(106,27) 
$txtBegins.Size = New-Object System.Drawing.Size(32,16)
$txtBegins.ForeColor="Black"
$txtBegins.Text = "Start"
$objForm.Controls.Add($txtBegins)

$txtColor = New-Object System.Windows.Forms.Label
$txtColor.Location = New-Object System.Drawing.Size(146,27) 
$txtColor.Size = New-Object System.Drawing.Size(32,16)
$txtColor.ForeColor="Black"
$txtColor.Text = "Color"
$objForm.Controls.Add($txtColor)

$txtP1 = New-Object System.Windows.Forms.Label
$txtP1.Location = New-Object System.Drawing.Size(8,48) 
$txtP1.Size = New-Object System.Drawing.Size(30,16)
$txtP1.ForeColor="Black"
$txtP1.Text = "Pl. 1"
$objForm.Controls.Add($txtP1)

$RadioButton1 = New-Object System.Windows.Forms.RadioButton 
$RadioButton1.Location = new-object System.Drawing.Point(111,43) 
$RadioButton1.size = New-Object System.Drawing.Size(16,16) 
$RadioButton1.Checked = $True
$RadioButton1.Add_Click({
    handleBeginChange
    playSoundFXRandom 2 1;
})
$objForm.Controls.Add($RadioButton1) 

$txtP2 = New-Object System.Windows.Forms.Label
$txtP2.Location = New-Object System.Drawing.Size(8,68) 
$txtP2.Size = New-Object System.Drawing.Size(30,16)
$txtP2.ForeColor="Black"
$txtP2.Text = "Pl. 2"
$objForm.Controls.Add($txtP2)

$RadioButton2 = New-Object System.Windows.Forms.RadioButton 
$RadioButton2.Location = new-object System.Drawing.Point(111,63) 
$RadioButton2.size = New-Object System.Drawing.Size(16,16) 
$RadioButton2.Checked = $False
$RadioButton2.Add_Click({
    handleBeginChange
    playSoundFXRandom 2 1;
})
$objForm.Controls.Add($RadioButton2) 

[array]$global:PlayerTypes = "Human", "Rand AI", "Block AI", "BlockWin AI", "BlockWinII AI"#"Score AI", "Block AI";

[array]$DropDownArray = $DropDownArrayItems | sort
$DropDown1 = new-object System.Windows.Forms.ComboBox
$DropDown1.Location = new-object System.Drawing.Size(40,43)
$DropDown1.Size = new-object System.Drawing.Size(60,30)
$DropDown1.Text = $global:PlayerTypes[0]
    for ($i = 0; $i -le ($global:PlayerTypes.length - 1); $i++)
    {
    [void] $DropDown1.Items.Add($global:PlayerTypes[$i])
    }
$DropDown1.Add_Click({playSoundFXRandom 1 1;})
$DropDown1.DropDownStyle = "DropDownList";
$DropDown1.SelectedIndex = $strSelectedIndex[0];

$objForm.Controls.Add($DropDown1)

$DropDown2 = new-object System.Windows.Forms.ComboBox
$DropDown2.Location = new-object System.Drawing.Size(40,63)
$DropDown2.Size = new-object System.Drawing.Size(60,30)
$DropDown2.Text = $global:PlayerTypes[0]
    for ($i = 0; $i -le ($global:PlayerTypes.length - 1); $i++)
    {
    [void] $DropDown2.Items.Add($global:PlayerTypes[$i])
    }
$DropDown2.Add_Click({playSoundFXRandom 1 1;})
$objForm.Controls.Add($DropDown2)
$DropDown2.DropDownStyle = "DropDownList";
$DropDown2.SelectedIndex = $strSelectedIndex[1];

#Button: Row4
$txfTextLog = New-Object System.Windows.Forms.TextBox
$txfTextLog.Location = New-Object System.Drawing.Size(400,8)
$txfTextLog.Size = New-Object System.Drawing.Size(280,120)
$txfTextLog.Text = "Talk to Strangers!"
$txfTextLog.Multiline = $True
$txfTextLog.Scrollbars = "Vertical"
$txfTextLog.ReadOnly = $True
$objForm.Controls.Add($txfTextLog)

#TextBox for message inpit
$txfSendMsg = New-Object System.Windows.Forms.TextBox
$txfSendMsg.Location = New-Object System.Drawing.Size(400,148)
$txfSendMsg.Size = New-Object System.Drawing.Size(280,80)
$txfSendMsg.Text = ""
$txfSendMsg.Multiline = $True
$objForm.Controls.Add($txfSendMsg)

#Button: Send
$btnSend = New-Object System.Windows.Forms.Button
$btnSend.Location = New-Object System.Drawing.Size(608,240)
$btnSend.Size = New-Object System.Drawing.Size(72,26)
$btnSend.Text = "Send"
$btnSend.Add_Click({
    playSoundFXRandom 0 1
    $txfSendMsg.ReadOnly = $True
    $txfSendMsg.Enabled = $False;
    $btnSend.Enabled = $False;
    $global:strChatMessage = $txfSendMsg.Text
    $txfTextLog.Text = $txfTextLog.Text + "`r`n<You> " + $global:strChatMessage
    $txfSendMsg.Text = ""
})
$objForm.Controls.Add($btnSend)
$txfSendMsg.ReadOnly = $True;
$txfSendMsg.Enabled = $False;
$txfTextLog.Enabled = $False;
$btnSend.Enabled = $False;

#Button: Play one Step
$btnPlayStep = New-Object System.Windows.Forms.Button
$btnPlayStep.Location = New-Object System.Drawing.Size(255,195)
$btnPlayStep.Size = New-Object System.Drawing.Size(28,20)
$btnPlayStep.Text = ">"
$btnPlayStep.ForeColor = "Blue"
$btnPlayStep.Font = New-Object Drawing.Font($btnPlayStep.Font.FontFamily, $btnPlayStep.Font.Size, [Drawing.FontStyle]::Bold)
$btnPlayStep.Hide();
$btnPlayStep.Add_Click({
    # Replay has been played till the end?
    if($global:strCurrentLoadedGameString.Length -eq 0)
    {
        # Hide button and ignore click
        $btnPlayStep.Hide();
        return;
    }
    
    # Handles a Row button click, id is in the game string
    handleRowButtonClick($global:strCurrentLoadedGameString.Substring(0,1));
    
    if($global:strCurrentLoadedGameString.Length -le 1)
    {
        $global:strCurrentLoadedGameString = ""
        return;
    }
    
    # Remove the latest step
    $global:strCurrentLoadedGameString = $global:strCurrentLoadedGameString.Substring(1, $global:strCurrentLoadedGameString.Length - 1)
})
$objForm.Controls.Add($btnPlayStep)

$btnPlayAllSteps = New-Object System.Windows.Forms.Button
$btnPlayAllSteps.Location = New-Object System.Drawing.Size(305,195)
$btnPlayAllSteps.Size = New-Object System.Drawing.Size(28,20)
$btnPlayAllSteps.Text = ">>"
$btnPlayAllSteps.ForeColor = "Blue"
$btnPlayAllSteps.Font = New-Object Drawing.Font($btnPlayAllSteps.Font.FontFamily, $btnPlayAllSteps.Font.Size, [Drawing.FontStyle]::Bold)
$btnPlayAllSteps.Hide();
$btnPlayAllSteps.Add_Click({
    # Replay has been played till the end?
    if($global:strCurrentLoadedGameString.Length -le 1)
    {
        # Hide button and ignore click
        $btnPlayAllSteps.Hide();
        $btnPlayStep.Hide();
        $btnPlayEnd.Hide();
        return;
    }
    
    $btnPlayAllSteps.Hide();
    $btnPlayStep.Hide();
    $btnPlayEnd.Hide();
    
    while($global:strCurrentLoadedGameString.Length -ge 1)
    {
        # Handles a Row button click, id is in the game string
        handleRowButtonClick($global:strCurrentLoadedGameString.Substring(0,1));
        # Remove the latest step
        $global:strCurrentLoadedGameString = $global:strCurrentLoadedGameString.Substring(1, $global:strCurrentLoadedGameString.Length - 1)
        # Wait 2 Seconds
        Start-Sleep -Milliseconds 1000
        $objForm.Refresh();
    }

})
$objForm.Controls.Add($btnPlayAllSteps)

$btnPlayEnd = New-Object System.Windows.Forms.Button
$btnPlayEnd.Location = New-Object System.Drawing.Size(355,195)
$btnPlayEnd.Size = New-Object System.Drawing.Size(28,20)
$btnPlayEnd.Text = ">|"
$btnPlayEnd.ForeColor = "Blue"
$btnPlayEnd.Font = New-Object Drawing.Font($btnPlayEnd.Font.FontFamily, $btnPlayEnd.Font.Size, [Drawing.FontStyle]::Bold)
$btnPlayEnd.Hide();
$btnPlayEnd.Add_Click({
    # Replay has been played till the end?
    if($global:strCurrentLoadedGameString.Length -le 1)
    {
        # Hide button and ignore click
        $btnPlayAllSteps.Hide();
        $btnPlayStep.Hide();
        $btnPlayEnd.Hide();
        return;
    }
    
    $btnPlayAllSteps.Hide();
    $btnPlayStep.Hide();
    $btnPlayEnd.Hide();
    
    while($global:strCurrentLoadedGameString.Length -ge 1)
    {
        # Handles a Row button click, id is in the game string
        handleRowButtonClick($global:strCurrentLoadedGameString.Substring(0,1));
        # Remove the latest step
        $global:strCurrentLoadedGameString = $global:strCurrentLoadedGameString.Substring(1, $global:strCurrentLoadedGameString.Length - 1)
        
    }
    $objForm.Refresh()

})
$objForm.Controls.Add($btnPlayEnd)

#Button: Color1
$btnC1 = New-Object System.Windows.Forms.Button
$btnC1.Location = New-Object System.Drawing.Size(150,46)
$btnC1.Size = New-Object System.Drawing.Size(20,10)
$btnC1.Text = ""
$btnC1.BackColor = "Red"
$btnC1.Add_Click({
pickColor $btnC1.BackColor 1
})
$objForm.Controls.Add($btnC1)

#Button: Color2
$btnC2 = New-Object System.Windows.Forms.Button
$btnC2.Location = New-Object System.Drawing.Size(150,66)
$btnC2.Size = New-Object System.Drawing.Size(20,10)
$btnC2.Text = ""
$btnC2.BackColor = "Orange"
$btnC2.Add_Click({
pickColor $btnC2.BackColor 2
})
$objForm.Controls.Add($btnC2)






$objForm.Add_Shown({$objForm.Activate()})





#$objForm.Add_Click({
##[System.Windows.Forms.MessageBox]::Show("Config File not existing!","Config File",0)
##$cursor = New-Object System.Windows.Forms.Cursor
##
#[System.Windows.Forms.MessageBox]::Show("X: " + [System.Windows.Forms.Cursor]::Position.X + " Y: " + [System.Windows.Forms.Cursor]::Position.Y ,"Config File",0)
#
#Write-Host 
#
#})

###Window Settings###
$objForm.Topmost = $True

if($global:bDoReallyLeave)
{
    $objForm.Close()
    break
}
else
{
    loadConfigFromFile
    handleBeginChange
    
    $global:WindowPosition.X = $global:arrConfig[7];
    $global:WindowPosition.Y = $global:arrConfig[9];
    if($global:WindowPosition.X -eq 0 -and $global:WindowPosition.Y -eq 0)
    {
        $objForm.StartPosition = "CenterScreen"
    }
    else
    {
        $objForm.Location = $global:WindowPosition
    }

    [void] $objForm.ShowDialog()
}

}While ($true)