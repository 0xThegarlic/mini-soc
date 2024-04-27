# Import du module json
import json

# Chargement des données du fichier JSON ======> https://www.programiz.com/python-programming/json
with open('nom_du_fichier_operation.json', 'r') as f:
    resultats_operations = json.load(f)

# Filtrage des résultats d'opération avec le status = 0
resultats_filtres = [op for op in resultats_operations if op['status'] == 0]

# Écriture des résultats filtrés dans un nouveau fichier JSON
with open('resultats_operations_filtres.json', 'w') as f:
    json.dump(resultats_filtres, f, indent=2)
