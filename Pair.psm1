$baseEmail =  "test@gmail.com"

Function Set-PairFile ($path) {
	setEnvVar "PAIR_FILE_PATH" $path
}

Function Get-PairFile {
	return safeGetEnvVar "PAIR_FILE_PATH" "$home\gitUsers.csv"
}

Function story ($story) {
	if($story) {
		setEnvVar "CURRENT_STORY" $story
		return
	}
	
	return safeGetEnvVar "CURRENT_STORY" "No story"
}

Function pair ($alias1, $alias2, $alias3, $alias4) {  
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
    
    echo (getPair);
}

Function Get-PairAliases {
    $currentPair = (Get-Item "env:GIT_AUTHOR_ALIASES").value
    return $currentPair
}

Function setSingle ($alias1) {
    $pairEmail = makeEmail $baseEmail @($alias1)
    $pairName = (lookupName $alias1) + " on " + [Environment]::UserName
    updateUserData $pairName $pairEmail $alias1
    echo "$pairName is working alone now"
}

Function setDouble ($alias1, $alias2) {
    $pairName = (lookupName $alias1) + " and " + (lookupName $alias2) + " on " + [Environment]::UserName
    $pairEmail = makeEmail $baseEmail @($alias1, $alias2)
    updateUserData $pairName $pairEmail ($alias1, $alias2)    
    echo "$pairName are pairing now"
}

Function setTripple ($alias1, $alias2, $alias3) {
    $pairName = (lookupName $alias1) + ", " + (lookupName $alias2) + " and " + (lookupName $alias3) + " on " + [Environment]::UserName
    $pairEmail = makeEmail $baseEmail @($alias1, $alias2, $alias3)
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

Function safeGetEnvVar($varName, $default) {
	if (Test-Path "env:$varName") {
		return getEnvVar $varName
	}
	
	return $default
}

Function getEnvVar($varName) {
    return (Get-Item "env:$varName").value
}

Function getPair() {
    $currentPair = getEnvVar("GIT_AUTHOR_NAME")
    return "Currently pairing: $currentPair"
}

Function setEnvVar($name, $value) {
    setLocalEnvVar $name $value
    [Environment]::SetEnvironmentVariable($name, $value, "User")
}

Function setLocalEnvVar($name, $value) {
    New-Item "env:" -Force -name $name -value $value
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
    setLocalEnvVar $varName ([Environment]::GetEnvironmentVariable($varName, "User"))
}

reloadVariable "GIT_AUTHOR_NAME"
reloadVariable "GIT_AUTHOR_ALIASES"
reloadVariable "GIT_AUTHOR_EMAIL"

Export-ModuleMember *pair*
Export-ModuleMember *story`*
