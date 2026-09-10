# Run in a REGULAR (non-admin) PowerShell — Scoop refuses to install as Administrator.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
