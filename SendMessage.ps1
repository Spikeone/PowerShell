 # Define port and target IP address 
  [int] $Port = 8989
  #$IP = "127.0.0.1"
  $IP = "10.126.244.235"
  $Address = [system.net.IPAddress]::Parse($IP) 

  # Create IP Endpoint 
  $End = New-Object System.Net.IPEndPoint $address, $port 

  # Create Socket 
  $Saddrf = [System.Net.Sockets.AddressFamily]::InterNetwork 
  $Stype = [System.Net.Sockets.SocketType]::Stream 
  $Ptype = [System.Net.Sockets.ProtocolType]::TCP
  $Sock = New-Object System.Net.Sockets.Socket $saddrf, $stype, $ptype 
  $Sock.TTL = 26 

  # Connect to socket 
  $sock.Connect($end)

  # Create byte array
  # TCP [Byte[]] $Message = 0xAA,0x55,0x00,0x12,0x00,0x00,0x00,0x7B,0x00,0x00,0x00,0x41,0x00,0x00,0x00,0x00,0xD6,0xDE,0xD5,0xA7,0x14,0x00
  [Byte[]] $Message = 0x01, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x0B, 0x0B, 0x0B, 0x00, 0x11, 0x11, 0x11;
  [Byte[]] $EOM = 0x00;
 # for ($i=0; $i -le 1000; $i++)
 # {
  # Send the byte array 
  $Sent = $Sock.Send($Message)
  Start-Sleep -Milliseconds 50
  $Sent = $Sock.Send($EOM)
  $Sent = $Sock.Send($Message)
  #$Sent = $Sock.Send($EOM)
  Start-Sleep 5
  #$Sock.Close()
  #"{0} characters sent to: {1} " -f $Sent,$IP
  #"Message is: $Message" 
  # End of Script
 # }