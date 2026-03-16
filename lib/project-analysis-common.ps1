# Project Analysis Common Functions

function Write-Step {
    param([string]$Message)
    Write-Host "`n$Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "Success: $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "Warning: $Message" -ForegroundColor Yellow
}

function Write-Info {
    param([string]$Message)
    Write-Host "  $Message" -ForegroundColor Gray
}

function Detect-TechStack {
    param([string]$Path)
    Write-Info "Detecting tech stack..."
    $detected = @()

    if (Test-Path "$Path\package.json") {
        $detected += "typescript/nodejs"
    }
    if (Test-Path "$Path\requirements.txt") {
        $detected += "python"
    }
    if (Test-Path "$Path\pom.xml") {
        $detected += "java-maven"
    }
    if (Test-Path "$Path\build.gradle") {
        $detected += "java-gradle"
    }
    if (Test-Path "$Path\CMakeLists.txt") {
        $detected += "cpp"
    }
    if (Test-Path "$Path\go.mod") {
        $detected += "go"
    }
    if (Test-Path "$Path\Cargo.toml") {
        $detected += "rust"
    }

    $csprojFiles = Get-ChildItem -Path $Path -Filter "*.csproj" -ErrorAction SilentlyContinue
    if ($csprojFiles) {
        $detected += "csharp"
    }

    $vbprojFiles = Get-ChildItem -Path $Path -Filter "*.vbproj" -ErrorAction SilentlyContinue
    if ($vbprojFiles) {
        $detected += "vbnet"
    }

    if ($detected.Count -eq 0) {
        Write-Warning-Custom "No known tech stack detected"
    }

    return $detected
}

function Get-ProjectDescription {
    param([string]$Path)
    Write-Info "Extracting project description..."

    $readmePath = "$Path\README.md"
    if (Test-Path $readmePath) {
        $readme = Get-Content $readmePath -Raw
        if ($readme -match '(?m)^#\s+(.+?)$') {
            return $Matches[1]
        }
    }

    if (Test-Path "$Path\package.json") {
        try {
            $packageJson = Get-Content "$Path\package.json" | ConvertFrom-Json
            if ($packageJson.description) {
                return $packageJson.description
            }
        } catch {
            Write-Info "Cannot parse package.json"
        }
    }

    $projectName = Split-Path $Path -Leaf
    return $projectName
}

function Get-KeyCommands {
    param([string]$Path, [array]$TechStack)
    Write-Info "Extracting key commands..."

    $commands = @()

    if ($TechStack -contains "typescript/nodejs") {
        $commands += "npm install"
        $commands += "npm run build"
        $commands += "npm test"
    }

    if ($TechStack -contains "python") {
        $commands += "pip install -r requirements.txt"
        $commands += "pytest"
    }

    if ($TechStack -contains "java-maven") {
        $commands += "mvn clean install"
        $commands += "mvn test"
    }

    if ($TechStack -contains "java-gradle") {
        $commands += "gradle build"
        $commands += "gradle test"
    }

    if ($TechStack -contains "cpp") {
        $commands += "cmake -B build"
        $commands += "cmake --build build"
    }

    if ($TechStack -contains "csharp") {
        $commands += "dotnet build"
        $commands += "dotnet test"
    }

    if ($TechStack -contains "go") {
        $commands += "go build"
        $commands += "go test ./..."
    }

    if ($TechStack -contains "rust") {
        $commands += "cargo build"
        $commands += "cargo test"
    }

    return $commands
}

function Get-KeyDirectories {
    param([string]$Path)
    Write-Info "Analyzing project structure..."

    $excludeDirs = @(
        'node_modules', '.git', '.venv', 'venv', '__pycache__',
        'bin', 'obj', 'target', 'build', 'dist', '.next',
        'coverage', '.pytest_cache', '.idea', '.vscode'
    )

    $dirs = Get-ChildItem -Path $Path -Directory -ErrorAction SilentlyContinue |
        Where-Object { $excludeDirs -notcontains $_.Name } |
        Select-Object -ExpandProperty Name

    return $dirs
}
