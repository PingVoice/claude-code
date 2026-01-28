#Requires -Version 5.1
<#
.SYNOPSIS
    PingVoice Installer for Claude Code (Windows)

.DESCRIPTION
    One-liner: irm https://raw.githubusercontent.com/pingvoice/claude-code/master/install.ps1 | iex

.NOTES
    Requires: claude CLI, uv
#>

$ErrorActionPreference = "Stop"

# Colors
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Header {
    Write-Host ""
    Write-Host "🔊 PingVoice Installer for Claude Code" -ForegroundColor Blue
    Write-Host "======================================"
    Write-Host ""
}

function Write-Success($message) {
    Write-Host "  ✓ " -ForegroundColor Green -NoNewline
    Write-Host $message
}

function Write-Error($message) {
    Write-Host "  ✗ " -ForegroundColor Red -NoNewline
    Write-Host $message
}

function Write-Info($message) {
    Write-Host "  → " -ForegroundColor Yellow -NoNewline
    Write-Host $message
}

function Test-CommandExists($command) {
    $null = Get-Command $command -ErrorAction SilentlyContinue
    return $?
}

function Test-ApiKey($apiKey) {
    try {
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
        }
        $body = @{
            message = "API key validated"
        } | ConvertTo-Json

        $response = Invoke-WebRequest -Uri "https://pingvoice.io/api/tts" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing `
            -ErrorAction SilentlyContinue

        return $response.StatusCode -eq 202
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        if ($statusCode -eq 401 -or $statusCode -eq 403) {
            return $false
        }
        # Accept other responses (might be rate limiting, etc.)
        return $true
    }
}

function Add-ToProfile($varName, $varValue) {
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileDir = Split-Path -Parent $profilePath

    # Create profile directory if it doesn't exist
    if (-not (Test-Path $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    # Create profile file if it doesn't exist
    if (-not (Test-Path $profilePath)) {
        New-Item -ItemType File -Path $profilePath -Force | Out-Null
    }

    $envLine = "`$env:$varName = `"$varValue`""
    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue

    if ($profileContent -match "^\`$env:$varName\s*=") {
        # Update existing line
        $profileContent = $profileContent -replace "^\`$env:$varName\s*=.*", $envLine
        Set-Content -Path $profilePath -Value $profileContent
    }
    else {
        # Add new line
        Add-Content -Path $profilePath -Value $envLine
    }
}

function Main {
    Write-Header

    # Voices available
    $voices = @("Kore", "Puck", "Zephyr", "Charon", "Fenrir", "Aoede", "Leda", "Orus", "Perseus")

    # Step 1: Check prerequisites
    Write-Host "Checking prerequisites..."

    if (Test-CommandExists "claude") {
        Write-Success "claude CLI found"
    }
    else {
        Write-Error "claude CLI not found"
        Write-Host ""
        Write-Host "Please install Claude Code first:"
        Write-Host "  https://docs.anthropic.com/en/docs/claude-code"
        exit 1
    }

    if (Test-CommandExists "uv") {
        Write-Success "uv found"
    }
    else {
        Write-Error "uv not found"
        Write-Host ""
        $installUv = Read-Host "Would you like to install uv now? [Y/n]"
        if ([string]::IsNullOrWhiteSpace($installUv) -or $installUv -eq "Y" -or $installUv -eq "y") {
            Write-Host ""
            Write-Info "Installing uv..."
            try {
                Invoke-Expression (Invoke-RestMethod https://astral.sh/uv/install.ps1)
                $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
                if (Test-CommandExists "uv") {
                    Write-Success "uv installed"
                }
                else {
                    Write-Error "Failed to install uv"
                    exit 1
                }
            }
            catch {
                Write-Error "Failed to install uv: $_"
                exit 1
            }
        }
        else {
            Write-Host ""
            Write-Host "Please install uv manually:"
            Write-Host "  powershell -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
            exit 1
        }
    }

    Write-Host ""

    # Step 2: Prompt for API key
    while ($true) {
        $apiKeySecure = Read-Host "Enter your PingVoice API key" -AsSecureString
        $apiKey = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($apiKeySecure))

        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Write-Error "API key is required"
            continue
        }

        Write-Host "  Validating..." -NoNewline
        if (Test-ApiKey $apiKey) {
            Write-Host "`r                    `r" -NoNewline
            Write-Success "API key validated"
            break
        }
        else {
            Write-Host "`r                    `r" -NoNewline
            Write-Error "Invalid API key. Please try again."
        }
    }

    Write-Host ""

    # Step 3: Prompt for user name (optional)
    $userName = Read-Host "Enter your name (for personalized greetings) [skip]"

    if (-not [string]::IsNullOrWhiteSpace($userName)) {
        Write-Success "Name set to: $userName"
    }
    else {
        Write-Info "Skipping personalized name"
        $userName = $null
    }

    Write-Host ""

    # Step 4: Voice selection
    Write-Host "Select a voice (default: Kore):"
    for ($i = 0; $i -lt $voices.Count; $i++) {
        if ($i -eq 0) {
            Write-Host "  $($i + 1)) $($voices[$i]) (default)"
        }
        else {
            Write-Host "  $($i + 1)) $($voices[$i])"
        }
    }
    Write-Host ""
    $voiceChoice = Read-Host "Enter number [1]"

    if ([string]::IsNullOrWhiteSpace($voiceChoice)) {
        $voiceChoice = 1
    }

    $voiceIndex = [int]$voiceChoice - 1
    if ($voiceIndex -ge 0 -and $voiceIndex -lt $voices.Count) {
        $selectedVoice = $voices[$voiceIndex]
        Write-Success "Voice set to: $selectedVoice"
    }
    else {
        $selectedVoice = "Kore"
        Write-Info "Invalid selection, using default: Kore"
    }

    Write-Host ""

    # Step 5: Install plugin
    Write-Host "Installing plugin..."

    try {
        $null = & claude plugin marketplace add pingvoice/claude-code 2>&1
        Write-Success "Marketplace added"
    }
    catch {
        Write-Info "Marketplace already added or updated"
    }

    try {
        $null = & claude plugin install pingvoice@pingvoice 2>&1
        Write-Success "Plugin installed"
    }
    catch {
        Write-Info "Plugin already installed or updated"
    }

    Write-Host ""

    # Step 6: Configure environment
    Write-Host "Configuring environment..."

    # Add PingVoice comment marker if not present
    $profilePath = $PROFILE.CurrentUserAllHosts
    $profileContent = Get-Content $profilePath -Raw -ErrorAction SilentlyContinue
    if (-not ($profileContent -match "# PingVoice Configuration")) {
        Add-Content -Path $profilePath -Value ""
        Add-Content -Path $profilePath -Value "# PingVoice Configuration"
    }

    Add-ToProfile "PINGVOICE_API_KEY" $apiKey

    if ($userName) {
        Add-ToProfile "PINGVOICE_USER_NAME" $userName
    }

    Add-ToProfile "PINGVOICE_API_VOICE_ID" $selectedVoice

    $profileName = Split-Path -Leaf $profilePath
    Write-Success "Added to $profileName"

    # Export for current session
    $env:PINGVOICE_API_KEY = $apiKey
    $env:PINGVOICE_API_VOICE_ID = $selectedVoice
    if ($userName) {
        $env:PINGVOICE_USER_NAME = $userName
    }

    Write-Host ""

    # Step 7: Test TTS
    Write-Host "Testing installation..."

    $testMessage = "Welcome to PingVoice!"
    if ($userName) {
        $testMessage = "Welcome to PingVoice, $userName!"
    }

    try {
        $headers = @{
            "Authorization" = "Bearer $apiKey"
            "Content-Type" = "application/json"
        }
        $body = @{
            message = $testMessage
            voiceId = $selectedVoice
        } | ConvertTo-Json

        $response = Invoke-WebRequest -Uri "https://pingvoice.io/api/tts" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -UseBasicParsing `
            -ErrorAction SilentlyContinue

        if ($response.StatusCode -eq 202) {
            Write-Success "`"$testMessage`" - audio sent"
        }
        else {
            Write-Info "Test message sent (check your PingVoice Dashboard)"
        }
    }
    catch {
        Write-Info "Test message sent (check your PingVoice Dashboard)"
    }

    Write-Host ""

    # Step 8: Success message
    Write-Host "======================================"
    Write-Host "✅ Installation complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. Restart your terminal (or run: . `$PROFILE)"
    Write-Host "  2. Open the PingVoice Dashboard in your browser"
    Write-Host "  3. Start Claude Code and hear the greeting!"
    Write-Host ""
    Write-Host "To enable task summaries (optional):"
    Write-Host "  Run /output-style in Claude Code and select 'pingvoice:TTS Summary'"
    Write-Host ""
    Write-Host "Docs: https://github.com/pingvoice/claude-code"
    Write-Host ""
}

Main
