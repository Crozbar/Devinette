<# Crozbar, janvier 2022
Rédigé pour Powershell 7
Ce jeu implémente le plus simple des 'guessing games' dans un menu CLI#>

Clear-Host
$menu = "
================
Les devinettes |
================
Que faire?

1. Ajouter un joueur
2. Commencer une partie
3. Afficher le score
4. Sauvegarder la partie
5. Charger une partie
6. Quitter le jeu
7. Modifier un score / RESET (admin)`n`n"

$participants = @{} #Créer la table qui va contenir le couple clé=valeur pour garder le score
$password = "root" #Devra apprendre à valider()
$sauvegarde = ".\savedGames\devinette-savegame.json" #Emplacement pour sauvegarder et charger sa partie

while ($true) {   
    switch (Read-Host "$menu   Choisir une option (1-7)") {
        '1' {#Ajoute un nouveau joueur            
            Clear-Host
            $nom = read-host -Prompt "Nouveau joueur"
                if ($participants.ContainsKey($nom)) { #Vérifie l'existence d'un homonyme
                    Write-Warning "Ce joueur est déjà inscrit !"; Start-Sleep 2; Clear-Host
                }else {
                    $participants.Add($nom, 0)
                    Clear-Host
                }
        }
        '2' {#Commence une partie            
            Clear-Host
            $nom = read-host -Prompt "Qui devine? "
            if ($participants.ContainsKey($nom)) {
                $nbcible = ( Read-Host -Prompt "Inscrivez le mot à deviner" -MaskInput )
                if ($nbcible -eq ''){ Write-Warning "Cette entrée ne peut être vide..."; Start-Sleep 2; Clear-Host }
                else{
                do {
                    $essai = Read-Host -Prompt "Devinez le mot secret..."
                    if ($essai -eq ''){ Write-Warning "Il faut essayer quelque chose..."; Start-Sleep 2; Clear-Host }
                }until ($nbcible -ieq $essai)
                $participants[$nom] += 1
                Clear-Host
                Write-Host -ForegroundColor "green" "`n`nBravo $nom! le bon mot était: $nbcible`n`n`n"
                }
            }else { Write-Error "Insérez un nom de joueur valide" ; Start-Sleep 2}
            
        }
        '3' {#Affiche le score
            Clear-Host
            $participants | format-table
        }
        '4' {#sauvegarde la partie
            if (Test-Path -Path "$sauvegarde") {
            $participants | ConvertTo-Json |  set-content "$sauvegarde"
            Write-warning "`n`nPartie sauvegardée dans le fichier $sauvegarde"
            Start-Sleep 2; Clear-Host
        }else {
            Clear-Host; Write-Error "`n`nLa destination de sauvegarde est introuvable.`n`n"; start-sleep 1
            $createdir = Read-Host -Prompt "Créer un nouveau dossier de sauvegarde? `n           [O]oui ou [N]on"
            if ($createdir -ieq "o" -or $createdir -ieq "oui") {
                New-Item -Path '.\savedGames' -ItemType Directory
                #Copié des lignes précédentes... On pourrait reformuler la logique
                $participants | ConvertTo-Json |  set-content "$sauvegarde"
                Clear-Host; Write-warning "`n`nPartie sauvegardée dans le fichier $sauvegarde"
                Start-Sleep 2; Clear-Host
            }
        }
        }
        '5' {#charger une partie JSON             
            if (Test-Path -Path "$sauvegarde") {
            $savedTable = Get-Content "$sauvegarde" | ConvertFrom-Json -AsHashtable
            $loadedTable = @{}
            #Y a probablement une meilleure méthode pour jouer dans un forEach loop
            #On crée un second hashtable dérivé de la sauvegarde, et swap à la fin
            Foreach ($item in $savedTable.GetEnumerator()) {
                $loadedKey = $item.key
                $loadedValue = $item.value
                $loadedTable.add("$loadedKey", $loadedValue)
            }
            Write-warning "`n`nPartie chargée depuis le fichier $sauvegarde"
            Start-Sleep 2
            $participants = $loadedTable            
            Clear-Host
            }else { clear-host; Write-Error "`n`nUne erreur est survenue...`n`nRien n'a été modifié" ; Start-Sleep 2; Clear-Host}            
        }
        '6' {#Quitter            
            exit
        }
        '7' {#Modifie le score
            $check = 0
            $mdp = $null
            Clear-Host
            while ( $mdp -ne $password -AND $check -lt 3) {
                $mdp = Read-Host -Prompt "`n`nZone protégée par un bout de coton`nMot de passe" -MaskInput
                $check ++
            }
            if ($check -lt 3){    
                Clear-Host            
                $reset = Read-Host -prompt "Voulez-vous repartir à zéro`n(en conservant les mêmes joueurs)?`n           [O]oui ou [N]on"
                
                if($reset -ieq "oui" -or $reset -ieq "o"){
                    Clear-Host
                    Write-Output "Reset!"
                    #Pour modifier la table dans un forEach loop, on copie les noms dans $participants
                    #dans une autre table, on leur assigne 0, puis on swap
                    $newPerson = @{}
                    ForEach ($peep in $participants.GetEnumerator()) {
                        Write-Output "j'efface le score de $($peep.name)"
                        $newPeep = $peep.Name
                        $newPerson.add("$newpeep", 0)
                    }
                    $participants = $newPerson                   
                }else {
                $nom = read-host -Prompt "À qui assigner un score?"
                $modif = Read-Host -Prompt "Son score"
                $participants[$nom] = [int]$modif
                Clear-Host
                }
            }
        }
    }    
}
