<#
.SYNOPSIS
     Terminal FX Manager v4.0
    A tool to manage and apply terminal presets automatically.
    Now supports GIFs, MP4s, and URLs!
#>

$ScriptPath = $PSScriptRoot
$PresetsPath = Join-Path $ScriptPath "presets"
$AssetsPath = Join-Path $ScriptPath "assets"

function Show-Header {
    Clear-Host
    $Cyan = [ConsoleColor]::Cyan
    $Magenta = [ConsoleColor]::Magenta
    $Yellow = [ConsoleColor]::Yellow
    $White = [ConsoleColor]::White
    
    Write-Host " "
    Write-Host "   _______                  _             _   _______   __" -ForegroundColor $Cyan
    Write-Host "  |__   __|                (_)           | | |  ____|  / /" -ForegroundColor $Cyan
    Write-Host "     | | ___ _ __ _ __ ___  _ _ __   __ _| | | |__  _  \/ " -ForegroundColor $Cyan
    Write-Host "     | |/ _ \ '__| '_ \   \| | '_ \ / _\ | | |  __| \ \/  " -ForegroundColor $Magenta
    Write-Host "     | |  __/ |  | | | | | | | | | | (_| | | | |    / /\  " -ForegroundColor $Magenta
    Write-Host "     |_|\___|_|  |_| |_|_|_|_|_| |_|\__,_|_| |_|   /_/  \ " -ForegroundColor $Magenta
    Write-Host " "
    Write-Host "   :: ULTIMATE TERMINAL MANAGER :: v4.2 :: BY MEKLASDEV " -ForegroundColor $Yellow
    Write-Host "   ==================================================== " -ForegroundColor $White
}

function Get-Presets {
    return Get-ChildItem -Path $PresetsPath -Directory | Select-Object -ExpandProperty Name
}

function Install-HyperConfig {
    param([string]$PresetName)
    $Source = Join-Path $PresetsPath "$PresetName\.hyper.js"
    $Dest = "$env:USERPROFILE\.hyper.js"
    
    if (Test-Path $Source) {
        Copy-Item -Path $Source -Destination $Dest -Force
        Write-Host "[SUCCESS] Hyper config applied!" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] No .hyper.js found for this preset." -ForegroundColor Yellow
    }
}

function Install-WindowsTerminalConfig {
    param([string]$PresetName)
    $SourcePath = Join-Path $PresetsPath "$PresetName\windows-terminal.json"
    
    if (-not (Test-Path $SourcePath)) {
        Write-Host "[WARNING] No windows-terminal.json found for this preset." -ForegroundColor Yellow
        return
    }

    $WTPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    if (-not (Test-Path $WTPath)) {
        $WTPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    }

    if (Test-Path $WTPath) {
        try {
            # Backup
            Copy-Item -Path $WTPath -Destination "$WTPath.bak" -Force
            Write-Host "[BACKUP] Settings backed up to settings.json.bak" -ForegroundColor Gray

            # Read Settings (Ignore comments by -Raw and manual cleaning if needed, but ConvertFrom-Json often fails on comments in WinPS 5.1)
            # We will use stricter parsing. If it fails, we abort to avoid corruption.
            try {
                $JsonContent = Get-Content -Path $WTPath -Raw
                # 1. Remove Block Comments /* ... */
                $JsonContentClean = $JsonContent -replace '(?s)/\*.*?\*/', ''
                # 2. Remove Line Comments // ...
                $JsonContentClean = $JsonContentClean -replace '(?m)(?<!:)\/\/.*$', ''
                # 3. Remove Trailing Commas (comma followed by closing brace/bracket)
                $JsonContentClean = $JsonContentClean -replace ',\s*([\}\]])', '$1'
                
                $Settings = $JsonContentClean | ConvertFrom-Json
            } catch {
                Write-Host "[ERROR] strict JSON parsing failed." -ForegroundColor Red
                Write-Host "   This is usually due to comments or trailing commas in your existing settings.json." -ForegroundColor Gray
                Write-Host "   Error details: $_" -ForegroundColor DarkGray
                
                # FALLBACK / SAFE MODE PROMPT
                Write-Host "`n[!] OPTION: SAFE MODE OVERWRITE" -ForegroundColor Yellow
                Write-Host "I can create a FRESH settings.json with only this preset."
                Write-Host "Your old config is backed up to settings.json.bak"
                
                $Confirm = Read-Host "Do you want to overwrite your config with a clean version? (Y/N)"
                if ($Confirm -eq 'Y' -or $Confirm -eq 'y') {
                    Write-Host "Creating fresh configuration (Restoring Standard Profiles)..." -ForegroundColor Cyan
                    # Basic skeleton for WT with STANDARD PROFILES
                    $Settings = @{
                        "defaultProfile" = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
                        "profiles" = @{
                            "defaults" = @{}
                            "list" = @(
                                @{
                                    "guid" = "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}"
                                    "name" = "Windows PowerShell"
                                    "commandline" = "powershell.exe"
                                    "hidden" = $false
                                },
                                @{
                                    "guid" = "{0caa0dad-35d5-51a9-858a-351d5ade1a15}"
                                    "name" = "Command Prompt"
                                    "commandline" = "cmd.exe"
                                    "hidden" = $false
                                }
                            )
                        }
                        "schemes" = @()
                    }
                    # Convert hashtable to PSCustomObject for dot notation below to work
                    # (Quick-and-dirty deep conversion via JSON roundtrip is safer/easier than manual casting)
                    $Settings = $Settings | ConvertTo-Json -Depth 10 | ConvertFrom-Json
                } else {
                    Write-Host "Aborting Windows Terminal setup." -ForegroundColor Red
                    return
                }
            }

            # Read Preset
            $PresetContent = Get-Content -Path $SourcePath -Raw 
            
            # Escape path properly for JSON (needs double backslashes)
            $EscapedRoot = $ScriptPath.Replace("\", "\\")
            $PresetContent = $PresetContent.Replace("%REPO_ROOT%", $EscapedRoot)
            
            $PresetSettings = $PresetContent | ConvertFrom-Json
            
            # DEBUG: Show what path we calculated
            if ($PresetSettings.profiles.list[0].backgroundImage) {
                 Write-Host "[DEBUG] Resolved Background Path: $($PresetSettings.profiles.list[0].backgroundImage)" -ForegroundColor DarkGray
            }


            # --- CRITICAL FIXES FOR ARRAYS ---
            
            # Ensure proper structure (Safe checks)
            if ($null -eq $Settings.profiles) { $Settings | Add-Member -Name "profiles" -Value ([PSCustomObject]@{ list = @() }) -MemberType NoteProperty }
            if ($null -eq $Settings.profiles.list) { $Settings.profiles.list = @() }
             # Safe check for schemes using PSObject properties
            if (-not ($null -ne $Settings.PSObject -and $Settings.PSObject.Properties.Name -contains "schemes")) { 
                 $Settings | Add-Member -Name "schemes" -Value @() -MemberType NoteProperty 
            }
            if ($null -eq $Settings.schemes) { $Settings.schemes = @() }

            # Force to ArrayLists to avoid "fixed size" or "single object" issues
            $ProfileList = [System.Collections.ArrayList]@($Settings.profiles.list)
            $SchemeList = [System.Collections.ArrayList]@($Settings.schemes)

            # Check for PowerShell Core vs Windows PowerShell
            $ShellCmd = "powershell.exe"
            if (Get-Command "pwsh.exe" -ErrorAction SilentlyContinue) {
                $ShellCmd = "pwsh.exe"
            }

            # Merge Profiles
            if ($PresetSettings.profiles.list) {
                foreach ($newProfile in $PresetSettings.profiles.list) {
                    
                    # 1. Ensure GUID exists. If missing, generate one based on name hash or random to trigger update logic
                    if (-not $newProfile.guid) {
                        # Tweak: Use a deterministic GUID based on name if possible to avoid infinite dupes on re-run,
                        # OR just check if a profile with this name exists and reuse its GUID.
                        $ExistingByName = $ProfileList | Where-Object { $_.name -eq $newProfile.name }
                        if ($ExistingByName -and $ExistingByName.guid) {
                            $newProfile | Add-Member -Name "guid" -Value $ExistingByName.guid -MemberType NoteProperty -Force
                        } else {
                            $newProfile | Add-Member -Name "guid" -Value ("{" + [guid]::NewGuid().ToString() + "}") -MemberType NoteProperty
                        }
                    }
                    
                    # Fix Shell Command if it's set to pwsh but user doesn't have it
                    if ($newProfile.commandline -eq "pwsh.exe" -and $ShellCmd -eq "powershell.exe") {
                        $newProfile.commandline = "powershell.exe"
                        Write-Host "[INFO] 'pwsh.exe' not found. Falling back to 'powershell.exe' for profile '$($newProfile.name)'." -ForegroundColor Yellow
                    }
                    
                    # 2. Remove ANY existing profile with the same GUID *OR* the same Name
                    # This prevents "same GUID" errors and "duplicate name" clutter
                    $Existing = $ProfileList | Where-Object { ($_.guid -eq $newProfile.guid) -or ($_.name -eq $newProfile.name) }
                    if ($Existing) { 
                        # To be safe, remove all matches (though usually just one)
                        # We use a loop because ArrayList removal by object removes only first instance
                        foreach ($ex in @($Existing)) { $ProfileList.Remove($ex) }
                    }
                    
                    # 3. Add the new properly configured profile
                    $ProfileList.Add($newProfile) | Out-Null
                    
                    
                    # SET AS DEFAULT PROFILE
                    $Settings.defaultProfile = $newProfile.guid
                    Write-Host "[INFO] Set '$($newProfile.name)' as the DEFAULT Windows Terminal profile." -ForegroundColor Cyan
                    
                    # --- AUTO-APPLY TO DEFAULTS (GLOBAL STYLE) ---
                    # Use the style from the first profile in the preset to update profiles.defaults
                    # This ensures detailed visuals apply to CMD, PowerShell, etc. if they don't override them.
                    $StyleSource = $PresetSettings.profiles.list[0]
                    if ($null -eq $Settings.profiles.defaults) { 
                        $Settings.profiles | Add-Member -Name "defaults" -Value (@{}) -MemberType NoteProperty 
                    }
                    
                    # Apply specific visual properties to 'defaults'
                    $PropsToCopy = @("colorScheme", "backgroundImage", "backgroundImageOpacity", "backgroundImageStretchMode", "font", "cursorShape", "cursorColor", "experimental.pixelShaderPath", "experimental.retroTerminalEffect")
                    
                    foreach ($prop in $PropsToCopy) {
                         if ($null -ne $StyleSource.$prop) {
                             $Settings.profiles.defaults | Add-Member -Name $prop -Value $StyleSource.$prop -MemberType NoteProperty -Force
                         }
                    }
                    Write-Host "[INFO] Applied visual style GLOBALLY (to Command Prompt, PowerShell, WSL, etc.)" -ForegroundColor Magenta
                }
            }
            $Settings.profiles.list = $ProfileList

            # Merge Schemes
            if ($PresetSettings.schemes) {
                foreach ($newScheme in $PresetSettings.schemes) {
                    # Remove existing
                    $Existing = $SchemeList | Where-Object { $_.name -eq $newScheme.name }
                    if ($Existing) { $SchemeList.Remove($Existing) }
                    
                    # Add new
                    $SchemeList.Add($newScheme) | Out-Null
                }
            }
            $Settings.schemes = $SchemeList

            # Save with UTF8 Encoding (No BOM is standard for JSON, but UTF8 works)
            $Settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $WTPath -Encoding UTF8
            
            Write-Host "[SUCCESS] Windows Terminal profile installed automatically!" -ForegroundColor Green
            Write-Host "         Open Terminal settings and select '$($PresetSettings.profiles.list[0].name)' as your profile." -ForegroundColor Cyan

        } catch {
            Write-Host "[ERROR] Failed to patch settings.json: $_" -ForegroundColor Red
            Write-Host "Stack Trace: $($_.Exception.StackTrace)" -ForegroundColor Gray
        }
    } else {
        Write-Host "[ERROR] Windows Terminal settings.json not found." -ForegroundColor Red
    }
}

function Install-OhMyPosh-Theme {
    param([string]$PresetName)
    $Source = Join-Path $PresetsPath "$PresetName\theme.omp.json"
    $DestDir = "$env:USERPROFILE\.poshthemes"
    
    if (-not (Test-Path $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir | Out-Null
    }
    
    if (Test-Path $Source) {
        $DestFile = Join-Path $DestDir "custom-$PresetName.omp.json"
        Copy-Item -Path $Source -Destination $DestFile -Force
        
        Write-Host "[SUCCESS] Theme copied to $DestFile" -ForegroundColor Green
        
        $ProfilePath = $PROFILE
        if (-not (Test-Path $ProfilePath)) {
            New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
        }
        $ProfileContent = Get-Content $ProfilePath -Raw -ErrorAction SilentlyContinue
        $InitCommand = "oh-my-posh init pwsh --config '$DestFile' | Invoke-Expression"
        
        if ($ProfileContent -notmatch "oh-my-posh.*custom-$PresetName") {
            Add-Content -Path $ProfilePath -Value "`n$InitCommand"
            Write-Host "[SUCCESS] Added init command to `$PROFILE" -ForegroundColor Green
        }
    }
}

function Install-ShaderSelector {
    param([string]$PresetName)
    
    Write-Host "`n=== SHADER SELECTOR ===" -ForegroundColor Cyan
    Write-Host "Customize your look with a post-processing effect:"
    
    # Shader Descriptions
    $Descriptions = @{
        "Retro" = "Classic CRT monitor effect with scanlines"
        "Matrix" = "Digital rain and green tint"
        "Glitch" = "Cyberpunk chromatic aberration and shaking"
        "Bloom" = "Neon glow effect for bright colors"
        "CRT-Green" = "Monochromatic green fallout terminal"
        "CRT-Amber" = "Monochromatic amber retro display"
        "NightVision" = "Tactical green vision with noise"
        "Sepia" = "Old photo style yellowish tint"
        "Grayscale" = "Black and white monochrome"
        "Invert" = "Inverts all colors (Negative)"
        "VHS" = "Analog tracking errors and jitter"
        "Pixelate" = "Low resolution 8-bit mosaic"
        "Ripple" = "Underwater wavy distortion"
        "HueShift" = "Psychedelic cycling colors"
        "Scanlines" = "Simple horizontal TV lines"
        "Vignette" = "Dark corners cinematic effect"
        "Contrast" = "High contrast crunchy look"
        "FishEye" = "Wide angle lens distortion"
        "SobelEdge" = "Glowing edge detection (Outline)"
        "RadialBlur" = "Motion blur zooming out"
        "Dreamy" = "Soft focus and glow"
        "Crosshatch" = "Comic book style shading"
        "CyberScan" = "Futuristic moving scanner line"
        "RedTint" = "system_failure / red alert"
        "BlueTint" = "Cold ice terminal"
        "Noise" = "Static signal interference"
    }

    $Shaders = Get-ChildItem -Path "$AssetsPath\shaders" -Filter "*.hlsl"
    $i = 1
    Write-Host "[0] None (Clear)"
    foreach ($s in $Shaders) {
        $Desc = if ($Descriptions.ContainsKey($s.BaseName)) { $Descriptions[$s.BaseName] } else { "Custom shader" }
        Write-Host "[$i] $($s.BaseName) - $Desc"
        $i++
    }
    
    $Choice = Read-Host "Choose a shader"
    if ($Choice -eq "0") { return }
    
    try {
        $Idx = [int]$Choice - 1
        if ($Idx -ge 0 -and $Idx -lt $Shaders.Count) {
             $SelectedShader = $Shaders[$Idx]
             # Fix path resolution: Replace %REPO_ROOT% with actual path immediately
             # (Escaped for JSON: backslashes need to be doubled)
             $EscapedRoot = $ScriptPath.Replace("\", "\\")
             $ShaderPath = "$EscapedRoot\\assets\\shaders\\$($SelectedShader.Name)"
             
             # Apply to Windows Terminal Settings
             $WTPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
             if (-not (Test-Path $WTPath)) { $WTPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json" }
             
             if (Test-Path $WTPath) {
                 $JsonContent = Get-Content -Path $WTPath -Raw
                 # Simple regex cleanup just in case
                 $JsonContentClean = $JsonContent -replace '(?s)/\*.*?\*/', '' -replace '(?m)(?<!:)\/\/.*$', '' -replace ',\s*([\}\]])', '$1'
                 $Settings = $JsonContentClean | ConvertFrom-Json
                 
                 # Look for our newly installed profile (by name) OR modify defaults
                 # Modifying defaults is safer for 'global' look
                 if ($null -eq $Settings.profiles.defaults) { $Settings.profiles | Add-Member -Name "defaults" -Value (@{}) -MemberType NoteProperty }
                 
                 $Settings.profiles.defaults | Add-Member -Name "experimental.pixelShaderPath" -Value $ShaderPath -MemberType NoteProperty -Force
                 
                 # Also try to update specific profile if found
                 if ($Settings.profiles.list) {
                     foreach ($prof in $Settings.profiles.list) {
                         if ($prof.name -like "*$PresetName*" -or $prof.name -eq "Anonymous Hacker" -or $prof.name -eq "Vaporwave") {
                              $prof | Add-Member -Name "experimental.pixelShaderPath" -Value $ShaderPath -MemberType NoteProperty -Force
                         }
                     }
                 }

                 $Settings | ConvertTo-Json -Depth 10 | Out-File -FilePath $WTPath -Encoding UTF8
                 Write-Host "[SUCCESS] Applied shader: $($SelectedShader.BaseName)" -ForegroundColor Green
             }
        }
    } catch {
        Write-Host "[WARNING] Could not apply shader: $_" -ForegroundColor Yellow
    }
}

function Create-Custom-Preset {
    Clear-Host
    Show-Header
    Write-Host "   [ CUSTOM PRESET WIZARD ]" -ForegroundColor Cyan
    Write-Host "   Let's build your dream terminal!" -ForegroundColor Gray
    Write-Host ""
    
    $Name = Read-Host "   1. Preset Name (e.g. MyNeon)"
    if ([string]::IsNullOrWhiteSpace($Name)) { return }
    $SafeName = $Name -replace "[^a-zA-Z0-9]", ""
    
    # --- COLORS ---
    Write-Host ""
    $ColorInput = Read-Host "   2. Key Color (Hex #ff00ff OR Name like 'red')"
    $Color = "#00ff00" # Default green
    
    # Simple color name lookup
    $Colors = @{
        "red"="#ff0000"; "green"="#00ff00"; "blue"="#0000ff"; "cyan"="#00ffff";
        "magenta"="#ff00ff"; "yellow"="#ffff00"; "white"="#ffffff"; "black"="#000000";
        "purple"="#800080"; "orange"="#ffa500"; "pink"="#ffc0cb"
    }
    if ($Colors.ContainsKey($ColorInput.ToLower())) { 
        $Color = $Colors[$ColorInput.ToLower()]
        Write-Host "      -> Resolved to $Color" -ForegroundColor DarkGray
    } elseif ($ColorInput -match "^#[0-9a-fA-F]{6}$") {
        $Color = $ColorInput
    }
    
    # --- BACKGROUND ---
    Write-Host ""
    Write-Host "   3. Background Source" -ForegroundColor Yellow
    Write-Host "   [1] Choose existing (bundled)"
    Write-Host "   [2] URL (Image/GIF/Video)"
    Write-Host "   [3] Local File Path"
    Write-Host "   [4] None (Solid Color)"
    $BgChoice = Read-Host "   >> Select"
    
    $BgPath = $null
    
    switch ($BgChoice) {
        "1" {
            $Bgs = Get-ChildItem -Path "$AssetsPath\backgrounds"
            $i = 1
            foreach ($b in $Bgs) { Write-Host "   [$i] $($b.Name)"; $i++ }
            $c = Read-Host "   >> Select number"; 
            try { $Idx = [int]$c - 1; if ($Idx -ge 0 -and $Idx -lt $Bgs.Count) { $BgPath = "%REPO_ROOT%\\assets\\backgrounds\\$($Bgs[$Idx].Name)" } } catch {}
        }
        "2" {
            $Url = Read-Host "   >> Paste URL"
            if (-not [string]::IsNullOrWhiteSpace($Url)) {
                Write-Host "      Analyzing URL..." -ForegroundColor Cyan
                
                $CustomAssetsDir = Join-Path $AssetsPath "custom"
                if (-not (Test-Path $CustomAssetsDir)) { New-Item -ItemType Directory -Path $CustomAssetsDir -Force | Out-Null }
                
                # --- ROBUST DETECTION LOGIC ---
                $Ext = ".jpg" # Default
                $Hit = $false
                
                # 1. URL Pattern Matching (Fastest)
                if ($Url -match "(?i)video" -or $Url -match "(?i)\.mp4" -or $Url -match "(?i)pexels.*download") {
                    $Ext = ".mp4"
                    $Hit = $true
                    Write-Host "      [MATCH] URL pattern indicates Video." -ForegroundColor DarkGray
                }
                
                # 2. Content-Type Header (If not already matched)
                if (-not $Hit) {
                    try {
                        $Head = Invoke-WebRequest -Uri $Url -Method Head -UseBasicParsing -MaximumRedirection 5 -ErrorAction SilentlyContinue
                        if ($Head.Headers["Content-Type"] -match "video") { 
                            $Ext = ".mp4"
                            $Hit = $true
                             Write-Host "      [MATCH] Header says type is Video." -ForegroundColor DarkGray
                        }
                    } catch {}
                }
                
                # 3. Magic Number Peeking (If still unsure)
                if (-not $Hit) {
                    try {
                         Write-Host "      [DEEP SCAN] Checking file signature..." -ForegroundColor DarkGray
                         # Download first 64 bytes to check for MP4 signature 'ftyp'
                         $Req = [System.Net.HttpWebRequest]::Create($Url)
                         $Req.AddRange(0, 64)
                         $Resp = $Req.GetResponse()
                         $Stream = $Resp.GetResponseStream()
                         $Buffer = New-Object byte[] 64
                         $BytesRead = $Stream.Read($Buffer, 0, 64)
                         $Stream.Close()
                         $Resp.Close()
                         
                         $Hex = ($Buffer[0..$BytesRead] | ForEach-Object { "{0:X2}" -f $_ }) -join ""
                         # MP4 usually contains 'ftyp' at offset 4 (66 74 79 70)
                         # Simple check for 'ftyp' bytes: 66747970
                         if ($Hex -match "66747970") {
                             $Ext = ".mp4"
                             $Hit = $true
                             Write-Host "      [MATCH] File signature confirms MP4 Video." -ForegroundColor Green
                         }
                    } catch { 
                        Write-Host "      [INFO] Deep scan skipped/failed." -ForegroundColor DarkGray 
                    }
                }
                
                # 4. Manual Verification Fallback
                if (-not $Hit) {
                    Write-Host "      [?] Could not automatically detect file type." -ForegroundColor Yellow
                    $Manual = Read-Host "      Is this a video (MP4)? (Y/N)"
                    if ($Manual -eq 'Y' -or $Manual -eq 'y') { $Ext = ".mp4" }
                }
                
                # WARNING FOR WINDOWS TERMINAL USERS
                if ($Ext -eq ".mp4") {
                     Write-Host "      [WARNING] Windows Terminal usually supports GIFs, but NOT MP4 videos natively!" -ForegroundColor Red
                     Write-Host "                The background might be black. Try converting to GIF if possible." -ForegroundColor Yellow
                }

                $FileName = "$SafeName$Ext"
                $LocalFile = Join-Path $CustomAssetsDir $FileName
                
                try {
                    Write-Host "      Downloading..." -ForegroundColor Green
                    $oldP = $ProgressPreference; $ProgressPreference = 'SilentlyContinue'
                    Invoke-WebRequest -Uri $Url -OutFile $LocalFile -UserAgent "Mozilla/5.0" -UseBasicParsing
                    $ProgressPreference = $oldP
                    $BgPath = "%REPO_ROOT%\\assets\\custom\\$FileName"
                } catch { Write-Host "      Download failed." -ForegroundColor Red }
            }
        }
        "3" {
             $PathInput = Read-Host "   >> Paste full path"
             if (Test-Path $PathInput) {
                 $BgPath = $PathInput.Replace("\", "\\")
             }
        }
    }
    
    # --- OPACITY ---
    Write-Host ""
    $Opacity = Read-Host "   4. Background Opacity (0.1 to 1.0, Default 0.4)"
    if ([string]::IsNullOrWhiteSpace($Opacity)) { $Opacity = "0.4" }
    
    # --- CURSOR ---
    Write-Host ""
    Write-Host "   5. Cursor Shape" -ForegroundColor Yellow
    Write-Host "   [1] Bar ( | )"
    Write-Host "   [2] Vintage ( _ )"
    Write-Host "   [3] Filled Box ( [] )"
    Write-Host "   [4] Empty Box ( [] )"
    $CursorChoice = Read-Host "   >> Select"
    $CursorShape = switch ($CursorChoice) { "1" {"bar"}; "2" {"vintage"}; "3" {"filledBox"}; "4" {"emptyBox"}; Default {"bar"} }
    
    # --- FONT ---
    Write-Host ""
    $FontName = Read-Host "   6. Font Name (Default: 'CaskaydiaCove Nerd Font')"
    if ([string]::IsNullOrWhiteSpace($FontName)) { $FontName = "CaskaydiaCove Nerd Font" }
    
    # --- SHADER ---
    Write-Host ""
    Write-Host "   7. Initial Shader Effect" -ForegroundColor Yellow
    Write-Host "   [0] None"
    $Shaders = Get-ChildItem -Path "$AssetsPath\shaders" -Filter "*.hlsl"
    $i = 1
    foreach ($s in $Shaders) { Write-Host "   [$i] $($s.BaseName)"; $i++ }
    $ShaderChoice = Read-Host "   >> Select"
    $ShaderPathJson = $null
    try {
        $SIdx = [int]$ShaderChoice - 1
        if ($SIdx -ge 0 -and $SIdx -lt $Shaders.Count) {
             # Use generic path for config file portability
             $ShaderPathJson = "%REPO_ROOT%\\assets\\shaders\\$($Shaders[$SIdx].Name)"
        }
    } catch {}

    
    # --- SAVE PRESET ---
    $PresetDir = Join-Path $PresetsPath $SafeName
    New-Item -ItemType Directory -Path $PresetDir -Force | Out-Null
    
    # WT Config
    $WTConfig = @{
        "profiles" = @{
            "list" = @(
                @{
                    "name" = $Name
                    "commandline" = "pwsh.exe"
                    "colorScheme" = $Name
                    "cursorShape" = $CursorShape
                    "cursorColor" = $Color
                    "backgroundImage" = $BgPath
                    "backgroundImageOpacity" = [double]$Opacity
                    "backgroundImageStretchMode" = "uniformToFill"
                    "font" = @{ "face" = $FontName; "size" = 12 }
                    "padding" = "10, 10, 10, 10"
                }
            )
        }
        "schemes" = @(
            @{
                "name" = $Name
                "background" = "#0c0c0c"
                "foreground" = "#e0e0e0"
                "cursorColor" = $Color
                "black"="#0c0c0c"; "red"=$Color; "green"=$Color; "yellow"=$Color
                "blue"=$Color; "purple"=$Color; "cyan"=$Color; "white"="#f1f1f1"
                "brightBlack"="#666666"; "brightRed"=$Color; "brightGreen"=$Color; "brightYellow"=$Color
                "brightBlue"=$Color; "brightPurple"=$Color; "brightCyan"=$Color; "brightWhite"="#ffffff"
            }
        )
    }
    
    if ($ShaderPathJson) {
        $WTConfig.profiles.list[0] | Add-Member -Name "experimental.pixelShaderPath" -Value $ShaderPathJson -MemberType NoteProperty
    }
    
    $WTConfig | ConvertTo-Json -Depth 5 | Out-File (Join-Path $PresetDir "windows-terminal.json") -Encoding UTF8
    
    # Hyper Config (Simplified)
    $HyperConfig = @"
module.exports = {
  config: {
    fontFamily: '"$FontName", monospace',
    cursorColor: '$Color',
    foregroundColor: '$Color',
    borderColor: '$Color',
    css: '.hyper_main { border: 2px solid $Color; }',
    colors: { black: '#000', red: '$Color', green: '$Color', blue: '$Color', white: '#fff' }
  },
  plugins: ['hyper-power-mode'],
  hyperPowerMode: { "shake": false, "particles": true }
};
"@
    $HyperConfig | Out-File (Join-Path $PresetDir ".hyper.js") -Encoding UTF8
    
    Write-Host "`n   [SUCCESS] Preset '$Name' created! Use menu to Install it." -ForegroundColor Green
    Start-Sleep -Seconds 2
}

# Main Loop
while ($true) {
    Show-Header
    $Presets = Get-Presets
    
    Write-Host "   [ AVAILABLE PRESETS ]" -ForegroundColor Green
    Write-Host "   ---------------------" -ForegroundColor DarkGray
    $i = 1
    foreach ($p in $Presets) {
        Write-Host "   [$i] $p" -ForegroundColor Cyan
        $i++
    }
    
    Write-Host ""
    Write-Host "   [ CUSTOMIZATION ]" -ForegroundColor Yellow
    Write-Host "   -----------------" -ForegroundColor DarkGray
    $CustomOption = $Presets.Count + 1
    Write-Host "   [$CustomOption] Create Custom Preset (Wizard)" -ForegroundColor Yellow
    Write-Host "   [Q] Quit" -ForegroundColor Red
    Write-Host ""
    
    $Choice = Read-Host "   >> Choose an option"
    
    if ($Choice -eq 'Q' -or $Choice -eq 'q') { break }
    
    try {
        $Index = [int]$Choice - 1
        
        if ($Index -eq $Presets.Count) {
             Create-Custom-Preset
        }
        elseif ($Index -ge 0 -and $Index -lt $Presets.Count) {
            $Selected = $Presets[$Index]
            Write-Host "`nApplying preset: $Selected..." -ForegroundColor Magenta
            
            Install-HyperConfig -PresetName $Selected
            Install-WindowsTerminalConfig -PresetName $Selected
            Install-OhMyPosh-Theme -PresetName $Selected
            
            # Offer Shader Selection
            Install-ShaderSelector -PresetName $Selected
            
            Write-Host "`nDone! Restart your terminal to see changes." -ForegroundColor Green
            Pause
        }
    } catch {
       # Ignore
    }
}
