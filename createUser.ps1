import-module activedirectory
$ADUsers = Import-csv -Path "C:\testAD.csv" -DeLimiter ";"

Foreach($Utilisateur in $ADUsers){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurMotDePasse = "whatever!"
    $UtilisateurNomMail = [System.String]::Concat($UtilisateurPrenom,".",$UtilisateurNom)

    $Prenom = $UtilisateurPrenom.tolower()
    $UtilisateurConnect = $Prenom[0]+$UtilisateurNom
    
 # Vérifier la présence de l'utilisateur dans l'AD
    if (Get-ADUser -Filter {SamAccountName -eq $UtilisateurConnect})
     {
       Write-Warning "L'identifiant $UtilisateurConnect existe déjà dans l'AD"
     }

    else

    {
        # Création de l'utilisateur
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                    -DisplayName "$UtilisateurPrenom $UtilisateurNom" `
                    -GivenName $UtilisateurPrenom `
                    -Surname $UtilisateurNom `
                    -SamAccountName $UtilisateurConnect `
                    -UserPrincipalName "$UtilisateurNomMail@whatever.com" `
                    -EmailAddress "$UtilisateurNomMail@whatever.com" `
                    -Path "OU=whatever,DC=whatever,DC=whatever" `
                    -AccountPassword(ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                    -ChangePasswordAtLogon $true `
                    -Enabled $true 

         # Copie des groupes AD en utilisant l'utilisateur ugroupe 
        $CopyFromUser = Get-ADUser loginofuserwithgroups -prop MemberOf
        $CopyToUser = Get-ADUser $UtilisateurConnect -prop MemberOf
        $CopyFromUser.MemberOf | Where{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Members $CopyToUser
    }
}
