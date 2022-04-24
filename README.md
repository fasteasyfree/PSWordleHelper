# PSWordleHelper

Some helper scripts to provide suggestions for solving Wordle.

## Export-WordListCount.ps1
This was used to generate the WordValues.json file. Sorts through the provided text files and generates a hashtable of the words and the number of occurrences.
Without modification it dumps the JSON into the script root.

## Get-WordleOptions.ps1
Gets a list of possibilities from th provided word list.

## Get-WordleValues.ps1
Gives a weighting to the words output from Get-WordleOptions.ps1. Accepts pipeline input.

## \*\.(json|txt)
Helper files for the scripts so you don't need to generate them yourself.

### Words.txt
To generate a words.txt file, I downloaded the alpha list from https://github.com/dwyl/english-words
Then it's a simple matter of: Get-Content .\words_alpha.txt | Select-String -Pattern "^[a-zA-Z]{5}$" | Set-Content .\Words.txt

### WordValues.json
Generated from the Export-WordListCount.ps1 above.

### LetterValues.json
Created this by getting the frequency of letters from the WordValues.json file, and storing the log value of that frequency.
