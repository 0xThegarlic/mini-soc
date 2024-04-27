#!/bin/bash

#********************************************************************************************************
#   Description : ce script permet le déploiement complet d un mini SOC composé d un SIEM et d'un SOAR  *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#   Date de la V2.0 : 09/04/2024                                                                        *
#********************************************************************************************************

source data.txt

#******************Fonction pour afficher le menu******************
afficher_menu() {                                                 #
    echo "******************** Menu : ********************"       #
    echo "1- Déploiement du SIEM Wazuh"                           #
    echo "2- Déploiement du SOAR"                                 #
    echo "3- Intégration du SIEM-SOAR"                            #
    echo "4- Quitter"                                             #
}                                                                 #
#******************************************************************

#********************************Fonction pour déployer le SIEM Wazuh********************************
deploiement_siem() {                                                                                #
    echo "**************************** Déploiement du SIEM Wazuh ****************************"      #
                                                                                                    #
    # On récupère le chemin absolu du répertoire contenant le script wazuh                          #
    absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"                      #
                                                                                                    #
    # On se déplace vers le répertoire SIEM                                                         #
    cd "$absoluteScriptPath"/SIEM || exit                                                           #
                                                                                                    #
    # Script de déploiement du SIEM Wazuh                                                           #
    bash ./wazuh.sh                                                                                 #
                                                                                                    #
    echo "**************************** LE SIEM WAZUH DEPOYE !!!! ****************************"      #
}                                                                                                   #
#****************************************************************************************************

#**********************************Fonction pour déployer le SOAR************************************************************************
deploiement_soar() {                                                                                                                    #
    echo "**************************** Déploiement du SOAR ****************************"                                                #
                                                                                                                                        #
    # On propose les options de déploiement                                                                                             #
    echo "Choisissez une option de déploiement pour le SOAR :"                                                                          #
    echo "1- Déploiement via Docker"                                                                                                    #
    echo "2- Déploiement via apt"                                                                                                       #
                                                                                                                                        #
    # On récupère le choix de l'utilisateur                                                                                             #
    read -p "Choix : " choix_deploy                                                                                                     #
                                                                                                                                        #
    case $choix_deploy in                                                                                                               #
        1)                                                                                                                              #
            echo "Déploiement du SOAR via Docker-Compose..."                                                                            #
                                                                                                                                        #
            # Récupère le chemin absolu du répertoire contenant le absoluteScriptPath                                                   #
            absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"                                                  #
                                                                                                                                        #
            # Se déplacer vers le répertoire SOAR                                                                                       #
            cd "$absoluteScriptPath" || exit                                                                                            #
                                                                                                                                        #
            # Copie du répertoire SOAR vers la machine hébergeant le SOAR                                                               #                                                                                     
            scp -r SOAR $SOAR_USER@$SOAR_IP:~/                                                                                          #
                                                                                                                                        #
            # Déploiement du SOAR via Docker-Compose                                                                                    #
            ssh $SOAR_USER@$SOAR_IP "cd SOAR && sed -i 's/my_ip/$SOAR_IP/g' docker-compose.yml && sudo -S docker-compose up -d"         #
            ;;                                                                                                                          #
        2)                                                                                                                              #
            echo "Déploiement du SOAR via apt..."                                                                                       #
                                                                                                                                        #
            # Récupérer le chemin absolu du répertoire contenant le script                                                              #
            absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"                                                  #
                                                                                                                                        #
            # Se déplacer vers le répertoire SOAR                                                                                       #
            cd "$absoluteScriptPath" || exit                                                                                            #
                                                                                                                                        #
            # Copie du répertoire SOAR vers la machine hébergeant le SOAR                                                               #
            scp -r SOAR $SOAR_USER@$SOAR_IP:~/                                                                                          #
                                                                                                                                        #
            # Déploiement du SOAR via Docker-Compose                                                                                    #
            ssh $SOAR_USER@$SOAR_IP "cd SOAR && sudo -S bash soar.sh"                                                                   #
            ;;                                                                                                                          #
        *)                                                                                                                              #
            echo "Option invalide. Le déploiement du SOAR est annulé."                                                                  #
            return                                                                                                                      #
            ;;                                                                                                                          #
    esac                                                                                                                                #

    echo "**************************** SOAR EST DEPLOYÉ !!!! ****************************"
    echo "****** MISP est accessible via https://IP-SOAR (les identifiants sont : admin@admin.test : admin) ******"
    echo "****** THEHIVE est accessible via http://IP-SOAR:9000 ****** (les identifiants sont : admin@thehive.local : secret)"
    echo "****** CORTEX est accessible via http://IP-SOAR:9001 ******"
}

#***********************Fonction pour intégrer Wazuh à TheHive***********************
integration_wazuh_thehive() {                                                       #
    echo "Intégration de Wazuh et TheHive"                                          #
    # Ajoutez votre code d'intégration SIEM-SOAR avec ELK ici                       #
                                                                                    #
    # Récupérer le chemin absolu du répertoire contenant le script                  #
    absoluteScriptPath="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"      #
                                                                                    #
    # Se déplacer vers le répertoire SIEM                                           #
    cd "$absoluteScriptPath"/INTEGRATION || exit                                    #
                                                                                    #
    bash ./wazuh_thehive_integration.sh                                             #
 }                                                                                  #
#************************************************************************************

#*************************Fonction pour intégrer ELK à TheHive*************************
integration_elk_thehive() {                                                           #
    echo "Intégration du SIEM-SOAR avec TheHive..."                                   #
    # Ajoutez votre code d'intégration SIEM-SOAR avec TheHive ici                     #
}                                                                                     #
#**************************************************************************************

#******************Choix de la fonction pour intégrer le SIEM au SOAR******************
integration_siem_soar() {                                                             #
    echo "Intégration du SIEM au SOAR..."                                             #
    echo "Veuillez choisir le SIEM que vous souhaiteriez connecter à TheHive : "      #
    echo "1- Wazuh - TheHive Intégration"                                             #
    echo "2- ELK - TheHive Intégration"                                               #
    read -p "Votre choix : " integration_choice                                       #
                                                                                      #
    case $integration_choice in                                                       #
        1) integration_wazuh_thehive ;;                                               #
        2) integration_elk_thehive ;;                                                 #
        *)                                                                            #
            echo "Choix invalide. L'intégration du SIEM-SOAR est annulée."            #
            return                                                                    #
            ;;                                                                        #
    esac                                                                              #
}                                                                                     #
#**************************************************************************************

#**************************Boucle principale du menu*************************
while true; do                                                              #   
    afficher_menu                                                           #
    read -p "Choisissez une option : " choix                                #
    case $choix in                                                          #
        1) deploiement_siem ;;                                              #
        2) deploiement_soar ;;                                              #
        3) integration_siem_soar ;;                                         #
        4) echo "Au revoir !" && break ;;                                   #
        *) echo "Option invalide. Veuillez choisir une option valide." ;;   #
    esac                                                                    #
done                                                                        #
#****************************************************************************
