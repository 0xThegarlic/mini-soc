#!/bin/bash

#********************************************************************************************************
#   Description : ce script permet l'intégration du Wazuh à TheHive                                     *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 09/04/2024									*
#   Date de la V2.0 : 12/04/2024                                                                        *
#********************************************************************************************************

# Fichier déclaratif
source data.txt


echo -e "**************************** Installation de pip3 ****************************"

# Installation de pip3 (s'il n'existe pas)
sudo apt install python3-pip -y

echo -e "**************************** Installation du module TheHive4py ****************************"

# Installation du module de TheHive avec PIP
sudo /var/ossec/framework/python/bin/pip3 install thehive4py

echo -e "**************** Copie es fichiers d'intégration vers var/ossec/integrations ****************"

# Copie des fichies d'intégration vers /var/ossec/integrations
cp custom-w2thive* /var/ossec/integrations

echo -e "**************** Attribution des droits nécessaires aux fichiers d'intégration ****************"

# Attribution des droits nécessaires aux fichiers d'intégration
sudo chmod 755 /var/ossec/integrations/custom-w2thive*
sudo chown root:wazuh /var/ossec/integrations/custom-w2thive*

# Saisie de la clé API de TheHive
read -p "Veuillez saisir la clé API de l'utilisateur de TheHive : " api_key

echo -e "********************* Insertion de la section d'integration dans ossec.conf *********************"

#Insertion de la section Integration avant la ligne contenant la section <alerts>

sudo sed -i '/<alerts>/i \
  <integration>\
    <name>custom-w2thive</name>\
    <hook_url>http://'$SOAR_IP':9000</hook_url>\
    <api_key>'$api_key'</api_key>\
    <alert_format>json</alert_format>\
  </integration>\
' /var/ossec/etc/ossec.conf

echo -e "**************************** Redémarrage de WAZUH SERVER ****************************"

# Démarrage de Wazuh Server
sudo systemctl restart wazuh-manager

echo -e "**************************** WAZUH ET THEHIVE SONT CONNECTES !!!! ****************************"

