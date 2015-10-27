Import-Module PSWorkflow
Import-Module activedirectory

Workflow Test-Workflow {
[CmdletBinding()]
        param(
        [String]$user,
        [String]$place
        )

##########################################################################################
####### CHANGE THIS TO DO FASTER #########################################################
# uncomment needed lines and comment don't needed lines ##################################
##########################################################################################
                                                                                         #
                                                                                         #
 #   $place = "DC=magni,DC=local"                                                        #
                                                                                         #
#    $place = "CN=Computers,DC=magni,DC=local"                                           #
                                                                                         #
#    $place = "OU=MAGNI Servers,DC=magni,DC=local"                                       #
                                                                                         #
#    $place = "OU=MAGNI Computers,DC=magni,DC=local"                                     #
                                                                                         #
#    $place = "OU=Ulster Folk and Transport Museum,OU=MAGNI Computers,DC=magni,DC=local" #
                                                                                         #
#    $place = "OU=Ulster Museum,OU=MAGNI Computers,DC=magni,DC=local"                    #
                                                                                         #
#    $place = "OU=Ulster American Folk Park,OU=MAGNI Computers,DC=magni,DC=local" 
                                                                                         #
##########################################################################################


    Function Test-ConnectionQuietFast {
 
        [CmdletBinding()]
        param(
        [String]$ComputerName,
        [int]$Count = 1,
        [int]$Delay = 20
        )
 
        for($I = 1; $I -lt $Count + 1 ; $i++)
        {
            If (Test-Connection -ComputerName $ComputerName -Quiet -Count 1)
            {
                return $True
            }
        }
        $False
    }
    $ErrorActionPreference= 'silentlycontinue'

    $Computers = Get-ADComputer -Filter * -SearchBase $place
    "Username: $user"
    "Place: $place"

    Foreach –parallel -ThrottleLimit 100 ($comp in $computers) {
        $Computer = $comp.Name
        $Computer = $Computer.Trim()
        If (Test-ConnectionQuietFast -ComputerName $Computer -Count 1 -Delay 20) {
            $sali = inlinescript{
                if($Using:Computer){
                    $proc = Get-WmiObject win32_process -computer $Using:Computer -Filter "Name = 'explorer.exe'"
                    if($proc){
                        $proc = ($proc.GetOwner()).User
                        $ips = [System.Net.Dns]::GetHostAddresses("$Using:Computer").IPAddressToString
                        <#$sali = new-object psobject -Property @{
                                ComputerName = $Using:computer
                                LoggedUsers = $proc
                                Username  = $Using:user
                                IP  = $ips
                            }#>
                        if($proc -eq $Using:user){
                            #$sali | Format-Table ComputerName,LoggedUsers,Username,IP -AutoSize
                            $sali = "$ips -------- $Using:Computer -------- $proc -------- $Using:user"; $sali
                        } else {
                            #$sali | Format-Table ComputerName,LoggedUsers -AutoSize
                            $sali = "$Using:Computer  ----  $proc"; $sali
                        }
                    }
                }
            }
            $sali
        }
    }
}

$user = read-host “What is the Username of the user?”
$UserCheck = get-aduser $user
if ($user -eq ""){
	Write-Host "Username cannot be blank, please re-enter username!!!!!"
} elseif ($UserCheck -eq $null){
	Write-Host $user
	Write-Host "Invalid username, please verify this is the logon id for the account"
} else {
    $op = Read-Host "Where do you want to search?
    A) DC=magni,DC=local
    B) CN=Computers,DC=magni,DC=local
    C) OU=MAGNI Servers,DC=magni,DC=local
    D) OU=MAGNI Computers,DC=magni,DC=local
    E) OU=Ulster Folk and Transport Museum,OU=MAGNI Computers,DC=magni,DC=local
    F) OU=Ulster Museum,OU=MAGNI Computers,DC=magni,DC=local
    G) OU=Ulster American Folk Park,OU=MAGNI Computers,DC=magni,DC=local
    
    Answer"
    if($op -eq "a"){$place = "DC=magni,DC=local"
    }elseif($op -eq "b"){$place = "CN=Computers,DC=magni,DC=local"
    }elseif($op -eq "c"){$place = "OU=MAGNI Servers,DC=magni,DC=local"
    }elseif($op -eq "d"){$place = "OU=MAGNI Computers,DC=magni,DC=local"
    }elseif($op -eq "e"){$place = "OU=Ulster Folk and Transport Museum,OU=MAGNI Computers,DC=magni,DC=local"
    }elseif($op -eq "f"){$place = "OU=Ulster Museum,OU=MAGNI Computers,DC=magni,DC=local"
    }elseif($op -eq "g"){$place = "OU=Ulster American Folk Park,OU=MAGNI Computers,DC=magni,DC=local"
    }else{Write-Host "Invalid option" 
    exit}
    Test-Workflow -user $user -place $place
}