#!/bin/bash

#********************************************************************************************************
#   Description : ce script permet le déploiement de WAZUH est ses différents composants                *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#********************************************************************************************************


echo -e "************************ INSTALLATION DE CASSANDRA ************************"

# Installation de Java Virtual Machine
apt-get install -y openjdk-8-jre-headless
echo JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64" >> /etc/environment
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"


#****************************************************************************Installation de Cassandra***************************************************************************
wget -qO -  https://downloads.apache.org/cassandra/KEYS | sudo gpg --dearmor  -o /usr/share/keyrings/cassandra-archive.gpg							#
echo "deb [signed-by=/usr/share/keyrings/cassandra-archive.gpg] https://debian.cassandra.apache.org 40x main" |  sudo tee -a /etc/apt/sources.list.d/cassandra.sources.list 	#
sudo apt update																					#
sudo apt install cassandra -y																			#
#********************************************************************************************************************************************************************************
sleep 15

#****************************************************Configuration de cassandra****************************************************
sed -i "s/Test Cluster/thp/g" /etc/cassandra/cassandra.yaml									  #
sed -i "s%^listen_address:.*$%listen_address: $(hostname -I | awk '{print $1}')%" /etc/cassandra/cassandra.yaml                   #
sed -i "s%^rpc_address:.*$%rpc_address: $(hostname -I | awk '{print $1}')%" /etc/cassandra/cassandra.yaml                         #
sleep 15															  #
sed -i "s/^# hints_directory:/hints_directory:/" /etc/cassandra/cassandra.yaml							  #
sleep 15                                  											  #
cqlsh localhost 9042 -e "UPDATE system.local SET cluster_name = 'thp' WHERE key='local';"                                         #
sleep 15															  #
#**********************************************************************************************************************************

#******Démarrage de cassandra******
sudo systemctl start cassandra    #
sudo systemctl enable cassandra   #
#**********************************

echo -e "************************ INSTALLATION D'ELASTICSEARCH ************************"

#****************************************************************************Installation d'ElasticSearch****************************************************************************
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch |  sudo gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg						    #
sudo apt-get install apt-transport-https																	    #
echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" |  sudo tee /etc/apt/sources.list.d/elastic-7.x.list #
sudo apt update																					    #
sudo apt install elasticsearch -y																		    #
#************************************************************************************************************************************************************************************

#***********************************Configuration d'ElasticSearch***********************************
sed -i "s/#cluster.name: my-application/cluster.name: hive/g" /etc/elasticsearch/elasticsearch.yml  #
#****************************************************************************************************

#****Démarrage d'ElasticSearch****
systemctl daemon-reload          #
systemctl start elasticsearch    #
systemctl enable elasticsearch   #
#*********************************

#**Test de fonctionnement d'Elastic**
curl localhost:9200                 #
#************************************

echo -e "************************ INSTALLATION DE TheHIVE ************************"

#*******************************************************************************Installation de TheHive*******************************************************************************
wget -O- https://archives.strangebee.com/keys/strangebee.gpg | sudo gpg --dearmor -o /usr/share/keyrings/strangebee-archive-keyring.gpg						     #
echo 'deb [arch=all signed-by=/usr/share/keyrings/strangebee-archive-keyring.gpg] https://deb.strangebee.com thehive-5.2 main' |sudo tee -a /etc/apt/sources.list.d/strangebee.list  #
sudo apt-get update																				     #
sudo apt-get install -y thehive																			     #
#*************************************************************************************************************************************************************************************

#***Démarrage de TheHive***
systemctl start thehive   #
systemctl enable thehive  #
#**************************

echo -e "************************ TheHive est Déployé et accéssible via : http://$(hostname -I | awk '{print $1}'):9000 ************************"
echo -e "************************ Identifiants de TheHive : admin@thehive.local : secret ************************"

sleep 5

echo -e "************************ INSTALLATION DE CORTEX ************************"

#**************************************************************Installation de Cortex**************************************************************
wget -qO- "https://raw.githubusercontent.com/TheHive-Project/Cortex/master/PGP-PUBLIC-KEY" | gpg --dearmor -o /etc/apt/trusted.gpg.d/cortex.gpg   #
wget -qO- https://raw.githubusercontent.com/TheHive-Project/Cortex/master/PGP-PUBLIC-KEY | gpg --dearmor -o /etc/apt/trusted.gpg.d/thehive.gpg    #
echo 'deb https://deb.thehive-project.org release main' | tee -a /etc/apt/sources.list.d/thehive-project.list                                     #
sudo apt update																	  #
sudo apt install cortex -y															  #
#**************************************************************************************************************************************************

#*************************************************Configuration de Cortex*************************************************
# Générer le mot de passe												 #
key=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 64 | head -n 1)							 #
# Remplacer le mot de passe dans le fichier /etc/cortex/application.conf						 #
sed -i "s/^#play.http.secret.key=\"\*\*\*CHANGEME\*\*\*\"/play.http.secret.key=\"$key\"/" /etc/cortex/application.conf	 #
#*************************************************************************************************************************

#******Démarrage de Cortex******
systemctl enable --now cortex  #
systemctl start cortex         #
#*******************************

echo -e "************************ Cortex est Déployé et accéssible via : http://$(hostname -I | awk '{print $1}'):9001 ************************"
