# PO_laposte

Project d'option de dernière année (IMT Atlantique - Campus Nanets). Le but est de prédir à un instant donné les 10 meilleures destinations CE30 d'une PIC afin de maximiser le taux d'utilisation d'un robot trieur.

## Méthode Prophet

Utilisation de la méthode Prophet. TO DO

## Méthode LSTM

Utilisation de réseaux neuronnes profonds à travers d'un LSTM



## Nettoyage des données

Le script utilisé est **data_processing.py**. Les inputs sont les suivantes :

- *dir_path* : chemin vers le dossier contenant les données brutes (.fichiers xlsx)
- *out_path* : chemin output pour sauvegarder les fichier nettoyés

Example de commande

`python data_processing.py "row_data/" "data_processed.csv"`



## Génération des inputs

Le script utilisé est **input_generation.py**. Les inputs sont les suivantes 

* *data_path* : chemin vers le fichier csv contenant les données nettoyées
* *step_group* : pas de temps pour grouper les lignes
* delta_train : intervalle de temps pour chaque instance d'entrainement
* delta_prediction : intervalle de temps sur lequel la prédiction doit être faite
* window_slide : temps de window slide pour chaque nouvelle inpute

Example de commande

`python input_generation.py "data_processed.csv" "2min" "2h" "30min" "2h"` 

# Auteurs

* **Gauthier Gris** : travail sur le LSTM - nettoyage des données - génération des inputs
* **Quentin Depoortere** : travail sur le LSTM
* **Etienne Raveau** : travail sur Prohpet
* **Laura Mabru** : travail sur Prophet