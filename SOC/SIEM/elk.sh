#!/bin/bash


#********************************************************************************************************
#   Description : ce script permet le déploiement de WAZUH est ses différents composants                *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#********************************************************************************************************

echo -e "************************ INSTALLATION D'ELASTICSEARCH ************************"

#***********************************Installation d'Elasticsearch**********************************#
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.2-amd64.deb          #
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.2-amd64.deb.sha512   #
shasum -a 512 -c elasticsearch-8.13.2-amd64.deb.sha512                                            #
sudo dpkg -i elasticsearch-8.13.2-amd64.deb                                                       #
#**************************************************************************************************

#***********************************Configuration d'Elasticsearch**********************************#
sed -i '/^#network.host: 192.168.0.1/a\network.host: 0.0.0.0' /etc/elasticsearch/elasticsearch.yml #
sed -i '94i\xpack.security.authc.api_key.enabled: true' /etc/elasticsearch/elasticsearch.yml       #
sed -i 's/^#\(transport\.host: 0.0.0.0\)/\1/' /etc/elasticsearch/elasticsearch.yml                 #
#***************************************************************************************************

#************Démarrage d'Elasticsearch ************#
systemctl daemon-reload                            #
systemctl enable elasticsearch.service             #
systemctl start elasticsearch.service              #
#***************************************************


echo -e "************************ INSTALLATION DE KIBANA ************************"

#**************************Installation de Kibana**************************#
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.13.2-amd64.deb #
shasum -a 512 kibana-8.13.2-amd64.deb                                      #
sudo dpkg -i kibana-8.13.2-amd64.deb                                       #
#***************************************************************************

#*********************************Configuration de Kibana*********************************#
sed -i 's/^#\(server\.port: 5601\)/\1/' /etc/kibana/kibana.yml                            #
sed -i 's/^#\(server\.host: "localhost"\)/server.host: "0.0.0.0"/' /etc/kibana/kibana.yml #
#******************************************************************************************

#*******Démarrage de Kiabana*******#
systemctl daemon-reload            #
systemctl enable kibana.service    #
systemctl start kibana.service     #
#***********************************
