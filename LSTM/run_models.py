from main import *
from utils import *
import tensorflow as tf

# Disable warnings
import warnings
warnings.filterwarnings('ignore')

specs = {'version': "v90min",
         'step_group': "5min",
         'd_train_time': "2h",
         'd_prediction_time': "90min",
         'shift_time': "10min",
         'batch_size': 64,
         'nb_cbn': 80,
         'seed': 2,
         }

my_network = Main(**specs)

compile_specs = {'loss': tf.keras.losses.mean_squared_error,
                 'optimizer': 'adam',
                 'metrics': [tf.keras.metrics.Accuracy()]
                 }


run = {'callbacks': [],
       'epochs': 30,
       'verbose': 1}

my_network.compile(**compile_specs)
my_network.fit(**run)