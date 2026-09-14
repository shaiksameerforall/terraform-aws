# ============================================================
# DynamoDB HitCounter -> Display in PowerShell + CSV Export
# ============================================================

$TableName  = "HitCounter"
$Region     = "eu-central-1"
$OutputFile = "C:\Temp\ALBAIK-app-hits.csv"

function Write-Log($Message) {
    [Console]::Error.WriteLine($Message)
}

Write-Log ""
Write-Log "============================================"
Write-Log "DynamoDB HitCounter"
Write-Log "============================================"
Write-Log "Table  : $TableName"
Write-Log "Region : $Region"
Write-Log "CSV    : $OutputFile"
Write-Log ""

# ------------------------------------------------------------
# Check AWS CLI
# ------------------------------------------------------------

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Log "ERROR: AWS CLI is not installed."
    exit 1
}

# ------------------------------------------------------------
# Check AWS credentials
# ------------------------------------------------------------

Write-Log "Checking AWS credentials..."

$null = aws sts get-caller-identity --region $Region --no-cli-pager

if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR: AWS credentials are invalid."
    exit 1
}

Write-Log ""
Write-Log "Reading DynamoDB table..."
Write-Log ""

# ------------------------------------------------------------
# Get all records
# ------------------------------------------------------------

$AllItems = @()
$ExclusiveStartKey = $null
$PageNumber = 0

do {

    $PageNumber++

    Write-Log "Reading page $PageNumber..."

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
        Write-Log "ERROR: DynamoDB scan failed."
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

Write-Log ""
Write-Log "Total records found: $($AllItems.Count)"
Write-Log ""

if ($AllItems.Count -eq 0) {

    Write-Log "No records found."
    [PSCustomObject]@{
        count = "0"
        file  = "$OutputFile"
    } | ConvertTo-Json -Compress
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

Write-Log ""
Write-Log "============================================"
Write-Log "EXPORT COMPLETED"
Write-Log "============================================"
Write-Log "Total records : $($Records.Count)"
Write-Log "CSV file      : $OutputFile"
Write-Log ""

# Output JSON for Terraform data.external to STDOUT
[PSCustomObject]@{
    count = "$($Records.Count)"
    file  = "$OutputFile"
} | ConvertTo-Json -Compress


