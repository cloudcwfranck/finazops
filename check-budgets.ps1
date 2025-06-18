# Check budgets using mock data
$red="`e[1;31m"
$green="`e[1;32m"
$reset="`e[0m"

$budgets=@(
  @{Profile='profile-02'; Limit=100; Actual=90}
  @{Profile='profile-03'; Limit=120; Actual=130}
)

Write-Host ""
Write-Host "┌──┬──┬──┐"
Write-Host "│ Profile    │ Limit     │ Actual    │"
Write-Host "├──┼──┼──┤"
foreach($b in $budgets){
  if($b.Actual -gt $b.Limit){
    $color=$red
  }else{
    $color=$green
  }
  Write-Host ("│ {0,-10} │ {1,6}    │ {2,6}    │" -f $b.Profile, $b.Limit, $b.Actual) -ForegroundColor ($color.Trim('`e[0m'))
}
Write-Host "└──┴──┴──┘"

