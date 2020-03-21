"""
Author : Gauthier Gris
Date : 3 February 2020
"""

import numpy as np
import pandas as pd
import sys
import tensorflow as tf
import matplotlib.pyplot as plt
import seaborn as sns

# Data visualization
sns.set(style="darkgrid")
sns.set_context("notebook", font_scale=1.3)

# Ajout du dossier au path
path = None
sys.path.append(path)


def compute_param_lstm(step_group, d_train_time, d_pred_time, shift_time):
    """
    Calcul des paramètres pour le LSTM

    @param step_group: str
            Time pour grouper les données
    @param d_train_time: str
            Time interval pour entrainer le modèle
    @param d_pred_time: str
            Time interval pour faire la prédiction
    @param shift_time: str
            Time shift pour créer la prochaine input

    @return: int, int, int, int
            Les nombrbes d'index correspondant aux paramètres de temps dans le DataSet
    """
    d_train = pd.Timedelta(d_train_time).seconds // pd.Timedelta(step_group).seconds
    d_prediction = pd.Timedelta(d_pred_time).seconds // pd.Timedelta(step_group).seconds

    shift = pd.Timedelta(shift_time).seconds // pd.Timedelta(step_group).seconds
    window_size = d_train + d_prediction

    return d_train, d_prediction, shift, window_size


def windowed_dataset_v1(dataframe, nb_cbn, seed, window_size, shift, batch_size, d_train, train_proportion,
                        val_proportion, **kwargs):
    """
    Create a windowed DataSet avec toutes les features en même temps

   @param seed: int
            Seed pour la fonction shuffle
    @param nb_cbn: int
            Nombre de CBN
    @param dataframe: pd.DataFrame
            DataFrame contenant toutes les données
    @param window_size: int
            Taille d'une fenêtre entière pour créer une input
    @param shift: int
            Nombre d'index à sauter pour créer la prochaine inpute
    @param batch_size: int
            Batch size pour grouper les inputs
    @param d_train: int
            Nombre d'index à regrouper pour créer une input
    @param train_proportion: float
            Proportion de training examples dans dataset
    @param val_proportion: float
            Proportion de validation examples dans le dataset

    return: tf.DataSet
            Training, validation and testing dataset  prêt à etre passer dans le modèle. Retourne aussi
            les dates correspondantes.
    """
    # Transforme la date en seconde pour pouvoir la passer dans les tensors
    dataframe['date'] = dataframe['date'].apply(lambda x: pd.Timestamp(x).timestamp())

    # Création du dataset
    dataset = tf.data.Dataset.from_tensor_slices(dataframe.values)
    dataset = dataset.window(window_size, shift=shift, drop_remainder=True)
    dataset = dataset.flat_map(lambda window: window.batch(window_size))

    dataset = dataset.map(lambda window: (window[d_train, 0],  # dates
                                          window[:d_train, 1:],  # X
                                          tf.reduce_sum(window[d_train:, 1:1+nb_cbn], 0)))  # y

    dataset = dataset.shuffle(buffer_size=100, seed=seed)
    dataset = dataset.batch(batch_size, drop_remainder=True).prefetch(1)

    # Suppression des dates du DataSet
    dates = dataset.map(lambda date, x, y: date)
    dataset = dataset.map(lambda date, x, y: (x, y))

    # Split en train, val, test
    DATASET_SIZE = (dataframe.shape[0] - window_size) // shift // batch_size
    dataset_train, dataset_val, dataset_test = split_data_set(dataset, DATASET_SIZE, train_proportion, val_proportion)
    dates_train, dates_val, dates_test = split_data_set(dates, DATASET_SIZE, train_proportion, val_proportion)

    return dataset_train, dataset_val, dataset_test, dates_train, dates_val, dates_test


def windowed_dataset_v2(dataframe, nb_cbn, seed, window_size, shift, batch_size, d_train, train_proportion,
                        val_proportion, **kwargs):
    """
    Crée un windowed DataSet avec deux groupes de features :
                    - CBN
                    - Catégoriques inputs (date...)

    @param seed: int
            Seed pour la fonction shuffle
    @param nb_cbn: int
            Nombre de CBN
    @param dataframe: pd.DataFrame
            DataFrame contenant toutes les données
    @param window_size: int
            Taille d'une fenêtre entière pour créer une input
    @param shift: int
            Nombre d'index à sauter pour créer la prochaine inpute
    @param batch_size: int
            Batch size pour grouper les inputs
    @param d_train: int
            Nombre d'index à regrouper pour créer une input
    @param train_proportion: float
            Proportion de training examples dans dataset
    @param val_proportion: float
            Proportion de validation examples dans le dataset

    return: tf.DataSet
            Training, validation and testing dataset  prêt à etre passer dans le modèle. Retourne aussi
            les dates correspondantes.
    """
    # Transforme la date en seconde pour pouvoir la passer dans les tensors
    dataframe['date'] = dataframe['date'].apply(lambda x: pd.Timestamp(x).timestamp())

    # Create dataset
    dataset = tf.data.Dataset.from_tensor_slices(dataframe.values)
    dataset = dataset.window(window_size, shift=shift, drop_remainder=True)
    dataset = dataset.flat_map(lambda window: window.batch(window_size))

    dataset = dataset.map(lambda window: (window[d_train, 0],  # dates
                                          window[:d_train, 1:1 + nb_cbn],  # X_1 i.e. CBN
                                          window[d_train, 1 + nb_cbn:],  # X_2 i.e. categorical data
                                          tf.reduce_sum(window[d_train:, 1:1 + nb_cbn], 0)))  # y

    dataset = dataset.shuffle(buffer_size=100, seed=seed)
    dataset = dataset.batch(batch_size, drop_remainder=True).prefetch(1)

    # Suppression des dates du DataSet
    dates = dataset.map(lambda date, x_1, x_2, y: date)
    dataset = dataset.map(lambda date, x_1, x_2, y: ((x_1, x_2), y))

    # Split en train, val, test
    DATASET_SIZE = (dataframe.shape[0] - window_size) // shift // batch_size
    dataset_train, dataset_val, dataset_test = split_data_set(dataset, DATASET_SIZE, train_proportion, val_proportion)
    dates_train, dates_val, dates_test = split_data_set(dates, DATASET_SIZE, train_proportion, val_proportion)

    return dataset_train, dataset_val, dataset_test, dates_train, dates_val, dates_test


def split_data_set(dataset, DATASET_SIZE, train_prop, val_prop):
    """
    Split Dataset en train, val and test set

    @param dataset: tf.DataSet
            Contient toutes les données
    @param DATASET_SIZE: int
            Taille du DataSet
    @param train_prop: float
            Proportion de training examples dans le dataset
    @param val_prop: float
            Proportion de validation examples dans le dataset

    @return: tf.DataSet
            Split DataSet entre train, val et test set
    """
    train_size = int(train_prop * DATASET_SIZE)
    val_size = int(val_prop * DATASET_SIZE)

    dataset_train = dataset.take(train_size)
    dataset_test = dataset.skip(train_size)
    dataset_val = dataset.take(val_size)
    dataset_test = dataset_test.skip(val_size)

    return dataset_train, dataset_val, dataset_test


def plot_learning_curves(history, metrics, val=True):
    """
    Affichage des learning curves pour les metrics utilisées

    @param history: tf.Model.history
            Contient les données d'entrainement
    @param metrics: str[]
            Contient les metrics utilisées pendant l'entrainement
    @param val: bool
            True si un set de validation a été utilisé durant l'entrainelment. Faux sinon.

    @return: None
    """
    metrics.append("loss")
    res = {}
    for metric in metrics:
        res.update({metric: history.history[metric]})
        if val:
            res.update({"val_{}".format(metric): history.history["val_{}".format(metric)]})
    res.update({'epochs': range(len(history.history['loss']))})
    res_df = pd.DataFrame(res)

    nb_metrics = len(metrics)

    # Plot Learning curves
    f, axes = plt.subplots(1, nb_metrics, figsize=(15, 6))

    for i in range(nb_metrics):
        metric = metrics[i]
        axes[i].set_title(metric)
        sns.lineplot(x='epochs', y=metric, data=res_df, label='Training', ax=axes[i])
        sns.lineplot(x='epochs', y="val_{}".format(metric), data=res_df, label='Validation', ax=axes[i])

    plt.show()


def count_steps(main):
    """
    Compte le nombre d'étapes à faire dans le training et validation set

    @param main: Main

    @return: int, int
    """
    count_train = 0
    for x, y in main.data['train']:
        count_train += 1

    count_val = 0
    for x, y in main.data['val']:
        count_val += 1

    return count_train, count_val


def save_info(main, name, save_path):
    """
           Sauvegarde des informations
           @param main : Main
           @param name : str
                    Nom de l'entrainement (ex: "essai_8")
           @param save_path : str
                    Sauvegarde les données à ce chemin


            @return: None
            """

    info = ("Name    : {}\n"
            "\n"
            "step_group      : {}\n"
            "d_train_time    : {}\n"
            "d_pred_time     : {}\n"
            "shift_time      : {}\n"
            "seed            : {}\n"
            "nb_cbn          : {}\n"
            "nb_cbn_predict  : {}\n"
            "\n"
            "batch_size      : {}\n"
            "loss            : {}\n"
            "optimizer       : {}\n"
            "learning_rate   : {}\n"
            "summary         : {}".format(name, main.specs['step_group'], main.specs['d_train_time'],
                                          main.specs['d_prediction_time'],
                                          main.specs['shift_time'], main.data_specs['seed'],
                                          main.specs['nb_cbn'], main.specs['nb_cbn_predict'],
                                          main.data_specs['batch_size'],
                                          main.compile_specs['loss'],
                                          main.compile_specs['optimizer'], main.compile_specs['lr'],
                                          get_summary(main)
                                          ))

    # Save info
    file = open(save_path, "w")
    file.write(info)
    file.close()


def get_summary(main):
    """
    Get summary du modèle

    @param main: Main
            Instance
    @return: str
            Model summary sous la forme de string
    """
    dummy = []
    summary = ""
    main.model.summary(print_fn=lambda x: dummy.append(x))
    for row in dummy:
        summary += row + "\n"
    return summary


def evaluate_top_k(my_network, dataset, k):
    # Prediction
    y_pred = my_network.model.predict(my_network.data[dataset])

    # True values
    y_true = []
    for X, y in my_network.data[dataset].as_numpy_iterator():
        y_true.extend(y)
    y_true = np.array(y_true)

    idx_true = np.argpartition(y_true, -k)[:, -k:]
    idx_pred = np.argpartition(y_pred, -k)[:, -k:]
    total_top = 0
    nb_top = 0

    arr = []

    for i in range(y_true.shape[0]):
        total_top += len(idx_true[i])
        nb_top += len(np.intersect1d(idx_pred[i], idx_true[i]))
        arr.append(len(np.intersect1d(idx_pred[i], idx_true[i])))

    return y_true, y_pred, nb_top / total_top * 100
