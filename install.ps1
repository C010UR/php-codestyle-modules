#requires -version 7

function Write-Succ {
    param(
        [Parameter(Mandatory = $true)][string]$text
    )
    
    Write-Host "`e[32m :: $text`e[0m"
}

function Write-Warn {
    param(
        [Parameter(Mandatory = $true)][string]$text
    )
    
    Write-Host "`e[33m :: $text`e[0m"
}

function Write-Err {
    param(
        [Parameter(Mandatory = $true)][string]$text
    )
    
    Write-Host "`e[31m !! $text`e[0m"
}

function Write-Up {
    Write-Host "`e[1A" -NoNewline
}

function Add-PathToEnv {
    param(
        [Parameter(Mandatory = $true)][string]$path
    )

    $res = [Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User) -split ';' | findstr $path

    if (!$res) {
        Write-Host
        Write-Warn "PATH entry $path is not present, adding..."

        $res_path = "$([Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User));$path"

        [Environment]::SetEnvironmentVariable("Path", $res_path, [System.EnvironmentVariableTarget]::User)
        $env:Path = $res_path

        Write-Succ "$path was added to the PATH."
        Write-Err "You need to restart all PowerShell instances for the changes to take effect!"

    }
}

function composer-install {
    param(
        [Parameter(Mandatory = $true)][string]$label,
        [Parameter(Mandatory = $true)][string]$name
    )
    Write-Warn "Searching for $label..."
    Write-Up

    $null = composer global show squizlabs/php_codesniffer 2>&1 3>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Succ "$label is already installed."
        Write-Warn "Updating..."
        $null = composer global update $name 2>&1 3>&1
        Write-Succ "Update finished."
    } else {
        Write-Warn "$label is not installed, installing..."
        $null = composer global require $code_sniffer 2>&1 3>&1
        Write-Succ "$label was successfully installed."
    }
}

function npm-install {
    param(
        [Parameter(Mandatory = $true)][string]$label,
        [Parameter(Mandatory = $true)][string]$name
    )

    Write-Warn "Searching for $label..."
    Write-Up
    
    $modules = ConvertFrom-Json $($(Invoke-Expression "npm list --json -g") -join '') -AshashTable

    if ($modules["dependencies"][$name]) {
        Write-Succ "$label is already installed."
        Write-Warn "Updating..."
        npm update $name -g | Out-Null
        Write-Succ "Update finished."
    } else {
        Write-Warn "$label is not installed, installing..."
        npm install $name -g | Out-Null
        Write-Succ "$label was successfully installed."
    }
}

$code_sniffer = "squizlabs/php_codesniffer"
$prettier = "prettier"
$prettier_php = "@prettier/plugin-php"

composer-install "PHP Code Sniffer" $code_sniffer
Write-Host

npm-install "Prettier" $prettier
Write-Host
npm-install "Prettier PHP module" $prettier_php

Add-PathToEnv "$env:appdata\npm"
Add-PathToEnv "$env:appdata\Composer\vendor\bin"