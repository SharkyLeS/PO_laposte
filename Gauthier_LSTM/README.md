# LSTM - Gauthier

Ce dossier comprant le travail réalisé pour résoudre le problème avec une méthode LSTM (réseau de neurones). Le code est écrit en python et une nécessite une version supérieur à 3.0 ([install python3](https://www.python.org/downloads/)).

## Installation des packages

TODO

pandas

matplotlib

seaborn

keras

Tensorflow



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

### Script *main.py* 

Ce script contient une classe appellée **Main** représentant le réseau de neurones et toutes les méthodes lui étant reliées : de la récupération des données pour créer le dataset jusqu'à l'affichage des résultats.

Le code est à modifier ligne 23 pour ajouter le dossier dans lequel les autres scripts sont contenus.

### Script *model_version.py* 

Ce script permet la construction du modèle via les différentes fonctions et des inputs via la méthode *inputs_generation*. Pour ajouter un nouveau modèle il suffit de créer une nouvelle fonction et d'ajouter cette fonction dans le switcher de la fonction *build_model* de la classe **Main**.

Le code est à modifier ligne 5 pour ajouter le dossier dans lequel les données sont contenus.



## Jupyter notebooks

### Notebook *data_grouping.ipynb*

Correspond au script *data_grouping.py*, ce notebook permet de visualiser la DataFrame au cours de l'éxécution du code.

### Notebbook *data_exploration*.ipybn

Résultats de l'exploration des données que nous avons effectuée.





