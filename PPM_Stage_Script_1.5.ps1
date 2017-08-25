#
# PPM_Stage_Script.ps1
#
param(
  [Parameter(Mandatory=$true)]
  $SubscriptionId,
  [Parameter(Mandatory=$true)]
  $Location,
  [Parameter(Mandatory=$true)]
  [ValidateSet("Environment", "Servers", "Security")]
  $Mode
)

$ErrorActionPreference = "Stop"

$templateRootUriString = $env:TEMPLATE_ROOT_URI
if ($templateRootUriString -eq $null) {
  $templateRootUriString = "https://ericsson.azure.com/ppm-environment-deployment/v1.0/"
}

if (![System.Uri]::IsWellFormedUriString($templateRootUriString, [System.UriKind]::Absolute)) {
  throw "Invalid value for TEMPLATE_ROOT_URI: $env:TEMPLATE_ROOT_URI"
}

Write-Host
Write-Host "Using $templateRootUriString to locate templates"
Write-Host

$templateRootUri = New-Object System.Uri -ArgumentList @($templateRootUriString)

$vNetTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/vnet.json")
#$virtualMachineTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/vm.json")
#$loadBalancerTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/loadBalancer.json")
#$networkSecurityGroupTemplate = New-Object System.Uri -ArgumentList @($templateRootUri, "templates/nsg.json")


# Parameters Files
$vNetParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\vnet.parameters.json")
#$jumpboxParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\jumpbox.parameters.json")
#$appLoadBalancerParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\app.parameters.json")
#$dbLoadBalancerParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\db.parameters.json")
#$networkSecurityGroupParametersFile = [System.IO.Path]::Combine($PSScriptRoot, "parameters\nsg.parameters.json")

$environmentResourceGroupName = "ppm-environment-rg"
$serversResourceGroupName = "ppm-servers-rg"

# Login to Azure and select your subscription
Login-AzureRmAccount -SubscriptionId $SubscriptionId | Out-Null

if ($Mode -eq "Environment") {
    $environmentResourceGroup = New-AzureRmResourceGroup -Name $environmentResourceGroupName -Location $Location

    Write-Host "Deploying virtual network ..."
    New-AzureRmResourceGroupservers -Name "ppm-vnet-deploy" `
        -ResourceGroupName $environmentResourceGroup.ResourceGroupName -TemplateUri $vNetTemplate.AbsoluteUri `
        -TemplateParameterFile $vNetParametersFile

#    Write-Host "Deploying jumpbox..."
#	 New-AzureRmResourceGroupDeployment -Name "ppm-jumpbox-deploy" -ResourceGroupName $environmentResourceGroup.ResourceGroupName `
#    -TemplateUri $virtualMachineTemplate.AbsoluteUri -TemplateParameterFile $jumpboxParametersFile

}
elseif ($Mode -eq "Servers") {
    Write-Host "Deploying servers ..."

    $serversResourceGroup = New-AzureRmResourceGroup -Name $serversResourceGroupName -Location $Location

}
elseif ($Mode -eq "Security") {
    $environmentResourceGroup = Get-AzureRmResourceGroup -Name $infrastructureResourceGroupName 

    Write-Host "Deploying security ..."
}