function encrypt($input, $output, $primary_pass, $secondary_pass){
    [string]$combinedpass = "$primary_pass$secondary_pass"
    $key_filename = Get-Random
    $keyfile = "$PSScriptRoot\$key_filename.txt"
    New-Item -ItemType "file" -Path -keyfile | Out-Null
    $EncryptPMixpwdKey = Echo $ShifflePMixPwd | .\openssl.exe dgst -sha256
    $AllFiles = GetChildItem -Path $input -Recurse | ?{$_.Extension -ne $null -and $_.Extension -ne ""}

    ForEach ($File in $AllFiles){
        $path = $file.Fullname
        $filen = $file.Name
        $fileenc = Echo $filen | .\openssl.exe dgst -sha256
        Add-Content -Path $keyfile -Value "$fileenc,$filen"
        .\openssl.exe enc -aes256-cbc -salt -in $path -out $output\$fileenc -k $EncryptPMixpwdKey
    }

    .\openssl.exe enc -aes-256-cbc -salt -in $keyfile -out $output"\Encryption.key" -k $EncryptPMixpwdKey
    Remove-Item $keyfile -Force
}

function decrypt($input, $output, $unique_key, $keyfile){
    $key_filename = Get-Random
    $keyfile_extract_path = "$Env:APPDATA\Microsoft"
    .\openssl.exe enc -aes256-cbc -salt -d -in $keyfile -out $keyfile_extract_path\"$key_filename.key" -k $unique_key
    $readkey = Get-Content -Path $keyfile_extract_path\"$key_filename.key"
    $allfiles = Get-ChildItem -Path $input | ?{$_.Extension -eq $null -or $_.Extension -eq ""}

    ForEach ($file in $allfiles){
        $path = $file.Fullname
        $filen = $file.Name
        ForEach ($fileI in $readkey){
            $FileH,$FileJ = $fileI.split(",",2)
            if($FileH -eq $filen){
                .\openssl.exe enc -aes-256-cbc -salt -d -in $path -out $Output\$FileJ -k $unique_key
        }

    }
    Remove-Item $KeyFileExtractPath\"$key_filename.key" -Force }
