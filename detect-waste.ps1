# Detect cloud waste using mock data and display summary
$red="`e[1;31m"
$green="`e[1;32m"
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

Write-Host ""
Write-Host "┌──┬──┬──┐"
Write-Host "│ Resource ID │ Status   │ Monthly $ │"
Write-Host "├──┼──┼──┤"

$total=0
foreach($i in $instances){
  if($i.State -eq 'stopped'){
    Write-Host ("│ {0,-12} │ {1,-8} │ {2,4}     │" -f $i.Id, $i.State, $i.Cost) -NoNewline
    Write-Host "" -ForegroundColor Red
    $total+=$i.Cost
  }
}
foreach($e in $eips){
  if(-not $e.Attached){
    Write-Host ("│ {0,-12} │ detached │ {1,4}     │" -f $e.Id, $e.Cost) -ForegroundColor Yellow
    $total+=$e.Cost
  }
}
foreach($v in $volumes){
  if(-not $v.Attached){
    Write-Host ("│ {0,-12} │ unattached │ {1,4}   │" -f $v.Id, $v.Cost) -ForegroundColor Yellow
    $total+=$v.Cost
  }
}
Write-Host "└──┴──┴──┘"
Write-Host ""
Write-Host ("Estimated monthly waste: $${0}" -f $total) -ForegroundColor Red

