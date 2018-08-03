# **********************************************************************
# Funktion parseCSVFile
# * Verarbeitet Datei
# -> Dateiname (strFileName)
# <- Array mit Dateiinhalt
# **********************************************************************
function parseCSVFile ($strFileName)
{
    $strSeperator = ";"
	$arrDigi = New-Object System.Collections.ArrayList
	
	ForEach ($line in Get-Content -Path $strFileName) 
	{		
	    # Zeile aufteilen (0=Name, 1=PortName, 2=TreiberName)
		$ServerAndPort  = $line.Split($strSeperator)[0]
	    $IP   			= $line.Split($strSeperator)[1]
		$Device 		= $line.Split($strSeperator)[2]
		
		# Trenne erste Spalte
		$Server = $ServerAndPort.Split("/")[0]
		$Port   = $ServerAndPort.Split("/")[1]
		
		# Wenn erste Digi, immer eintragen
		if (-Not $arrDigi.Length)
		{	
			$new = $true
		}
		# Wenn Digi noch nicht vorhanden, dann eintragen
		elseif ($arrDigi[$arrDigi.Length -1][0] -ne $Server)
		{	
			$new = $true
		}
		# Wenn nur neuer Port, dann nicht eintragen
		else
		{	
			$new = $false
		}
		
		# Digi eintragen
		if ($new) 
		{	
			$arrDigi += ,@($Server,$IP)
		}
		
		# Port hinzufügen
		$arrDigi[$arrDigi.Length -1] += ,@($Device)
		
		# Struktur:
		# $arrDigi[x][y]
		# y = 0 				 = digi-Name
		# y = 1 				 = digi-IP
		# y > 2 				 = Gerät an Port y-1
		# $arrDigi.Length 		 = Anzahl Digis
		# $arrDigi[x].Length - 2 = Anzahl der Ports
		
	}

	return $arrDigi
}


Function Get-Telnet
{   Param (
        [Parameter(ValueFromPipeline=$true)]
        [String[]]$Commands = @("username","password","command"),
        [string]$RemoteHost = "HostnameOrIPAddress",
        [string]$Port = "23",
        [int]$WaitTime = 1000,
        [string]$OutputPath = "\\server\share\switchbackup.txt"
    )
    #Attach to the remote device, setup streaming requirements
    $Socket = New-Object System.Net.Sockets.TcpClient($RemoteHost, $Port)
    If ($Socket)
    {   $Stream = $Socket.GetStream()
        $Writer = New-Object System.IO.StreamWriter($Stream)
        $Buffer = New-Object System.Byte[] 1024 
        $Encoding = New-Object System.Text.AsciiEncoding

        #Now start issuing the commands
        ForEach ($Command in $Commands)
        {   $Writer.WriteLine($Command) 
            $Writer.Flush()
            Start-Sleep -Milliseconds $WaitTime
        }
        #All commands issued, but since the last command is usually going to be
        #the longest let's wait a little longer for it to finish
        Start-Sleep -Milliseconds ($WaitTime * 4)
        $Result = ""
        #Save all the results
        While($Stream.DataAvailable) 
        {   $Read = $Stream.Read($Buffer, 0, 1024) 
            $Result += ($Encoding.GetString($Buffer, 0, $Read))
        }
    }
    Else     
    {   $Result = "Unable to connect to host: $($RemoteHost):$Port"
    }
    #Done, now save the results to a file
    $Result | Out-File $OutputPath
}

# **********************************************************************
# Funktion parseXMLFile
# * Verarbeitet Datei
# -> Dateiname (strFileName)
# <- Array mit Dateiinhalt
# **********************************************************************
function parseXMLFile ($strFileName)
{
	$arrPorts = New-Object System.Collections.ArrayList
	
	$file = Get-Content -Path $strFileName
	$matches = ([regex]'<serial[^>]*>.*?(?=<\/serial>)<\/serial>').Matches($file)
	
	ForEach ($match in $matches) 
	{		
		if (([regex]'<desc>.+<\/desc>').Matches($match) -ne $null)
		{
			$Port = ([regex]'<desc>.+<\/desc>').Matches($match)[0]
			$Port = ([string]$Port).Substring(6,$Port.Length - 13)
			$arrPorts += ,@($Port)
		}
		
	}

	return $arrPorts
}

# **********************************************************************
# Funktion parseXMLFile
# * Verarbeitet Datei
# -> Dateiname (strFileName)
# <- Array mit Dateiinhalt
# **********************************************************************
function compareConfig ($DigiAccess, $DigiConfig)
{
	$arrDigiFull = New-Object System.Collections.ArrayList
	
	$numberOfPorts = (($DigiAccess.Length - 2),$DigiConfig.Length | Measure -Max).Maximum
	
	for ($i=0; $i -lt $numberOfPorts; $i++)
	{
		$arrDigiFull += ,@($DigiAccess[$i + 2],$DigiConfig[$i])
	}
	
	return $arrDigiFull
}

$arrPrint = New-Object System.Collections.ArrayList

$arrDigi = parseCSVFile "U:\Bischof\verifyDigiPorts\digi.csv"

ForEach ($Digi in $arrDigi)
{
	$filename = "\\stringer\it\Bischof\" + $Digi[0] + ".xml"
	Get-Telnet -RemoteHost $Digi[1] -Commands "root","dbps","backup print" -OutputPath $filename

	$arrPorts = parseXMLFile $filename

	$arrComparison = compareConfig $Digi $arrPorts
	
	
	ForEach ($Port in $arrComparison)
	{
		$strLine = $Digi[0] + ';' + $Port[0] + ';' + $Port[1]
		$strLine | Out-File "output.csv" -Append
	}
}





