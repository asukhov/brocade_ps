function Invoke-FCConfiguration
{
   [CmdletBinding()]
   Param
   (
      [Parameter(Mandatory=$true,
         ValueFromPipeline=$true,
         HelpMessage='Please provide a computer name.')]
      [ValidateNotNullOrEmpty()]
      [string[]]$ComputerName,

      [Parameter(Mandatory=$false,
         HelpMessage='Please specify action type.')]
      [ValidateSet("ChecksOnly", "PrepareConfig" ,"Create-Zones")]
      [string[]]$ActionType = "ChecksOnly",

      [Parameter(Mandatory=$true,
         HelpMessage='Please specify storage array.')]
      [ValidateSet("TargetStorageName01","TargetStorageName02","TargetStorageName03","TargetStorageName04","TargetStorageName05")]
      [string[]]$StorageArrayName,

      [Parameter(Mandatory=$false,
         HelpMessage='Please specify SAN.')]
      [ValidateSet("SAN1","SAN2")]
      [string[]]$SAN,

      [Parameter(Mandatory=$false,
      HelpMessage='Please specify Cluster or Host Name for new Zone')]
      [string]$ZoneHostGroupName,

      [Parameter(Mandatory=$false,
      HelpMessage='Please specify PrepareConfig Action')]
      [ValidateSet("Create", "Add")]
      [string]$PrepConfigAction,

      [Parameter(Mandatory=$false,
         HelpMessage='Please specify log location.')]
      $LogFile = "C:\Users\Public\Documents\FibreChannelTools.txt"        
   )
   Begin
   {
      $LocalServerName = $env:COMPUTERNAME
      $AliasesUrlSAN1 = "https://SAN1LSD/rest/running/brocade-zone/defined-configuration/alias"
      $AliasesUrlSAN2 = "https://SAN2LSD/rest/running/brocade-zone/defined-configuration/alias"
      $ZonesUrlSAN1 = "https://SAN1LSD/rest/running/brocade-zone/defined-configuration/zone"
      $ZonesUrlSAN2 = "https://SAN2LSD/rest/running/brocade-zone/defined-configuration/zone"
      $LogoutUrlSAN1 = "https://SAN1LSD/rest/logout"
      $LogoutUrlSAN2 = "https://SAN2LSD/rest/logout"

      $SAN1_TargetStorageName01_Ports = "TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx"
      $SAN1_TargetStorageName02_Ports = "TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx"
      $SAN1_TargetStorageName03_Ports = "TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx"
      $SAN1_TargetStorageName04_Ports = "TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx"
      $SAN1_TargetStorageName05_Ports = "TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx"

      $SAN2_TargetStorageName01_Ports = "TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx","TargetStorageName01-CTxFCx"
      $SAN2_TargetStorageName02_Ports = "TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx","TargetStorageName02-CTxFCx"
      $SAN2_TargetStorageName03_Ports = "TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx","TargetStorageName03-CTxFCx"
      $SAN2_TargetStorageName04_Ports = "TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx","TargetStorageName04-CTxFCx"
      $SAN2_TargetStorageName05_Ports = "TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx","TargetStorageName05-CTxFCx"

      if ($ActionType -eq "Create-Zones")
      {
         if (!$SAN) {
            $SAN = Read-Host "Enter a value for SAN (SAN1 or SAN2)"
            if ($SAN -notin "SAN1","SAN2")
            {
               Write-Error "Invalid value for SAN. Valid values are 'SAN1' and 'SAN2'."
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "Invalid value for SAN. Valid values are 'SAN1' and 'SAN2'." -LogFile $LogFile
               throw "Invalid value for SAN. Valid values are 'SAN1' and 'SAN2'."
            }
         }

         if (!$ZoneHostGroupName) {
            $ZoneHostGroupName = Read-Host "Enter the name of the zone host group (must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter)"
            if ($ZoneHostGroupName -cnotmatch '^[A-Z][A-Z\d-]{0,14}$') {
               Write-Error "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter."
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter." -LogFile $LogFile
               throw "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter."
            }
         }
      }

      if ($ActionType -eq "PrepareConfig"){
         if (!$ZoneHostGroupName) {
            $ZoneHostGroupName = Read-Host "Enter the name of the zone host group (must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter)"
            if ($ZoneHostGroupName -cnotmatch '^[A-Z][A-Z\d-]{0,14}$') {
               Write-Error "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter."
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter." -LogFile $LogFile
               throw "Invalid zone host group name. Must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter."
            }
         }

         if (!$PrepConfigAction) {
            $PrepConfigAction = Read-Host "Enter the action type (Create or Add)"
            if ($PrepConfigAction -notin "Create","Add")
            {
               Write-Error "Invalid value for action type. Valid values are 'Create' and 'Add'."
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "Invalid value for action type. Valid values are 'Create' and 'Add'." -LogFile $LogFile
               throw "Invalid value for action type. Valid values are 'Create' and 'Add'."
            }
         }
      }

      Write-Host ('-'*80) -ForegroundColor Yellow
      Write-Host "Client name Name: [$ComputerName] `nAction Type: [$ActionType] `nLog file location: [$LogFile]`nStorage Array Name: [$StorageArrayName]" -ForegroundColor Yellow
      
      "--------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
      "                                SESSION STARTED.                                " | Out-File -FilePath $LogFile -Append
      "--------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
      "Client name Name: [$ComputerName] `nAction Type: [$ActionType] `nLog file location: [$LogFile]`nStorage Array Name: [$StorageArrayName]" | Out-File -FilePath $LogFile -Append
      "--------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append

      # 1. Login procedure and getting session key
      # 1.1 Generate request header using authtoken instead of password
      if ($ActionType -match "ChecksOnly") {
         try {
            $Headers_SAN1 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Headers_SAN1.Add("Content-Type", "application/yang-data+json") # Required key
            $Headers_SAN1.Add("Accept", "application/yang-data+json") # Required key
            $Headers_SAN1.Add("Authorization", "Custom_Auth PUT_KEY_HERE")
            $Headers_SAN1.Add("User-Agent", "PowerShell/Script")
            $Headers_SAN1.Add("Host", $LocalServerName)
            Invoke-RestMethod 'https://SAN1LSD/rest/login' -Method Post -Headers $Headers_SAN1 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_SAN1 -StatusCodeVariable Resp_HTTP_Status_SAN1
            Write-Host "Trying to connect to SAN-1. Resp_HTTP_Status: [$Resp_HTTP_Status_SAN1]" -ForegroundColor Yellow
            # Give some time to get response (according documentation it could take up to 30 sec.)
            Start-Sleep -Seconds 10
            # 1.2 Generate session header with session authorization key
            $Session_Headers_SAN1 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Session_Headers_SAN1.Add("Content-Type", "application/yang-data+json")
            $Session_Headers_SAN1.Add("Accept", "application/yang-data+json")
            $Session_Headers_SAN1.Add("Authorization", $Resp_Headers_SAN1.Authorization)
            $Session_Headers_SAN1.Add("User-Agent", "PowerShell/Script")
            $Session_Headers_SAN1.Add("Host", $LocalServerName)
            Write-Host "Generating session key for SAN-1" -ForegroundColor Yellow
         }
         catch {
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] Failed to establish session via REST API to SAN-1 (SAN1LSD)" $LogFile
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] $Resp_HTTP_Status_SAN1" $LogFile
            throw "Failed to establish session via REST API to SAN-1 (SAN1LSD)"
         }     
         try {
            $Headers_SAN2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Headers_SAN2.Add("Content-Type", "application/yang-data+json") # Required key
            $Headers_SAN2.Add("Accept", "application/yang-data+json") # Required key
            $Headers_SAN2.Add("Authorization", "Custom_Auth PUT_KEY_HERE")
            $Headers_SAN2.Add("User-Agent", "PowerShell/Script")
            $Headers_SAN2.Add("Host", $LocalServerName)
            Invoke-RestMethod 'https://SAN2LSD/rest/login' -Method Post -Headers $Headers_SAN2 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_SAN2 -StatusCodeVariable Resp_HTTP_Status_SAN2
            Write-Host "Trying to connect to SAN-2. Resp_HTTP_Status: [$Resp_HTTP_Status_SAN2]" -ForegroundColor Yellow
            # Give some time to get response (according documentation it could take up to 30 sec.)
            Start-Sleep -Seconds 10
            # 1.2 Generate session header with session authorization key
            $Session_Headers_SAN2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Session_Headers_SAN2.Add("Content-Type", "application/yang-data+json")
            $Session_Headers_SAN2.Add("Accept", "application/yang-data+json")
            $Session_Headers_SAN2.Add("Authorization", $Resp_Headers_SAN2.Authorization)
            $Session_Headers_SAN2.Add("User-Agent", "PowerShell/Script")
            $Session_Headers_SAN2.Add("Host", $LocalServerName)
            Write-Host "Generating session key for SAN-2" -ForegroundColor Yellow
         }
         catch {
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] Failed to establish session via REST API to SAN-2 (SAN2LSD)" $LogFile
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] $Resp_HTTP_Status_SAN2" $LogFile
            Invoke-RestMethod 'https://SAN1LSD/rest/logout' -Method Post -Headers $Session_Headers_SAN1 -SkipCertificateCheck
            throw "Failed to establish session via REST API to SAN-2 (SAN2LSD)"
         }
         try {
            $ResponseAliasesSAN1 = Invoke-RestMethod $AliasesUrlSAN1 -Method Get -Headers $Session_Headers_SAN1 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_Aliases_SAN1 -StatusCodeVariable Resp_HTTP_Status_Alias_SAN1
            Invoke-FCLogToFile "[INFO]" "[$ComputerName][SAN-1] Request aliases via REST API status: [$Resp_HTTP_Status_Alias_SAN1]" $LogFile
            $ResponseZonesSAN1 = Invoke-RestMethod $ZonesUrlSAN1 -Method Get -Headers $Session_Headers_SAN1 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_Zones_SAN1 -StatusCodeVariable Resp_HTTP_Status_Zones_SAN1
            Invoke-FCLogToFile "[INFO]" "[$ComputerName][SAN-1] Request zones via REST API status: [$Resp_HTTP_Status_Zones_SAN1]" $LogFile
         }
         catch {
            Write-Host "[SAN-1] Aliases and zones GET FAILED. Aliase Response: [$Resp_HTTP_Status_Alias_SAN1] Zones Response: [$Resp_HTTP_Status_Zones_SAN1]" -ForegroundColor Red
            Invoke-FCLogToFile "[ERROR]" "[$ComputerName][SAN-1] Aliases and zones GET FAILED. Aliase Response: [$Resp_HTTP_Status_Alias_SAN1] Zones Response: [$Resp_HTTP_Status_Zones_SAN1]" $LogFile
         }
         try {
            $ResponseAliasesSAN2 = Invoke-RestMethod $AliasesUrlSAN2 -Method Get -Headers $Session_Headers_SAN2 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_Aliases_SAN2 -StatusCodeVariable Resp_HTTP_Status_Alias_SAN2
            Invoke-FCLogToFile "[INFO]" "[$ComputerName][SAN-2] Request aliases via REST API status: [$Resp_HTTP_Status_Alias_SAN2]" $LogFile
            $ResponseZonesSAN2 = Invoke-RestMethod $ZonesUrlSAN2 -Method Get -Headers $Session_Headers_SAN2 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_Zones_SAN2 -StatusCodeVariable Resp_HTTP_Status_Zones_SAN2
            Invoke-FCLogToFile "[INFO]" "[$ComputerName][SAN-2] Request zones via REST API status: [$Resp_HTTP_Status_Zones_SAN2]" $LogFile
         }
         catch {
            Write-Host "[SAN-2] Aliases and zones GET FAILED. Aliase Response: [$Resp_HTTP_Status_Alias_SAN2] Zones Response: [$Resp_HTTP_Status_Zones_SAN2]" -ForegroundColor Red
            Invoke-FCLogToFile "[ERROR]" "[$ComputerName][SAN-2] Aliases and zones GET FAILED. Aliase Response: [$Resp_HTTP_Status_Alias_SAN2] Zones Response: [$Resp_HTTP_Status_Zones_SAN2]" $LogFile
         }
      }

      if ($ActionType -match "Create-Zones") {
         try {
            $Headers_SAN1 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Headers_SAN1.Add("Content-Type", "application/yang-data+xml") # Required key
            $Headers_SAN1.Add("Accept", "application/yang-data+xml") # Required key
            $Headers_SAN1.Add("Authorization", "Custom_Auth PUT_KEY_HERE")
            $Headers_SAN1.Add("User-Agent", "PowerShell/Script")
            $Headers_SAN1.Add("Host", $LocalServerName)
            Invoke-RestMethod 'https://SAN1LSD/rest/login' -Method Post -Headers $Headers_SAN1 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_SAN1 -StatusCodeVariable Resp_HTTP_Status_SAN1
            Write-Host "Trying to connect to SAN-1. Resp_HTTP_Status: [$Resp_HTTP_Status_SAN1]" -ForegroundColor Yellow
            # Give some time to get response (according documentation it could take up to 30 sec.)
            Start-Sleep -Seconds 10
            # 1.2 Generate session header with session authorization key
            $Session_Headers_SAN1 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Session_Headers_SAN1.Add("Content-Type", "application/yang-data+xml")
            $Session_Headers_SAN1.Add("Accept", "application/yang-data+xml")
            $Session_Headers_SAN1.Add("Authorization", $Resp_Headers_SAN1.Authorization)
            $Session_Headers_SAN1.Add("User-Agent", "PowerShell/Script")
            $Session_Headers_SAN1.Add("Host", $LocalServerName)
            Write-Host "Generating session key for SAN-1" -ForegroundColor Yellow
         }
         catch {
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] Failed to establish session via REST API to SAN-1 (SAN1LSD)" $LogFile
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] $Resp_HTTP_Status_SAN1" $LogFile
            throw "Failed to establish session via REST API to SAN-1 (SAN1LSD)"
         }     
         try {
            $Headers_SAN2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Headers_SAN2.Add("Content-Type", "application/yang-data+xml") # Required key
            $Headers_SAN2.Add("Accept", "application/yang-data+xml") # Required key
            $Headers_SAN2.Add("Authorization", "Custom_Auth PUT_KEY_HERE")
            $Headers_SAN2.Add("User-Agent", "PowerShell/Script")
            $Headers_SAN2.Add("Host", $LocalServerName)
            Invoke-RestMethod 'https://SAN2LSD/rest/login' -Method Post -Headers $Headers_SAN2 -SkipCertificateCheck -ResponseHeadersVariable Resp_Headers_SAN2 -StatusCodeVariable Resp_HTTP_Status_SAN2
            Write-Host "Trying to connect to SAN-2. Resp_HTTP_Status: [$Resp_HTTP_Status_SAN2]" -ForegroundColor Yellow
            # Give some time to get response (according documentation it could take up to 30 sec.)
            Start-Sleep -Seconds 10
            # 1.2 Generate session header with session authorization key
            $Session_Headers_SAN2 = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
            $Session_Headers_SAN2.Add("Content-Type", "application/yang-data+xml")
            $Session_Headers_SAN2.Add("Accept", "application/yang-data+xml")
            $Session_Headers_SAN2.Add("Authorization", $Resp_Headers_SAN2.Authorization)
            $Session_Headers_SAN2.Add("User-Agent", "PowerShell/Script")
            $Session_Headers_SAN2.Add("Host", $LocalServerName)
            Write-Host "Generating session key for SAN-2" -ForegroundColor Yellow
         }
         catch {
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] Failed to establish session via REST API to SAN-2 (SAN2LSD)" $LogFile
            Invoke-FCLogToFile "[ERROR]" "[GLOBAL] $Resp_HTTP_Status_SAN2" $LogFile
            Invoke-RestMethod 'https://SAN1LSD/rest/logout' -Method Post -Headers $Session_Headers_SAN1 -SkipCertificateCheck
            throw "Failed to establish session via REST API to SAN-2 (SAN2LSD)"
         }

         if ($SAN -eq "SAN1"){
            $TargetStorageName01_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName02_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName03_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName04_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName05_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"

            $Session_Headers_SAN = $Session_Headers_SAN1
            $SAN_Name = "SAN1LSD"
         }
         elseif ($SAN -eq "SAN2"){
            $TargetStorageName01_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName02_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName03_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName04_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"
            $TargetStorageName05_Ports_WWPNs = "WWPN_HERE","WWPN_HERE","WWPN_HERE","WWPN_HERE"

            $Session_Headers_SAN = $Session_Headers_SAN2
            $SAN_Name = "SAN2LSD"
         }

         switch -Exact ($StorageArrayName)
         {
            'TargetStorageName01' { $StorageArrayName_WWPNs = $TargetStorageName01_Ports_WWPNs }
            'TargetStorageName02' { $StorageArrayName_WWPNs = $TargetStorageName02_Ports_WWPNs }
            'TargetStorageName03' { $StorageArrayName_WWPNs = $TargetStorageName03_Ports_WWPNs }
            'TargetStorageName04' { $StorageArrayName_WWPNs = $TargetStorageName04_Ports_WWPNs }
            'PURCLU02PR' { $StorageArrayName_WWPNs = $PURCLU02PR_Ports_WWPNs }
            'PURCLU04PR' { $StorageArrayName_WWPNs = $PURCLU04PR_Ports_WWPNs }
            'TargetStorageName05' { $StorageArrayName_WWPNs = $TargetStorageName05_Ports_WWPNs }
         }
      }
   }
   Process
   {
      foreach($Computer in $ComputerName) {
         try {
            $VMWWPNs_All = Get-FCVMWWPNs -Computer $Computer -LogFile $LogFile
            if ($SAN -eq "SAN1"){
               $VMWWPNs = $VMWWPNs_All[0], $VMWWPNs_All[2]
            }
            elseif ($SAN -eq "SAN2"){
               $VMWWPNs = $VMWWPNs_All[1], $VMWWPNs_All[3]
            }
         }
         catch {
            Invoke-FCLogToFile "[ERROR]" "[$Computer] Failed to get WWPNs." $LogFile
            if ($ActionType -match "ChecksOnly") {
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
            }
            throw "Failed to get [$Computer] WWPNs."
         }
         if($ActionType -match "ChecksOnly") {
            try {
               $AliasWWPNsSAN1 = @()
               $AliasWWPNsSAN2 = @()
               if($Resp_HTTP_Status_Alias_SAN1 -eq "200"){
                  $AliasMatchSAN1 = $null
                  foreach($ResponseAliasSAN1 in $ResponseAliasesSAN1.Response.alias){
                     if ($ResponseAliasSAN1."alias-name" -match $Computer) {
                        $AliasMatchSAN1 += $ResponseAliasSAN1."alias-name"
                        Write-Host "[$Computer][SAN-1] Alias matched by name found: [$($ResponseAliasSAN1."alias-name")]" -ForegroundColor Green
                        Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-1] Alias matched by name found: [$($ResponseAliasSAN1."alias-name")]" $LogFile
                        foreach($ResponseAliasMemeberSAN1 in $ResponseAliasSAN1."member-entry"."alias-entry-name"){
                           $AliasWWPNsSAN1 += $ResponseAliasMemeberSAN1
                        }
                        Write-Host "[$Computer][SAN-1] Following WWPNs for [$($ResponseAliasSAN1."alias-name")] found: `n [$AliasWWPNsSAN1]" -ForegroundColor Green
                        if($AliasWWPNsSAN1[0] -eq $VMWWPNs[0]) {
                           Write-Host "[$Computer][SAN-1] First WWPN is correct one: [$($AliasWWPNsSAN1[0])]" -ForegroundColor Green
                           Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-1] First WWPN is correct one: [$($AliasWWPNsSAN1[0])]" $LogFile
                        } else {
                           Write-Host "[$Computer][SAN-1] First WWPN is NOT correct one: [$($AliasWWPNsSAN1[0])] instead of [$($VMWWPNs[0])]" -ForegroundColor Red
                           Invoke-FCLogToFile "[WARNING]" "[$Computer][SAN-1] First WWPN is NOT correct one: $($AliasWWPNsSAN1[0]) instead of $($VMWWPNs[0])" $LogFile
                        }
                        if($AliasWWPNsSAN1[1] -eq $VMWWPNs[2]) {
                           Write-Host "[$Computer][SAN-1] Second WWPN is correct one: [$($AliasWWPNsSAN1[1])]" -ForegroundColor Green
                           Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-1] Second WWPN is correct one: [$($AliasWWPNsSAN1[1])]" $LogFile
                        } else {
                           Write-Host "[$Computer][SAN-1] Second WWPN is NOT correct one: [$($AliasWWPNsSAN1[1])] instead of [$($VMWWPNs[2])]" -ForegroundColor Red
                           Invoke-FCLogToFile "[WARNING]" "[$Computer][SAN-1] Second WWPN is NOT correct one: [$($AliasWWPNsSAN1[1])] instead of [$($VMWWPNs[2])]" $LogFile
                        }
                        $AliasWWPNsSAN1 = @()
                        if($Resp_HTTP_Status_Zones_SAN1 -eq "200"){
                           foreach($ResponseZoneSAN1 in $ResponseZonesSAN1.Response.zone){
                              foreach($ResponseZoneMemeberSAN1 in $ResponseZoneSAN1."member-entry"."entry-name"){
                                 if ($ResponseZoneMemeberSAN1 -match $ResponseAliasSAN1."alias-name") {
                                    Write-Host "[$Computer][SAN-1] Alias [$($ResponseAliasSAN1."alias-name")] is a part of zone [$($ResponseZoneSAN1."zone-name")]" -ForegroundColor Magenta
                                    Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-1] Alias [$($ResponseAliasSAN1."alias-name")] is a part of zone [$($ResponseZoneSAN1."zone-name")]" $LogFile
                                 }
                              }
                           }
                        } else {
                           Write-Host "[$Computer][SAN-1] Zones GET FAILED" -ForegroundColor Red
                           Invoke-FCLogToFile "[ERROR]" "[$Computer][SAN-1] Zones GET FAILED" $LogFile
                        }
                     }
                  }
                  if($null -eq $AliasMatchSAN1) {
                     Write-Host "[$Computer][SAN-1] No existing aliases were found." -ForegroundColor Yellow
                     Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-1] No existing aliases were found." $LogFile
                  }
               } else {
                  Write-Host "[$Computer][SAN-1] Aliases GET FAILED" -ForegroundColor Red
                  Invoke-FCLogToFile "[ERROR]" "[$Computer][SAN-1] Aliases GET FAILED: no response" $LogFile
               }
               if($Resp_HTTP_Status_Alias_SAN2 -eq "200"){
                  $AliasMatchSAN2 = $null
                  foreach($ResponseAliasSAN2 in $ResponseAliasesSAN2.Response.alias){
                     if ($ResponseAliasSAN2."alias-name" -match $Computer) {
                        $AliasMatchSAN2 += $ResponseAliasSAN2."alias-name"
                        Write-Host "[$Computer][SAN-2] Alias matched by name found: [$($ResponseAliasSAN2."alias-name")]" -ForegroundColor Green
                        Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-2] Alias matched by name found: [$($ResponseAliasSAN2."alias-name")]" $LogFile
                        foreach($ResponseAliasMemeberSAN2 in $ResponseAliasSAN2."member-entry"."alias-entry-name"){
                           $AliasWWPNsSAN2 += $ResponseAliasMemeberSAN2
                        }
                        Write-Host "[$Computer][SAN-2] Following WWPNs for [$($ResponseAliasSAN2."alias-name")] found: `n [$AliasWWPNsSAN2]" -ForegroundColor Green
                        if($AliasWWPNsSAN2[0] -eq $VMWWPNs[1]) {
                           Write-Host "[$Computer][SAN-2] First WWPN is correct one: [$($AliasWWPNsSAN2[0])]" -ForegroundColor Green
                           Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-2] First WWPN is correct one: [$($AliasWWPNsSAN2[0])]" $LogFile
                        } else {
                           Write-Host "[$Computer][SAN-2] First WWPN is NOT correct one: [$($AliasWWPNsSAN2[0])] instead of [$($VMWWPNs[1])]" -ForegroundColor Red
                           Invoke-FCLogToFile "[WARNING]" "[$Computer][SAN-2] First WWPN is NOT correct one: [$($AliasWWPNsSAN2[0])] instead of [$($VMWWPNs[1])]" $LogFile
                        }
                        if($AliasWWPNsSAN2[1] -eq $VMWWPNs[3]) {
                           Write-Host "[$Computer][SAN-2] Second WWPN is correct one: [$($AliasWWPNsSAN2[1])]" -ForegroundColor Green
                           Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-2] Second WWPN is correct one: [$($AliasWWPNsSAN2[1])]" $LogFile
                        } else {
                           Write-Host "[$Computer][SAN-2] Second WWPN is NOT correct one: [$($AliasWWPNsSAN2[1])] instead of [$($VMWWPNs[3])]" -ForegroundColor Red
                           Invoke-FCLogToFile "[WARNING]" "[$Computer][SAN-2] Second WWPN is NOT correct one: [$($AliasWWPNsSAN2[1])] instead of [$($VMWWPNs[3])]" $LogFile
                        }
                        $AliasWWPNsSAN2 = @()
                        if($Resp_HTTP_Status_Zones_SAN2 -eq "200"){
                           foreach($ResponseZoneSAN2 in $ResponseZonesSAN2.Response.zone){
                              foreach($ResponseZoneMemeberSAN2 in $ResponseZoneSAN2."member-entry"."entry-name"){
                                 if ($ResponseZoneMemeberSAN2 -match $ResponseAliasSAN2."alias-name") {
                                    Write-Host "[$Computer][SAN-2] Alias [$($ResponseAliasSAN2."alias-name")] is a part of zone [$($ResponseZoneSAN2."zone-name")]" -ForegroundColor Magenta
                                    Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-2] Alias [$($ResponseAliasSAN2."alias-name")] is a part of zone [$($ResponseZoneSAN2."zone-name")]" $LogFile
                                 }
                              }
                           }
                        } else {
                           Write-Host "[$Computer][SAN-2] Zones GET FAILED" -ForegroundColor Red
                           Invoke-FCLogToFile "[ERROR]" "[$Computer][SAN-2] Zones GET FAILED" $LogFile
                        }
                     }
                  }
                  if($null -eq $AliasMatchSAN2) {
                     Write-Host "[$Computer][SAN-2] No existing aliases were found." -ForegroundColor Yellow
                     Invoke-FCLogToFile "[INFO]" "[$Computer][SAN-2] No existing aliases were found." $LogFile
                  }
               } else {
                  Write-Host "[$Computer]Aliases GET FAILED" -ForegroundColor Red
                  Invoke-FCLogToFile "[ERROR]" "[$Computer][SAN-2] Aliases GET FAILED: no response" $LogFile
               }
            }
            catch {
               Invoke-FCLogToFile "[ERROR]" "[GLOBAL] Failed to establish sessions via REST API" $LogFile
               Invoke-RestMethod 'https://SAN1LSD/rest/logout' -Method Post -Headers $Session_Headers_SAN1 -SkipCertificateCheck
               Invoke-RestMethod 'https://SAN2LSD/rest/logout' -Method Post -Headers $Session_Headers_SAN2 -SkipCertificateCheck
               throw "Failed to check aliases and wwpns via REST API"

            }
         }
         if($ActionType -match "Create-Zones"){

            ##############################################################################################################

            # Workflow is:
            # 0. Login to SAN
            # 1. Check Fabric Lock and Transaction Lock. If exists, then throw an exception.
            # 2. Get Effective Config Checksum
            # 3. Check aliases in Defined Config. If alias exists, then throw an exception.
            # 4. Compare Effective Config Zones with Defined Config Zones. If not equal, then throw an exception. (to-do)
            # 4.1 By names (to-do)
            # 4.2 By members (to-do)
            # 5. Create new alias within Defined Config
            # 6. Create new Peer zone within Defined Config
            # 7. Add new zone to Defined Config
            # 8. Save Defined Config using Effective Config Checksum from step 2
            # 9. Compare new Defined Config with Effective Config. The difference should be only in new alias and new zone.
            # 10. Get new Effective Config Checksum
            # 11. Activate new Effective Config Checksum from step 10
            # 12. Compare new Effective Config with Initial Effective Config. The difference should be only in new alias and new zone.
            # 13. Logout from SAN

            ##############################################################################################################

            # Check if Fabric Lock Principal Domain ID is 0 (no locks)
            try {
               $FabricLock = Get-FCFabricLock -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($FabricLock -eq "0") {
                  Write-Host "Fabric Lock Principal Domain ID is 0. We are good to go" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Fabric Lock Principal Domain ID is 0. We are good to go" -LogFile $LogFile
               }
               else {
                  Write-Host "Fabric Lock Principal Domain ID is [$FabricLock]. Please release lock and try again." -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Fabric Lock Principal Domain ID is [$FabricLock]. Please release lock and try again." -LogFile $LogFile
                  throw "Fabric Lock Principal Domain ID is [$FabricLock]. Please release lock and try again."
               }
            }
            catch {
               Write-Host "Failed to get Fabric Lock Principal Domain ID. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Fabric Lock Principal Domain ID. Error: $_" -LogFile $LogFile
               throw "Failed to get Fabric Lock Principal Domain ID. Error: $_"
            }

            # Check if Transaction Token is 0 (no locks)
            try {
               $TransactionToken = Get-FCTransactionToken -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($TransactionToken -eq "0") {
                  Write-Host "Transaction Token is 0. We are good to go" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Transaction Token is 0. We are good to go" -LogFile $LogFile
               }
               else {
                  Write-Host "Transaction Token is [$TransactionToken]. Please release lock and try again." -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Transaction Token is [$TransactionToken]. Please release lock and try again." -LogFile $LogFile
                  throw "Transaction Token is [$TransactionToken]. Please release lock and try again."
               }    
            }
            catch {
               Write-Host "Failed to get Transaction Token. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Transaction Token. Error: $_" -LogFile $LogFile
               throw "Failed to get Transaction Token. Error: $_"
            }

            # Get Initial full Effective Configuration
            try {
               $InitialEffectiveConfig = Get-FCEffectiveConfiguration -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($InitialEffectiveConfig) {
                  Write-Host "Initial Effective Configuration is captured" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Effective Configuration is captured:`n [$($InitialEffectiveConfig.OuterXml)]" -LogFile $LogFile
               }
               else {
                  Write-Host "Failed to get Initial Effective Configuration. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Initial Effective Configuration. Error: $_" -LogFile $LogFile
                  throw "Failed to get Initial Effective Configuration. Error: $_"
               }
           }
           catch {
               Write-Host "Failed to get Initial Effective Configuration. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Initial Effective Configuration. Error: $_" -LogFile $LogFile
               throw "Failed to get Initial Effective Configuration. Error: $_"
           }

           # Get Initial Defined Configuration
           try {
               $InitialDefinedConfig = Get-FCDefinedConfiguration -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($InitialDefinedConfig) {
                  Write-Host "Initial Defined Configuration is captured" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Defined Configuration is captured:`n [$($InitialDefinedConfig.OuterXml)]" -LogFile $LogFile
               }
               else {
                  Write-Host "Failed to get Initial Defined Configuration. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Initial Defined Configuration. Error: $_" -LogFile $LogFile
                  throw "Failed to get Initial Defined Configuration. Error: $_"
               }
            }
            catch {
               Write-Host "Failed to get Initial Defined Configuration. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Initial Defined Configuration. Error: $_" -LogFile $LogFile
               throw "Failed to get Initial Defined Configuration. Error: $_"
            }

            # Get Effective Configuration Checksum
            try {
               $InitialChecksum = Get-FCEffectiveConfigChecksum -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($InitialChecksum) {
                  Write-Host "Effective Configuration Checksum is [$InitialChecksum]" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Effective Configuration Checksum is [$InitialChecksum]" -LogFile $LogFile
               }
               else {
                  Write-Host "Failed to get Effective Configuration Checksum. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Effective Configuration Checksum. Error: $_" -LogFile $LogFile
                  throw "Failed to get Effective Configuration Checksum. Error: $_"
               }
           }
           catch {
               Write-Host "Failed to get Effective Configuration Checksum. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Effective Configuration Checksum. Error: $_" -LogFile $LogFile
               throw "Failed to get Effective Configuration Checksum. Error: $_"
           }

           # Get Effective Configuration Name
           try {
               $EffectiveConfigName = Get-FCEffectiveConfigName -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               Write-Host "Effective Configuration Name is [$EffectiveConfigName]" -ForegroundColor Green
               Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Effective Configuration Name is [$EffectiveConfigName]" -LogFile $LogFile
            }
            catch {
               Write-Host "Failed to get Effective Configuration Name. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Effective Configuration Name. Error: $_" -LogFile $LogFile
               throw "Failed to get Effective Configuration Name. Error: $_"
            }

            # Perform Alias Check V2
            try {
               $AliasCheckResults = Invoke-FCAliasCheckV2 -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -AliasName $Computer -WWPNs $VMWWPNs_All -LogFile $LogFile
               if ($AliasCheckResults[0] -eq "5") {
                  $AliasAlreadyExists = $false
                  Write-Host "Alias Check passed. Alias [$Computer] doesn't exists. We are good to go." -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Alias Check passed. Alias [$Computer] doesn't exists. We are good to go." -LogFile $LogFile
               }
               elseif ($AliasCheckResults[0] -eq "3") {
                  Write-Host "Alias Check passed. Alias [$Computer] exists but all WWPNs are different. New WWPNs will be added to existing alias. Please double-check it after" -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Alias Check passed. Alias [$Computer] exists but all WWPNs are different. New WWPNs will be added to existing alias. Please double-check it after" -LogFile $LogFile
               }
               elseif ($AliasCheckResults[0] -eq "2") {
                  $AliasAlreadyExists = $true
                  Write-Host "Alias Check passed. Alias [$Computer] exists with correct WWPNs. New alias won't be created." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Alias Check passed. Alias [$Computer] exists with correct WWPNs. New alias won't be created." -LogFile $LogFile
               }
               else {
                  Write-Host "Alias Check failed. Result is [$($AliasCheckResults[0])].`n1 - means alias exists but with one incorrect WWPN.`n2 - means exists with correct WWPNs`n3 - means exists but all WWPNs are different" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Alias Check failed. Result is [$($AliasCheckResults[0])].`n1 - means alias exists but with one incorrect WWPN.`n2 - means exists with correct WWPNs`n3 - means exists but all WWPNs are different" -LogFile $LogFile
                  throw "Alias Check failed. Result is [$($AliasCheckResults[0])]. 1 - means alias exists but with incorrect WWPNs. 2 - means exists with correct WWPNs. 3 - means exists but all WWPNs are different"
               }
            }
            catch {
               Write-Host "Failed to perform Alias Check. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to perform Alias Check. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to perform Alias Check. Error: $_"
            }

            # Create new alias within Defined Configuration
            if ($AliasAlreadyExists -eq $false) {
               try {
                  $CreateAlias = New-FCAlias -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -ComputerName $Computer -WWPNs $VMWWPNs -LogFile $LogFile
                  if ($CreateAlias) {
                     Write-Host "Alias [$Computer] created successfully" -ForegroundColor Green
                     Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Alias [$Computer] created successfully" -LogFile $LogFile
                  }
                  else {
                     Write-Host "Failed to create Alias [$Computer]" -ForegroundColor Red
                     Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to create Alias [$Computer]" -LogFile $LogFile
                     Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                     Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                     throw "Failed to create Alias [$Computer]"
                  }   
               }
               catch {
                  Write-Host "Failed to create Alias [$Computer]. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to create Alias [$Computer]. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to create Alias [$Computer]. Error: $_"
               }
            }

            # Check if Zone exists in Defined Configuration
            $PeerZoneName = "PRZ_" + $StorageArrayName + "_" + $ZoneHostGroupName + "_01"
            try {
               $ZoneCheck = Invoke-FCZoneCheckDefinedConfiguration -SAN $SAN_Name -InitialDefinedConfig $InitialDefinedConfig -ZoneName $PeerZoneName -LogFile $LogFile
               if ($ZoneCheck) {
                  Write-Host "[$SAN_Name] Zone [$PeerZoneName] exists. New WWPNs will be added to it." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Zone [$PeerZoneName] exists. New WWPNs will be added to it." -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Zone [$PeerZoneName] doesn't exists and it will be created" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Zone [$PeerZoneName] doesn't exists and it will be created" -LogFile $LogFile
               }
            }
            catch {
                  Write-Host "Failed to check if Zone [$PeerZoneName] exists. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to check if Zone [$PeerZoneName] exists. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to check if Zone [$PeerZoneName] exists. Error: $_"
            }

            # Check if Zone exists in Effective Configuration
            try {
               $ZoneCheck = Invoke-FCZoneCheckEffectiveConfiguration -SAN $SAN_Name -InitialEffectiveConfig $InitialEffectiveConfig -ZoneName $PeerZoneName -LogFile $LogFile
               if ($ZoneCheck) {
                  Write-Host "[$SAN_Name] Zone [$PeerZoneName] exists. New WWPNs will be added to it." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Zone [$PeerZoneName] exists. New WWPNs will be added to it." -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Zone [$PeerZoneName] doesn't exists and it will be created" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Zone [$PeerZoneName] doesn't exists and it will be created" -LogFile $LogFile
               }
            }
            catch {
               Write-Host "Failed to check if Zone [$PeerZoneName] exists. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to check if Zone [$PeerZoneName] exists. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to check if Zone [$PeerZoneName] exists. Error: $_"
            }

            # Create new Peer Zone within Defined Configuration
            try {
               $PeerZoneName = "PRZ_" + $StorageArrayName + "_" + $ZoneHostGroupName + "_01"
               if ($ZoneCheck) {
                  $CreatePeerZone = New-FCPeerZone -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -PeerZoneName $PeerZoneName -PeerZoneMembers $VMWWPNs -LogFile $LogFile 
               }
               else {
                  $CreatePeerZone = New-FCPeerZone -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -PeerZoneName $PeerZoneName -PeerZoneMembers $VMWWPNs -PeerZonePrincipals $StorageArrayName_WWPNs -LogFile $LogFile
               }
               if ($CreatePeerZone) {
                  Write-Host "[$SAN_Name] Peer Zone [$PeerZoneName] created successfully" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Peer Zone [$PeerZoneName] created successfully" -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Failed to create Peer Zone [$PeerZoneName]" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to create Peer Zone [$PeerZoneName]" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to create Peer Zone [$PeerZoneName]"
               }   
            }
            catch {
                  Write-Host "Failed to create Peer Zone [$PeerZoneName]. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to create Peer Zone [$PeerZoneName]. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to create Peer Zone [$PeerZoneName]. Error: $_"
            }

            # Add new Peer Zone to Defined Active Configuration
            try {
               if ($ZoneCheck) {
                  Write-Host "[$SAN_Name] Peer Zone [$PeerZoneName] is already exists Defined Active Configuration [$EffectiveConfigName]. No need to add it." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Peer Zone [$PeerZoneName] is already exists in Defined Active Configuration [$EffectiveConfigName]. No need to add it." -LogFile $LogFile
               }
               else {
                  $AddPeerZone = Add-FCZoneToDefinedConfig -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -ZoneNames $PeerZoneName -ConfigName $EffectiveConfigName -LogFile $LogFile
                  if ($AddPeerZone) {
                     Write-Host "[$SAN_Name] Peer Zone [$PeerZoneName] added to Defined Active Configuration [$EffectiveConfigName] successfully" -ForegroundColor Green
                     Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Peer Zone [$PeerZoneName] added to Defined Configuration [$EffectiveConfigName] successfully" -LogFile $LogFile
                  }
                  else {
                     Write-Host "[$SAN_Name] Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]" -ForegroundColor Red
                     Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]" -LogFile $LogFile
                     Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                     Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                     throw "Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]"
                  }
               }  
            }
            catch {
                  Write-Host "Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to add Peer Zone [$PeerZoneName] to Defined Configuration [$EffectiveConfigName]. Error: $_"
            }

            # Get Final Defined Configuration
            try {
               $FinalDefinedConfig = Get-FCDefinedConfiguration -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($FinalDefinedConfig) {
                  Write-Host "Final Defined Configuration is captured" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Defined Configuration is captured:`n [$($FinalDefinedConfig.OuterXml)]" -LogFile $LogFile
               }
               else {
                  Write-Host "Failed to get Final Defined Configuration. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Final Defined Configuration. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to get Final Defined Configuration. Error: $_"
               }
            }
            catch {
                  Write-Host "Failed to get Final Defined Configuration. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Final Defined Configuration. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to get Final Defined Configuration. Error: $_"
            }

            # Compare Initial and Final Defined Configuration
            try {
               $CompareDefinedConfig = Invoke-FCConfigComparison -InitialConfig $InitialDefinedConfig -FinalConfig $FinalDefinedConfig -EffectiveConfigName $EffectiveConfigName -SAN $SAN_Name -WWPNs $VMWWPNs -LogFile $LogFile -ConfigToCheck "DeffinedConfig"
               if ($CompareDefinedConfig -eq "1") {
                  Write-Host "[$SAN_Name] Defined Configuration comparison completed successfully. Configs looks good." -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Defined Configuration comparison completed successfully." -LogFile $LogFile
               }
               elseif ($CompareDefinedConfig -eq "2") {
                  Write-Host "[$SAN_Name] Defined Configuration comparison completed successfully. Nothing changed from Zone point of view. Seems only WWPNs added. Please double check configs after." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[WARNING]" -LogMessage "[$SAN_Name] Defined Configuration comparison completed successfully. Nothing changed from Zone point of view. Seems only WWPNs added. Please double check configs after." -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Defined Configuration comparison failed. Please check configs!!!" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Defined Configuration comparison failed. Please check configs!!!" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Defined Configuration comparison failed. Please check configs before move forward!!!"
               }    
            }
            catch {
               Write-Host "Defined Configuration comparison failed. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Defined Configuration comparison failed. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Defined Configuration comparison failed. Error: $_"
            }

            # Save Defined Configuration to Effective Configuration
            try {
               $SaveDefinedConfig = Invoke-FCSaveDefinedConfig -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -EffectiveConfigChecksum $InitialChecksum -LogFile $LogFile
               if ($SaveDefinedConfig) {
                  Write-Host "[$SAN_Name] Defined Configuration [$EffectiveConfigName] saved to Effective Configuration successfully" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN1_Name] Defined Configuration [$EffectiveConfigName] saved to Effective Configuration successfully" -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration"
               }    
            }
            catch {
               Write-Host "Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to save Defined Configuration [$EffectiveConfigName] to Effective Configuration. Error: $_"
            }

            # Get New Effective Configuration Checksum
            try {
               $NewChecksum = Get-FCEffectiveConfigChecksum -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -LogFile $LogFile
               if ($NewChecksum) {
                  Write-Host "[$SAN_Name] New Effective Configuration Checksum [$NewChecksum] retrieved successfully" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] New Effective Configuration Checksum [$NewChecksum] retrieved successfully" -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Failed to retrieve New Effective Configuration Checksum" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to retrieve New Effective Configuration Checksum" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to retrieve New Effective Configuration Checksum"
               }    
            }
            catch {
               Write-Host "Failed to retrieve New Effective Configuration Checksum. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to retrieve New Effective Configuration Checksum. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to retrieve New Effective Configuration Checksum. Error: $_"
            }

            # Activate New Effective Configuration
            try {
               $ActivateEffectiveConfig = Invoke-FCActivateDefinedConfig -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name -EffectiveConfigName $EffectiveConfigName -EffectiveConfigChecksum $NewChecksum -LogFile $LogFile
               if ($ActivateEffectiveConfig) {
                  Write-Host "[$SAN_Name] New Effective Configuration activated successfully" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] New Effective Configuration activated successfully" -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Failed to activate New Effective Configuration" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to activate New Effective Configuration" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to activate New Effective Configuration"
               }    
            }
            catch {
               Write-Host "Failed to activate New Effective Configuration. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to activate New Effective Configuration. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to activate New Effective Configuration. Error: $_"
            }

            # Get Final Effective Configuration
            try {
               $FinalEffectiveConfig = Get-FCEffectiveConfiguration -Session_Headers_SAN $Session_Headers_SAN -SAN $SAN_Name
               if ($FinalEffectiveConfig) {
                  Write-Host "Final Effective Configuration is captured" -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Effective Configuration is captured:`n [$($FinalEffectiveConfig.OuterXml)]" -LogFile $LogFile
               }
               else {
                  Write-Host "Failed to get Final Effective Configuration. Error: $_" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Final Effective Configuration. Error: $_" -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
                  Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
                  throw "Failed to get Final Effective Configuration. Error: $_"
               }
            }
            catch {
               Write-Host "Failed to get Final Effective Configuration. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Failed to get Final Effective Configuration. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Failed to get Final Effective Configuration. Error: $_"
            }

            # Compare Initial and Final Effective Configuration
            try {
               $CompareEffectiveConfig = Invoke-FCConfigComparison -InitialConfig $InitialEffectiveConfig -FinalConfig $FinalEffectiveConfig -EffectiveConfigName $EffectiveConfigName -SAN $SAN_Name -WWPNs $VMWWPNs -LogFile $LogFile -ConfigToCheck "EffectiveConfig"
               if ($CompareEffectiveConfig -eq "1") {
                  Write-Host "[$SAN_Name] Effective Configuration comparison completed successfully. Configs looks good." -ForegroundColor Green
                  Invoke-FCLogToFile -LogMessageType "[INFO]" -LogMessage "[$SAN_Name] Effective Configuration comparison completed successfully." -LogFile $LogFile
               }
               elseif ($CompareEffectiveConfig -eq "2") {
                  Write-Host "[$SAN_Name] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you haven't activated new configuration yet or added only WWPNs." -ForegroundColor Yellow
                  Invoke-FCLogToFile -LogMessageType "[WARNING]" -LogMessage "[$SAN_Name] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you haven't activated new configuration yet." -LogFile $LogFile
               }
               else {
                  Write-Host "[$SAN_Name] Effective Configuration comparison failed. Please check configs!!!" -ForegroundColor Red
                  Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Effective Configuration comparison failed. Please check configs!!!" -LogFile $LogFile
               }    
            }
            catch {
               Write-Host "Effective Configuration comparison failed. Error: $_" -ForegroundColor Red
               Invoke-FCLogToFile -LogMessageType "[ERROR]" -LogMessage "[$SAN_Name] Effective Configuration comparison failed. Error: $_" -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
               Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
               throw "Effective Configuration comparison failed. Error: $_"
            }
         }
         if($ActionType -match "PrepareConfig") {

            switch -Exact ($StorageArrayName)
            {
               'TargetStorageName01' {
                  $SAN1_StoragePorts = $SAN1_TargetStorageName01_Ports
                  $SAN2_StoragePorts = $SAN2_TargetStorageName01_Ports
               }
               'TargetStorageName02' {
                  $SAN1_StoragePorts = $SAN1_TargetStorageName02_Ports
                  $SAN2_StoragePorts = $SAN2_TargetStorageName02_Ports
               }
               'TargetStorageName03' {
                  $SAN1_StoragePorts = $SAN1_TargetStorageName03_Ports
                  $SAN2_StoragePorts = $SAN2_TargetStorageName03_Ports
               }
               'TargetStorageName04' {
                  $SAN1_StoragePorts = $SAN1_TargetStorageName04_Ports
                  $SAN2_StoragePorts = $SAN2_TargetStorageName04_Ports
               }
               'TargetStorageName05' {
                  $SAN1_StoragePorts = $SAN1_TargetStorageName05_Ports
                  $SAN2_StoragePorts = $SAN2_TargetStorageName05_Ports
               }
            }

            $FC_Zone_Name = "PRZ_" + $StorageArrayName[0] + "_" + $ZoneHostGroupName + "_01"

            switch -Exact ($FC_ZoneOption)
            {
               'Create' {
                  $SAN1_Config = "
alicreate """ + $Computer + "_vFC1"",""" + $VMWWPNs_All[0] + ";" + $VMWWPNs_All[2] + """
zonecreate --peerzone """ + $FC_Zone_Name + """ -principal """ + $SAN1_StoragePorts[0] + ";" + $SAN1_StoragePorts[1] + `
";" + $SAN1_StoragePorts[2] + ";" + $SAN1_StoragePorts[3] + """ -members """ + $Computer + "_vFC1""
cfgadd ITSS_SAN_1_LSD,""" + $FC_Zone_Name + """
cfgenable ITSS_SAN_1_LSD"
                  $SAN2_Config = "
alicreate """ + $Computer + "_vFC2"",""" + $VMWWPNs_All[1] + ";" + $VMWWPNs_All[3] + """ 
zonecreate --peerzone """ + $FC_Zone_Name + """ -principal """ + $SAN2_StoragePorts[0] + ";" + $SAN2_StoragePorts[1] + `
";" + $SAN2_StoragePorts[2] + ";" + $SAN2_StoragePorts[3] + """ -members """ + $Computer + "_vFC2""
cfgadd ITSS_SAN_2_LSD,""" + $FC_Zone_Name + """
cfgenable ITSS_SAN_2_LSD
"
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host "[SAN-1] Config - Please double check everything and apply commands line by line" -ForegroundColor Magenta
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host $SAN1_Config "`n" -ForegroundColor Yellow
                  
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host "[SAN-2] Config - Please double check everything and apply commands line by line" -ForegroundColor Magenta
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host $SAN2_Config -ForegroundColor Yellow

                  Invoke-FCLogToFile "[INFO]" "[GLOBAL][$Computer] CREATE option has been choosen for PrepareConfig" $LogFile
                  Invoke-FCLogToFile "[INFO]" "[SAN-1][$Computer] $SAN1_Config" $LogFile
                  Invoke-FCLogToFile "[INFO]" "[SAN-2][$Computer] $SAN2_Config" $LogFile
               }
               'Add' {
                # The formatting below is done specifically for pretty output to the console
                  $SAN1_Config = "
alicreate """ + $Computer + "_vFC1"",""" + $VMWWPNs_All[0] + ";" + $VMWWPNs_All[2] + """ 
zoneadd --peerzone """ + $FC_Zone_Name + """ -members """ + $Computer + "_vFC1""
cfgenable ITSS_SAN_1_LSD"
                        
                  $SAN2_Config = "
alicreate """ + $Computer + "_vFC2"",""" + $VMWWPNs_All[1] + ";" + $VMWWPNs_All[3] + """ 
zoneadd --peerzone """ + $FC_Zone_Name + """ -members """ + $Computer + "_vFC2""
cfgenable ITSS_SAN_2_LSD"

                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host "[SAN-1] Config - Please double check everything and apply commands line by line" -ForegroundColor Magenta
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host $SAN1_Config "`n" -ForegroundColor Yellow

                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host "[SAN-2] Config - Please double check everything and apply commands line by line" -ForegroundColor Magenta
                  Write-Host ('-'*80) -ForegroundColor Green
                  Write-Host $SAN2_Config "`n" -ForegroundColor Yellow

                  Invoke-FCLogToFile "[INFO]" "[GLOBAL][$Computer] ADD option has been choosen for PrepareConfig" $LogFile
                  Invoke-FCLogToFile "[INFO]" "[SAN-1][$Computer] $SAN1_Config" $LogFile
                  Invoke-FCLogToFile "[INFO]" "[SAN-2][$Computer] $SAN2_Config" $LogFile
               }
               default {
                  Invoke-FCLogToFile "[WARNING]" "[GLOBAL] Incorrect option choosed for PrepareConfig: $FC_ZoneOption" $LogFile
                  throw "Incorrect option" 
               }
            }
         }
      }
   }
   End
   {
      # REST API Log OUT
      if (($ActionType -match "ChecksOnly") -or ($ActionType -match "Create-Zones")) {
         Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN1 -URL $LogoutUrlSAN1 -LogFile $LogFile
         Invoke-FCSwitchLogout -SessionHeaders $Session_Headers_SAN2 -URL $LogoutUrlSAN2 -LogFile $LogFile
      }
      Write-Host ('-'*80) -ForegroundColor Yellow
      Write-Host "End Block" -ForegroundColor Yellow
      Write-Host ('-'*80) -ForegroundColor Yellow
   }
}