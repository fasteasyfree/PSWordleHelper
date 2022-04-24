# cobbled together to take .txt format books downloaded from Project Gutenberg (or wherever),
# and create a hashtable/json for how often those words appear.

[CmdletBinding()]
param (
    [System.IO.DirectoryInfo]$BookPath="~\downloads\books\",

    [System.IO.DirectoryInfo]$ExportPath=$PSScriptRoot,

    [int]$WordLength=5
)

$Books = Get-ChildItem -Path (Join-Path -Path $BookPath -ChildPath "*.txt")

$WordHash = @{}

foreach ($Book in $Books) {
    $Content = Get-Content -Path $Book

    $Content = $Content -join " " -replace "[^a-zA-Z]+"," " -split " " | Select-String -Pattern "^\w{$WordLength}$"
    
    $Content.ForEach({

        $Word = ([string]$_).ToLower()

        if ($WordHash[$Word]) {
            $WordHash[$Word] += 1
        } else {
            $WordHash[$Word] = 1
        }
    })
}

$WordHash | 
    ConvertTo-Json | 
    Set-Content -Path (Join-Path -Path $ExportPath -ChildPath "WordValues.json") -Force