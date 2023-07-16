function Get-FCTransactionToken {
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
    $TransactionTokenUrl = "https://$SAN/rest/running/brocade-zone/effective-configuration/transaction-token"

    # Get Transaction Token
    try {
        $TransactionTokenSAN = Invoke-RestMethod $TransactionTokenUrl -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_TransactionToken_SAN -StatusCodeVariable Resp_HTTP_Status_TransactionToken_SAN
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Transaction Token GET SUCCESS. Response: [$Resp_HTTP_Status_TransactionToken_SAN] Transaction Token:`n[$($TransactionTokenSAN.OuterXml)]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Transaction Token GET FAILED. Response: [$Resp_HTTP_Status_TransactionToken_SAN]" -LogFile $LogFile
        throw "[$SAN] Transaction Token GET FAILED. Response: [$Resp_HTTP_Status_TransactionToken_SAN]"
    }
    try {
        $TransactionToken = $TransactionTokenSAN.Response."effective-configuration"."transaction-token"
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] Transaction Token GET SUCCESS. Transaction Token: [$TransactionToken]" -LogFile $LogFile        
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Transaction Token GET FAILED. Response: [$Resp_HTTP_Status_TransactionToken_SAN]" -LogFile $LogFile
        throw "[$SAN] Transaction Token GET FAILED. Response: [$Resp_HTTP_Status_TransactionToken_SAN]"
    }

    return $TransactionToken
}