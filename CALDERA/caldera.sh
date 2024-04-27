#!/bin/bash


#********************************************************************************************************
#   Description : ce script permet le déploiement de WAZUH est ses différents composants                *
#   Auteur : Laye                                                                                       *
#   Version : 1.0                                                                                       *
#   Date de la V1.0 : 07/04/2024                                                                        *
#********************************************************************************************************


echo -e "************************* MISE A JOUR DU SYSTEME *************************"

sudo apt-get update && sudo apt-get upgrade -y

echo -e "************************* INSTALLATION DE PIP *************************"

# Installation de pip
sudo apt install python3-pip -y

pip3 install pyopenssl --upgrade

echo -e "********************** CLONAGE DU DEPOT CALDERA **********************"

# Clonage du dépôt de caldera
#git clone https://github.com/mitre/caldera.git --recursive --branch 3.1.0

cd caldera

pip3 install -r requirements.txt

echo -e "********************** DEMARRAGE DE CALDERA **********************"
echo -e "********************** IDENTIFIANT DE CALDERA : (red : nxokrsBxiDJnEhfNndx4kJ8lObUrrL-ud9AOCIncyzc) **********************"

python3 server.py
