# 🔍 Dataverse Comment Viewer
This application renders Dataverse comments in a table format in the console.

DISCLAIMER: This viewer provides a simplified representation of Dataverse comments. Certain aspects of the commenting system, including deleted comments, orphaned comment threads, and resolved thread states, are not fully represented in this view. For complete comment functionality and state management, please refer to the native Dataverse interface.

Long-term support and maintenance of this project is not guaranteed.

Comment data is available in the Comments dataverse entity.  For more information about programmatically querying dataverse using OData, visit the official documentation: [Use OData to query data](https://learn.microsoft.com/en-us/power-apps/developer/data-platform/webapi/query/overview)

## 📋 Prerequisites
- PowerShell 7+
    - Check your version by running `$PSVersionTable.PSVersion` in PowerShell
    - If PowerShell 7+ is not installed, [follow these instructions](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)

## ⚡ Setup
```powershell
# 0. Clone this repository and navigate to its directory,
# or copy the contents of ViewComments.ps1 into a local file
# and open PowerShell in the same folder.

# 1. Install Az module if not already installed
Install-Module -Name Az -Repository PSGallery -Force

# 2. Authenticate with Azure
Connect-AzAccount

# 3. Save the script to a file and run
.\ViewComments.ps1 https://your-org.crm.dynamics.com
```

## Obtaining your organization's Dataverse environment endpoint
- Navigate to https://make.powerapps.com, or whatever url you use to access Power Apps Maker Portal.
    - Use the environment switcher to select the environment whose comments you wish to view.
- Click on the gear (add emoji here) in the upper right-hand corner.
- Click on 'Session Details'

You should be shown diagnostic information that will include your environment url as "Instance url", like so:
Timestamp: 2025-03-11T18:30:03.887Z
Session ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Tenant ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Object ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Build name: 0.0.20250306.7-2503.2-prod
Organization ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Unique name: unqxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Instance url: **https://example.crm.dynamics.com/**
Environment ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Cluster environment: Prod
Cluster category: Prod
Cluster geo name: US
Cluster URI suffix: us-xx000.gateway.test.island

## How to find App Id
Navigate to the following URL to view the details for the application in question.  You may need substitute the hostname with that which you normally use to access Power Apps.
https://make.powerapps.com/environments/{your_environment_id}/apps/{app_id}/details

## Usage
```powershell
# Display results
.\ViewComments.ps1 https://your-org.crm.dynamics.com

# Write to file
.\ViewComments.ps1 https://your-org.crm.dynamics.com ./comments.csv

# Filter on application
.\ViewComments.ps1 https://your-org.crm.dynamics.com -applicationId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## Arguments
Arguments may be passed as named (e.g. -baseUrl https//example.crm.dynamics.com) or in order without names.

## 🔧 Troubleshooting
- **Trouble passing arguments?** Run `Get-Help .\ViewComments.ps1 -Full` for detailed parameter documentation.
- **Auth fails?** Run `Connect-AzAccount` again
- **Permission errors?** Verify Dataverse access rights
- **Module issues?** Run `Update-Module -Name Az`
- **Too many comments to read in terminal?** Follow the instructions to write to output file, and use a spreadsheet application to organize the data.

## 📱 Need Help?
Contact your Dataverse administrator or Microsoft support.  This data may be accessed from Dataverse directly in the comments entity.

