# -*- coding: utf-8 -*-
#*******************************************************************************************************************************************************
#   Description : Ce code Python permet l'automatisation du scraping pour faciliter le traitement des opérations de test effectuées avec Caldera 3.1.0 *
#   Auteur : Laye                                                                                                                                      *
#   Version : 1.0                                                                                                                                      *
#   Date de la V1 : 12/04/2024                                                                                                                         *
#   Date de la V2 : 22/04/2024                                                                                                                         *
#*******************************************************************************************************************************************************

# Référence selenium : https://www.youtube.com/watch?v=tnrsSJ17ei8

#Importe les modules nécessaires de la bibliothèque Selenium.
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
import time



# Initialise le pilote WebDriver (Firefox ou Chrome)
driver = webdriver.Firefox()  # Ou webdriver.Chrome() pour Chrome

#driver = webdriver.Firefox(executable_path='./geckodriver.exe')
# URL du site cible
url = "http://IP_ADDRESS:8888/"

# Ouvre le site dans le navigateur
driver.get(url)

# Identifiants de connexion
username = "red"
password = "nxokrsBxiDJnEhfNndx4kJ8lObUrrL-ud9AOCIncyzc"

# Localisation du champ username et saisie du nom d'utilisateur en utilisant le sélecteur CSS SELECTOR
username_field = driver.find_element(By.CSS_SELECTOR, 'div.control-group:nth-child(1) > input:nth-child(1)')
username_field.send_keys(username)

# Localisation du champ password et saisie du mot de passe en utilisant le sélecteur CSS SELECTOR
password_field = driver.find_element(By.CSS_SELECTOR, 'div.control-group:nth-child(2) > input:nth-child(1)')
password_field.send_keys(password)

# Action de clic sur le bouton de connexion en utilisant CSS SELECTOR
login_button = driver.find_element(By.CSS_SELECTOR, '.button-success')
login_button.click()


# Action de clic sur le bouton "navigate" en utilisant le sélecteur CSS PATH
navigate_button = driver.find_element(By.CSS_SELECTOR, 'html body div.navbar-buffer div.navbar span')
navigate_button.click()


# Attendre que le bouton "operations" soit cliquable
WebDriverWait(driver, 30).until(EC.element_to_be_clickable((By.CSS_SELECTOR, 'a[onclick="viewSection(\'operations\', \'/campaign/operations\')"]')))


# Action de clic sur "operations" en utilisant le sélecteur CSS SELECTOR
operations_link = driver.find_element(By.CSS_SELECTOR, 'a[onclick="viewSection(\'operations\', \'/campaign/operations\')"]')
operations_link.click()

# attente de 5s
time.sleep(5)


# Obtenir la liste des opérations en utilisant le sélecteur XPATH
operation_list = driver.find_element(By.XPATH, '//*[@id="operation-list"]')
actions = ActionChains(driver)
actions.move_to_element(operation_list).perform()
operation_list.click()


# Localisation d'une opération spécifique après le clic précédent
operation_element = driver.find_element(By.XPATH, '//*[contains(@id, "operation_name")]')
# Cliquer sur l'opération spécifique
operation_element.click()



# Attendre que le bouton de téléchargement du rapport soit cliquable et le télécharger en utilisant le sélecteur XPATH
download_button = WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.XPATH, '//*[@id="eventLogBtn"]')))
# Cliquez sur le bouton de téléchargement du rapport
download_button.click()


# Fermer le navigateur après le téléchargement
driver.quit()
