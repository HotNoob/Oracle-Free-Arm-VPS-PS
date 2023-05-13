# Oracle-Free-Arm-VPS-PS
Simple Powershell Script that automatically tries to create a arm vps in oracle cloud using OCI. Resulting in a work-around for "out of capacity"

#Resolving Oracle Cloud "Out of Capacity" issue and getting free VPS with 4 ARM cores / 24GB of memory

#Requirements. OCI CLI. 
follow instructions to install oracle cloud cli
Install: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__windows

#usage
in powershell prompt login to oracle cloud using this cli command:
oci session authenticate

open script, add tenancy id. follow instructions in script. 

run script to easily get other parameters. read script for instructions. 
disable setup mode. 

then run script. 

#session expiry!
oci sessions expire every 24 hours, you must re-run:
oci session authenticate
