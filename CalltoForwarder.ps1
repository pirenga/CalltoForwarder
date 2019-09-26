## CallToForwarder 
## script for make call via 3CXPhone ver.6  on windows 10 
## support callto: sip: tel: 
## by Mikhail Taniushkin email: mt[]pirenga.com 
## source https://github.com/pirenga/CalltoForwarder
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT.
##
## You can use the current version of this software in a commercial environment, but we will always be grateful for a reasonable donation through Paypal. =)
##
######################################################################################################################################################################

$_pathToSIPClient = "C:\Program Files (x86)\3CXPhone\3CXPhone.exe"
$_OutPref = "9"         #Prefix access to external line, e.g. "0" or "9" or "" if direct access
$_areaPref = "8812"         #full Local Area Prefix
$_countrCode = "8"        # for Russia  add "8" for 10 digit number
$_cmd_param = "sip:"     # additional command line parameters for external sip app, e.g. 3CXPhone ver.6
$_intPref ="810"        # prefix access to international line 


#######################################################################################################################################################################
If ($args[0] -eq $null) { Write-Host "You must provide Argument. e.g. `n`t`tcalltoforwarder.ps1 -install`n`t`t or `n`t`tcallforwarder.ps1 callto:+12345678901"; exit }

$_inputStr = $args[0]
function NumNormalize {
$_repl = [regex]::replace($_inputStr, "[a-z,A-Z,:,-]", "")
    if ($_repl -like '+7*') { $_repl = [regex]::replace($_repl, '(.)[+7]', '8'); RunExtApp }
    if ($_repl -like '+*') { $_repl = [regex]::replace($_repl, '\+', $($_intPref)); RunExtApp }
    if ($_repl.Length -eq 12 -and $_repl -like '98*') { $_repl = [regex]::replace($_repl, '^9', '');RunExtApp }
    if ($_repl.Length -eq 10) { $_repl = $($_countrCode) + $($_repl); RunExtApp}
    if ($_repl.Length -lt 10) { $_repl = $($_areaPref) + $($_repl); RunExtApp }

}

function RunExtApp {
    #Write-Host $_pathToSIPClient $_cmd_param$_OutPref$_repl
    Start-Process -FilePath $_pathToSIPClient -ArgumentList $_cmd_param$_OutPref$_repl 
    exit
}


$pathCalltoForwarder = "powershell -windowstyle hidden $($MyInvocation.MyCommand.Path) %1"


function installCalltoForwarder {
    New-Item -Path 'HKCU:\SOFTWARE\Classes\callto' -Force -Value 'URL:callto' | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\Classes\callto' -Force -Name 'URL Protocol' -Value '' | Out-Null
    New-Item -Path 'HKCU:\SOFTWARE\Classes\tel' -Force -Value 'URL:tel' | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\Classes\tel' -Force -Name 'URL Protocol' -Value '' | Out-Null

    New-Item -Path 'HKCU:\SOFTWARE\Classes\sip' -Force -Value 'URL:sip' | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\Classes\sip' -Force -Name 'URL Protocol' -Value '' | Out-Null

    New-Item -Path 'HKCU:\SOFTWARE\Classes\CalltoForwarder' -Force -Value 'CalltoForwarder' | Out-Null
    New-Item -Path 'HKCU:\SOFTWARE\Classes\CalltoForwarder\Shell\Open\Command' -Force -Value $pathCalltoForwarder | Out-Null
    

    New-Item -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities' -Name 'ApplicationName' -Value 'CalltoForwarder' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities' -Name 'ApplicationDescription' -Value 'CalltoForwarder' -Force | Out-Null

    New-Item -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities\URLAssociations' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities\URLAssociations' -Name 'callto' -Value 'CalltoForwarder' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities\URLAssociations' -Name 'tel' -Value 'CalltoForwarder' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\CalltoForwarder\Capabilities\URLAssociations' -Name 'sip' -Value 'CalltoForwarder' -Force | Out-Null

    New-Item -Path 'HKCU:\SOFTWARE\RegisteredApplications' -Force | Out-Null
    New-ItemProperty -Path 'HKCU:\SOFTWARE\RegisteredApplications' -Name 'CalltoForwarder' -Value 'SOFTWARE\CalltoForwarder\Capabilities' -Force | Out-Null
     }

function deinstallCalltoForwarder {
 
    Remove-item -Path 'HKCU:\SOFTWARE\Classes\CalltoForwarder' -Force -Recurse | Out-Null
    Remove-item -Path 'HKCU:\SOFTWARE\CalltoForwarder' -Force -Recurse | Out-Null
    
    Remove-ItemProperty -Path 'HKCU:\SOFTWARE\RegisteredApplications' -Name 'CalltoForwarder' -Force | Out-Null
     }

If ($args[0] -like '-install') { installCalltoForwarder; exit }
If ($args[0] -like '-deinstall') { deinstallCalltoForwarder; exit }
NumNormalize
exit
#
#
#
