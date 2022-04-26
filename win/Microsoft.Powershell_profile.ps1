Set-Alias d docker
Set-Alias g git

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Node env
fnm env --use-on-cd | Out-String | Invoke-Expression

# Starship
Invoke-Expression (&starship init powershell)