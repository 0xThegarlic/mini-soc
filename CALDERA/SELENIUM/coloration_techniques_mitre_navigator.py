#*********************************************************************************************************************************************************************************>#   Description : ce code python permet dans un 1er temps de traiter les résultats de test d'opération de CALDERA (succès "status=0") afin d'attribuer une couleur différente à ch>#   Auteur : garlic                                                                                                                                                               >#   Date de la V2 : 01/05/2024                                                                                                                   *
#   ATTENTION !! La e script a été testé que sur Mitre Navigator 4.9.5 avec Layer 4.5 et attack 15 ("domain": "enterprise-attack")                      *
#*********************************************************************************************************************************************************************************>
'''
Références :
  - https://www.docstring.fr/glossaire/json/
  - https://python.doctor/page-apprendre-dictionnaire-python
  - https://stackabuse.com/bytes/generating-random-hex-colors-in-python/
  - https://www.programiz.com/python-programming/json
'''



import json
import base64

#***********************************FONCTION DE TRAITEMENT DES RESULTATS D'OPERATION CALDERA***********************************

# Saisi du nom du fichier des résultats caldera
name_of_caldera_results = input("Entrez le nom du fichier : ")

# Chargement du fichier JSON contenant les résultats de test d'opération CALDERA
with open(name_of_caldera_results, 'r') as f:
    resultats_operations = json.load(f)

# Décodage du champ "command" de base64 en texte clair
for op in resultats_operations:
    op['command'] = base64.b64decode(op['command']).decode('utf-8')

# Écriture des résultats dans un nouveau fichier JSON (resultats_operations_decodes.json)
with open('resultats_operations_decodes.json', 'w') as f:
    json.dump(resultats_operations, f, indent=2)

#***********************************FONCTION DE COLORATION DES TECHNIQUES DANS MITRE NAVIGATOR***********************************

# Chargement du résultat des opérations de test de MITRE CALDERA décodés
with open('resultats_operations_decodes.json', 'r') as f:
    caldera_results = json.load(f)

# Création d'un dictionnaire permettant de stocker les couleurs attribuées à chaque technique de base
technique_colors = {}

# Création d'une liste qui stockera les techniques formatées dans le format requis par MITRE Navigator.
formatted_techniques = []

# On parcourt les résultats de MITRE CALDERA
for result in caldera_results:
    technique_id = result['attack_metadata']['technique_id']
    tactic = result['attack_metadata']['tactic']

    # On extrait l'identifiant de la technique de base
    # Par exemple, une technique pourrait avoir un identifiant comme "T1003.003" où "T1003" est la technique de base et "003" est une sous-technique.
    base_technique_id = technique_id.split('.')[0]

    # Déterminer la couleur en fonction du statut
    if result['status'] == 0:
        color = "#00FF00"  # Vert pour status = 0
    else:
        color = "#FF0000"  # Rouge pour les autres statuts

    # On crée le format de technique pour MITRE Navigator
    technique_format = {
        "techniqueID": technique_id,
        "tactic": tactic,
        "color": color,
        "comment": "",
        "enabled": True,
        "metadata": [],
        "links": [],
        "showSubtechniques": False
    }

    # On ajoute la technique formatée à la liste
    formatted_techniques.append(technique_format)

# On crée le format de technique pour MITRE Navigator. Ici, on se base du modèle de Mitre Navigator
mitre_navigator_layer = {
    "name": "layer",
    "versions": {"attack": "15", "navigator": "5.0.1", "layer": "4.5"},
    "domain": "enterprise-attack",
    "description": "",
    "filters": {"platforms": ["Windows", "Linux", "macOS", "Network", "PRE", "Containers", "Office 365", "SaaS", "Google Workspace", "IaaS", "Azure AD"]},
    "sorting": 0,
    "layout": {"layout": "side", "aggregateFunction": "average", "showID": False, "showName": True, "showAggregateScores": False, "countUnscored": False, "expandedSubtechniques": "none"},
    "hideDisabled": False,
    "techniques": formatted_techniques,
    "gradient": {"colors": ["#ff6666ff", "#ffe766ff", "#8ec843ff"], "minValue": 0, "maxValue": 100},
    "legendItems": [],
    "metadata": [],
    "links": [],
    "showTacticRowBackground": False,
    "tacticRowBackground": "#dddddd",
    "selectTechniquesAcrossTactics": True,
    "selectSubtechniquesWithParent": False,
    "selectVisibleTechniques": False
}

# On enregistre le résultat final dans un fichier JSON
with open('mitre_navigator_coloration.json', 'w') as f:
    json.dump(mitre_navigator_layer, f, indent=4)
