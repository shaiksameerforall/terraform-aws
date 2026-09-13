# ============================================================
# DynamoDB HitCounter -> Display in PowerShell + CSV Export
# ============================================================

$TableName  = "HitCounter"
$Region     = "eu-central-1"
$OutputFile = "C:\Temp\ALBAIK-app-hits.csv"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "DynamoDB HitCounter"
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Table  : $TableName"
Write-Host "Region : $Region"
Write-Host "CSV    : $OutputFile"
Write-Host ""

# ------------------------------------------------------------
# Check AWS CLI
# ------------------------------------------------------------

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: AWS CLI is not installed." -ForegroundColor Red
    exit 1
}

# ------------------------------------------------------------
# Check AWS credentials
# ------------------------------------------------------------

Write-Host "Checking AWS credentials..." -ForegroundColor Yellow

aws sts get-caller-identity --region $Region --no-cli-pager

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: AWS credentials are invalid." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Reading DynamoDB table..." -ForegroundColor Yellow
Write-Host ""

# ------------------------------------------------------------
# Get all records
# ------------------------------------------------------------

$AllItems = @()
$ExclusiveStartKey = $null
$PageNumber = 0

do {

    $PageNumber++

    Write-Host "Reading page $PageNumber..." -ForegroundColor Gray

    if ($null -eq $ExclusiveStartKey) {

        $Result = aws dynamodb scan `
            --table-name $TableName `
            --region $Region `
            --output json `
            --no-cli-pager

    }
    else {

        $Result = aws dynamodb scan `
            --table-name $TableName `
            --region $Region `
            --output json `
            --no-cli-pager `
            --exclusive-start-key $ExclusiveStartKey

    }

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: DynamoDB scan failed." -ForegroundColor Red
        exit 1
    }

    $JsonResult = $Result | ConvertFrom-Json

    if ($JsonResult.Items) {
        $AllItems += $JsonResult.Items
    }

    if ($JsonResult.LastEvaluatedKey) {

        $ExclusiveStartKey =
            $JsonResult.LastEvaluatedKey |
            ConvertTo-Json -Compress

    }
    else {

        $ExclusiveStartKey = $null

    }

} while ($null -ne $ExclusiveStartKey)

# ------------------------------------------------------------
# Check records
# ------------------------------------------------------------

Write-Host ""
Write-Host "Total records found: $($AllItems.Count)" -ForegroundColor Green
Write-Host ""

if ($AllItems.Count -eq 0) {

    Write-Host "No records found." -ForegroundColor Yellow
    exit 0

}

# ------------------------------------------------------------
# Convert DynamoDB data to PowerShell objects
# ------------------------------------------------------------

$Records = foreach ($Item in $AllItems) {

    $Record = [ordered]@{}

    foreach ($Property in $Item.PSObject.Properties) {

        $Attribute = $Property.Value

        if ($null -ne $Attribute.S) {

            $Record[$Property.Name] = $Attribute.S

        }
        elseif ($null -ne $Attribute.N) {

            $Record[$Property.Name] = $Attribute.N

        }
        elseif ($null -ne $Attribute.BOOL) {

            $Record[$Property.Name] = $Attribute.BOOL

        }
        elseif ($null -ne $Attribute.NULL) {

            $Record[$Property.Name] = ""

        }
        elseif ($null -ne $Attribute.SS) {

            $Record[$Property.Name] =
                ($Attribute.SS -join ";")

        }
        elseif ($null -ne $Attribute.NS) {

            $Record[$Property.Name] =
                ($Attribute.NS -join ";")

        }
        else {

            $Record[$Property.Name] =
                ($Attribute | ConvertTo-Json -Compress)

        }
    }

    [PSCustomObject]$Record
}

# ============================================================
# DISPLAY VALUES IN POWERSHELL
# ============================================================

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "DYNAMODB HIT COUNTER VALUES" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$Records | Format-Table -AutoSize

# ------------------------------------------------------------
# Export CSV
# ------------------------------------------------------------

$OutputDirectory = Split-Path $OutputFile

if (-not (Test-Path $OutputDirectory)) {

    New-Item `
        -ItemType Directory `
        -Path $OutputDirectory `
        -Force | Out-Null

}

$Records | Export-Csv `
    -Path $OutputFile `
    -NoTypeInformation `
    -Encoding UTF8

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "EXPORT COMPLETED" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

Write-Host "Total records : $($Records.Count)"
Write-Host "CSV file      : $OutputFile"
Write-Host ""

# Open CSV automatically
if (Test-Path $OutputFile) {
    Invoke-Item $OutputFile
}
