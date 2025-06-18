# Check budgets using mock data
$red="`e[1;31m"
$green="`e[1;32m"
$reset="`e[0m"

$budgets=@(
  @{Subscription='sub-01'; Limit=100; Actual=90}
  @{Subscription='sub-02'; Limit=120; Actual=130}
)

Write-Host ""
Write-Host "┌──┬──┬──┐"
Write-Host "│ Subscription │ Limit     │ Actual    │"
Write-Host "├──┼──┼──┤"
foreach($b in $budgets){
  if($b.Actual -gt $b.Limit){
    $color=$red
  }else{
    $color=$green
  }
  Write-Host ("│ {0,-12} │ {1,6}    │ {2,6}    │" -f $b.Subscription, $b.Limit, $b.Actual) -ForegroundColor ($color.Trim('`e[0m'))
}
Write-Host "└──┴──┴──┘"

