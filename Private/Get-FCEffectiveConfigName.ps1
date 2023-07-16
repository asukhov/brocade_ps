function Get-FCEffectiveConfigName {
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
    $EffectiveConfigUrlSAN = "https://$SAN/rest/running/brocade-zone/effective-configuration/cfg-name"

    # Get Effective Configuration Name
    try {
        $ResponseEffectiveConfigSAN = Invoke-RestMethod $EffectiveConfigUrlSAN -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_EffCfg_SAN -StatusCodeVariable Resp_HTTP_Status_EffCfg_SAN
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Effective Configuration GET SUCCESSFUL. HTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]. Response:`n[$($ResponseEffectiveConfigSAN.OuterXml)]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Effective Configuration GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]" -LogFile $LogFile
        throw "[$SAN] Effective Configuration GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]`n Error: [$($_.Exception.Message)]"
    }

    try {
        $EffectiveConfigName = $ResponseEffectiveConfigSAN.Response."effective-configuration"."cfg-name"
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Effective Configuration Name: [$EffectiveConfigName]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Effective Configuration Name GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]" -LogFile $LogFile
        throw "[$SAN] Effective Configuration Name GET FAILED. Response: [$Resp_Headers_EffCfg_SAN]`nHTTP Response: [$Resp_HTTP_Status_EffCfg_SAN]`n Error: [$($_.Exception.Message)]"
    }

    return $EffectiveConfigName
}