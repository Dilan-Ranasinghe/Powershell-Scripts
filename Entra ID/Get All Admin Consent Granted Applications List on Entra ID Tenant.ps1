# Install Microsoft Graph PowerShell if not already installed
# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph with required permissions
Connect-MgGraph -Scopes "Application.Read.All","DelegatedPermissionGrant.Read.All","Directory.Read.All"

# Get all admin consent grants for all principals (tenant-wide)
$grants = Get-MgOauth2PermissionGrant -All | Where-Object { $_.ConsentType -eq "AllPrincipals" }

$results = foreach ($grant in $grants) {
    # Get the Service Principal (application)
    $sp = Get-MgServicePrincipal -ServicePrincipalId $grant.ClientId

    # Get the resource/service principal (API) name
    $resourceSp = Get-MgServicePrincipal -ServicePrincipalId $grant.ResourceId

    [PSCustomObject]@{
        ApplicationName   = $sp.DisplayName
        ApplicationId     = $sp.AppId
        Publisher         = $sp.PublisherName
        Resource          = $resourceSp.DisplayName
        GrantedScopes     = $grant.Scope
        ConsentType       = $grant.ConsentType
    }
}

# Export to CSV in your Documents folder
$csvPath = "$env:USERPROFILE\Documents\TenantWideAdminConsents.csv"
$results | Sort-Object ApplicationName | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "CSV file created at: $csvPath" -ForegroundColor Green
