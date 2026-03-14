param(
    [Parameter(Mandatory = $true)]
    [string]$TexFile
)

$ErrorActionPreference = "Stop"

function Add-ToPathIfExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$PathEntry
    )

    try {
        if ((Test-Path $PathEntry) -and -not (($env:PATH -split ";") -contains $PathEntry)) {
            $env:PATH = "$PathEntry;$env:PATH"
        }
    }
    catch {
        return
    }
}

function Resolve-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $command = Get-Command $Name -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64\$Name"),
        (Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\$Name"),
        (Join-Path $env:ProgramFiles "MiKTeX\miktex\bin\x64\$Name"),
        (Join-Path $env:ProgramFiles "MiKTeX\miktex\bin\$Name"),
        ("C:\Program Files\MiKTeX\miktex\bin\x64\$Name"),
        ("C:\Program Files\MiKTeX\miktex\bin\$Name")
    )

    foreach ($candidate in $candidates) {
        if (-not $candidate) {
            continue
        }

        try {
            if (Test-Path $candidate) {
                return $candidate
            }
        }
        catch {
            continue
        }
    }

    throw "Could not find $Name. Install MiKTeX and ensure the binaries are available."
}

function Invoke-LatexTool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & $Command @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$([System.IO.Path]::GetFileName($Command)) failed with exit code $LASTEXITCODE."
    }
}

$miktexBin = Join-Path $env:LOCALAPPDATA "Programs\MiKTeX\miktex\bin\x64"
$strawberryPaths = @(
    "C:\Strawberry\perl\bin",
    "C:\Strawberry\perl\site\bin",
    "C:\Strawberry\c\bin"
)

Add-ToPathIfExists -PathEntry $miktexBin
foreach ($pathEntry in $strawberryPaths) {
    Add-ToPathIfExists -PathEntry $pathEntry
}

$texPath = [System.IO.Path]::GetFullPath($TexFile)
$workDir = Split-Path -Parent $texPath
$texName = Split-Path -Leaf $texPath
$latexmk = Resolve-Tool -Name "latexmk.exe"

Push-Location $workDir
try {
    Invoke-LatexTool -Command $latexmk -Arguments @(
        "-pdf",
        "-interaction=nonstopmode",
        "-synctex=1",
        "-file-line-error",
        "-outdir=.",
        $texName
    )
}
finally {
    Pop-Location
}
