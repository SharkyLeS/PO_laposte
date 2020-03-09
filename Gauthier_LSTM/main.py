"""
Author : Gauthier Gris
Date : 3 February 2020
"""

import warnings
import sys
import os
import json
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import tensorflow as tf
import utils
from utils import *
from model_version import *

# Suppression des warnings
warnings.filterwarnings('ignore')
warnings.simplefilter('ignore')

# Ajout du dossier au path
path = None
sys.path.append(path)

# Data visualization
sns.set(style="darkgrid")
sns.set_context("notebook", font_scale=1.3)


class Main:
    def __init__(self, version, seed, step_group, d_train_time, d_prediction_time, shift_time, batch_size, nb_cbn=257,
                 train_proportion=0.8,
                 val_proportion=0.1):

        # Model
        self.model = None

        # Version et time specs
        self.specs = {'version': version,
                      'step_group': step_group,
                      'd_train_time': d_train_time,
                      'd_prediction_time': d_prediction_time,
                      'shift_time': shift_time,
                      'nb_cbn': nb_cbn,
                      }

        # Specs pour créer le  DataSet
        self.data_specs = {'batch_size': batch_size,
                           'train_proportion': train_proportion,
                           'val_proportion': val_proportion,
                           'seed': seed,
                           'd_train': None,
                           'd_prediction': None,
                           'shift': None,
                           'window_size': None
                           }

        # DataSet
        self.data = {'train': None,
                     'dates_train': None,
                     'val': None,
                     'dates_val': None,
                     'test': None,
                     'dates_test': None,
                     'steps_per_epoch': None,
                     'validation_step': None,
                     'cbn': None}

        # Construction du modèle
        self.build_model(version)

        # Paramètres du modèle
        self.compile_specs = {'loss': None,
                              'optimizer': None,
                              'metrics': None,
                              'lr': None}

        self.fit_specs = {'callbacks': []}

        # History
        self.history = None

    def build_model(self, version):
        """
        Build the deep neural network model giving a certain version
        Construction du réseau de neuronnes pour une certaine version donnée

        @param version: str
                Version du modèle

        @return: None
        """

        # Calcul des specs sur les données pour construire le DataSet
        (self.data_specs['d_train'], self.data_specs['d_prediction'],
         self.data_specs['shift'], self.data_specs['window_size']) = compute_param_lstm(self.specs['step_group'],
                                                                                        self.specs['d_train_time'],
                                                                                        self.specs['d_prediction_time'],
                                                                                        self.specs['shift_time'])
        switcher = {
            "v1": model_v1,
            "v2": model_v2,
            "v90min": model_v90min,
            "v15min": model_v15min,
        }
        if version not in switcher.keys():
            raise Exception("Cette version n'existe pas")
        model = switcher[version]
        model(self)

    def compile(self, loss='mse', optimizer='adam', lr=None, metrics=None, **kwargs):
        """
        Compile le modèle

        @param loss: tf.keras.losses
                Loss pour entrainer le modèle
        @param optimizer: tf.keras.optimizer
                Optimizer de la descente de gradient
        @param lr : float
                Hard coded learning rate
        @param metrics: tf.keras.metrics
                Metrics utilisées pour évaluer les performances du modèle
        @param kwargs: dict
                Arguments additionnels

        @return: None
        """
        if metrics is None:
            metrics = [tf.keras.metrics.Accuracy()]

        (self.compile_specs['loss'], self.compile_specs['optimizer'],
         self.compile_specs['metrics'], self.compile_specs['lr']) = loss, optimizer, metrics, lr
        self.model.compile(loss=loss, optimizer=optimizer, metrics=metrics, **kwargs)

    def fit(self, **kwargs):
        """
        Entrainement du modèle

        @param kwargs: dict
                Arguments additionnels

        @return: None
        """

        # Fit
        self.history = self.model.fit(self.data['train'],
                                      validation_data=self.data['val'], validation_steps=self.data['validation_steps'],
                                      **kwargs)

    def summary(self):
        """
        Racourcis pour accéder au summary

        @return: None
        """
        self.model.summary()

    def load_weights(self, path_w):
        """
        Racourcis pour charger des poids pré-entrainés

        @param path_w: chemin vers ces poids

        @return:None
        """
        self.model.load_weights(path_w)

    def plot_learning_curves(self, val=True):
        """
        Affichage des learning_curves

        @param val: bool
                True si un set de validation a été utilisé durant l'entrainelment. Faux sinon.

        @return: None
        """
        utils.plot_learning_curves(self.history, self.compile_specs['metrics'], val=val)
