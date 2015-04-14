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
   

configuration PrepareADBDC
{ 
   param 
    (
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    ) 
    Import-DscResource -ModuleName xDisk, xNetworking 

    Node localhost
    {
       # setting up DNS with default DNS servers for VNet does not work so install DNS and set this VMs DNS tp localhost temporarily
        WindowsFeature DNS 
        { 
            Ensure = "Present" 
            Name = "DNS"
        }
        xDnsServerAddress DnsServerAddress 
        { 
            Address        = '127.0.0.1' 
            InterfaceAlias = 'Ethernet'
            AddressFamily  = 'IPv4'
            DependsOn="[WindowsFeature]DNS" 
        }
        xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec =$RetryIntervalSec
             RetryCount = $RetryCount
             DependsOn="[WindowsFeature]DNS"
        }
        xDisk ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
            DependsOn = "[xWaitforDisk]Disk2"
        }
        WindowsFeature ADDSInstall 
        { 
            Ensure = "Present" 
            Name = "AD-Domain-Services"
            # this is to stop the machine being rebooted during disk initialisation as there is a race condition that can cause disk init to fail
            DependsOn = "[xDisk]ADDataDisk"
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
            DependsOn = "[WindowsFeature]ADDSInstall" 
        }
   }

} 
