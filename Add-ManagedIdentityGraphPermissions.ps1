# === Input Variables ===
$miPrincipalId = ""
$graphPermissions = @("Application.Read.All")  # Add desired permissions

# === Constants ===
<#
Graph App ID hier eintragen
Auf diese built-in Enterprise Application (nicht in der GUI sichtbar) wird die MI berechtigt
    MS Graph API AppId: 00000003-0000-0000-c000-000000000000
        Für allgemeine API Calls in Entra ID / Azure verwenden
    Defender for Endpoint App ID: fc780465-2017-40d4-a0c5-307022471b92
        Für z.B. Machine.Isolate API Calls verwenden
#>
$graphAppId = "00000003-0000-0000-c000-000000000000"

# === Check 1: Managed Identtiy ID (Prompt for input if not set) ===
if (!$mi) {
    $miPrincipalId = Read-Host "Enter Managed Identity ID (GUID)"
}

# === Check 2: Microsoft Graph SP existence ===
$graphSpExists = az ad sp show --id $graphAppId --only-show-errors 2>$null
if (-not $graphSpExists) {
    Read-Host -Prompt "❌  Microsoft Graph service principal not found in this tenant. Deployment cannot proceed. Press Enter to exit."
    exit 1
}

# === Check 3: Managed Identity existence ===
$miSpExists = az ad sp show --id $miPrincipalId --only-show-errors 2>$null
if (-not $miSpExists) {
    Read-Host -Prompt "❌  Managed identity with objectId $miPrincipalId does not exist. Check the value and try again. Press Enter to exit."
    exit 1
}

# === Get Graph SP objectId ===
$graphSpId = az ad sp show --id $graphAppId --query id -o tsv

# === Loop through permissions and assign them ===
foreach ($permission in $graphPermissions) {
    Write-Host "🔄  Assigning permission: $permission"

    $appRoleId = az ad sp show `
        --id $graphAppId `
        --query "appRoles[?value=='$permission' && contains(allowedMemberTypes,'Application')].id | [0]" `
        -o tsv

    if (-not $appRoleId) {
        Write-Warning "❌  Could not resolve appRoleId for permission: $permission"
        continue
    }

    $body = @{
        principalId = $miPrincipalId
        resourceId  = $graphSpId
        appRoleId   = $appRoleId
    } | ConvertTo-Json -Compress

    az rest --method POST `
        --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$miPrincipalId/appRoleAssignments" `
        --headers "Content-Type=application/json" `
        --body $body | Out-Null
}

# === Output current Graph permissions for verification ===
Write-Host "✅  Current Graph permissions assigned to the managed identity:"
az rest --method GET --uri "https://graph.microsoft.com/v1.0/servicePrincipals/$miPrincipalId/appRoleAssignments"
