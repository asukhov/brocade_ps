function Invoke-FCSwitchLogout {
    Param
    (
       [Parameter(Mandatory=$true)]
       $SessionHeaders,

       [Parameter(Mandatory=$true)]
       $URL,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    # Logout from switch
    try {
        Invoke-RestMethod $URL -Method Post -Headers $SessionHeaders -SkipCertificateCheck -StatusCodeVariable Resp_HTTP_Status_SwitchLogout_SAN
        Write-Host ('-'*80) -ForegroundColor Yellow
        Write-Host "[$URL] Session closed. Response: [$Resp_HTTP_Status_SwitchLogout_SAN]" -ForegroundColor Yellow
        Write-Host ('-'*80) -ForegroundColor Yellow
        Write-Host "End Block" -ForegroundColor Yellow
        Write-Host ('-'*80) -ForegroundColor Yellow
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$URL] Session closed. Response: [$Resp_HTTP_Status_SwitchLogout_SAN]" -LogFile $LogFile
        "--------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
        "                                 SESSION CLOSED.                                " | Out-File -FilePath $LogFile -Append
        "--------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] Switch Logout POST FAILED. Response: [$Resp_HTTP_Status_SwitchLogout_SAN]" -LogFile $LogFile
        throw "[$SAN] Switch Logout POST FAILED. Response: [$Resp_HTTP_Status_SwitchLogout_SAN]"
    }
}