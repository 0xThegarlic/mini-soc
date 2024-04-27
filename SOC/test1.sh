#!/bin/bash

source data.txt

# On récupère le chemin aboslu du script exécuté 
absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"



# Fonction pour afficher le menu
afficher_menu() {
    echo "******************** Menu : ********************"
    echo "1- Déploiement du SIEM Wazuh"
    echo "2- Déploiement du SOAR"
    echo "3- Intégration du SIEM-SOAR"
    echo "4- Quitter"
}

# Fonction pour déployer le SIEM Wazuh
deploiement_siem() {
    echo "**************************** Déploiement du SIEM Wazuh ****************************"
    # Ajoutez votre code de déploiement Wazuh ici

    # Récupérer le chemin absolu du répertoire contenant le script
    absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

    # Se déplacer vers le répertoire SIEM
    cd "$absoluteScriptPath"/SIEM || exit

    # Exécuter la commande docker-compose up -d
    bash ./wazuh.sh

    echo "**************************** SIEM WAZUH DEPOYE !!!! ****************************"


}

# Fonction pour déployer le SOAR
deploiement_soar() {
    echo "**************************** Déploiement du SOAR ****************************"
    # Ajoutez votre code de déploiement SOAR ici

    # Récupérer le chemin absolu du répertoire contenant le script
    absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

    # Se déplacer vers le répertoire SOAR
    #cd "$absoluteScriptPath"/SOAR || exit

    cd "$absoluteScriptPath" || exit

    # Exécuter la commande docker-compose up -d

    #sed -i "s/my_ip/$SOAR_IP/g" docker-compose.yml

    #scp docker-compose.yml $SOAR_USER@$SOAR_IP:$HOME

    scp -r SOAR $SOAR_USER@$SOAR_IP:~/

    ssh $SOAR_USER@$SOAR_IP "cd SOAR && sed -i 's/my_ip/$SOAR_IP/g' docker-compose.yml && sudo -S docker-compose up -d"

    #ssh $SOAR_USER@$SOAR_IP "cd SOAR && sudo -S bash soar.sh"

    
    #ssh garlic@192.1174 "cd $HOME && sed -i "s/my_ip/$(hostname -I | awk '{print $1}')/g" docker-compose.yml"

    echo "**************************** SOAR DEPOYE !!!! ****************************"

}

# Fonction pour intégrer SIEM-SOAR
integration_siem_soar() {
    echo "Intégration du SIEM-SOAR..."
    # Ajoutez votre code d'intégration SIEM-SOAR ici
}

# Boucle principale du menu
while true; do
    afficher_menu
    read -p "Choisissez une option : " choix
    case $choix in
        1) deploiement_siem ;;
        2) deploiement_soar ;;
        3) integration_siem_soar ;;
        4) echo "Au revoir !" && break ;;
        *) echo "Option invalide. Veuillez choisir une option valide." ;;
    esac
done
