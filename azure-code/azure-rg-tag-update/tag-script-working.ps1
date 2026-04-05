# 🔹 Resource Groups
$resourceGroups = @("AKS", "AVD", "Virtual-Machine")

# 🔹 Tags to enforce
$newTags = @{
    "Billing Division" = "anoop"
    "Applications nam" = "prod"
    "Owner" = "anoop"
}

Write-Host "🚀 Starting Tag Update..." -ForegroundColor Cyan

foreach ($rg in $resourceGroups) {

    Write-Host "=============================="
    Write-Host "🔹 Processing RG: $rg"
    Write-Host "=============================="

    # ✅ Get Resource Group
    $rgObj = Get-AzResourceGroup -Name $rg

    # Merge tags
    $rgTags = $rgObj.Tags
    if (-not $rgTags) { $rgTags = @{} }

    foreach ($key in $newTags.Keys) {
        $rgTags[$key] = $newTags[$key]
    }

    # Update RG
    Set-AzResourceGroup -Name $rg -Tag $rgTags
    Write-Host "✅ RG Updated"

    # ✅ Get all resources in RG
    $resources = Get-AzResource -ResourceGroupName $rg

    foreach ($res in $resources) {

        Write-Host "   ↳ Processing: $($res.Name)"

        try {
            $tags = $res.Tags
            if (-not $tags) { $tags = @{} }

            # Merge tags
            foreach ($key in $newTags.Keys) {
                $tags[$key] = $newTags[$key]
            }

            # Update resource
            Set-AzResource -ResourceId $res.ResourceId -Tag $tags -Force

            Write-Host "   ✅ Updated"
        }
        catch {
            Write-Host "   ⚠️ Skipped (not supported)" -ForegroundColor Yellow
        }
    }
}

Write-Host "🎯 Tagging Completed!" -ForegroundColor Green