# Introduction
This script can be used to grant (system-assigned) managed identities Azure Graph API permissions.

# Prerequisites
1. System-assigned Managed Identity
2. Graph API permission names
3. At least `AppRoleAssignment.ReadWrite.All` or `Directory.ReadWrite.All` permissions
4. Azure CLI session

# Usage
1. Fill the variable `$graphPermissions` with the full Graph API permissions
    1. This is a regular PowerShell array
2. Fill the variable `$miPrincipalId` with the ID of the already created managed identity
3. Optionally change the variable `$graphAppId`
    1. By default, this contains the ID for Graph API permissions, `00000003-0000-0000-c000-000000000000`
    2. However, there are other Graph permissions, e.g., for Defender for Endpoint (`fc780465-2017-40d4-a0c5-307022471b92`)
4. Run the script
    1. This script is made for the Azure CLI. Here you do not need to authenticate separately, load modules, etc.
