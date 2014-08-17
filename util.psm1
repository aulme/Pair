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

Export-ModuleMember *