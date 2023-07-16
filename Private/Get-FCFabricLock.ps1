function Get-FCFabricLock {
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
    $FabricLockUrl = "https://$SAN/rest/running/brocade-zone/fabric-lock"

    # Get Fabric Lock
    try {
        $ResponseFabricLockSAN = Invoke-RestMethod $FabricLockUrl -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_FabricLock_SAN -StatusCodeVariable Resp_HTTP_Status_FabricLock_SAN
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Fabric Lock Status GET SUCCESS. Response: [$Resp_HTTP_Status_FabricLock_SAN] Fabric Lock Status:`n[$($ResponseFabricLockSAN.OuterXml)]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Fabric Lock GET FAILED. Response: [$Resp_HTTP_Status_FabricLock_SAN]" -LogFile $LogFile
        throw "[$SAN] Fabric Lock GET FAILED. Response: [$Resp_HTTP_Status_FabricLock_SAN]"
    }
    try {
        $ResponseFabricLockID = $ResponseFabricLockSAN.Response."fabric-lock"."lock-principal-domain-id"
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Fabric Lock ID GET SUCCESS. Lock-principal-domain-id: [$ResponseFabricLockID]" -LogFile $LogFile      
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Fabric Lock ID GET FAILED. Response: [$Resp_HTTP_Status_FabricLock_SAN]" -LogFile $LogFile
        throw "[$SAN] Fabric Lock ID GET FAILED. Response: [$Resp_HTTP_Status_FabricLock_SAN]"
    }

    return $ResponseFabricLockID
}