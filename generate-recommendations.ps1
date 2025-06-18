# Generate cost-saving recommendations
$yellow="`e[1;33m"
$reset="`e[0m"

$vms=@(
  @{Id='vm-001'; State='stopped'; Cost=10}
  @{Id='vm-002'; State='running'; Cost=20}
  @{Id='vm-003'; State='stopped'; Cost=15}
)
$publicIps=@(
  @{Id='pip-001'; Associated=$false; Cost=3}
  @{Id='pip-002'; Associated=$true; Cost=0}
)
$disks=@(
  @{Id='disk-001'; Attached=$false; Cost=5}
  @{Id='disk-002'; Attached=$true; Cost=0}
)

$recs=@()
foreach($i in $vms){ if($i.State -eq 'stopped'){ $recs+= "Terminate $($i.Id) to save $${$i.Cost}/mo" } }
foreach($e in $publicIps){ if(-not $e.Associated){ $recs+= "Release $($e.Id) to save $${$e.Cost}/mo" } }
foreach($v in $disks){ if(-not $v.Attached){ $recs+= "Delete $($v.Id) to save $${$v.Cost}/mo" } }

Write-Host ""
Write-Host "┌──┬──┐"
Write-Host "│ Recommendation                           │"
Write-Host "├──┼──┤"
foreach($r in $recs){
  Write-Host ("│ {0,-40} │" -f $r) -ForegroundColor Yellow
}
Write-Host "└──┴──┘"

