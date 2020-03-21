'''
Author : Gauthier Gris
Date : 14 Jan 2020
'''

# Import des librairies
import pandas as pd
import sys

# Paramètres
data_path = sys.argv[1]  # Chemin vers les données nettoyées
step_group = sys.argv[2]  # Intervall de temps sur lequel regrouper les données en min
out_path = sys.argv[3]  # Dossier de sauvegarde des données groupées

# Chargement des données nettoyées dans un DataFrame
dataFrame = pd.read_csv(data_path)

dataFrame['date'] = dataFrame['date'].apply(lambda x : pd.Timestamp(x))
dataFrame['CBN'] = pd.Categorical(dataFrame['CBN'])

# Créer les one hot encodings pour chaque variabble
dfDummies_cbn = pd.get_dummies(dataFrame['CBN'], prefix = 'CBN')

# Concatener les one hot encodings avec les données
dataFrame = pd.concat([dataFrame, dfDummies_cbn], axis=1)

# Suppression de la variable CBBN
dataFrame.drop(columns=['CBN'], inplace=True)

# On ordonne les dataFrame par "date"
dataFrame.sort_values(by='date', inplace=True)

# Réindexage des lignes
dataFrame.reset_index(inplace=True)
dataFrame.drop(columns=['index'], inplace=True)


grouped_dataFrame = dataFrame.groupby(pd.Grouper(key="date", freq=step_group)).sum()
grouped_dataFrame.reset_index(inplace=True)

# Ajout variables
grouped_dataFrame['month'] = grouped_dataFrame['date'].apply(lambda x : x.month)
grouped_dataFrame['weekday'] = grouped_dataFrame['date'].apply(lambda x : x.weekday())
grouped_dataFrame['hour'] = grouped_dataFrame['date'].apply(lambda x : x.hour)


grouped_dataFrame['month'] = pd.Categorical(grouped_dataFrame['month'])
grouped_dataFrame['weekday'] = pd.Categorical(grouped_dataFrame['weekday'])
grouped_dataFrame['hour'] = pd.Categorical(grouped_dataFrame['hour'])

# Créer les one hot encodings pour chaque variabble
dfDummies_month = pd.get_dummies(grouped_dataFrame['month'], prefix = 'month')
dfDummies_weekday = pd.get_dummies(grouped_dataFrame['weekday'], prefix = 'weekday')
dfDummies_hour = pd.get_dummies(grouped_dataFrame['hour'], prefix = 'hour')

# Concatener les one hot encodings avec les données
grouped_dataFrame = pd.concat([grouped_dataFrame, dfDummies_weekday, dfDummies_month, dfDummies_hour], axis=1)

# Suppression de la variable mois et jour de la semaine
grouped_dataFrame.drop(columns=['month', 'weekday', 'hour'], inplace=True)

# Sauvegarde des données
grouped_dataFrame.to_csv(os.path.join(out_path, "data_processed_{}_257".format(step_group)), index=False)
