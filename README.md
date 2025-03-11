# 🔍 Dataverse Comment Viewer

 **Disclaimer**: Long-term support and maintenance of this project is not guaranteed.

## 📋 Requirements
- PowerShell 7+ (`winget install Microsoft.PowerShell`)
    - [Install PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
- Az PowerShell module
- Azure authentication
- Dataverse access permissions

## ⚡ Setup
```powershell
# 1. Install Az module if not already installed
Install-Module -Name Az -Repository PSGallery -Force

# 2. Authenticate with Azure
Connect-AzAccount

# 3. Save the script to a file and run
.\Get-DataverseComments.ps1 https://your-org.crm.dynamics.com
```

## 🔧 Troubleshooting
- **Auth fails?** Run `Connect-AzAccount` again
- **Permission errors?** Verify Dataverse access rights
- **Module issues?** Run `Update-Module -Name Az`

## 📱 Need Help?
Contact your Dataverse administrator or Microsoft support.
