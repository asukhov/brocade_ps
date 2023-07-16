function Invoke-FCAliasCheckV2 {
    Param
    (
       [Parameter(Mandatory=$true)]
       $Session_Headers_SAN,

       [Parameter(Mandatory=$true)]
       $AliasName,

       [Parameter(Mandatory=$true)]
       $WWPNs,

       [Parameter(Mandatory=$true)]
       $SAN,

       [Parameter(Mandatory=$false,
       HelpMessage='Please specify log location.')]
       $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"
    )

    $AliasWWPNs = @()
    $AliasMatch = $null
    $AliasState = $null # If this variable will be less then 2 then alias WWPNs are not correct

    # Set URLs
    $AliasesUrl = "https://$SAN/rest/running/brocade-zone/defined-configuration/alias"

    try {
        $ResponseAliases = Invoke-RestMethod $AliasesUrl -Method Get -Headers $Session_Headers_SAN -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_Aliases -StatusCodeVariable Resp_HTTP_Status_Alias
        Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN] HTTP Response: [$Resp_HTTP_Status_Alias]. Aliases response:`n[$($ResponseAliases.OuterXml)]" -LogFile $LogFile
    }
    catch {
        Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN] HTTP Response: [$Resp_HTTP_Status_Alias] Aliases response FAILED. Response: [$($ResponseAliases.OuterXml)]" -LogFile $LogFile
        throw "[$SAN] Aliases response FAILED. Response: [$Resp_Headers_Aliases]`nHTTP Response: [$Resp_HTTP_Status_Alias]"
    }

    foreach($ResponseAlias in $ResponseAliases.Response.alias){
        if($ResponseAlias."alias-name" -match $AliasName) {
            $AliasMatch += $ResponseAlias."alias-name"
            Write-Host "[$AliasName][$SAN] Alias matched by name found: [$($ResponseAlias."alias-name")]" -ForegroundColor Green

            foreach($ResponseAliasMemeber in $ResponseAlias."member-entry"."alias-entry-name"){
                $AliasWWPNs += $ResponseAliasMemeber
            }

            Write-Host "[$AliasName][$SAN] Following WWPNs for [$($ResponseAlias."alias-name")] found: `n [$AliasWWPNs]" -ForegroundColor Green

            if($SAN -match "DC1CS10"){
                if($AliasWWPNs[0] -eq $WWPNs[0]) {
                    Write-Host "[$AliasName][$SAN] First WWPN is correct one: [$($AliasWWPNs[0])]" -ForegroundColor Green
                    Invoke-FCLogToFile "INFO" "[$AliasName][$SAN] First WWPN is correct one: [$($AliasWWPNs[0])]" $LogFile
                    $AliasState++
                } else {
                    Write-Host "[$AliasName][$SAN] First WWPN is NOT correct one: [$($AliasWWPNs[0])] instead of [$($WWPNs[0])]" -ForegroundColor Red
                    Invoke-FCLogToFile "ERROR" "[$AliasName][$SAN] First WWPN is NOT correct one: [$($AliasWWPNs[0])] instead of [$($WWPNs[0])]" $LogFile
                }
                if($AliasWWPNs[1] -eq $WWPNs[2]) {
                    Write-Host "[$AliasName][$SAN] Second WWPN is correct one: [$($AliasWWPNs[1])]" -ForegroundColor Green
                    Invoke-FCLogToFile "INFO" "[$AliasName][$SAN] Second WWPN is correct one: [$($AliasWWPNs[1])]" $LogFile
                    $AliasState++
                } else {
                    Write-Host "[$AliasName][$SAN] Second WWPN is NOT correct one: [$($AliasWWPNs[1])] instead of [$($WWPNs[2])]" -ForegroundColor Red
                    Invoke-FCLogToFile "ERROR" "[$AliasName][$SAN] Second WWPN is NOT correct one: [$($AliasWWPNs[1])] instead of [$($WWPNs[2])]" $LogFile
                }
                if(-not $AliasState){
                    Write-Host "[$AliasName][$SAN] Alias WWPNs are not correct. Please check." -ForegroundColor Red
                    Invoke-FCLogToFile -LogMessageType "ERROR" -LogMessage "[$AliasName][$SAN] Alias WWPNs are not correct. Please check." -LogFile $LogFile
                    $AliasState = 3
                }
                $Results = @($AliasState,$AliasName)
                $AliasWWPNs = @()
                $AliasState = $null
                return $Results
            } elseif ($SAN -match "DC1CS20") {
                if($AliasWWPNs[0] -eq $WWPNs[1]) {
                    Write-Host "[$AliasName][$SAN] First WWPN is correct one: [$($AliasWWPNs[0])]" -ForegroundColor Green
                    Invoke-FCLogToFile "INFO" "[$AliasName][$SAN] First WWPN is correct one: [$($AliasWWPNs[0])]" $LogFile
                    $AliasState++
                } else {
                    Write-Host "[$AliasName][$SAN] First WWPN is NOT correct one: [$($AliasWWPNs[0])] instead of [$($WWPNs[1])]" -ForegroundColor Red
                    Invoke-FCLogToFile "ERROR" "[$AliasName][$SAN] First WWPN is NOT correct one: [$($AliasWWPNs[0])] instead of [$($WWPNs[1])]" $LogFile
                }
                if($AliasWWPNs[1] -eq $WWPNs[3]) {
                    Write-Host "[$AliasName][$SAN] Second WWPN is correct one: [$($AliasWWPNs[1])]" -ForegroundColor Green
                    Invoke-FCLogToFile "INFO" "[$AliasName][$SAN] Second WWPN is correct one: [$($AliasWWPNs[1])]" $LogFile
                    $AliasState++
                } else {
                    Write-Host "[$AliasName][$SAN] Second WWPN is NOT correct one: [$($AliasWWPNs[1])] instead of [$($WWPNs[3])]" -ForegroundColor Red
                    Invoke-FCLogToFile "ERROR" "[$AliasName][$SAN] Second WWPN is NOT correct one: [$($AliasWWPNs[1])] instead of [$($WWPNs[3])]" $LogFile
                }
                $Results = @($AliasState,$AliasName)
                $AliasWWPNs = @()
                $AliasState = $null
                return $Results
            } else {
                $AliasState = 4
                Write-Host "Wrong SAN specified" -ForegroundColor Red
                $Results = @($AliasState,"Throwing exception")
                $AliasState = $null
                return $Results
            }
        }
    }
    if($null -eq $AliasMatch) {
        $AliasState = 5
        Write-Host "[$AliasName][$SAN] No existing aliases were found. We are good to go." -ForegroundColor Yellow
        $Results = @($AliasState,"Not existing alias")
        $AliasState = $null
        return $Results # No aliases exists - we are good to go
    }
}