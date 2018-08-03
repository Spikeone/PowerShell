[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Net.Sockets") 
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

$global:FormSizeX = 1024
$global:FormSizeY = 600

$tooltip = New-Object System.Windows.Forms.ToolTip

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Size = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.minimumSize = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.maximumSize = New-Object System.Drawing.Size($global:FormSizeX, $global:FormSizeY)
$objForm.Add_Closing({$udpclient.Close( )})
$objForm.Text = "Server"

$btnSend = New-Object System.Windows.Forms.Button
$btnSend.Location = New-Object System.Drawing.Size(632,($global:FormSizeY - 48 - 18))
$btnSend.Size = New-Object System.Drawing.Size(160,24)
$btnSend.Text = "Send"
$btnSend.Add_Click({SendData $txfText.Text; $txfText.Text = ""})
$objForm.Controls.Add($btnSend)

$txfText = New-Object System.Windows.Forms.Textbox
$txfText.Location = New-Object System.Drawing.Size(8,($global:FormSizeY - 48 - 16))
$txfText.Size = New-Object System.Drawing.Size(($global:FormSizeX - 200 - 24 - 16 - 160),($global:FormSizeY - 48 - 60))
$txfText.Font = New-Object System.Drawing.Font("Lucida Console",10)
$txfText.Text = ""
$objForm.Controls.Add($txfText)

$lbClients = New-Object System.Windows.Forms.ListBox
$lbClients.Location = New-Object System.Drawing.Size(($global:FormSizeX - 200 - 24),8)
$lbClients.Size = New-Object System.Drawing.Size(200,($global:FormSizeY - 48))
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

$address="Any"
$port=2020
$global:keepRunning = $True
$global:frames = 60
$global:lastRun = Get-Date

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

try
{
    $endpoint = new-object System.Net.IPEndPoint( [IPAddress]::$address, $port )
    $udpclient = new-object System.Net.Sockets.UdpClient $port
}
catch
{
    throw $_
    exit -1
}

Write-Host "Press ESC to stop the udp server ..." -fore yellow
Write-Host ""

#$lbClients.Items.Add("Test")
#$lbClients.Items.Add("aTest1")
#$lbClients.Items.Add("Test3")

[void] $objForm.Show()

function handleLoginRequest($endpoint, $port, $strMsg)
{
    $splittedData = $strMsg.Split('/')

    Write-Host "Length: "  $splittedData.Length

    if($splittedData.Length -ne 2)
    {
        Write-Host "Invalid Login Request from $endpoint : $port"
        return;
    }

    # 0 = invalid
    # 1 = valid
    $loginResult = 0

    if($global:listClients.ContainsKey($endpoint))
    {
        Write-Host "bekannter endpoint"

        #SendData 
    }
    else
    {
        #Write-Host "neuer endpoint"
        $global:listClients[$endpoint] = @{}
        $global:listClients[$endpoint].name = $splittedData[1]
        $global:listClients[$endpoint].endpoint = new-object System.Net.IPEndPoint([IPAddress]::Parse($endpoint), [int]$port)
        $global:listClients[$endpoint].pingTimer = 10000
        $lbClients.Items.Add($global:listClients[$endpoint].name)

        SendDataEndpoint $global:listClients[$endpoint].endpoint "0x02/1"
        
        AppendTextTimeStampNewLine ([Drawing.Color]::Black) ("User '" + $splittedData[1] + "' connected.")
    }
}

function SendDataEndpoint($endpoint, $data)
{
    $bytes = [Text.Encoding]::ASCII.GetBytes( $data )
    $bytesSent = $udpclient.Send( $bytes, $bytes.length, $endpoint)
}

function handleMessages($endpoint, $port, $strMsg)
{
    $splittedData = $strMsg.Split('/')

    if($splittedData.Length -lt 2) {return;}

    switch($splittedData[0])
    {
        # Login Request
        "0x01" { handleLoginRequest $endpoint $port $strMsg}
        default { Write-Host "Unknown Message: $strMsg"}
    }

    Write-Host $splittedData.Length
}

function doPings($uiDiff)
{
    foreach ($h in $global:listClients.GetEnumerator()) 
    {
        if($global:listClients[$($h.name)].pingTimer -le $uiDiff)
        {
            try
            {
                SendDataEndpoint $global:listClients[$($h.name)].endpoint "0x03/Ping"
                $global:listClients[$($h.name)].pingTimer = 10000;
            }
            catch
            {
                $global:listClients[$($h.name)].endpoint.Close()
                AppendTextTimeStampNewLine ([Drawing.Color]::Red) ("User '" + $global:listClients[$($h.name)].name + "' disconnected.")
            }
        }
        else
        {
            $global:listClients[$($h.name)].pingTimer = $global:listClients[$($h.name)].pingTimer - $uiDiff
        }
    }
}

while($global:keepRunning)
{
    [System.Windows.Forms.Application]::DoEvents()
    
    $diff = (Get-Date) - $global:lastRun
    $global:lastRun = Get-Date
    $diffms = $diff.TotalMilliseconds
    
    if( $udpclient.Available )
    {
        try
        {
            $content = $udpclient.Receive( [ref]$endpoint )
            handleMessages $($endpoint.Address.IPAddressToString) $($endpoint.Port) ($([Text.Encoding]::ASCII.GetString($content)))
        }
        catch
        {
            Write-Host "Error: " $endpoint.ToString()
            #$global:listClients[(($endpoint.ToString().Split(':'))[0])].endpoint.Close()
            AppendTextTimeStampNewLine ([Drawing.Color]::Red) ("User '" + $global:listClients[(($endpoint.ToString().Split(':'))[0])].name + "' disconnected.")
        }
    }
    
    doPings $diffms

    Start-Sleep -m ((1 / $global:frames) * 1000)
}

$udpclient.Close( )