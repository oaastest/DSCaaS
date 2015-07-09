workflow testGetRunbook
{
	$data = Get-AutomationRunbook -Name "GetAzureVMTutorial" -UseDraft $true
	Write-Output $data
}