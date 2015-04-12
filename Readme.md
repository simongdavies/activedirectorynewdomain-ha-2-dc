# Create a 2 new Windows VMs, create a new AD Forest, Domain and 2 DCs in an availability set

This template will deploy 2 new VMs (along with a new VNet, Storage Account and Load Balancer) and create a new  AD forest and domain, each VM will be created as a DC for the new domain and will be placed in an availability set. Each VM will also have an RDP endpoint added with a public load balanced IP address.

There are a number of issues\workarounds in this template and the associated DSC Script:

1. Version 1.7 of the DSC Extension has a problem whereby the script execution policy will not allow scripts to be executed , therefore the DSC script provided updates the execution policy before the DSC extension is run and then sets it back to default once the configuration has been applied.

Click the button below to deploy

<a href="https://azuredeploy.net" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Below are the parameters that the template expects

| Name   | Description    |
|:--- |:---|
| newStorageAccountName    | Name of the storage account to create    |
| storageAccountType      | Type of the storage account <br> <ul>**Allowed Values**<li>Standard_LRS **(default)**</li><li>Standard_GRS</li><li>"Standard_ZRS"</li></ul> |
| deploymentLocation  | Location where to deploy the resource <br><ul>**Allowed Values**<li>West US</li><li>East US</li><li>**West Europe (default)**</li><li>East Asia</li><li>Southeast Asia</li>|
| virtualNetworkName | Name of the Virtual Network |
| virtualNetworkAddressRange | Virtual Network Address Range <br> <ul><li>10.0.0.0/16 **(default)**</li></ul> |
| adSubnetName | Name of Subnet for AD VM  |
| adSubnet | Address prefix for adSubnetName <br> <ul><li>10.0.0.0/24 **(default)**</li></ul> |
| adPDCNicName | The name of the NIC attached to the new PDC |
| adPDCNicIPAddress | The IP address of the new AD PDC  <br> <ul><li>**10.0.0.4 (default)**</li></ul> |
| adBDCNicName | The name of the NIC attached to the new BDC |
| adBDCNicIPAddress | The IP address of the new AD BDC  <br> <ul><li>**10.0.0.5 (default)**</li></ul> |
| publicIPAddressName | Name of the public IP address to create |
| publicIPAddressType | Type of Public IP Address <br> <ul>**Allowed Values**<li>Dynamic **(default)**</li><li>Static</li></ul>|
| adPDCVMName | Name for the PDC |
| adBDCVMName | Name for the BDC |
| adminUsername | Admin username for the VM **This will also be used as the domain admin user name**|
| adminPassword | Admin password for the VM **This will also be used as the domain admin password and the SafeMode password** |
| adVMSize | Size of the VM <br> <ul>**Allowed Values**<li>Standard_A0 </li><li>Standard_A1**(default)**</li><li>Standard_A2</li><li>Standard_A3</li><li>Standard_A4</li></ul>|
| adImageName | Name of image to use for the VM <br> <ul><li>a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-201502.01-en.us-127GB.vhd **(default)**</li></ul>|
| vmContainerName | The container name in the storage account where VM disks are stored|
| adAvailabilitySetName | The name of the availability set that the AD VM is created in|
| domainName | The FQDN of the AD Domain created |
| domainNetbiosName | The NetBIOS name of the AD Domain created |
| adPDCModulesURL |The URL to the zip containing the DSC package that creates and installs AD and the PDC <br> <ul> <li>**https://raw.githubusercontent.com/simongdavies/activedirectorynewdomain-ha-2-dc/master/CreateADPDC.ps1.zip (default)**</li></ul>|
| adPDCConfigurationFunction | The name of the DSC Configuration Function that configures the VM , creates the AD Domain etc.<br> <ul> <li>**CreateADPDC.ps1\\CreateADPDC(default)** </li></ul> |
| adBDCPrepareModulesURL |The URL to the zip containing the DSC package that prepares the VM <br> <ul> <li>**https://raw.githubusercontent.com/simongdavies/activedirectorynewdomain-ha-2-dc/master/PrepareADBDC.ps1.zip (default)**</li></ul>|
| adBDCPrepareConfigurationFunction | The name of the DSC Configuration Function that prepares the VM prior to installing joining the domain and creating the DC<br> <ul> <li>**PrepareADBDC.ps1\\PrepareADBDC(default)** </li></ul> |
| adBDCCreateModulesURL |The URL to the zip containing the DSC package that creates and installs the second DC <br> <ul> <li>**https://raw.githubusercontent.com/simongdavies/activedirectorynewdomain-ha-2-dc/master/CreateADBDC.ps1.zip (default)**</li></ul>|
| adBDCCreateConfigurationFunction | The name of the DSC Configuration Function that configures the VM , creates the DC etc.<br> <ul> <li>**CreateADBDC.ps1\\CreateADBDC(default)** </li></ul> |
| addnsName | The DNS prefix for the public IP address used by the Load Balancer |
| PDCRDPPort | The public RDP port for the PDC VM |
| BDCRDPPort | The public RDP port for the BDC VM |

