Configuration DevelopmentVM
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource –ModuleName PSDesiredStateConfiguration

    $VSCodePackageLocalPath = "c:\temp\vscodeSetup.exe"
    $GoogleChromePackageLocalPath = "c:\temp\ChromeStandaloneSetup.msi"

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
                    Result = [string]$(Get-ScheduledTask -TaskName ServerManager | Select TaskName, State)
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
            Uri = "https://dl.google.com/tag/s/appguid={8A69D345-D564-463C-AFF1-A69D9E530F96}&iid={00000000-0000-0000-0000-000000000000}&lang=en&browser=3&usagestats=0&appname=Google%2520Chrome&needsadmin=prefers/edgedl/chrome/install/GoogleChromeStandaloneEnterprise.msi"
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