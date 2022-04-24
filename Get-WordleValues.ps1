<#
.SYNOPSIS
    Sort output of wordle option generator.
.DESCRIPTION
    Get-WordleOptions does not weight the output. This function will calculate the higher-value words.
.EXAMPLE
.PARAMETER WordValues
    Hashtable of words, with the word as key and its weighting as the value.
.PARAMETER LetterValues
    Hashtable of letters, with the letter as key and its weighting as value.
.PARAMETER Word
    String of five characters to be processed.
.EXAMPLE
    .\Get-WordleOptions.ps1 -Grey "fl" -AmberArray "","e","","","r" -Green "____t" | .\Get-WordleValues.ps1 | Sort-Object -Property Value -Descending

    Word   Value
    ----   -----
    great 45.265
    treat 29.732
    crept 28.525
    erect  26.99
    crest 23.936
    greet 22.433
    ...
.OUTPUTS
    [string[]]

    Array of words, sorted into probability order.
.LINK
    https://www.nytimes.com/games/wordle/index.html
#>

[CmdletBinding()]
param (
    # Json list of word values
    [hashtable]$WordValues=(Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "WordValues.json") | ConvertFrom-Json -AsHashtable),

    # Json list of letter values
    [hashtable]$LetterValues=(Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "LetterValues.json") | ConvertFrom-Json -AsHashtable),

    # Pipeline in the words for processing
    [parameter(
        ValueFromPipeline,
        Mandatory
    )]
    [ValidatePattern(
        "^[a-zA-Z]{5}$",
        ErrorMessage = "It must contain only letters and be exactly five characters in length."
    )]
    [string]$Word
)

process {
    $WordValue = 0
    $Word = $Word.ToLower()

    # First generate a value from the letters, and get the log
    foreach ($Letter in $Word.ToCharArray()) {
        if ($LetterValues["$Letter"]) {
            $WordValue += $LetterValues["$Letter"]
        } 
    }
    $WordValue = [math]::Log($WordValue)

    # Check that the word is in the hashtable for processing.
    if ($WordValues[$word]) {
        # Get the log value. Add 1 in case the word only appears once (and thus returns a zero)
        $WordValue *= (1 + [math]::Log($WordValues[$word]))
    }

    [PSCustomObject]@{
        Word = $Word
        Value = [math]::Round($WordValue,3)
    }
}