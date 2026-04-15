class ServerBluePrint {
    [string]$servername
    [string]$ip
    [string]$status

    [void] ping() {
        test-connection -TargetName $this.ip -count 1
    }
}
$newServer = [ServerBlueprint]@{servername = "SRV-999"; IP = "10.10.1.1"; Status = "Online" }
$newServer