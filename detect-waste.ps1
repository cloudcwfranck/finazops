# Detect cloud waste using mock data and display summary
$red="`e[1;31m"
$green="`e[1;32m"
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

Write-Host ""
Write-Host "┌──┬──┬──┐"
Write-Host "│ Resource ID │ Status   │ Monthly $ │"
Write-Host "├──┼──┼──┤"

$total=0
foreach($i in $vms){
  if($i.State -eq 'stopped'){
    Write-Host ("│ {0,-12} │ {1,-8} │ {2,4}     │" -f $i.Id, $i.State, $i.Cost) -NoNewline
    Write-Host "" -ForegroundColor Red
    $total+=$i.Cost
  }
}
$publicIps | ForEach-Object {
  if(-not $_.Associated){
    Write-Host ("│ {0,-12} │ unassociated │ {1,4}     │" -f $_.Id, $_.Cost) -ForegroundColor Yellow
    $total+=$_.Cost
  }
}
$disks | ForEach-Object {
  if(-not $_.Attached){
    Write-Host ("│ {0,-12} │ unattached │ {1,4}   │" -f $_.Id, $_.Cost) -ForegroundColor Yellow
    $total+=$_.Cost
  }
}
Write-Host "└──┴──┴──┘"
Write-Host ""
Write-Host ("Estimated monthly waste: $${0}" -f $total) -ForegroundColor Red

