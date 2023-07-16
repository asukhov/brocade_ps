# Introduction
When I wrote this code, only God and I knew how it worked. Now, only God knows it! Maybe Github Copilot will help you :)
This module was written to automate some FibreChannel related tasks. I've removed parts not related to Brocade switches configuration. But if something left just ignore it.
This module uses Brocade REST API and some functions required specific PowerShell version. See details below.
## Quick Overview
**FibreChannelTools** contains following functions:
1. **Invoke-FCLogToFile** - service function for logging purposes. Other module functions heavily uses it to log everything. By default it stores logs into *C:\Users\Public\Documents\FibreChannelTools.txt*.
This function PowerShell agnostic. 

2. **Get-FCVMWWPNs** - function which collects WWPNs of Hyper-V VMs. Can be run independently. This function PowerShell agnostic.

3. **Invoke-FCConfiguration** - function which checks existing SAN configuration or prepare config for new VMs. This function **requires PowerShell 7**.

## Installation process
To make it work, you have to:
- install or import following module:
    ```powershell
    Import-Module C:\...\FibreChannelTools\FibreChannelTools.psm1
    ```

Additionally, to be able run FibreChannel SAN functions you should have PS7, because FC config uses PS7 REST API cmdlets to query SAN switches.
PS7 could be installed and used in parallel with PS5 without any issues.

# Getting Started
## 1. Get-FCVMWWPNs - get WWPNs of Hyper-V VM
To get VM WWPNs we can use **Get-FCVMWWPNs** function:
```powershell
PS C:\WINDOWS\system32> Import-Module FibreChannelTools
PS C:\WINDOWS\system32> Get-FCVMWWPNs -ComputerName VMNAME00
[VMNAME00] SAN-1 Primary WWPN [c0:03:ff:d8:07:8f:00:00]
[VMNAME00] SAN-1 Secondary WWPN [c0:03:ff:d8:07:8f:00:01]
[VMNAME00] SAN-2 Primary WWPN [c0:03:ff:d8:07:8f:00:02]
[VMNAME00] SAN-2 Secondary WWPN [c0:03:ff:d8:07:8f:00:03]
```
## 2. Invoke-FCConfiguration - check existing SAN configuration
Before prepare config you can check configuration for new or existing Hyper-V VM. This function will connects to both fabrics and check current status for VMs. Also it's worth to run this checks after applying configuration, to check that everything configured properly.
This function requires PowerShell 7. Also this function has several mandatory parameters (even for checks). Some of them not in use for checks, but you still have to provide them.
Additionally, you can provide several Computer Names:
```powershell
PS C:\WINDOWS\system32> pwsh
PowerShell 7.2.5
Copyright (c) Microsoft Corporation.

https://aka.ms/powershell
Type 'help' to get help.

PS C:\Windows\System32> Import-Module FibreChannelTools
PS C:\Windows\System32> Invoke-FCConfiguration -ComputerName VMNAME00, VMNAME01 -ActionType ChecksOnly -StorageArrayName TargetStorageName01
--------------------------------------------------------------------------------
Computer Name: [VMNAME00 VMNAME01]
Action Type: [ChecksOnly]
Log file location: [C:\Users\Public\Documents\FibreChannelTools.txt]
Storage Array Name: [TargetStorageName01]
--------------------------------------------------------------------------------

Trying to connect to SAN-1. Resp_HTTP_Status: [200]
Generating session key for SAN-1
Response
--------
@{switch-parameters=}
@{switch-parameters=}
Trying to connect to SAN-2. Resp_HTTP_Status: [200]
Generating session key for SAN-2
[VMNAME00] SAN-1 Primary WWPN [c0:03:ff:d8:07:8f:00:00]
[VMNAME00] SAN-1 Secondary WWPN [c0:03:ff:d8:07:8f:00:01]
[VMNAME00] SAN-2 Primary WWPN [c0:03:ff:d8:07:8f:00:02]
[VMNAME00] SAN-2 Secondary WWPN [c0:03:ff:d8:07:8f:00:03]
[VMNAME00][SAN-1] Alias matched by name found: [VMNAME00_vFC1]
[VMNAME00][SAN-1] Following WWPNs for [VMNAME00_vFC1] found:
 [c0:03:ff:d8:07:8f:00:00 c0:03:ff:d8:07:8f:00:01]
[VMNAME00][SAN-1] First WWPN is correct one: [c0:03:ff:d8:07:8f:00:00]
[VMNAME00][SAN-1] Second WWPN is correct one: [c0:03:ff:d8:07:8f:00:01]
[VMNAME00][SAN-1] Alias [VMNAME00_vFC1] is a part of zone [PRZ_TargetStorageName02_VMNAME01]
[VMNAME00][SAN-2] Alias matched by name found: [VMNAME00_vFC2]
[VMNAME00][SAN-2] Following WWPNs for [VMNAME00_vFC2] found:
 [c0:03:ff:d8:07:8f:00:02 c0:03:ff:d8:07:8f:00:03]
[VMNAME00][SAN-2] First WWPN is correct one: [c0:03:ff:d8:07:8f:00:02]
[VMNAME00][SAN-2] Second WWPN is correct one: [c0:03:ff:d8:07:8f:00:03]
[VMNAME00][SAN-2] Alias [VMNAME00_vFC2] is a part of zone [PRZ_TargetStorageName02_VMNAME01]
[VMNAME01] SAN-1 Primary WWPN [c0:03:ff:7d:f9:5f:00:1a]
[VMNAME01] SAN-1 Secondary WWPN [c0:03:ff:7d:f9:5f:00:1b]
[VMNAME01] SAN-2 Primary WWPN [c0:03:ff:7d:f9:5f:00:1c]
[VMNAME01] SAN-2 Secondary WWPN [c0:03:ff:7d:f9:5f:00:1d]
[VMNAME01][SAN-1] Alias matched by name found: [VMNAME01_vFC1]
[VMNAME01][SAN-1] Following WWPNs for [VMNAME01_vFC1] found:
 [c0:03:ff:7d:f9:5f:00:1a c0:03:ff:7d:f9:5f:00:1b]
[VMNAME01][SAN-1] First WWPN is correct one: [c0:03:ff:7d:f9:5f:00:1a]
[VMNAME01][SAN-1] Second WWPN is correct one: [c0:03:ff:7d:f9:5f:00:1b]
[VMNAME01][SAN-1] Alias [VMNAME01_vFC1] is a part of zone [PRZ_TargetStorageName03_VMNAME01_01]
[VMNAME01][SAN-2] Alias matched by name found: [VMNAME01_vFC2]
[VMNAME01][SAN-2] Following WWPNs for [VMNAME01_vFC2] found:
 [c0:03:ff:7d:f9:5f:00:1c c0:03:ff:7d:f9:5f:00:1d]
[VMNAME01][SAN-2] First WWPN is correct one: [c0:03:ff:7d:f9:5f:00:1c]
[VMNAME01][SAN-2] Second WWPN is correct one: [c0:03:ff:7d:f9:5f:00:1d]
[VMNAME01][SAN-2] Alias [VMNAME01_vFC2] is a part of zone [PRZ_TargetStorageName03_VMNAME01_01]


[SAN-1] Session closed. Response: [204]
[SAN-2] Session closed. Response: [204]
--------------------------------------------------------------------------------
End Block
--------------------------------------------------------------------------------
```

## 3. Invoke-FCConfiguration - prepare SAN configuration
By using **Invoke-FCConfiguration** you can prepare commands which you will need to apply to configure SAN switches.
To prepare configuration commands you will need to provide additional data:
* Cluster\HostGroup name - it will be used for Zone name. If you create new zones for cluster you need to provide cluster name. If you create new zones for standalone host you need to provide its name. If you want to add new servers to existing zones you need to provide cluster name as well.
* Are you creating new zones or amend existing ones.
This function won't check if there any similar zones already exists or not. You have to check it yourself. This function will only prepare config commands for you. 

In below example we prepare config for two VMs which will be part of the same cluster (VMCluster01): 
```powershell
PS C:\Windows\System32> Invoke-FCConfiguration -ComputerName VMNAME00, VMNAME01 -ActionType PrepareConfig -StorageArrayName TargetStorageName01
--------------------------------------------------------------------------------
Computer Name: [VMNAME00 VMNAME01]
Action Type: [PrepareConfig]
Log file location: [C:\Users\Public\Documents\FibreChannelTools.txt]
Storage Array Name: [TargetStorageName01]
--------------------------------------------------------------------------------
[VMNAME00] SAN-1 Primary WWPN [c0:03:ff:d8:07:8f:00:00]
[VMNAME00] SAN-1 Secondary WWPN [c0:03:ff:d8:07:8f:00:01]
[VMNAME00] SAN-2 Primary WWPN [c0:03:ff:d8:07:8f:00:02]
[VMNAME00] SAN-2 Secondary WWPN [c0:03:ff:d8:07:8f:00:03]
Please enter Cluster\HostGroup name (it will be used for Zone name):
VMCluster01
Create new Zone PRZ_TargetStorageName01_VMCluster01_01 (Create) for VMNAME00 or Add VMNAME00 to Existing Zone PRZ_TargetStorageName01_VMCluster01_01 (Add)? (Create\Add):
Create
--------------------------------------------------------------------------------
[SAN-1] Config - Please double check everything and apply commands line by line
--------------------------------------------------------------------------------

alicreate "VMNAME00_vFC1","c0:03:ff:d8:07:8f:00:00;c0:03:ff:d8:07:8f:00:01"
zonecreate --peerzone "PRZ_TargetStorageName01_VMCluster01_01" -principal "TargetStorageName01-CT0FC0;TargetStorageName01-CT0FC2;TargetStorageName01-CT1FC0;TargetStorageName01-CT1FC2" -members "VMNAME00_vFC1"
cfgadd SAN_1_LSD,"PRZ_TargetStorageName01_VMCluster01_01"
cfgenable SAN_1_LSD

--------------------------------------------------------------------------------
[SAN-2] Config - Please double check everything and apply commands line by line
--------------------------------------------------------------------------------

alicreate "VMNAME00_vFC2","c0:03:ff:d8:07:8f:00:02;c0:03:ff:d8:07:8f:00:03"
zonecreate --peerzone "PRZ_TargetStorageName01_VMCluster01_01" -principal "TargetStorageName01-CT0FC1;TargetStorageName01-CT0FC3;TargetStorageName01-CT1FC1;TargetStorageName01-CT1FC3" -members "VMNAME00_vFC2"
cfgadd SAN_2_LSD,"PRZ_TargetStorageName01_VMCluster01_01"
cfgenable SAN_2_LSD

[VMNAME01] SAN-1 Primary WWPN [c0:03:ff:7d:f9:5f:00:1a]
[VMNAME01] SAN-1 Secondary WWPN [c0:03:ff:7d:f9:5f:00:1b]
[VMNAME01] SAN-2 Primary WWPN [c0:03:ff:7d:f9:5f:00:1c]
[VMNAME01] SAN-2 Secondary WWPN [c0:03:ff:7d:f9:5f:00:1d]
Please enter Cluster\HostGroup name (it will be used for Zone name):
VMCluster01
Create new Zone PRZ_TargetStorageName01_VMCluster01_01 (Create) for VMNAME01 or Add VMNAME01 to Existing Zone PRZ_TargetStorageName01_VMCluster01_01 (Add)? (Create\Add):
Add
--------------------------------------------------------------------------------
[SAN-1] Config - Please double check everything and apply commands line by line
--------------------------------------------------------------------------------

alicreate "VMNAME01_vFC1","c0:03:ff:7d:f9:5f:00:1a;c0:03:ff:7d:f9:5f:00:1b"
zoneadd --peerzone "PRZ_TargetStorageName01_VMCluster01_01" -members "VMNAME01_vFC1"
cfgenable SAN_1_LSD

--------------------------------------------------------------------------------
[SAN-2] Config - Please double check everything and apply commands line by line
--------------------------------------------------------------------------------

alicreate "VMNAME01_vFC2","c0:03:ff:7d:f9:5f:00:1c;c0:03:ff:7d:f9:5f:00:1d"
zoneadd --peerzone "PRZ_TargetStorageName01_VMCluster01_01-members "VMNAME01_vFC2"
cfgenable SAN_2_LSD

--------------------------------------------------------------------------------
End Block
--------------------------------------------------------------------------------

```
## 4. Invoke-FCConfiguration - automated SAN configuration
By using **Invoke-FCConfiguration** with *Create-Zones* as an **ActionType** value. All configuration will be done via Brocade SAN Switches REST API. Below is the workflow:
* Login to SAN Switches.
* Check Fabric Lock and Transaction Lock. If exists, then throw an exception.
* Get Effective Config Checksum
* Check aliases in Defined Config. If alias exists but with different WWPNs then throw an exception.
* Create new alias within Defined Config or add new WWPNs to the existing one.
* Check Peer zone. If zone already exists VM WWPNs will be added to it.
* Create new Peer zone within Defined Config.
* Add new zone to Defined Config.
* Save Defined Config using Effective Config Checksum from step above.
* Compare new Defined Config with Effective Config. The difference should be only in new zone.
* Get new Effective Config Checksum
* Activate new Effective Config Checksum from previouse step
* Compare new Effective Config with Initial Effective Config. The difference should be only in new zone.
* Logout from SAN Switches.

To configure SAN Switch with **Invoke-FCConfiguration** you have to provide additional parameters:
* **StorageArrayName** - target storage to which your VM should have access.
* **SAN** - specify fabric for configuration. It could be SAN1 or SAN2.
* **ZoneHostGroupName** - it will be used for Zone name. If you create new zones for cluster you need to provide cluster name. If you create new zones for standalone host you need to provide its name. If you want to add new servers to existing zones you need to provide cluster name as well.

This function can configure ONLY one SAN at time. You should check everything before perfrom second SAN configuration.

Below an example for standalone node (VMName03) alias not exists for it but zone is already there:
```powershell
PS C:\WINDOWS\system32> Invoke-FCConfiguration -ComputerName VMName03 -ActionType Create-Zones -StorageArrayName TargetStorageName01 -SAN SAN1
Enter the name of the zone host group (must be in CAPITAL, less or equal 15 characters, accept only letters, digits and hyphen. First character should be a letter): VMName03
--------------------------------------------------------------------------------
Client name Name: [VMName03]
Action Type: [Create-Zones]
Log file location: [C:\Users\Public\Documents\FibreChannelTools.txt]
Storage Array Name: [TargetStorageName01]

Trying to connect to SAN-1. Resp_HTTP_Status: [200]
Generating session key for SAN-1
xml           Response
---           --------
version="1.0" Response
version="1.0" Response
Trying to connect to SAN-2. Resp_HTTP_Status: [200]
Generating session key for SAN-2
[VMName03] SAN-1 Primary WWPN [c0:03:ff:7d:f9:5f:00:b4]
[VMName03] SAN-1 Secondary WWPN [c0:03:ff:7d:f9:5f:00:b5]
[VMName03] SAN-2 Primary WWPN [c0:03:ff:7d:f9:5f:00:b6]
[VMName03] SAN-2 Secondary WWPN [c0:03:ff:7d:f9:5f:00:b7]
Fabric Lock Principal Domain ID is 0. We are good to go
Transaction Token is 0. We are good to go
[SAN1LSD] Effective Configuration retrieved successfully
Initial Effective Configuration is captured
[SAN1LSD] Defined Configuration retrieved successfully
Initial Defined Configuration is captured
Effective Configuration Checksum is [9d914122a0d460dc59e534f7e434d6f5]
Effective Configuration Name is [SAN_1_LSD]
[VMName03][SAN1LSD] No existing aliases were found. We are good to go.
Alias Check passed. Alias [VMName03] doesnt exists. We are good to go.
[SAN1LSD] Alias [VMName03_vFC1] created successfully
Alias [VMName03] created successfully
[SAN1LSD] Zone matched by name found: [PRZ_TargetStorageName01_VMName03_01]. New WWPNs will be added to it.
[SAN1LSD] Zone [PRZ_TargetStorageName01_VMName03_01] exists. New WWPNs will be added to it.
[SAN1LSD] Zone matched by name found in Effective Config: [PRZ_TargetStorageName01_VMName03_01]. New WWPNs will be added to it.
[SAN1LSD] Zone [PRZ_TargetStorageName01_VMName03_01] exists. New WWPNs will be added to it.
[SAN1LSD] Peer Zone [PRZ_TargetStorageName01_VMName03_01] created successfully
[SAN1LSD] Peer Zone [PRZ_TargetStorageName01_VMName03_01] is already exists Defined Active Configuration [SAN_1_LSD]. No need to add it.
[SAN1LSD] Defined Configuration retrieved successfully
Final Defined Configuration is captured
[SAN1LSD] Defined Configuration comparison completed successfully. Nothing changed from Zone point of view. Seems only WWPNs added. Please double check configs after.
[SAN1LSD] Defined Configuration [SAN_1_LSD] saved to Effective Configuration successfully
[SAN1LSD] New Effective Configuration Checksum [72d24e2d0feef84e069885a3f2d92c65] retrieved successfully
[SAN1LSD] New Effective Configuration activated successfully
[SAN1LSD] Effective Configuration retrieved successfully
Final Effective Configuration is captured
[SAN1LSD] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you havent activated new configuration yet.
[SAN1LSD] There are no differences between Initial Effective Configuration and Final Effective Configuration. Seems you havent activated new configuration yet or added only WWPNs.

--------------------------------------------------------------------------------
[https://SAN1LSD/rest/logout] Session closed. Response: [204]
--------------------------------------------------------------------------------
End Block
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
[https://SAN2LSD/rest/logout] Session closed. Response: [204]
--------------------------------------------------------------------------------
End Block
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
End Block
--------------------------------------------------------------------------------
``` 