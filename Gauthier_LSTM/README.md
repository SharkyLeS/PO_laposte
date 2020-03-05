# LSTM - Gauthier

Ce dossier comprant le travail réalisé pour résoudre le problème avec une méthode LSTM (réseau de neurones). Le code est écrit en python et une nécessite une version supérieur à 3.0 ([install python3](https://www.python.org/downloads/)).

## Installation des packages

TODO

pandas



## Nettoyages des données

### Script *data_processing.py* 

Les données brutes des fichiers excels fournis sont nettoyées : suppression des colonnes inutiles et des CBN non utilisables. Le fichier de sortie est de type csv.

Inputs : 

1. *dir_path* : dossier contenant les données brutes (fichiers excel)
2. *out_path* : chemin de sauvegarde des données nettoyées

Exemple d'utilisation :

`python dir_path out_path`

### Script *data_grouping.py* 

Ce script permet de grouper les données nettoyées pour un pas de temps donné. Les données sont ansi regroupées sur des intervalles de temps régulier, ceci permet d'avoir des tailles de données d'entrée fixes pour notre réseau de neuronnes.

Inputs : 

1. *data_path* : chemin vers les données nettoyées
2. *step_grou* : Intervall de temps sur lequel regrouper les données en min
3. *out_path* : chemin de sauvegarde des données groupées

Exemple d'utilisation :

`python data_path "5min" out_path`

