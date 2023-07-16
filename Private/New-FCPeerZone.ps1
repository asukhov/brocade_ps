function New-FCPeerZone {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $PeerZoneName,

       [Parameter(Mandatory=$true)]
       $PeerZoneMembers,

       [Parameter(Mandatory=$false)]
       $PeerZonePrincipals,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $PeerZoneDefinedConfigUrl = "https://$SAN/rest/running/brocade-zone/defined-configuration/zone"

    # Generate Body
    $PeerZoneMemberOutput = @()
    foreach($PeerZoneMember in $PeerZoneMembers){
        $PeerZoneMemberOutput += "`n<entry-name>$PeerZoneMember</entry-name>`n"
    }

    if($PeerZonePrincipals){
        $PeerZonePrincipalOutput = @()
        foreach($PeerZonePrincipal in $PeerZonePrincipals){
            $PeerZonePrincipalOutput += "`n<principal-entry-name>$PeerZonePrincipal</principal-entry-name>`n"
        }
        $Body = "<zone>
        `n<zone-name>$PeerZoneName</zone-name>
        `n<zone-type-string>user-created-peer-zone</zone-type-string>
        `n<member-entry>
        $PeerZonePrincipalOutput
        $PeerZoneMemberOutput
        `n</member-entry>
        `n</zone>"
    }
    else {
        $Body = "<zone>
        `n<zone-name>$PeerZoneName</zone-name>
        `n<zone-type-string>user-created-peer-zone</zone-type-string>
        `n<member-entry>
        $PeerZoneMemberOutput
        `n</member-entry>
        `n</zone>"
    }

    # Create Peer Zone
    try {
        Invoke-RestMethod $PeerZoneDefinedConfigUrl -Method Post -Headers $Session_Headers_SAN -SkipCertificateCheck -Body $Body -ResponseHeadersVariable Resp_Headers_PeerZone -StatusCodeVariable Resp_HTTP_Status_PeerZone
        if ($Resp_HTTP_Status_PeerZone -eq 201) {
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Peer Zone [$PeerZoneName] created. HTTP Response: [$Resp_HTTP_Status_PeerZone]" -LogFile $LogFile
        }
        else {
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Peer Zone [$PeerZoneName] creation FAILED. HTTP Response: [$Resp_HTTP_Status_PeerZone]" -LogFile $LogFile
            throw "[$SAN] Peer Zone [$PeerZoneName] creation FAILED. HTTP Response: [$Resp_HTTP_Status_PeerZone]"
        }
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Peer Zone [$PeerZoneName] creation FAILED. Error:`n[$_]" -LogFile $LogFile
        throw "[$SAN] Peer Zone [$PeerZoneName] creation FAILED. HTTP Response: [$Resp_HTTP_Status_PeerZone]"
    }

    return $true
}