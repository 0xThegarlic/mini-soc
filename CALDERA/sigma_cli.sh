#!/bin/bash

#References:
	# https://github.com/SigmaHQ/sigma-cli
	# https://sigconverter.io/

#***********************************************************************************************************************************
#   Description : ce script permet de convertir les règles sigma détectées dans l'extraction des opérations caldera                *
#   Auteur : Laye                                                                                                                  *
#   Version : 1.0                                                                                                                  *
#   Date de la V1.0 : 07/04/2024                                                                                                   *
#***********************************************************************************************************************************


echo -e "************************* Installation de PIP *************************"


apt-get -y install python3-pip

echo -e "************************* Installation de sigma-cli *************************"

python3 -m pip install sigma-cli

echo -e "************************* Installation des plugins sigma *************************"


sigma plugin install splunk

sigma plugin install microsoft365defender

sigma plugin install loki

sigma plugin install sentinelone

echo -e "************************* Vous pouvez convertir maintenant vos règles sigma *************************"

#sigma convert --without-pipeline  -t splunk -f default T1560.001
