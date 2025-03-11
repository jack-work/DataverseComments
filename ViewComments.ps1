<#
.SYNOPSIS
    Fetches comment data associated with Canvas Apps from Dataverse and formats it in a human readable way.

.PARAMETER baseUrl
    The endpoint of the Dataverse environment where the desired comments are located.

.PARAMETER outputPath
    Optional path to save the results to a CSV file.

.PARAMETER applicationId
    Filters the results to only comments to a provided application name.

.NOTES
    Copyright (c) Microsoft Corporation. All rights reserved.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$baseUrl,

    [Parameter(Mandatory=$false)]
    [string]$outputPath,

    [Parameter(Mandatory=$false)]
    [string]$applicationId
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
$canvasAppArtifactType = 1 # I don't know what the other artifact types are.
$query = "/api/data/v9.1/comments?`$expand=Container(`$select=artifactid,artifacttype)&`$filter=Container/artifacttype%20eq%20$canvasAppArtifactType"
if ($applicationId) {
    $query = $query + "%20and%20Container/artifactid%20eq%20'$applicationId'"
}
$query = $query + "&`$select=anchor,body,originalauthorfullname,createdon,state"
$fullUrl = $baseUrl + $query
$response = Invoke-RestMethod -Uri $fullUrl -Headers $headers -Method Get

Write-Host "✨ Processing and formatting comment data..." -ForegroundColor Magenta
$processedData = $response.value | Select-Object @{
    Name='Created On'
    Expression={$_.createdon}
}, @{
    Name='Comment'
    Expression={(($_.body | ConvertFrom-Json).ops | ForEach-Object { $_.insert } | Join-String).TrimEnd()}
}, @{
    Name='Author'
    Expression={$_.originalauthorfullname}
}, @{
    Name='App Id'
    Expression={$_.Container.artifactid}
}, @{
    Name='Thread Id'
    Expression={$_.anchor}
}, @{
    Name='State'
    Expression={if ($_.state -eq 0) { 'Active' } else { 'Inactive' }}
}, @{
    Name='Comment Id'
    Expression={$_.commentid}
}

# Group by Thread Id and create hierarchical display
$processedData | Group-Object -Property 'App Id' | ForEach-Object {
    $appId = $_.Name

    # Display App header
    Write-Host "`n┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
    Write-Host "┃ 📱 Application ID: $appId" -ForegroundColor Green
    Write-Host "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green

    # Now group the app's comments by Thread Id
    $_.Group | Group-Object -Property 'Thread Id' | ForEach-Object {
        $threadId = $_.Name
        $comments = $_.Group | Sort-Object -Property 'Created On'

        # Get the first comment (parent)
        $parentComment = $comments | Select-Object -First 1

        # Display thread header
        Write-Host "`n╔══════ Thread: $threadId ══════" -ForegroundColor Cyan
        Write-Host "║" -ForegroundColor Cyan

        # Display parent comment
        Write-Host "║ 📝 $($parentComment.'Created On')" -ForegroundColor Yellow
        Write-Host "║ 🔄 $($parentComment.'State')" -ForegroundColor Yellow
        Write-Host "║ 👤 $($parentComment.Author)" -ForegroundColor Yellow
        Write-Host "║ $($parentComment.Comment)" -ForegroundColor White

        # Display replies/child comments
        $childComments = $comments | Select-Object -Skip 1

        if ($childComments) {
            Write-Host "║" -ForegroundColor Cyan
            Write-Host "║ Replies:" -ForegroundColor Cyan

            foreach ($reply in $childComments) {
                Write-Host "║  ├─ $($reply.'Created On')" -ForegroundColor Magenta
                Write-Host "║  │  👤 $($reply.Author)" -ForegroundColor Magenta
                Write-Host "║  │  $($reply.Comment)" -ForegroundColor Gray
                Write-Host "║  │" -ForegroundColor Cyan
            }
        }

        Write-Host "╚════════════════════════════════" -ForegroundColor Cyan
    }
} | Select-Object -First 20

if ($processedData.Count -gt 20) {
    Write-Host "⚠️ Showing 20 of $($processedData.Count) comments in console. Specify output path argument to see them all." -ForegroundColor Yellow
    Write-Host
}

if ($outputPath) {
    Write-Host "💾 Saving data to CSV file: $outputPath" -ForegroundColor Green
    $processedData | Export-Csv -Path $outputPath -NoTypeInformation
}

Write-Host "✅ Operation completed successfully!" -ForegroundColor Blue

