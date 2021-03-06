$defaultBaseEmail =  "no_email_set@gmail.com"
$noOne = "no one"
$defaultPairFile = "$PSScriptRoot\defaultPairFile.csv"

# Public
Function Set-Pair ($alias1, $alias2, $alias3, $alias4) {  
    if($alias4) {
        "More then 3 people ""pairing""? You're crazy."
        return
    }
    
    if ($alias3) {
        setTripple $alias1 $alias2 $alias3
        return
    }
  
    if ($alias2) {
        setDouble $alias1 $alias2
        return
    }
    
    if ($alias1) {
        setSingle $alias1
        return
    }
    
    echo (Get-Pair);
}

Function Get-Pair () {
    $currentPair = safeGetEnvVar "GIT_AUTHOR_NAME" $noOne
    return "Currently pairing: $currentPair"
}

Function Get-BaseEmail () {
    return safeGetEnvVar "PAIR_BASE_EMAIL" $defaultBaseEmail
}

Function Set-BaseEmail ($baseEmail) {    
    setEnvVar "PAIR_BASE_EMAIL" $baseEmail
}

Function Set-PairFile ($path) {
    $fullPath = Resolve-Path $path
    setEnvVar "PAIR_FILE_PATH" $fullPath
}

Function Get-PairFile {
    $pairFile = safeGetEnvVar "PAIR_FILE_PATH" $defaultPairFile
    return $pairFile
}

Function Get-PairAliases {
    return safeGetEnvVar "GIT_AUTHOR_ALIASES" $noOne
}

# Private
Function setSingle ($alias1) {
    $pairEmail = makeEmail (Get-BaseEmail) @($alias1)
    $pairName = (lookupName $alias1) 
    $machineName = [Environment]::UserName
    updateUserData $pairName $pairEmail $alias1
    echo "$pairName is working alone on '$machineName' now"
}

Function setDouble ($alias1, $alias2) {
    $pairName = (lookupName $alias1) + " and " + (lookupName $alias2) + " on " + [Environment]::UserName
    $pairEmail = makeEmail (Get-BaseEmail) @($alias1, $alias2)
    updateUserData $pairName $pairEmail ($alias1, $alias2)    
    echo "$pairName are pairing now"
}

Function setTripple ($alias1, $alias2, $alias3) {
    $pairName = (lookupName $alias1) + ", " + (lookupName $alias2) + " and " + (lookupName $alias3) + " on " + [Environment]::UserName
    $pairEmail = makeEmail (Get-BaseEmail) @($alias1, $alias2, $alias3)
    updateUserData $pairName $pairEmail ($alias1, $alias2, $alias3)
    
    echo "$pairName are trippling now"
}

Function updateUserData($name, $email, $aliases) {
    setEnvVar "GIT_AUTHOR_NAME" $name
    setEnvVar "GIT_AUTHOR_EMAIL" $email
    setEnvVar "GIT_AUTHOR_ALIASES" $aliases
    git config --global user.name $name
    git config --global user.email $email    
}

Function makeEmail($baseEmail, $aliases) {    
    $emailParts = $baseEmail -split "@"
    return $emailParts[0] + "+" + ($aliases -join "+") + "@" + $emailParts[1]
}

Function lookupName($alias) {
    $name = (loadLookup | Where-Object {$_.Alias -eq $alias}).Name
    $pairFile = (Get-PairFile)
	
    if(!$name){
        throw "User [$alias] does not exist. Add the alias to $pairFile or change the source with Set-PairFile"
    }
    
    return $name
}

function loadLookup() {
    return Import-Csv (Get-PairFile)
}

function addToLookup($initials, $name) {
    Select-Object $initials, $name
}

function reloadVariable($varName) {
    $value = ([Environment]::GetEnvironmentVariable($varName, "User"))

    if ($value -ne $null) {
        setLocalEnvVar $varName $value
    }    
}

# Util
Function safeGetEnvVar($varName, $default) {
    if (Test-Path "env:$varName") {
        return getEnvVar $varName
    }
    
    return $default
}

Function getEnvVar($varName) {
    return (Get-Item "env:$varName").value
}

Function setEnvVar($name, $value) {
    setLocalEnvVar $name $value
    [Environment]::SetEnvironmentVariable($name, $value, "User")
}

Function setLocalEnvVar($name, $value) {
    New-Item "env:" -Force -name $name -value $value
}

Set-Alias pair Set-Pair

reloadVariable "GIT_AUTHOR_NAME"
reloadVariable "GIT_AUTHOR_EMAIL"
reloadVariable "GIT_AUTHOR_ALIASES"
reloadVariable "PAIR_BASE_EMAIL"
reloadVariable "PAIR_FILE_PATH"

Export-ModuleMember -Function Set-Pair, Get-PairFile, Set-PairFile, Get-PairAliases, Get-Pair, Set-BaseEmail, Get-BaseEmail
Export-ModuleMember -Alias *