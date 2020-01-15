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

# Parameters
dir_path = sys.argv[1]  # Directory of row data files
out_path = sys.argv[2]  # Output path to save processed data

files = []

# Get the names of all the files
for file in os.listdir(dir_path):
    filename = os.fsdecode(file)
    if filename.endswith(".xlsx"):
        files.append(dir_path+filename)


# Instantiate the frame with one file and then remove that file from the list
print(files[0])
df = pd.read_excel(files[0])
files.remove(files[0])

# Add all the files left in DataFrame
for f in files:
    print(f)
    df = df.append(pd.read_excel(f))


# Drop unnecessary columns
col_drop = ['CAB', 'Date de sortie', 'Emetteur', 'Code Regate Emetteur', 'Destination', 'Code Regate Destinataire',
            'Produit', 'Traitement', 'Code traitement', 'Contenant', 'Injecteur', 'Sortie', 'Rejet', 'CAB fonctionnel']
df.drop(columns=col_drop, inplace=True)
df.to_csv("data_processed_2.csv", index=False)


df = pd.read_csv("data_processed_2.csv")

# Remove unnecessary CBN
cbn_to_remove = ['non trouvé', 'BRIN A', 'BRIN B', 'BRIN C', 'ligne vide', 'CAB nul']
for cbn in cbn_to_remove:
    df.drop(df[df['CBN'] == cbn].index, inplace=True)

# Rename first column to date
df.rename(columns={'Date de passage': 'date'}, inplace=True)


print("size df to save : {}".format(df.shape))
# Save data to output path
df.to_csv(out_path, index=False)

print("Execution time : {:.2} s".format(time.time() - start))
