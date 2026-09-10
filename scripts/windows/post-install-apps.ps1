# Run in an elevated (Administrator) PowerShell after Windows 11 is installed and updated.
# Installs the day-to-day apps via winget and switches Windows to the light theme.

$ErrorActionPreference = "Stop"

$apps = @(
    "Mozilla.Firefox",
    "Google.Chrome",
    "Discord.Discord",
    "WhatsApp",
    "nukeop.nuclear",
    "Obsidian.Obsidian"
)

foreach ($app in $apps) {
    Write-Host "Installing $app..."
    winget install --id $app -e --accept-source-agreements --accept-package-agreements
}

# --- Light theme (apps + system) ---
$personalizeKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $personalizeKey -Name AppsUseLightTheme -Value 1 -Type DWord
Set-ItemProperty -Path $personalizeKey -Name SystemUsesLightTheme -Value 1 -Type DWord

Write-Host "Done. Sign out/in for the theme change to fully apply everywhere."
