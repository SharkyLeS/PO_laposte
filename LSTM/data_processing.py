'''
Author : Gauthier Gris
Date : 14 Jan 2020
'''

# Import libraries
import pandas as pd
import os
import sys
import time

start = time.time()

# Paramètres
dir_path = sys.argv[1]  # Dossier des données brutes
out_path = sys.argv[2]  # Chemin de sauvegarde des données nettoyées

files = []

# Récupérer le nom de tous les fichiers excel de données
for file in os.listdir(dir_path):
    filename = os.fsdecode(file)
    if filename.endswith(".xlsx"):
        files.append(dir_path+filename)


# Instantiation du DataFrame avec un fichier puis retrait du nom de ce fichier de la liste
print(files[0])
df = pd.read_excel(files[0])
files.remove(files[0])

# Ajout des fichiers restants dans le DataFrame
for f in files:
    print(f)
    df = df.append(pd.read_excel(f))


# Suppression des colonnes inutiles
col_drop = ['CAB', 'Date de sortie', 'Emetteur', 'Code Regate Emetteur', 'Destination', 'Code Regate Destinataire',
            'Produit', 'Traitement', 'Code traitement', 'Contenant', 'Injecteur', 'Sortie', 'Rejet', 'CAB fonctionnel']
df.drop(columns=col_drop, inplace=True)

# Suppression des CBN inutiles
cbn_to_remove = ['non trouvé', 'BRIN A', 'BRIN B', 'BRIN C', 'ligne vide', 'CAB nul']
for cbn in cbn_to_remove:
    df.drop(df[df['CBN'] == cbn].index, inplace=True)

# Renommage de la première colonne en "date"
df.rename(columns={'Date de passage': 'date'}, inplace=True)


# Sauvegarde des données nettoyées dans le chemin de sortie
df.to_csv(out_path, index=False)

print("Execution time : {:.2} s".format(time.time() - start))
