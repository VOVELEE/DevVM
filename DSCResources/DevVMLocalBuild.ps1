#Modules
Install-Module -Name xPSDesiredStateConfiguration -Force
Install-Module -Name xComputerManagement -Force
Import-Module  xPSDesiredStateConfiguration, xComputerManagement

#ConfigBuild
DevVm -OutputPath 'Test'

Start-DscConfiguration -ComputerName localhost -Path 'Test' -Wait -Verbose -Force