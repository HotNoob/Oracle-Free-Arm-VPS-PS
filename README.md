# Oracle-Free-Arm-VPS-PS
Simple Powershell Script that automatically tries to create a arm vps in oracle cloud using OCI. Resulting in a work-around for "out of capacity"

#Resolving Oracle Cloud "Out of Capacity" issue and getting free VPS with 4 ARM cores / 24GB of memory

#Requirements. OCI CLI. 
follow instructions to install oracle cloud cli
Install: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__windows

#usage
edit script, and add in required parameters. 

in powershell prompt login to oracle cloud using this cli command:
oci session authenticate

then run script. 
