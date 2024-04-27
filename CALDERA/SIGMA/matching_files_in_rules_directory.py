import os
import json

# Chemin vers le répertoire contenant les fichiers rules
rules_directory = "rules"

# Chargement du fichier le contenu du fichier JSON
with open("resultats_operations_filtres.json", "r") as file:
    data = json.load(file)

# Liste pour stocker les noms des fichiers correspondants aux technique_id
matching_files = []

# Parcourir chaque élément du fichier JSON
for item in data:
    # Extraire la valeur de la clé technique_id
    technique_id = item.get("attack_metadata", {}).get("technique_id")
    if technique_id:
        # Rechercher les fichiers correspondants dans le répertoire rules
        matching_files.extend([f for f in os.listdir(rules_directory) if technique_id in f])

# Afficher les noms des fichiers correspondants
if matching_files:
    print("Fichiers correspondants aux technique_id :")
    for file_name in matching_files:
        print(file_name)
else:
    print("Aucun fichier correspondant trouvé dans le répertoire rules.")
