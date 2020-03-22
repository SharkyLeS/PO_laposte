# Prophet

Ce dossier comprant le travail réalisé pour résoudre le problème avec la méthode Prophet (modèle de prédiction développé par Facebook). Le code est écrit en R ([install RStudio](https://rstudio.com/products/rstudio/download/)).

## 

## Installation des packages

Les scripts requièrent les packages suivants:

- prophet

- gdata

- Metrics

- matrixStats

- ggplot2

- dplyr

  

  Installation via la commande dans la console R :

  ```
  install.packages("nom du package")
  ```

## 

## Script *Prophet.R*



### Parameters

Les paramètres sont définis au début du script *prophet.R*. A définir sont :

- L'interval de temps dans lequel on compte le nombre de bacs d'un CBN donné (en heure): ligne 17
- Le nombre de période qu'on veut prédire en sortie (en jours) : ligne 20
- Le nombre de mois donné en entrée : ligne 23
- Le nombre de top cbns qu'on veut récupérer : ligne 146

Exemple d'utilisation :

```
## Defining interval between two predictions (in hours, ex: 0.25 = 15min)
interval <- 0.25

## Number of periods to be predicted onwards (in days)
nb_periods <- 7

## Number of months given as input data
nb_mois_donnees <- 10

top_size <- 30
```



### Input



Le fichier d'entrée doit être de type csv. On récupère seulement les dates de passage et le cbn correspondant à cette date. Les données brutes des fichiers fournis sont nettoyées :  suppression des CBN non utilisables. 

Inputs :

*data <- read.csv()* : dossier contenant les données brutes (fichiers excel de type csv)

(modification ligne 29)

Exemple d'utilisation :

```
data <- read.csv("C:/Travail A3/Projet d'option/data_cleaned.csv",sep=",", header=TRUE,dec=".")
```

### 

### Output

Ce script contient une fonction qui sauvegarde les prédictions réalisées par le modèle Prophet. Le modèle en lui-même est appliqué dans une boucle ligne 98 (on créé un modèle pour chaque CBN).

Le code est à modifier ligne 135 pour modifier le nom et le chemin du fichier csv sauvegardé représentant le nombre de bacs prédit pour chaque CBN dans un interval de temps donné.

Exemple d'utilisation :

```
write.csv(predictions, "C:/Travail A3/Projet d'option/Predictions_last_version/prediction_MARS.csv", row.names = TRUE)
```



Ce script imprime aussi les noms des *top_size* cbns prédient (ne pas oublier de définir *top_size* ligne 146).

## 

## Script *Result_Analysis.R*



### Input



Les fichiers d'entrée doit être de type csv. On récupère le fichier correspondant aux données réelles du mois en question, et le fichier correspondant aux prédictions faites précédemment grace au modèle Prophet.

Inputs :

*prediction <- read.csv()* : dossier contenant les données prédites (fichiers excel de type csv)

*real_data <- read.csv()* : dossier contenant les données réelles (fichiers excel de type csv)

(modification ligne 13 et 14)

Exemple d'utilisation :

```
prediction <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/prediction.csv",sep=",", header=TRUE,dec=".")

real_data <- read.csv("C:/Travail A3/Projet d'option/Predictions_last_version/real.csv",sep=",", header=TRUE,dec=".")

```

### 

### Parameters

Le seul paramètre a modifié est le *top_size* (ligne 27) qui correspond au nombre de top cbn qu'on veut extraire.

Exemple d'utilisation :

```
top_size <- 10 ## Extract top 10 cbns
```



### Output

Ce script nous renvoit les MSE, MAE et Accuracy obtenues ainsi que le nombre de top cbns correctement prédit.

Finalement, il renvoit aussi le nom des top cbns prédis et réels.