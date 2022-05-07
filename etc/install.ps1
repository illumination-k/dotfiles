$cur_dir = Split-Path $PSCommandPath

Write-Host $cur_dir

New-Item -Force -Type SymbolicLink ~/.gitconfig -Value .\.gitconfig
New-Item -Force -Type SymbolicLink ~/.config/starship.toml -Value .\.starship.toml