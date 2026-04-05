# SOP: Azure Resource Tagging Using PowerShell (Ubuntu / WSL)

## 1. Purpose

This SOP describes the process to update and enforce standardized tags on:

* Azure Resource Groups
* All resources inside the Resource Groups

The script ensures:

* Required tags are updated/replaced
* Existing tags are preserved
* Unsupported resources are skipped safely

---

## 2. Scope

Applicable to:

* Azure subscriptions managed by the team
* All selected Resource Groups
* All supported Azure resources (VM, NSG, NIC, Disk, etc.)

---

## 3. Prerequisites

### 3.1 Access Requirements

* Azure role: **Owner / Contributor / Tag Contributor**
* Access to target subscription

### 3.2 Tools Required

* PowerShell Core (pwsh)
* Az PowerShell Module or
*  Connect-AzAccount -UseDeviceAuthentication

---

## 4. Installation Steps (Ubuntu / WSL)

### 4.1 Install PowerShell

```bash
sudo apt update
sudo apt install -y wget apt-transport-https software-properties-common
wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo apt install -y powershell
```

### 4.2 Start PowerShell

```bash
pwsh
```

### 4.3 Install Azure Module

```powershell
Install-Module -Name Az -Scope CurrentUser -Force
```

---

## 5. Authentication

Login to Azure:

```powershell
Connect-AzAccount
```

Select subscription (if multiple):

```powershell
Set-AzContext -Subscription "<Subscription-Name-or-ID>"
```

---

## 6. Tagging Script

### 6.1 Define Resource Groups

```powershell
$resourceGroups = @("AKS", "AVD", "Virtual-Machine")
```

### 6.2 Define Tags

```powershell
$newTags = @{
    "Billing Division" = "anoop"
    "Applications nam" = "prod"
    "Owner" = "anoop"
}
```

### 6.3 Execute Script Logic

```powershell
foreach ($rg in $resourceGroups) {

    $rgObj = Get-AzResourceGroup -Name $rg
    $rgTags = $rgObj.Tags
    if (-not $rgTags) { $rgTags = @{} }

    foreach ($key in $newTags.Keys) {
        $rgTags[$key] = $newTags[$key]
    }

    Set-AzResourceGroup -Name $rg -Tag $rgTags

    $resources = Get-AzResource -ResourceGroupName $rg

    foreach ($res in $resources) {
        try {
            $tags = $res.Tags
            if (-not $tags) { $tags = @{} }

            foreach ($key in $newTags.Keys) {
                $tags[$key] = $newTags[$key]
            }

            Set-AzResource -ResourceId $res.ResourceId -Tag $tags -Force
        }
        catch {
            Write-Host "Skipped: $($res.Name)"
        }
    }
}
```

---

## 7. Execution Steps

1. Open terminal
2. Run:

```bash
pwsh
```

3. Execute script:

```powershell
./tag-script.ps1
```

---

## 8. Validation

### 8.1 Verify Resource Group Tags

```powershell
Get-AzResourceGroup -Name "<RG-Name>" | Select Tags
```

### 8.2 Verify Resource Tags

```powershell
Get-AzResource -ResourceGroupName "<RG-Name>" | Select Name, Tags
```

---

## 9. Expected Outcome

* Tags updated for all supported resources
* Existing tags preserved
* Target tags replaced with new values
* Unsupported resources skipped

---

## 10. Known Limitations

* Some Azure resources cannot be tagged:

  * Monitoring (Insights, Alerts)
  * AKS system-managed resources

* Script will skip such resources without failure

---

## 11. Troubleshooting

| Issue            | Resolution                 |
| ---------------- | -------------------------- |
| Login fails      | Re-run Connect-AzAccount   |
| Module missing   | Install-Module Az          |
| Permission issue | Assign Contributor role    |
| Script blocked   | Set-ExecutionPolicy Bypass |

---

## 12. Best Practice (Recommended)

For long-term governance, use:

* Azure Policy for automatic tagging
* Tag compliance monitoring

---

## 13. Author

Prepared by: Anoop Maurya
Purpose: Azure Tag Standardization Automation

---

## 14. Version History

| Version | Date | Description |
| ------- | ---- | ----------- |
| v1.0    | 2026 | Initial SOP |
