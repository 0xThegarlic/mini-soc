#!/bin/bash


#********************************************************************************************************
#   Description : ce script permet le déploiement de WAZUH est ses différents composants                *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#********************************************************************************************************

echo -e "************************ INSTALLATION DES PAQUETS ET TELECHARGEMENT DES FICHIERS DE CONFS ************************"


# Installation des paquets :

apt-get install -y debhelper tar curl libcap2-bin

# Téléchargement des fichiers de confs
curl -sO https://packages.wazuh.com/4.7/wazuh-certs-tool.sh
curl -sO https://packages.wazuh.com/4.7/config.yml

#*********************************Modification du contenu de config.yml*********************************
# node-1 = indexer										       #
sed -i 's/node-1/indexer/g' config.yml                                                                 #
# Config IP indexer avec 1ere occurence								       #
sed -i "0,/<indexer-node-ip>/s/<indexer-node-ip>/$(hostname -I | awk '{print $1}')/" config.yml        #
# wazuh-1 = manager                                                                                    #
sed -i 's/wazuh-1/manager/g' config.yml                                                                #
# Config IP manager avec 1ere occurence                                                                #
sed -i "0,/<wazuh-manager-ip>/s/<wazuh-manager-ip>/$(hostname -I | awk '{print $1}')/" config.yml      #
# Config IP dashboard avec 1ere occurence                                                              #
sed -i "0,/<dashboard-node-ip>/s/<dashboard-node-ip>/$(hostname -I | awk '{print $1}')/" config.yml    #
#*******************************************************************************************************

# Création des certificats
bash ./wazuh-certs-tool.sh -A

# Compression des fichiers
tar -cvf ./wazuh-certificates.tar -C ./wazuh-certificates/ .

# Installation des packets
apt-get install -y debconf adduser procps

#Ajout des repos wazuh

# Installation des paquets manquants
apt-get install -y gnupg apt-transport-https

# Installation de la clé GPG
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

# Ajout du référentiel
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list

echo -e "************************ MISE A JOUR DU SYSTEME ************************"

# MAJ
apt-get update


echo -e "************************ INSTALLATION DE WAZUH INDEXER ************************"
# Installation de wazuh indexer
apt-get -y install wazuh-indexer

#**************Configuration de wazuh indexer depuis /etc/wazuh-indexer/opensearch.yml**************
sed -i "0,/0.0.0.0/s/0.0.0.0/$(hostname -I | awk '{print $1}')/" /etc/wazuh-indexer/opensearch.yml #
sed -i 's/node-1/indexer/g' /etc/wazuh-indexer/opensearch.yml                                      #
#***************************************************************************************************

#*************************************************Déploiement des certificats pour Wazuh Indexer*************************************************
NODE_NAME=indexer																#
mkdir /etc/wazuh-indexer/certs															#
tar -xf ./wazuh-certificates.tar -C /etc/wazuh-indexer/certs/ ./$NODE_NAME.pem ./$NODE_NAME-key.pem ./admin.pem ./admin-key.pem ./root-ca.pem	#
mv -n /etc/wazuh-indexer/certs/$NODE_NAME.pem /etc/wazuh-indexer/certs/indexer.pem								#
mv -n /etc/wazuh-indexer/certs/$NODE_NAME-key.pem /etc/wazuh-indexer/certs/indexer-key.pem							#
chmod 500 /etc/wazuh-indexer/certs														#
chmod 400 /etc/wazuh-indexer/certs/*														#
chown -R wazuh-indexer:wazuh-indexer /etc/wazuh-indexer/certs											#
#************************************************************************************************************************************************

#********Démarrage du service Wazuh Indexer********
systemctl daemon-reload				  #
systemctl enable wazuh-indexer                    #
systemctl start wazuh-indexer                     #
#**************************************************

# Initialisation du cluster
/usr/share/wazuh-indexer/bin/indexer-security-init.sh

#*************************Test de l'installation du cluster*************************
curl -k -u admin:admin https://$(hostname -I | awk '{print $1}'):9200              #
curl -k -u admin:admin https://$(hostname -I | awk '{print $1}'):9200/_cat/nodes?v #
#***********************************************************************************


echo -e "************************ INSTALLATION DE WAZUH SERVER ************************"

# Installation des paquets de wazuh manager
apt-get -y install wazuh-manager

#********Démarrage du service Wazuh Manager********
systemctl daemon-reload                           #
systemctl enable wazuh-manager                    #
systemctl start wazuh-manager                     #
#**************************************************

# Installation des paquets filebeat
apt-get -y install filebeat

# Configuration de Filebeat

# Téléchargement du fichier de configuration Filebeat préconfiguré.
curl -so /etc/filebeat/filebeat.yml https://packages.wazuh.com/4.7/tpl/wazuh/filebeat/filebeat.yml

#**********************Modification de /etc/filebeat/filebeat.yml**********************
sed -i "s/127.0.0.1/$(hostname -I | awk '{print $1}')/g" /etc/filebeat/filebeat.yml   #
#**************************************************************************************

# Création d"un magasin de clés Filebeat pour stocker en toute sécurité les informations d'authentification.
filebeat keystore create

# Ajout du nom d'utilisateur et le mot de passe par défaut admin: adminau magasin de clés secrets.
echo admin | filebeat keystore add username --stdin --force
echo admin | filebeat keystore add password --stdin --force

# Téléchargement du modèle d'alertes pour l'indexeur Wazuh.
curl -so /etc/filebeat/wazuh-template.json https://raw.githubusercontent.com/wazuh/wazuh/v4.7.3/extensions/elasticsearch/7.x/wazuh-template.json
chmod go+r /etc/filebeat/wazuh-template.json

# Installation du module Wazuh pour Filebeat.
curl -s https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.3.tar.gz | tar -xvz -C /usr/share/filebeat/module

#*************************************************Déploiement des certificats pour Wazuh Indexer*************************************************
MANAGER_NAME=manager														                #
mkdir /etc/filebeat/certs                                     											#
tar -xf ./wazuh-certificates.tar -C /etc/filebeat/certs/ ./$MANAGER_NAME.pem ./$MANAGER_NAME-key.pem ./root-ca.pem				#
mv -n /etc/filebeat/certs/$MANAGER_NAME.pem /etc/filebeat/certs/filebeat.pem									#
mv -n /etc/filebeat/certs/$MANAGER_NAME-key.pem /etc/filebeat/certs/filebeat-key.pem								#
chmod 500 /etc/filebeat/certs															#
chmod 400 /etc/filebeat/certs/*															#
chown -R root:root /etc/filebeat/certs														#
#************************************************************************************************************************************************

#***Démarrage du service Filebeat***
systemctl daemon-reload            #
systemctl enable filebeat          #
systemctl start filebeat           #
#***********************************

# Vérification du fonctionnement de Filebeat
#filebeat test output


echo -e "***************************** WAZUH-DASHBOARD *****************************"

# Installation de Wazuh Dashboard
apt-get -y install wazuh-dashboard

#************************************Configuration de Wazuh Dashboard************************************
sed -i "s/0.0.0.0/$(hostname -I | awk '{print $1}')/g" /etc/wazuh-dashboard/opensearch_dashboards.yml   #
#sed -i "s/443/4443/g" /etc/wazuh-dashboard/opensearch_dashboards.yml                                   #
sed -i "s/localhost/$(hostname -I | awk '{print $1}')/g" /etc/wazuh-dashboard/opensearch_dashboards.yml #
#********************************************************************************************************

#**************************************************Déploiement des certificats**************************************************
DASHBOARD_NAME=dashboard 												       #
mkdir /etc/wazuh-dashboard/certs											       #
tar -xf ./wazuh-certificates.tar -C /etc/wazuh-dashboard/certs/ ./$DASHBOARD_NAME.pem ./$DASHBOARD_NAME-key.pem ./root-ca.pem  #
mv -n /etc/wazuh-dashboard/certs/$DASHBOARD_NAME.pem /etc/wazuh-dashboard/certs/dashboard.pem 				       #
mv -n /etc/wazuh-dashboard/certs/$DASHBOARD_NAME-key.pem /etc/wazuh-dashboard/certs/dashboard-key.pem                          #
chmod 500 /etc/wazuh-dashboard/certs											       #
chmod 400 /etc/wazuh-dashboard/certs/*											       #
chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/certs                                                            #
#*******************************************************************************************************************************

#***Démarrage de wazuh dashboard***
systemctl daemon-reload           #
systemctl enable wazuh-dashboard  #
systemctl start wazuh-dashboard   #
#**********************************
#sleep 20

#sed -i "s/localhost/$(hostname -I | awk '{print $1}')/g" /usr/share/wazuh-dashboard/data/wazuh/config/wazuh.yml

echo -e "************************ SUPPRESSION DES CERTIFICATS ************************"

# Suppression des fichiers et archives
rm -rf wazuh-cert*
rm config.yml

echo -e "******************** Vous pouvez accéder au dashboard de wazuh via : https://$(hostname -I | awk '{print $1}') avec les identifiants : (admin : admin)"
