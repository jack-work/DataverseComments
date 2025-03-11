<#
.DESCRIPTION
    Fetches comment data from Dataverse and formats it in a human readable way.

.PARAMETER baseUrl
    The endpoint of the Dataverse environment where the desired comments are located.

.NOTES
    Copyright (c) Microsoft Corporation. All rights reserved.

.REQUIREMENTS
    - PowerShell 7 or later
    - Az PowerShell module
    - Azure authentication (run Connect-AzAccount first)
    - Network access to Dataverse environment
    - Appropriate Dataverse permissions to read comments
#>
param(
    [Parameter(Mandatory=$true)]
    [string]$baseUrl
)

Write-Host "🔑 Authenticating with $baseUrl..." -ForegroundColor Cyan
$token = Get-AzAccessToken -AsSecureString -ResourceUrl $baseUrl
$tokenCredential = New-Object System.Management.Automation.PSCredential("temp", $token.Token)
$bearerToken = $tokenCredential.GetNetworkCredential().Password
$headers = @{
    'Authorization' = "Bearer $bearerToken"
}
$bearerToken = $null
Remove-Variable -Name tokenCredential -ErrorAction SilentlyContinue

Write-Host "📡 Fetching comments from the API..." -ForegroundColor Green
$query = "/api/data/v9.1/comments?`$expand=Container(`$select=artifactid,artifacttype)&`$filter=Container/artifacttype%20eq%201&`$select=anchor,body"
$fullUrl = $baseUrl + $query
$response = Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Get

Write-Host "✨ Processing and formatting comment data..." -ForegroundColor Magenta
$response.value | Select-Object @{
    Name='Comment'
    Expression={($_.body | ConvertFrom-Json).ops[0].insert.TrimEnd()}
}, @{
    Name='App Id'
    Expression={$_.Container.artifactid}
}, @{
    Name='Thread Id'
    Expression={$_.anchor}
}, @{
    Name='Comment Id'
    Expression={$_.commentid}
} | Format-List

Write-Host "✅ Operation completed successfully!" -ForegroundColor Blue
