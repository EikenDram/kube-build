#
{{- template "prepare" dict "Version" .Version.tekton "Images" .Images.tekton}}
#
if (Test-Match "<tekton> <all>" $Component) {
    if ($ObjectStr -match "<crypt>") {
        # generate htpasswd
        $password = "{{.Values.cluster.password}}"
        $user = "{{.Values.cluster.user}}"
        $htpasswdPath = "install/{{.Version.tekton.dir}}/htpasswd"
        
        # Generate bcrypt hash using .NET
        Add-Type -AssemblyName System.Security
        $salt = [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes(16)
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
        $combined = $bytes + $salt
        $hash = [Convert]::ToBase64String([System.Security.Cryptography.SHA512]::Create().ComputeHash($combined))
        
        # Create htpasswd entry (simplified bcrypt format)
        $htpasswdEntry = "$user`:`$2y`$10`$" + $hash.Substring(0, 53)
        Set-Content -Path $htpasswdPath -Value $htpasswdEntry
        Write-Output "htpasswd generated"
    }
}
#
