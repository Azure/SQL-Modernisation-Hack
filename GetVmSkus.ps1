[CmdletBinding()]
param()

# Adjust to test your regions
$regions = @("GermanyWestcentral", "italynorth")
$nameLike = "Standard_D[24]s_v*"

$all = foreach ($region in $regions) {

  $regionalVcpuAvailable = $null
  try {
    $usage = Get-AzVMUsage -Location $region
    $totalRegional = $usage | Where-Object {
      ($_.Name.Value -match 'Total\s*Regional\s*(vCPUs|Cores)') -or
      ($_.Name.LocalizedValue -match 'Total\s*Regional\s*(vCPUs|Cores)')
    } | Select-Object -First 1

    if (-not $totalRegional) {
      $totalRegional = $usage | Where-Object {
        ($_.Name.Value -match 'Regional\s*(vCPUs|Cores)') -or
        ($_.Name.LocalizedValue -match 'Regional\s*(vCPUs|Cores)')
      } | Sort-Object Limit -Descending | Select-Object -First 1
    }

    if ($totalRegional) {
      $regionalVcpuAvailable = [int64]$totalRegional.Limit - [int64]$totalRegional.CurrentValue
    }
  } catch {}

  $skus = @()
  try {
    $skus = Get-AzComputeResourceSku -Location $region |
      Where-Object {
        $_.ResourceType -eq "virtualMachines" -and
        $_.Locations -contains $region -and
        $_.Name -like $nameLike -and
        (($_.Capabilities | Where-Object Name -eq "HyperVGenerations").Value -match "V1")
      }
  } catch {}

  foreach ($sku in $skus) {
    $cap = @{}
    foreach ($c in $sku.Capabilities) { $cap[$c.Name] = $c.Value }

    $rwe = @()
    if ($sku.Restrictions) {
      $rwe = $sku.Restrictions | Where-Object {
        ($_.RestrictionInfo -and ($_.RestrictionInfo.Locations -contains $region)) -or
        ($_.Locations -and $_.Locations -contains $region)
      }
    }

    if (-not $rwe -or $rwe.Count -eq 0) {
      [pscustomobject]@{
        Scope                 = $region
        Name                  = $sku.Name
        vCPUs                 = $cap['vCPUs']
        MemoryGB              = $cap['MemoryGB']
        HyperVGenerations     = $cap['HyperVGenerations']
        RegionalVcpuAvailable = $regionalVcpuAvailable
        RestrictionType       = 'None'
        ReasonCode            = ''
        Zones                 = ''
      }
    } else {
      foreach ($r in $rwe) {
        $zones = 'AllZones/NotSpecified'
        if ($r.RestrictionInfo -and $r.RestrictionInfo.Zones) { $zones = ($r.RestrictionInfo.Zones -join ',') }
        [pscustomobject]@{
          Scope                 = $region
          Name                  = $sku.Name
          vCPUs                 = $cap['vCPUs']
          MemoryGB              = $cap['MemoryGB']
          HyperVGenerations     = $cap['HyperVGenerations']
          RegionalVcpuAvailable = $regionalVcpuAvailable
          RestrictionType       = $r.Type
          ReasonCode            = $r.ReasonCode
          Zones                 = $zones
        }
      }
    }
  }
}

$all | Sort-Object Scope, Name, RestrictionType | Format-Table -Auto