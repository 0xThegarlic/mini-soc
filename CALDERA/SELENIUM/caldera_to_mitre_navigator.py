
#******************************************************************************************************************************************************
#   Description : ce script permet d'attribuer une couleur différente à chaque technique rencontrée dans le résultat des tests d'opération de CALDERA *
#   Auteur : Laye                                                                                                                                     *
#   Version : 1                                                                                                                                       *
#   Date de la V1 : 01/05/2024                                                                                                                        *
#   ATTENTION !! Ce script a été testé que sur Mitre Navigator 4.9.5 avec Layer 4.5 et attack 15 ("domain": "enterprise-attack")                      *
#******************************************************************************************************************************************************


import json
import random


#Références :
#  - https://www.docstring.fr/glossaire/json/
#  - https://python.doctor/page-apprendre-dictionnaire-python
#  - https://stackabuse.com/bytes/generating-random-hex-colors-in-python/


# Chargement du résultat des opérations de test de MITRE CALDERA
with open('caldera_test_results.json', 'r') as f:
    caldera_results = json.load(f)

# Création d'un dictionnaire pour stocker les couleurs attribuées à chaque technique
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

    # On vérifie si la technique de base a déjà une couleur attribuée
    if base_technique_id in technique_colors:
        color = technique_colors[base_technique_id]
    else:
        # On génère une nouvelle couleur aléatoire pour la technique de base
        color = "#{:06x}".format(random.randint(0, 0xFFFFFF))
        technique_colors[base_technique_id] = color

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
    "versions": {"attack": "15", "navigator": "4.9.5", "layer": "4.5"},
    "domain": "enterprise-attack",
    "description": "",
    "filters": {"platforms": ["Linux", "macOS", "Windows", "Network", "PRE", "Containers", "Office 365", "SaaS", "Google Workspace", "IaaS", "Azure AD"]},
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
with open('formatted_mitre_navigator.json', 'w') as f:
    json.dump(mitre_navigator_layer, f, indent=4)
