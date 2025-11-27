#
{{- template "prepare" dict "Version" .Version.os "Images" .Images.os}}
#

{{- if .Values.server.admin.enabled}}
if (Test-Match "<os> <all>" $Component) {
    if ($ObjectStr -match "<crypt>") {
        # 
        # generate password hash for admin user
        Add-Type -AssemblyName System.Security
        $password = "{{.Values.server.admin.password}}"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($password)
        $passhash = '$6$' + [Convert]::ToBase64String([System.Security.Cryptography.SHA512]::Create().ComputeHash($bytes)) -replace '\+', '.' -replace '/', '_' -replace '=', ''
        (Get-Content "install/{{.Version.os.dir}}/coreos.yaml") -replace "__passhash__", $passhash | Set-Content "install/{{.Version.os.dir}}/coreos.yaml"
        Write-Output "Password hash for admin set"
        #
    }
}
{{- end}}
