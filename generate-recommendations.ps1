# Generate cost-saving recommendations
$yellow="`e[1;33m"
$reset="`e[0m"

$instances=@(
  @{Id='i-001'; State='stopped'; Cost=10}
  @{Id='i-002'; State='running'; Cost=20}
  @{Id='i-003'; State='stopped'; Cost=15}
)
$eips=@(
  @{Id='eipalloc-001'; Attached=$false; Cost=3}
  @{Id='eipalloc-002'; Attached=$true; Cost=0}
)
$volumes=@(
  @{Id='vol-001'; Attached=$false; Cost=5}
  @{Id='vol-002'; Attached=$true; Cost=0}
)

$recs=@()
foreach($i in $instances){ if($i.State -eq 'stopped'){ $recs+= "Terminate $($i.Id) to save $${$i.Cost}/mo" } }
foreach($e in $eips){ if(-not $e.Attached){ $recs+= "Release $($e.Id) to save $${$e.Cost}/mo" } }
foreach($v in $volumes){ if(-not $v.Attached){ $recs+= "Delete $($v.Id) to save $${$v.Cost}/mo" } }

Write-Host ""
Write-Host "┌──┬──┐"
Write-Host "│ Recommendation                           │"
Write-Host "├──┼──┤"
foreach($r in $recs){
  Write-Host ("│ {0,-40} │" -f $r) -ForegroundColor Yellow
}
Write-Host "└──┴──┘"

