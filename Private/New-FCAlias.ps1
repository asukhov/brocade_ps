function New-FCAlias {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,
       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $ComputerName,

       [Parameter(Mandatory=$true)]
       $WWPNs,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $AliasesUrl = "https://$SAN/rest/running/brocade-zone/defined-configuration/alias"

    # Generate Body
    $AliasBody = @()
    foreach($WWPN in $WWPNs){
        $AliasBody += "`n<alias-entry-name>$WWPN</alias-entry-name>`n"
    }

    # Generate Full Alias Name
    if ($SAN -match "DC1CS10") {
        $AliasFullName = $ComputerName + "_vFC1"
    } elseif ($SAN -match "DC1CS20") {
        $AliasFullName = $ComputerName + "_vFC2"
    } else {
        Write-Host "Wrong SAN specified" -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "ERROR" -LogMessage "Wrong SAN specified" -LogFile $LogFile
        throw "Wrong SAN specified - [$SAN]"
    }

    # Create Alias
    try {
        $Body = "<alias>
        `n<alias-name>$AliasFullName</alias-name>
        `n<member-entry>
        $AliasBody
        `n</member-entry>
        `n</alias>"

        $Response = Invoke-RestMethod -Uri $AliasesUrl -Method Post -Headers $Session_Headers_SAN -Body $Body -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        if ($Resp_HTTP_Status -eq 201) {
            Write-Host "[$SAN] Alias [$AliasFullName] created successfully" -ForegroundColor Green
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Alias [$AliasFullName] created successfully. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
        }
        else {
            Write-Host "[$SAN] Error creating alias [$AliasFullName]" -ForegroundColor Red
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error creating alias [$AliasFullName]. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
            throw "[$SAN] Error creating alias [$AliasFullName]. HTTP Response: [$Resp_HTTP_Status]"
        }
    }
    catch {
        Write-Host "[$SAN] Error creating alias [$AliasFullName]" -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error creating alias [$AliasFullName]" -LogFile $LogFile
        throw "[$SAN] Error creating alias [$AliasFullName]"
    }

    return $true
}