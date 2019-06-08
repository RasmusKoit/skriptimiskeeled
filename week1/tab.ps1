function SquareTabulation{
    [CmdletBinding()]
    param(
        [Parameter(Position=0,mandatory=$false)]
        [int] $From = -10,
        [Parameter(Position=1,mandatory=$false)]
        [int] $To = 10,
        [Parameter(Position=3,mandatory=$false)]
        [float] $Step = 1.0)

    process{
        if ($Step -lt 1){
            Write-Output "Step needs to be bigger than 0"
            Exit
        }
        if ($From -gt $To) {
            Write-Output "From cant be bigger than To"
            Exit
        }
        For ($i=$From; $i -le $To; $i++) {
            $result = [Math]::Pow($i, $step)
            Write-Output "$i powered to $Step = $result"
        }  
    }
}

SquareTabulation -From -10 -To 10 -Step 3.0