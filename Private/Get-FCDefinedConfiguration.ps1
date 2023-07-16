function Get-FCDefinedConfiguration {
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
    $DefinedConfigurationUrl = "https://$SAN/rest/running/brocade-zone/defined-configuration"

    # Get Defined Configuration
    try {
        $Response = Invoke-RestMethod -Uri $DefinedConfigurationUrl -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        if ($Resp_HTTP_Status -eq 200) {
            Write-Host "[$SAN] Defined Configuration retrieved successfully" -ForegroundColor Green
            Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Defined Configuration retrieved successfully. HTTP Response: [$Resp_HTTP_Status]. Here it is:`n[$($Response.OuterXml)]" -LogFile $LogFile
        }
        else {
            Write-Host "[$SAN] Error retrieving Defined Configuration" -ForegroundColor Red
            Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error retrieving Defined Configuration. HTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
            throw "[$SAN] Error retrieving Defined Configuration. HTTP Response: [$Resp_HTTP_Status]"
        }
    }
    catch {
        Write-Host "[$SAN] Error retrieving Defined Configuration" -ForegroundColor Red
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Error retrieving Defined Configuration. Error: $_ " -LogFile $LogFile
        throw "[$SAN] Error retrieving Defined Configuration. Error: $_ "
    }

    return $Response   
}