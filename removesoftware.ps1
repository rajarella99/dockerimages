    <#
    .SYNOPSIS
        Removes MSI-based software installations in bulk or individually either on the local computer or remotely via WMI.  
     
    .DESCRIPTION
        Use this script to remove software from a local or remote computer in bulk by using a partial name match (or wildcard, if you feel lucky), either by software title or by Product ID (GUID).
     
    .PARAMETER ComputerName
        Specifies the ComputerName you wish to query and perform the uninstallation routine.  If not specified, the script defaults to the local computer running the script.

    .PARAMETER LogFolder
        Specifies the folder destination where to save the log file.
     
    .PARAMETER Title
        Specifies the software title you wish to query for and uninstall.
     
    .PARAMETER GUID
        Specifies the product ID of the software title you wish to uninstall.
    
    .PARAMETER Force
        This is a switch that will bypass the confirmation prompt when applications that match the search criteria are found.

    .PARAMETER Timeout
        Continue the script if the uninstallation process hasn't completed in the alloted time (in seconds).  Default is 60 seconds.
         
    .EXAMPLE
        PS C:>.\Remove-SoftwareTitle.ps1 -Title "Java 8 Update 60"
     
        This will query the computer (local system by default) and attempt to uninstall the software with the title of "Java 8 Update 60"
     
    .EXAMPLE
        PS C:>.\Remove-SoftwareTitle.ps1 -Title "Java ? Update*"
     
        This will query the computer (local system by default) and attempt to uninstall any software with the title of "Java ? Update*," where the question mark represents a single character which can represent a 6, 7, 8, etc.  Using the wildcard (asterisk '*') tells the script to match any values after the specified text.
        
        For example, this single command would uninstall 'Java 7 Update 60,' 'Java 8 Update 40,' 'Java 8 Update 60,' etc.
     
    .EXAMPLE
        PS C:>.\Remove-SoftwareTitle.ps1 -GUID "*{26A24AE*"
     
        This will query the computer (local system by default) and attempt to uninstall any software with a GUID beginning with '{26A24AE.'  Since the script queries the uninstall registry keys, there is text prepending the product ID.  For this reason, using the *{ characters is recommended here.
     
    .LINK
        http://community.spiceworks.com
     
    .NOTES
        Obviously, this can be a VERY dangerous script if not used correctly.  Be sure to use -Force only when you're sure it's working the way you intend.

        Next up, adding alternate credential support.
    #>

    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$true,Position=0,ParameterSetName="Name")] [string] $Title,
        [Parameter(ValueFromPipeline=$true,Position=0)] [array] $ComputerName = $env:COMPUTERNAME,
        [Parameter(ParameterSetName="ProductID")] [string] $GUID,
        [Parameter()][string]$LogFolder = $env:TEMP,
        [Parameter()][switch]$Force = $false,
        [Parameter()][int]$Timeout = 60
    )
    
    If ((Get-Service -ComputerName $ComputerName -DisplayName 'Remote Registry').Status -eq 'stopped') {
        $WasStopped = $true
    
        Log "[$ComputerName$] - Enabling Remote Registry service..."
        (Get-WmiObject -class win32_service -ComputerName $ComputerName | where-object name -like 'remoteregistry').changestartmode("manual") | Out-Null
    
        Log "[$ComputerName$] - Starting Remote Registry service..."
        Start-Service -DisplayName 'Remote Registry' 
    }
    
    
    
    $LogFile = "$LogFolder\Remove-SoftwareTitles_$(get-date -f yyyy-MM-dd_HHmmss).log"
    Function Log($string)
    {
        Write-Verbose -Verbose "$(Get-Date) - [$Computer] $string"
       "$(Get-Date -f o) - [$Computer] $string" | out-file -Filepath $logfile -append
    }
    
    
    #Clear-Host
    
    
    function Get-Titles{
        [CmdletBinding(DefaultParametersetName="p1")]
        param(
            [Parameter(ValueFromPipeline=$true,Position=0)] [string] $Computer,
            [Parameter(ValueFromPipeline=$true,Position=1)] [string] $Title,
            [Parameter(ValueFromPipeline=$true,Position=2)] [string] $GUID
        )
    
        Begin {
            $Results = @()
        }
    
        Process{
    
                Log "Processing $Computer, Looking for $GUID$Title"
                Log "Working..."
    
                
                $SomethingsInstalled = $false
    
                $ErrorActionPreference = "Continue"
                If ((Get-WmiObject win32_processor -ComputerName $Computer).AddressWidth -eq 32){   
                    Log "32-bit system detected."
                    $keys = "SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
                } Else {   
                    #Write-Verbose -Verbose "[$(Get-Date)] -  [$computer] 64-bit system detected, iterating through 32-bit and 64-bit reg keys..."
                    $keys = "SOFTWARE\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall","SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall"
                }
                Do {
                    $Reg = ([microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine', $Computer))
                    $AppList = $null
                    ForEach ($regitem in $keys) {
                        $RegKey = $Reg.OpenSubKey($regitem)
                        $SubKeys = $RegKey.GetSubKeyNames()
                        $Count = 0
                                
                        $Data = ForEach ($Key in $SubKeys){   
                            $thisKey = $regitem + "\\" + $Key
                            $thisSubKey = $Reg.OpenSubKey($thisKey)
                                If ($Title) { 
                                    $CheckAgainst = $thisSubKey.GetValue("DisplayName")
                                    $CheckFor = $Title
                                } Else { 
                                    $CheckAgainst = $thisSubKey.GetValue("UninstallString")
                                    $CheckFor = $GUID
                                }
    
                                If (($CheckAgainst) -and ($CheckAgainst -like $CheckFor)){
     
                                    $SomethingsInstalled = $true    
                                    $ErrorActionPreference = "SilentlyContinue"
                                    New-Object PSObject -Property @{
                                        Query = "$Title; $Publisher"
                                        Installed = $true
                                        ComputerName = $Computer
                                        UninstallString = $thisSubKey.GetValue("UninstallString")
                                        DisplayName = $thisSubKey.GetValue("DisplayName")
                                        Publisher = $thisSubKey.GetValue("Publisher")
                                        DisplayVersion = $thisSubKey.GetValue("DisplayVersion")
                                        InstallLocation = $thisSubKey.GetValue("InstallLocation")
                                        GUID = $($thisSubKey.GetValue("UninstallString")).Split("{}")[1]
                                        Key = $($thisSubKey)
                                    }
                                } 
                            }
                            
                            $Results += $Data
    
                            $Results
                        }
    
                        If ($SomethingsInstalled -eq $false){
                            $Installed = New-Object PSObject -Property @{
                            Query = $Title
                            Installed = $false
                            ComputerName = $Computer
                            UninstallString = $null
                            DisplayName = $null
                            Publisher = $null
                            DisplayVersion = $null
                            InstallLocation = $null
                            GUID = $null
                        }
                        
                        $Results += $Installed
                        
                    }
                } 
                
                Until ($Return -eq $null)
                $Results
    
        }
        End {
            $Data
        }
    }
    
    
    
    
    Function Remove-Title {
        
        param(
            [parameter()][string]$Computer,
            [parameter()][array]$Titles,
            [parameter()][string]$GUID
        )
    
        If (!$Force) {
            Log "Application(s) found" 
        
            ForEach ($Title in $Titles) { 
                Log "$($Title)"
            }
         
            #prompt to let user abort if file sources aren't correct
            #-------------------------------------------------------------
            $title      = "Uninstallation from $Computer - approval needed"
            $message    = "You've selected the above app(s) for removal, do you wish to continue?"
            $yes        = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Removes application(s) from $computername."
            $no         = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Returns to application listing."
            $options    = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
            $result     = $host.ui.PromptForChoice($title, $message, $options, 0)
    
            write-output  "`n"
            Log "Operator answered $result" 
    
            switch ($result) {
                1 {
                    Log "App removal aborted by user."
                }
            }
        }
    
        #Uninstall the application, if we selected 'yes' manually or used the 'force' switch.
        If (($result -eq 0) -or ($Force)){
            Log "Performing uninstallation via MSI."
    
            ForEach ($App in $Titles){  
                Log "Uninstalling $($App.DisplayName) from $ComputerName using GUID: $($App.GUID)"
                $Return = Invoke-WmiMethod -ComputerName $ComputerName -Class Win32_Process -Name Create -ArgumentList "msiexec.exe /qr /norestart /x ""{$($App.guid)}""" 
    
                #(Get-WmiObject -Class Win32_Product -Filter "IdentifyingNumber='{$($App.GUID)}'" -ComputerName $ComputerName).Uninstall()
    
                if ($Return.ReturnValue -eq 0){
                    $StartTime = Get-Date
                    Log "Uninstallation process started"
                    
                    Do {
                        Log "Checking..."
                        Log $App.key
                        $Key = ($App.Key).toString()
    
                        $Key = $Key.replace("HKEY_LOCAL_MACHINE","hklm:")
                        
                        $Installed = Get-ItemProperty $Key -ErrorAction Continue
    
                        If ($?) {
                            Log "Application uninstalling.  Finishing up..."
                        }
                                   
    
                    } While ((Get-Date) -gt ($StartTime).AddSeconds($Timeout) -or ($Installed -eq $null))
    
                    If (!($Installed)) { 
                        Log "Uninstallation successful."
                    }        
    
                }
                Else {   
                    Log "Uninstallation of $($app.displayname) failed.  Error code: $($Return.ReturnValue)"
                }
            }
        }
    } 
    
    Function Do-Nothing { 
        #No match to our query either by title or GUID, so, nothing to do...
        If (!$Title) { 
            $Title = "not specified"
        } Else { 
            $Title = "'$Title'"
        }
        If (!$GUID) { 
            $GUID = "not specified"
        } Else { 
            $GUID = "'$GUID'"
        }
        Log "Applications not found (Title: $Title or GUID: $GUID)"
    }
    
    ForEach ($Computer in $ComputerName) { 
        If ($Title) { 
            
            $Titles = Get-Titles -Title $Title -Computer $Computer | Where-Object {$_.guid -ne $null} | Select-Object DisplayName,GUID,Key -Unique 
        } Else { 
            $Titles = Get-Titles -GUID $GUID -Computer $Computer | Where-Object {$_.guid -ne $null} | Select-Object DisplayName,GUID,Key -Unique 
    
        }
        
        If ($Titles) {
            $Titles
            Remove-Title -Computer $Computer -Titles $Titles
        } Else { 
            Do-Nothing
        }
    
    }
    
    
        If ($WasStopped -eq $true) { 
            Log "[$ComputerName$] - Stopping service 'Remote Registry'"
            Stop-Service -DisplayName 'Remote Registry' 
            Write-Verbose -Verbose "[$ComputerName$] - Disabling Remote Registry service"
            (Get-WmiObject -class win32_service -ComputerName $ComputerName | where-object name -like 'remoteregistry').changestartmode("disabled") | Out-Null
    
        }
    #$Return