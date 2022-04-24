<#
.SYNOPSIS
    Wordle option generator.
.DESCRIPTION
    After each guess in Wordle, generate a list of possibilities for your next guess.
.EXAMPLE
    PS C:\> .\Get-WordleOptions.ps1 -AmberArray "l","","o","e" -Grey "atrcs" -Green "_l___"
    elbow
    flexo
    ileon
    oldie
    olein
    ...
.PARAMETER WordList
    Array of five-letter words from which to conduct the search.
    Default (blank) will be to load from words.txt in the script root.
    To generate a words.txt file, I downloaded the alpha list from https://github.com/dwyl/english-words
    Then it's a simple matter of: Get-Content .\words_alpha.txt | Select-String -Pattern "^[a-zA-Z]{5}$" | Set-Content .\Words.txt
.PARAMETER Green
    Five character string that can contain only letters or underscore.

    e.g. "__t_r" or "a_____"
.PARAMETER AmberArray
    An array of strings, representing the amber locations. 
    Each array item can contain only letters or an empty string.
    Five entries required.

    e.g. "aq","","bst","",""
    e.g. "","","aoudf","","abc"
.PARAMETER Grey
    String that contains the grey letters, or "wrong" choices.

    e.g. "ahqy"
.OUTPUTS
    [string[]]

    Array of word possibilities.
.LINK
    https://www.nytimes.com/games/wordle/index.html
    https://github.com/dwyl/english-words
#>

[CmdletBinding()]
param (
    # List of valid english five-letter words to search from
    [string[]]$WordList=(Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath "words.txt") -ErrorAction stop),

    # Letters that are 'locked-in' - use underscore for blanks. Must contain five characters.
    [ValidatePattern(
        "^[a-zA-Z_]{5}$",
        ErrorMessage = "It must contain only letters or underscores, and be exactly five characters in length."
    )]
    [string]$Green,

    # Array of strings, maximum of five entries.
    [ValidateCount(5,5)]
    [ValidatePattern(
        "^[a-zA-Z]*$",
        ErrorMessage = "You must only use letters or an empty string."
    )]
    [System.Collections.Generic.List[string]]$AmberArray,

    # String of grey letters
    [string]$Grey
)

Write-verbose "WordList Count before starting: $($WordList.Count)"

# 1. If $Grey is passed, then let's remove every word that contains those letters first to speed up subsequent processing times.
if ($Grey) {
    # Build regex for forward lookup to exclude words with those letters.
    $MatchString = "^" + (($Grey.ToCharArray().ForEach({ "(?!.*$_)" })) -join "") + ".*$"
    $WordList = $WordList | Select-String -Pattern $MatchString

    Write-verbose "WordList Count after grey filter: $($WordList.Count)"
}

# 2. Next, we want to select words that contain the amber letters.
if ($AmberArray) {

    ## First, get all the words that contain the specified letters.
    # Join the array into a single string, and then remove duplicates.
    $CharList = ($AmberArray -join "").ToCharArray() | Select-Object -Unique

    # Do a regex forward lookup to remove any words that don't contain those letters.
    $MatchString = "^" + (($CharList.ForEach({ "(?=.*$_)" })) -join "") + ".*$"
    $WordList = $WordList | Select-String -Pattern $MatchString

    Write-verbose "WordList Count after amber first-stage: $($WordList.Count)"

    ## Secondly, remove the words that have the letters in the wrong location.
    # Build regex that excludes words with those letters in the wrong location.
    $MatchString = "^"
    foreach ($String in $AmberArray) {
        # If this particular element is an empty string, allow any letter at this location.
        if ([string]::IsNullOrEmpty($String)) {
            $MatchString += "\w"
        
        # Otherwise we want to exclude those ones passed.
        } else {
           $MatchString += "[^$String]"
        }
    }
    $MatchString += "$"
    $WordList = $WordList | Select-String -Pattern $MatchString

    Write-verbose "WordList Count after amber second stage: $($WordList.Count)"
}

# 3. Finally, select those words where the letters are locked in
if ($Green) {
    # Swap the underscores for letter wildcard
    $MatchString = $Green -replace "_","\w"
    $WordList = $WordList | Select-String -Pattern $MatchString

    Write-verbose "WordList Count after green: $($WordList.Count)"
}

# Let's make sure that we have something to work with...
if ((-not $Green) -and (-not $AmberArray) -and (-not $Grey)) {
    Write-Warning "You must select at least one of: Green, AmberList or Grey. Otherwise you'd be returning all the words you put in..."

# ...and if we do, output it
} else {
    
    $WordList    
}
