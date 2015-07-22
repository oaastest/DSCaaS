<# 
.SYNOPSIS 
    Provides a simple example of a Azure Automation runbook.   
 
.DESCRIPTION 
    This runbook provides the "Hello World" example for Azure Automation.  If you are  
    brand new to Automation in Azure, you can use this runbook to explore testing  
    and publishing capabilities.   
 
    The runbook takes in an optional string parameter.  If you leave the parameter blank, the  
    default of $Name will equal "World".  The runbook then prints "Hello" concatenated with $Name. 
    
 
.PARAMETER Name 
    String value to print as output 
 
.EXAMPLE 
    Write-HelloWorld -Name "World" 
 
.NOTES 
    Author: System Center Automation Team  
    Last Updated: 3/3/2014    
#> 
 
 
workflow Hello-World-Github { 
        Write-Output "Hello World"
		Get-Date #OMG HI THIS SO COOL
}
