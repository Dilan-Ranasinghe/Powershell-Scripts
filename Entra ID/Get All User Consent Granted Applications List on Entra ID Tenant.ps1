# Install Microsoft Graph PowerShell if not already installed
# Install-Module Microsoft.Graph -Scope CurrentUser

# Connect to Microsoft Graph with required permissions
Connect-MgGraph -Scopes "Application.Read.All","DelegatedPermissionGrant.Read.All","Directory.Read.All","User.Read.All"

# Get all OAuth2 permission grants for individual users
$userGrants = Get-MgOauth2PermissionGrant -All | Where-Object { $_.ConsentType -eq "Principal" }

$results = foreach ($grant in $userGrants) {
    # Get the Service Principal (application) info
    $app = Get-MgServicePrincipal -ServicePrincipalId $grant.ClientId

    # Get the Resource/Application info
    $resourceSp = Get-MgServicePrincipal -ServicePrincipalId $grant.ResourceId

    # Get the user who granted the consent
    $user = Get-MgUser -UserId $grant.PrincipalId

    [PSCustomObject]@{
        UserDisplayName   = $user.DisplayName
        UserUPN           = $user.UserPrincipalName
        ApplicationName   = $app.DisplayName
        ApplicationId     = $app.AppId
        Publisher         = $app.PublisherName
        Resource          = $resourceSp.DisplayName
        GrantedScopes     = $grant.Scope
        ConsentType       = $grant.ConsentType
    }
}

# Export to CSV
$csvPath = "$env:USERPROFILE\Documents\UserConsentApplications.csv"
$results | Sort-Object UserDisplayName, ApplicationName | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "CSV file created at: $csvPath" -ForegroundColor Green
