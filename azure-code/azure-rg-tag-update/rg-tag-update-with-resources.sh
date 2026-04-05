#!/bin/bash

RESOURCE_GROUPS=("AKS" "AVD" "Virtual-Machine")

echo "🚀 Starting Tag Update..."

for rg in "${RESOURCE_GROUPS[@]}"
do
  echo "=============================="
  echo "🔹 Processing RG: $rg"
  echo "=============================="

  # ✅ Update RG
  az group update \
    --name "$rg" \
    --set tags."Billing Division"="anoop" \
          tags."Applications nam"="prod" \
          tags."Owner"="anoop"

  echo "✅ RG updated"

  # ✅ Get NSGs (FIX for your issue)
  for nsg in $(az network nsg list --resource-group "$rg" --query "[].name" -o tsv)
  do
    echo "   ↳ Updating NSG: $nsg"

    az network nsg update \
      --resource-group "$rg" \
      --name "$nsg" \
      --set tags."Billing Division"="anoop" \
            tags."Applications nam"="prod" \
            tags."Owner"="anoop"

    echo "   ✅ NSG Updated"
  done

done

echo "🎯 Completed!"