#region Script Header
#	NAME: FibreChannelTools.psm1
#	AUTHOR: asukhov
#	CONTACT: 
#	DATE: 2022.09.08
#	VERSION: 
#
#	SYNOPSIS:
#
#
#	DESCRIPTION:
#	FibreChannel related tasks automation module
#
#	REQUIREMENTS:
#
#endregion Script Header

#Requires -Version 7.1

[CmdletBinding(PositionalBinding=$false)]
param()

Write-Host $PSScriptRoot

#Get Functions and Helpers function definition files.
$Public	= @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
ForEach ($Import in @($Public + $Private))
{
	Try
	{
		. $Import.Fullname
	}
	Catch
	{
		Write-Error -Message "Failed to Import function $($Import.Fullname): $_"
	}
}

Export-ModuleMember -Function $Public.Basename

