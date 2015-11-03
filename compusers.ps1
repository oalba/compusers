Import-Module PSWorkflow
Import-Module activedirectory

Workflow Test-Workflow {
[CmdletBinding()]
        param(
        [String[]]$user,
        [String]$place
        )

    $ErrorActionPreference= 'silentlycontinue'

    $Computers = Get-ADComputer -Filter * -SearchBase $place
    Foreach –parallel -ThrottleLimit 100 ($us in $user) {
        "Username: $us"
    }
    "Place: $place"

    Foreach –parallel -ThrottleLimit 100 ($comp in $computers) {
        $Computer = $comp.Name
        $Computer = $Computer.Trim()
        If (Test-Connection -ComputerName $Computer -Quiet -Count 1) {
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
                        foreach ($use in $Using:user){
                            if($proc -eq $use){
                                #$sali | Format-Table ComputerName,LoggedUsers,Username,IP -AutoSize
                                $sali = "$ips -------- $Using:Computer -------- $proc -------- $use"; $sali
                            }
                        }
                        #$sali | Format-Table ComputerName,LoggedUsers -AutoSize
                        $sali = "$Using:Computer  ----  $proc"; $sali
                    }
                }
            }
            $sali
        }
    }
    exit
}

$user4 = read-host “What is the Username of the user?”
$user2 = '*'+$user4+'*'
$user3 = Get-ADUser -Filter {samaccountname -like $user2}| Select-Object samaccountname
$user = $user3.samaccountname
if ($user -eq ""){
	Write-Host "Username cannot be blank!!!!!"
} elseif ($user -eq $null){
	Write-Host $user
	Write-Host "Invalid username, please verify this is the logon id for the account!!!!!"
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
    exit
}