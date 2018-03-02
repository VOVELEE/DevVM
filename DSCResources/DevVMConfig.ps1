Configuration DevVM
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource –ModuleName PSDesiredStateConfiguration

    $VSCodePackageLocalPath = "c:\temp\vscodeSetup.exe"
    $GoogleChromePackageLocalPath = "c:\temp\ChromeStandaloneSetup.exe"

    Node localhost {
        #Configurations
        xPowerPlan SetPlanHighPerformance
        {
            IsSingleInstance = 'Yes'
            Name             = 'High performance'
        }

        Script DisableServerManager {
            GetScript = {
                Return @{
                    Result = [string]$(Get-ScheduledTask -TaskName ServerManager | Select-Object TaskName, State)
                }
            }

            # Must return a boolean: $true or $false
            TestScript = {
                If ((Get-ScheduledTask -TaskName ServerManager).State -like "Disabled")
                {
                    Write-Verbose "Server Manager is disabled"
                    Return $true
                }
                Else
                {
                    Write-Verbose "Server Manager is enabled"
                    Return $false
                }
            }

            # Returns nothing
            SetScript = {
                Write-Verbose "Stopping ServerManager scheduled task"
                Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
            }
        }

        #Download a package
        xRemoteFile VSCodePackage {
            Uri = 'https://go.microsoft.com/fwlink/?Linkid=852157'
            DestinationPath = $VSCodePackageLocalPath
        }

        xRemoteFile GoogleChromePackage {
            Uri = "https://dl.google.com/tag/s/appguid%3D%7B8A69D345-D564-463C-AFF1-A69D9E530F96%7D%26iid%3D%7B62848266-EECC-3C9B-C987-B78369D4EBD6%7D%26lang%3Den%26browser%3D4%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dtrue%26ap%3Dx64-stable-statsdef_1%26installdataindex%3Ddefaultbrowser/chrome/install/ChromeStandaloneSetup64.exe"
            DestinationPath = $GoogleChromePackageLocalPath
        }

        <#Install Application
        Package VsCode {
            Ensure = "Present"
            Path = $VSCodePackageLocalPath
            Name = "Microsoft Monitoring Agent"
            ProductId = ""
            Arguments = '/C:"setup.exe /qn ADD_OPINSIGHTS_WORKSPACE=1 OPINSIGHTS_WORKSPACE_ID=' + $OmsWorkspaceID + ' OPINSIGHTS_WORKSPACE_KEY=' + $OmsWorkspaceKey + ' AcceptEndUserLicenseAgreement=1"'
            DependsOn = "[xRemoteFile]VSCodePackage"
        }
        #>

        Package GoogleChrome  {
            Ensure = 'Present'
            Name = 'Google Chrome'
            Path = $GoogleChromePackageLocalPath
            ProductId = ''
            Arguments = '/silent /install'
            DependsOn = "[xRemoteFile]GoogleChromePackage"
        }
    }

}