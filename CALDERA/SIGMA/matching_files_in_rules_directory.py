#***************************************************************************************************************************************************************************
#   Description : Ce script Python recherche dans le répertoire rules les fichiers qui correspondent aux identifiants de technique extraits dans les opérations de CALDERA *
#   Auteur : Laye                                                                                                                                                          *
#   Version : 1                                                                                                                                                            *
#   Date de la V1 : 17/04/2024                                                                                                                                             *
#***************************************************************************************************************************************************************************

import os
import json

# Chemin vers le répertoire contenant rules
rules_directory = "rules"

# On charge le contenu de resultats_operations_filtres.json dans data
with open("resultats_operations_filtres.json", "r") as file:
    data = json.load(file)

# On crée une liste pour stocker les noms des fichiers correspondants aux technique_id
matching_files = []

# On parcourt chaque élément du fichier resultats_operations_filtres.json
for item in data:
    # On extrait la valeur de chaque technique_id de data
    technique_id = item.get("attack_metadata", {}).get("technique_id")
    if technique_id:
        # On cherche dans les fichiers correspondants dans le répertoire rules pour voir s'il y a une correspondance entre le technique_id (ici c'est les noms des fichiers depuis rules)
        matching_files.extend([f for f in os.listdir(rules_directory) if technique_id in f])

# On affiche les noms des fichiers correspondants
if matching_files:
    print("Fichiers correspondants aux technique_id :")
    for file_name in matching_files:
        print(file_name)
else:
    print("Aucun fichier correspondant trouvé dans le répertoire rules.")
