function Invoke-FCAbortZoneTransaction {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$true)]
       $EffectiveConfigName,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Set URLs
    $EffectiveConfigAbortActionUrl = "https://$SAN/rest/running/brocade-zone/effective-configuration/cfg-action/4"

    # Abort Zone Transaction
    try {        
        Invoke-RestMethod $EffectiveConfigAbortActionUrl -Method Patch -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers -StatusCodeVariable Resp_HTTP_Status
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Zone Transaction for [$EffectiveConfigName] has been aborted. Response: [$Resp_Headers]`nHTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Zone Transaction for [$EffectiveConfigName] abort FAILED. Response: [$Resp_Headers]`nHTTP Response: [$Resp_HTTP_Status]" -LogFile $LogFile
        throw "[$SAN] Zone Transaction for [$EffectiveConfigName] abort FAILED. Response: [$Resp_Headers]`nHTTP Response: [$Resp_HTTP_Status]"
    }

    return $true
}