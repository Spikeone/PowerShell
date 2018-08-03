[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

$global:FormSizeX = 1024
$global:FormSizeY = 600
$global:isConnected = $False
$global:endpoint
$global:udpclient

$tooltip = New-Object System.Windows.Forms.ToolTip

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.minimumSize = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.maximumSize = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.Add_Closing({$udpclient.Close( )})
$objForm.Text = "Client"

$btnSend = New-Object System.Windows.Forms.Button
$btnSend.Location = New-Object System.Drawing.Size(632,($global:FormSizeY - 48 - 18))
$btnSend.Size = New-Object System.Drawing.Size(160,24)
$btnSend.Text = "Send"
$btnSend.Enabled = $False
$btnSend.Add_Click({SendData $txfText.Text; $txfText.Text = ""})
$objForm.Controls.Add($btnSend)

$btnConnect = New-Object System.Windows.Forms.Button
$btnConnect.Location = New-Object System.Drawing.Size(842,($global:FormSizeY - 48 - 18))
$btnConnect.Size = New-Object System.Drawing.Size(160,24)
$btnConnect.Text = "Connect"
$btnConnect.Add_Click({ConnectToServer})
$objForm.Controls.Add($btnConnect)

$txfText = New-Object System.Windows.Forms.Textbox
$txfText.Location = New-Object System.Drawing.Size(8,($global:FormSizeY - 48 - 16))
$txfText.Size = New-Object System.Drawing.Size(($global:FormSizeX - 200 - 24 - 16 - 160),($global:FormSizeY - 48 - 60))
$txfText.Font = New-Object System.Drawing.Font("Lucida Console",10)
$txfText.Text = ""
$objForm.Controls.Add($txfText)

$txfPort = New-Object System.Windows.Forms.Textbox
$txfPort.Location = New-Object System.Drawing.Size(882,($global:FormSizeY - 48 - 46))
$txfPort.Size = New-Object System.Drawing.Size(120,24)
$txfPort.Font = New-Object System.Drawing.Font("Lucida Console",10)
$txfPort.Text = "2020"
$objForm.Controls.Add($txfPort)

$txfAdress = New-Object System.Windows.Forms.Textbox
$txfAdress.Location = New-Object System.Drawing.Size(882,($global:FormSizeY - 48 - 72))
$txfAdress.Size = New-Object System.Drawing.Size(120,24)
$txfAdress.Font = New-Object System.Drawing.Font("Lucida Console",10)
$txfAdress.Text = "127.0.0.1"
$objForm.Controls.Add($txfAdress)

$txfNick= New-Object System.Windows.Forms.Textbox
$txfNick.Location = New-Object System.Drawing.Size(882,($global:FormSizeY - 48 - 98))
$txfNick.Size = New-Object System.Drawing.Size(120,24)
$txfNick.Font = New-Object System.Drawing.Font("Lucida Console",10)
$txfNick.Text = "Spikeone"
$objForm.Controls.Add($txfNick)

$lbClients = New-Object System.Windows.Forms.ListBox
$lbClients.Location = New-Object System.Drawing.Size(($global:FormSizeX - 200 - 24),8)
$lbClients.Size = New-Object System.Drawing.Size(200,($global:FormSizeY - 48 - 150))
$lbClients.Sorted = $True
$lbClients.Add_MouseMove({Listbox_MouseMove $this $_})
$objForm.Controls.Add($lbClients)

$outputBox = New-Object System.Windows.Forms.RichTextBox 
$outputBox.Location = New-Object System.Drawing.Size(8,8)
$outputBox.Size = New-Object System.Drawing.Size(($global:FormSizeX - 200 - 24 - 16),($global:FormSizeY - 48 - 52)) 
$outputBox.Font = New-Object System.Drawing.Font("Lucida Console",10)
$outputBox.ForeColor = [Drawing.Color]::Black
$outputBox.BackColor = [Drawing.Color]::White
$outputBox.MultiLine = $True 
$outputBox.ReadOnly = $True
$objForm.Controls.Add($outputBox)

$address="Any"
$port=2020
$global:keepRunning = $True
$global:frames = 60
$global:lastRun = Get-Date

function ConnectToServer()
{
    try
    {
        Write-Host "Connecting to: " $txfAdress.Text $txfPort.Text

        $global:endpoint = new-object System.Net.IPEndPoint( [IPAddress]::Parse($txfAdress.Text), [int]$txfPort.Text )
        $global:udpclient = new-object System.Net.Sockets.UdpClient
    }
    catch
    {
        throw $_
        return
    }

    Write-Host "Sending Login Request..."
    SendData ("0x01/" + $txfNick.Text)
}

function handleMessages($endpoint, $port, $strMsg)
{
    $splittedData = $strMsg.Split('/')

    if($splittedData.Length -lt 2) {return;}

    switch($splittedData[0])
    {
        # Login Result
        "0x02" { handleLoginResult $endpoint $port $strMsg}
        default { Write-Host "Unknown Message: $strMsg"}
    }

    Write-Host $splittedData.Length
}

function handleLoginResult($endpoint, $port, $strMsg)
{
    $splittedData = $strMsg.Split('/')

    Write-Host "Length: "  $splittedData.Length

    if($splittedData.Length -ne 2)
    {
        Write-Host "Invalid Login Result from $endpoint : $port"
        return;
    }

    #Write-Host "Login Result:" $splittedData[1]

    if($splittedData[1] -eq "1")
    {
        AppendTextTimeStampNewLine ([Drawing.Color]::Green) "Your are connected to the Server!"

        $txfNick.Enabled = $False
        $txfAdress.Enabled = $False
        $btnConnect.Enabled = $False
        $txfPort.Enabled = $False
        $btnSend.Enabled = $True

        $global:isConnected = $True
    }
}

function SendData($data)
{
    #if(!$global:isConnected) {return;}

    $bytes = [Text.Encoding]::ASCII.GetBytes( $data )
    $bytesSent = $global:udpclient.Send( $bytes, $bytes.length, $global:endpoint )
}

function AppendText($clr, $text)
{
    $start = $outputBox.TextLength;
    $outputBox.AppendText($text);
    $end = $outputBox.TextLength;
    
    $outputBox.Select($start, ($end - $start))
    $outputBox.SelectionColor = $clr
    $outputBox.SelectionLength = 0
}

function AppendTextTimeStampNewLine($clr, $text)
{
    AppendText ([Drawing.Color]::Gray)  ("<" + $(Get-Date) + ">: ")
    AppendText $clr ($text + "`n")
}

AppendTextTimeStampNewLine ([Drawing.Color]::Black) "Server started..."


$global:listClients = @{}



$global:lastClientIndex = -1

function Listbox_MouseMove($sender, $EventArgs)
{
    #Write-Host $EventArgs.Location
    
    $currentIndex = $lbClients.IndexFromPoint($EventArgs.Location)
    
    if($currentIndex -ne -1 -and $currentIndex -lt $lbClients.Items.Count)
    {
        if($global:lastClientIndex -ne $currentIndex)
        {
            $global:lastClientIndex = $currentIndex
            $tooltip.SetToolTip($lbClients, (getIPByName($lbClients.Items[$currentIndex])))
        }
    }
    else
    {
        $global:lastClientIndex = -1
    }
    
}

function getIPByName($name)
{
    foreach ($h in $global:listClients.GetEnumerator()) 
    {
        if($global:listClients[$($h.name)].name -eq $name)
        {
            return $($h.name)
        }
        return $($h.name)
    }

    return "?.?.?.?"
}

#try
#{
#    $endpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $port )
#    $udpclient = new-object System.Net.Sockets.UdpClient $port
#}
#catch
#{
#    throw $_
#    exit -1
#}

#Write-Host "Press ESC to stop the udp server ..." -fore yellow
#Write-Host ""

#$lbClients.Items.Add("Test")
#$lbClients.Items.Add("aTest1")
#$lbClients.Items.Add("Test3")

[void] $objForm.Show()



while($global:keepRunning)
{
    [System.Windows.Forms.Application]::DoEvents()
    
    $diff = (Get-Date) - $global:lastRun
    $global:lastRun = Get-Date
    $diffms = $diff.TotalMilliseconds
    
    #Write-Host "Diff: $diffms | Sleep: " ((1 / $global:frames) * 1000)

    #$btnLauris1.Location = New-Object System.Drawing.Size(8,(Get-Random -Maximum 32 -Minimum 16))
    
    if( $host.ui.RawUi.KeyAvailable )
    {
        $key = $host.ui.RawUI.ReadKey( "NoEcho,IncludeKeyUp,IncludeKeyDown" )
        if( $key.VirtualKeyCode -eq 27 )
        {   break   }
    }
    
    if( $global:udpclient.Available )
    {
        $error = 0

        try
        {
            $content = $global:udpclient.Receive( [ref]$endpoint )
        }
        catch
        {
            AppendTextTimeStampNewLine ([Drawing.Color]::Red) "Unable to connect to Server!"
            $global:udpclient.Close()
            $error = 1
        }
        
        if($error -eq 0)
        {
            handleMessages $($endpoint.Address.IPAddressToString) $($endpoint.Port) ($([Text.Encoding]::ASCII.GetString($content)))
        }

        #try
        #{
        #    $endpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $port )
        #    $udpclient = new-object System.Net.Sockets.UdpClient $port
        #}
        #catch
        #{
        #    throw $_
        #    exit -1
        #}

        #if($global:listClients.ContainsKey($($endpoint.Address.IPAddressToString)))
        #{
        #    Write-Host "bekannter endpoint"
        #}
        #else
        #{
        #    #Write-Host "neuer endpoint"
        #    $global:listClients[$($endpoint.Address.IPAddressToString)] = @{}
        #    $global:listClients[$($endpoint.Address.IPAddressToString)].name = $([Text.Encoding]::ASCII.GetString($content))
        #    $lbClients.Items.Add($global:listClients[$($endpoint.Address.IPAddressToString)].name)
        #    
        #    AppendTextTimeStampNewLine ([Drawing.Color]::Black) ("User " + $([Text.Encoding]::ASCII.GetString($content)) + " connected.")
        #}
    }
    
    Start-Sleep -m ((1 / $global:frames) * 1000)
}

$global:udpclient.Close()

#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
#[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets") 
#[void] [System.Windows.Forms.Application]::EnableVisualStyles()
#
#$objForm = New-Object System.Windows.Forms.Form 
#$objForm.Size = New-Object System.Drawing.Size(480, 240)
#$objForm.minimumSize = New-Object System.Drawing.Size(480, 240)
#$objForm.Add_Closing({$udpclient.Close( )})
#$objForm.Text = "Test Client"
#
#$btnSend = New-Object System.Windows.Forms.Button
#$btnSend.Location = New-Object System.Drawing.Size(8,16)
#$btnSend.Size = New-Object System.Drawing.Size(160,24)
#$btnSend.Text = "Send"
#$btnSend.Add_Click({SendData $txfText.Text; $txfText.Text = ""})
#$objForm.Controls.Add($btnSend)
#
#$txfText = New-Object System.Windows.Forms.Textbox
#$txfText.Location = New-Object System.Drawing.Size(8,48)
#$txfText.Size = New-Object System.Drawing.Size(320,24)
#$txfText.Text = ""
#$objForm.Controls.Add($txfText)
#
#$address="Loopback"
#$port=2020
#
#try
#{
#    $endpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $port )
#    $udpclient = new-object System.Net.Sockets.UdpClient
#}
#catch
#{
#    throw $_
#    exit -1
#}
#
#function SendData($data)
#{
#    $bytes = [Text.Encoding]::ASCII.GetBytes( $data )
#    $bytesSent = $udpclient.Send( $bytes, $bytes.length, $endpoint )
#}
#
#$objForm.Add_Shown({$objForm.Activate()})
#[void] $objForm.ShowDialog()
