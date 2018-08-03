[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Media")

function listen-port ($port=8989) {
    $endpoint = new-object System.Net.IPEndPoint ([system.net.ipaddress]::any, $port)
    $listener = new-object System.Net.Sockets.TcpListener $endpoint
    $listener.start()

    #do {
        $client = $listener.AcceptTcpClient() # will block here until connection
        $stream = $client.GetStream();
        $reader = New-Object System.IO.StreamReader $stream
        do {

            $line = $reader.ReadLine()
            #write-host $line
            if($line -eq "(C)?")
            {
                [System.Windows.Forms.MessageBox]::Show("Kaffee?")
            }
            else
            {
                Write-Host "Message: " $line
            }
        } while ($line -and $line -ne ([char]4))
        $reader.Dispose()
        $stream.Dispose()
        #$client.Dispose()
    #} #while ($line -ne ([char]4))
    $listener.stop()
}

while($True)
{
    listen-port 8989
    Start-Sleep 1
}

Write-Host "Warten..."
Start-Sleep 5