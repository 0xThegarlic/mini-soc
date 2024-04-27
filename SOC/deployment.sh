#!/bin/bash

#********************************************************************************************************
#   Description : ce script permet le déploiement complet d un mini SOC composé d un SIEM et d'un SOAR  *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#********************************************************************************************************


source data.txt

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

    # Récupérer le chemin absolu du répertoire contenant le script
    absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

    # Se déplacer vers le répertoire SIEM
    cd "$absoluteScriptPath"/SIEM || exit

    # Script de déploiement du SIEM Wazuh
    bash ./wazuh.sh

    echo "**************************** SIEM WAZUH DEPOYE !!!! ****************************"


}

# Fonction pour déployer le SOAR
deploiement_soar() {
    echo "**************************** Déploiement du SOAR ****************************"

    # Proposer les options de déploiement
    echo "Choisissez une option de déploiement pour le SOAR :"
    echo "1- Déploiement via Docker"
    echo "2- Déploiement via apt"

    read -p "Choix : " choix_deploy

    case $choix_deploy in
        1)
            echo "Déploiement du SOAR via Docker-Compose..."

            # Récupérer le chemin absolu du répertoire contenant le script
            absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

            # Se déplacer vers le répertoire SOAR
            cd "$absoluteScriptPath" || exit

            # Copie du répertoire SOAR vers la machine hébergeant le SOAR
            scp -r SOAR $SOAR_USER@$SOAR_IP:~/

            # Déploiement du SOAR via Docker-Compose
            ssh $SOAR_USER@$SOAR_IP "cd SOAR && sed -i 's/my_ip/$SOAR_IP/g' docker-compose.yml && sudo -S docker-compose up -d"

            ;;
        2)
            echo "Déploiement du SOAR via apt..."

            # Récupérer le chemin absolu du répertoire contenant le script
            absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

            # Se déplacer vers le répertoire SOAR
            cd "$absoluteScriptPath" || exit

            # Copie du répertoire SOAR vers la machine hébergeant le SOAR
            scp -r SOAR $SOAR_USER@$SOAR_IP:~/

            # Déploiement du SOAR via Docker-Compose
            ssh $SOAR_USER@$SOAR_IP "cd SOAR && sudo -S bash soar.sh"

            ;;
        *)
            echo "Option invalide. Le déploiement du SOAR est annulé."
            return
            ;;
    esac

    echo "**************************** SOAR EST DEPLOYÉ !!!! ****************************"
    echo "****** MISP est accessible via https://IP-SOAR (les identifiants sont : admin@admin.test : admin) ******"
    echo "****** THEHIVE est accessible via http://IP-SOAR:9000 ****** (les identifiants sont : admin@thehive.local : secret)"
    echo "****** CORTEX est accessible via http://IP-SOAR:9001 ******"
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
