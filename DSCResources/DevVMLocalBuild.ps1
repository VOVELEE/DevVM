#Modules
Install-Module -Name xPSDesiredStateConfiguration
Import-Module  xPSDesiredStateConfiguration

#ConfigBuild
DevelopmentVM -OutputPath 'Test'

Start-DscConfiguration -ComputerName localhost -Path 'Test' -Wait -Verbose -Force