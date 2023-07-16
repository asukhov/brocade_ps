function Get-FCEffectiveConfiguration {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $EffectiveConfigurationUrl = "https://$SAN/rest/running/brocade-zone/effective-configuration"

    # Get Effective Configuration
    try {
        $Response = Invoke-RestMethod -Uri $EffectiveConfigurationUrl -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        if ($Resp_HTTP_Status -eq 200) {
            Write-Host "[$SAN] Effective Configuration retrieved successfully" -ForegroundColor Green
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Effective Configuration retrieved successfully. HTTP Response: [$Resp_HTTP_Status]. Here it is:`n[$($Response.OuterXml)]" -LogFile $LogFile
        }
        else {
            Write-Host "[$SAN] Error retrieving Effective Configuration" -ForegroundColor Red
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error retrieving Effective Configuration. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
            throw "[$SAN] Error retrieving Effective Configuration. HTTP Response: [$Resp_HTTP_Status]"
        }
    }
    catch {
        Write-Host "[$SAN] Error retrieving Effective Configuration" -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error retrieving Effective Configuration. Error: $_ " -LogFile $LogFile
        throw "[$SAN] Error retrieving Effective Configuration. Error: $_ "
    }

    return $Response   
}