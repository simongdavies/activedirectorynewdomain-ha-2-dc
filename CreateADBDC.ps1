#### Remove this if this gets fixed in the extension

try {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted 
}
catch{
    Write-Verbose 'An exception occurred setting Execution Policy - Trying to Continue -:'
    if ($Error) {
        Write-Verbose ($Error|fl * -Force|Out-String) 
    }
}
   

configuration CreateADBDC 
{ 
   param 
    ( 
        [Parameter(Mandatory)]
        [String]$DomainName,

        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$Admincreds,

        [Parameter(Mandatory)]
        [string]$DnsServerAddress,

        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30,
        [String]$DomainNetbiosName=$(Get-NetBIOSName($DomainName))
    ) 
    Import-DscResource -ModuleName xActiveDirectory,xNetworking
    [System.Management.Automation.PSCredential ]$DomainCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$($Admincreds.UserName)", $Admincreds.Password)
   
    Node localhost
    {
        xDnsServerAddress DnsServerAddress 
        { 
            Address        = $DnsServerAddress 
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4' 
        } 
        xWaitForADDomain DscForestWait 
        { 
            DomainName = $DomainName 
            DomainUserCredential= $DomainCreds
            RetryCount = $RetryCount 
            RetryIntervalSec = $RetryIntervalSec
            DependsOn = "[xDnsServerAddress]DnsServerAddress" 
        } 
        xADDomainController BDC 
        { 
            DomainName = $DomainName 
            DomainAdministratorCredential = $DomainCreds 
            SafemodeAdministratorPassword = $DomainCreds
            DatabasePath = "F:\NTDS"
            LogPath = "F:\NTDS"
            SysvolPath = "F:\SYSVOL"
            DependsOn = "[xWaitForADDomain]DscForestWait" 
        } 

        #### Remove this if this gets fixed in the extension
        Script ResetExecutionPolicy
        {
            SetScript = "Set-ExecutionPolicy -ExecutionPolicy Default"
            TestScript = "((Get-ExecutionPolicy) -eq 'Default')"
            GetScript = "
                `$returnValue = @{
                    Ensure = if ((Get-ExecutionPolicy) -eq 'Default') {'Present'} else {'Absent'}
                }
                `$returnValue
                "
            DependsOn = "[xADDomainController]BDC" 
        }
   }

} 
function Get-NetBIOSName([string]$DomainName)
{ 
    [string]$NetBIOSName
    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) {
            $length=15
        }
        $NetBIOSName=$DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) {
            $NetBIOSName=$DomainName.Substring(0,15)
        }
        else {
            $NetBIOSName=$DomainName
        }
    }
    return $NetBIOSName
}
