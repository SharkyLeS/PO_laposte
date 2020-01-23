'''
Author : Gauthier Gris
Date : 14 Jan 2020
'''

# Import libraries
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
import sys
import os
import time

np.random.seed(0)
start = time.time()

# Parameters
data_path = sys.argv[1]  # Path to data csv file
step_group = sys.argv[2]  # Step to group data in rows
delta_train = sys.argv[3]  # Timedelta used for each training input
delta_prediction = sys.argv[4]  # Timedelta for prediction after a given date
window_slide = sys.argv[5]  # Window slide for each new input

print("Loading data")
# Load data
data = pd.read_csv(data_path)

# Use Timestamp format for dates
data['date'] = data['date'].apply(lambda x: pd.Timestamp(x))

# One hot encoding for CBN variable
data['CBN'] = pd.Categorical(data['CBN'])
dfDummies_cbn = pd.get_dummies(data['CBN'], prefix='CBN')
data = pd.concat([data, dfDummies_cbn], axis=1)
data.drop(columns=['CBN'], inplace=True)

# Sort values by date and reindex rows
data.sort_values(by='date', inplace=True)
data.reset_index(inplace=True)
data.drop(columns=['index'], inplace=True)

print("Grouping rows")
# Group rows by step_group and add index column
grouped_data = data.groupby(pd.Grouper(key="date", freq=step_group)).sum()
grouped_data.reset_index(inplace=True)

# Add months and weekdays variables
grouped_data['month'] = grouped_data['date'].apply(lambda x: x.month)
grouped_data['weekday'] = grouped_data['date'].apply(lambda x: x.weekday())

# One hot encoding for these two variables
grouped_data['month'], grouped_data['weekday'] = pd.Categorical(grouped_data['month']), \
                                                 pd.Categorical(grouped_data['weekday'])
dfDummies_month, dfDummies_weekday = pd.get_dummies(grouped_data['month'], prefix='month'), \
                                     pd.get_dummies(grouped_data['weekday'], prefix='weekday')
grouped_data = pd.concat([grouped_data, dfDummies_weekday, dfDummies_month], axis=1)
grouped_data.drop(columns=['month', 'weekday'], inplace=True)

# Delta indexes to select rows
index_delta_train = pd.Timedelta(delta_train).seconds // pd.Timedelta(step_group).seconds
index_delta_prediction = pd.Timedelta(delta_prediction).seconds // pd.Timedelta(step_group).seconds
index_window_slide = pd.Timedelta(window_slide).seconds // pd.Timedelta(step_group).seconds

# Create empty list
X, y, date = list(), list(), list()

print("Creating inputs")
# Add data to these variables and used numpy array format
index = 0

while (index + index_delta_train < grouped_data.shape[0]) and (index + index_delta_prediction < grouped_data.shape[0]):
    index_end = index + index_delta_train
    date.append(grouped_data.loc[index].date)
    X.append(list(grouped_data.iloc[index:index_end].values))
    y.append(list(grouped_data.iloc[index_end:index_end + index_delta_prediction, 1:-(7 + 12)].sum().values))
    index += index_window_slide
X, y, date = np.array(X), np.array(y), np.array(date)

# Split train (80%), dev (10%) and  test (10%) set
X_trainval, X_test, y_trainval, y_test = train_test_split(X, y, test_size=0.1, random_state=1)

# Test set
date_test = X_test[:, :, 0].flatten()
X_test = np.delete(X_test, 0, axis=2)

# Train and dev set
X_train, X_val, y_train, y_val = train_test_split(X_trainval, y_trainval, test_size=0.1, random_state=1)

# Train set
date_train = X_train[:, :, 0].flatten()
X_train = np.delete(X_train, 0, axis=2)

# Dev set
date_val = X_val[:, :, 0].flatten()
X_val = np.delete(X_val, 0, axis=2)

print("Saving inputs")
# Save data in files "inputs/"
out_dir_path = "inputs/group{}_dtrain{}_dpred{}_window{}".format(step_group, delta_train, delta_prediction,
                                                                 window_slide)
if not os.path.isdir(out_dir_path):  # create directory if it doesn't exist
    os.mkdir(out_dir_path)
np.save(out_dir_path + "/X_train", X_train)
np.save(out_dir_path + "/y_train", y_train)
np.save(out_dir_path + "/date_train", date_train)
np.save(out_dir_path + "/X_test", X_test)
np.save(out_dir_path + "/y_test", y_test)
np.save(out_dir_path + "/date_test", date_test)
np.save(out_dir_path + "/X_val", X_val)
np.save(out_dir_path + "/y_val", y_val)
np.save(out_dir_path + "/date_val", date_val)

print("Execution time : {:.2f} s".format(time.time() - start))
