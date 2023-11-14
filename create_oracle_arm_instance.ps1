
#oci session authenticate
#select your location, in my case i used ca-toronto-1, this will likely be different for you
#if prompted for a profile name, type in "DEFAULT", or whatever you set $profile to be
#after logging in, fillout tenancy id below.
#then run the script and use output to fill out the rest of the setup variables ($tenancyId, $imageId, $subnetId, $availDomain)

#your account's tenancy id
#on oracle cloud, go to profile -> tenancy: {your tenancy name here} -> {click} -> under Tenancy Information -> Copy OCID
#afterwards, you can run the script to get the rest of the setup info
$tenancyId = "ocid1.tenancy.oc1..***"

#get this by running the script in setup mode OR:
#oci compute image list -c {your tenancy id (OCID) here}
#this will be representing your ubuntu 22.04 ARM image or whatever. must be an arm image.
$imageId = "ocid1.image.oc1.***.***"

#get this by running the script in setup mode OR:
#you can get this from: oracle cloud -> left hand menu -> networks -> Virtual Cloud Networks (VCN) -> {click} -> the VCN you want -> {click name} -> the subnet you want -> {click name} -> under Subnet Information -> Copy OCID
#oci network subnet list -c {your vcn id (OCID) here} to get your subnet id. 
$subnetId = "ocid1.subnet.oc1.***.***"

#get this by running the script in setup mode OR:
#oci iam availability-domain list -c {your tenancy id (OCID) here}
$availDomain = "IGuL:***"

###### RUN SETUP FOR ABOVE VARIABLE VALUES ####
### ONCE variables have been set, set $setup = 0
[bool] $setup = 1
[bool] $silent = 1


#vm size
$cpus = 4 #number of cpu cores
$ram = 24 #memory size in gb

#session authentication parameters
$profile = "DEFAULT"
$configFile = $env:USERPROFILE+"\.oci\config"

$authParams = " --config-file $configFile --profile $profile  --auth security_token "

$requestInterval = 60 #interval in seconds
$max = 60*60*24 / $requestInterval




If($setup)
{
    Write-Output "Setup! Collect Require Information! then set `$setup to 0"
    Write-Output "`n###Images: ###"
    $json =  iex "oci compute image list --all -c $tenancyId $authParams" | ConvertFrom-Json
    
    Foreach($image in $json.data)
    {
        If($image.'display-name' -like "*aarch64*")
        {
            Write-Output  "$($image.'display-name'): $($image.'id')"
        }
    }

    Write-Output "`n###Subnets: ###"
    $json = iex "oci network subnet list -c $tenancyId $authParams" | ConvertFrom-Json
    Foreach($subnet in $json.data)
    {
        Write-Output "$($subnet.'display-name') : $($subnet.id)"
    }

    Write-Output "`n###Availability Domains: ###"
    $json = iex "oci iam availability-domain list -c $tenancyId $authParams" | ConvertFrom-Json
    Foreach($ad in $json.data)
    {
        Write-Output "$($ad.'name')"
    }

    Read-Host -Prompt "Press any key to continue..."
    Exit;
}


$startTime = $(get-date)
For ($i = 0; $i -lt $max; $i++)
{

    $elapsedTime = $(get-date) - $startTime
    If( $i -gt 1)
    {
        $sleep = $requestInterval - $elapsedTime.Seconds 
        If($sleep -gt 0)
        {
            Start-Sleep -Seconds $sleep;
        }
    }
    
    $startTime = $(get-date)
    Write-Output "$i of $max - $(Get-Date)" 

    If(($i % 10 -eq 0) -and ($i -gt 0))
    {
        #refresh token
        Write-Output "Refresh Token"
        oci session refresh --profile $profile
    }

    #request instance creation
    #must be single line, cuz iex / powershell syntax bs
    $response = & iex "& oci compute instance launch --no-retry --availability-domain $availDomain $authParams --compartment-id $tenancyId --image-id $imageId  --shape 'VM.Standard.A1.Flex' --shape-config `"{`'ocpus`':$cpus,`'memoryInGBs`':$ram}`"  --subnet-id $subnetId " 2>&1

    If($silent -eq 0)
    {
        Write-Output "RESPONSE: $($response | Out-String)"
    }

    try
    {
        try
        {
            $json = $response | ConvertFrom-Json
        }
        catch
        {
            #cause error messages not sent in json 
            $json = $response | select -skip 1 | ConvertFrom-Json
        }
    }
    catch
    {
        Write-Output "Bad JSON: $response"
        Read-Host -Prompt "Press any key to continue..."
        Exit #end program.    
    }

    If($silent -eq 0)
    {
        Write-Output "JSON : $($json | Out-String)"
    }

    try
    {
        If($json.data.id)
        {
            Write-Output "Container Created! Check your instances :)"
            Write-Output $json.data.id
            Write-Output $json.data.'display-name'
            Read-Host -Prompt "Press any key to continue..."
            Exit;
        }

        If($json.status -eq 429) #too many requests
        {
            
            Write-Output "Too Many Requests - Increasing Delay ($requestInterval)"
            $requestInterval++;
        }
        Write-Output $json.status
        Write-Output $json.message

        If($json.status -eq 200) #success ?
        {
            Write-Output "Status 200 = success?"
            Read-Host -Prompt "Press any key to continue..."
            Exit;
        }
    }
    catch
    {
        Write-Output "Error Not Found! Success??"
        Read-Host -Prompt "Press any key to continue..."
        Exit #end program. 
    }
}
