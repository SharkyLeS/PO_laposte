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
2. *step_grou* : intervall de temps sur lequel regrouper les données en min
3. *out_path* : dossier de sauvegarde des données groupées

Les données sont sauvegardées dans le dossier *out_path* sous le format csv, ce fichier est nommé data_processed_{step_group}_257.csv. Le 257 correspond aux nombres de CBN contenus dans ce fichier, il est possible de créer d'autres fichiers de manière ad hoc avec un nombre de CBN différent. Le fait de nommer les fichiers ainsi permet au script créant les réseaux de neronnes d'automaquement récupérer cette valeur.

Exemple d'utilisation :

`python data_path "5min" out_path`

## Jupyter notebooks

### Notebook *data_grouping.ipynb*

Correspond au script *data_grouping.py*, ce notebook permet de visualiser la DataFrame au cours de l'éxécution du code.

### Notebbook *data_exploration*.ipybn

Résultats de l'exploration des données que nous avons effectuée.





