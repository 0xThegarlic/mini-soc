# Import des modules
import json
import base64

# Référence :
#https://www.programiz.com/python-programming/json

# Chargement des données du fichier JSON
with open('nom_du_fichier_operation.json', 'r') as f:
    resultats_operations = json.load(f)

# Décodage du champ "command" de base64 en texte clair
for op in resultats_operations:
    op['command'] = base64.b64decode(op['command']).decode('utf-8')

# Filtrage des résultats d'opération avec status = 0
resultats_filtres = [op for op in resultats_operations if op['status'] == 0]

# Écriture des résultats filtrés dans un nouveau fichier JSON
with open('resultats_operations_filtres.json', 'w') as f:
    json.dump(resultats_filtres, f, indent=2)
