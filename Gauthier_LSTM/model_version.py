from main import *
from utils import *

# Dossier contenant les données (fichier data_processed_CBN.csv)
data_path = None


def model_v1(main):
    """
    Modèle version 1 : LSTM avec toutes les inputs en même temps + Dense layer

    @return: None
    """
    print("Model : v1")
    # Création du modèle
    model = tf.keras.models.Sequential([
        tf.keras.layers.LSTM(200, activation='relu'),
        tf.keras.layers.Dense(main.specs['nb_cbn'])
    ])
    main.model = model

    # Création des inputs
    inputs_generation(main)


def model_v2(main):
    """
    Modèle version 2 : Deux LSTM avec seulement les CBN + Concaténation avec les entrée de temps (catégoriques) +
    Dense layers (et Dropout)

    @return: None
    """
    print("Model : v2")
    # LSTM Inputs (CBN)
    lstm_input = tf.keras.layers.Input(shape=(None, main.specs['nb_cbn']), dtype='float32', name='lstm_input')
    lstm = tf.keras.layers.LSTM(250, activation='relu', return_sequences=True)(lstm_input)
    lstm_out = tf.keras.layers.LSTM(150, activation='relu')(lstm)
    # lstm_out = tf.keras.layers.LSTM(40, activation='relu')(lstm_input)

    # Catégoriques inputs (days of week, months, hours)
    cat_input = tf.keras.layers.Input(shape=(43,), dtype='float32', name='cat_input')

    # Assemblage LSTM entrainé et catégoriques inputs
    x = tf.keras.layers.concatenate([lstm_out, cat_input])
    x = tf.keras.layers.Dense(250, activation='relu')(x)
    x = tf.keras.layers.Dense(200, activation='relu')(x)
    # x = tf.keras.layers.Dropout(0.2)(x)
    output = tf.keras.layers.Dense(main.specs['nb_cbn'], activation='relu')(x)

    # Création du modèle
    main.model = tf.keras.Model(inputs=[lstm_input, cat_input], outputs=[output])

    # Création des inputs
    inputs_generation(main)


def model_v90min(main):
    """
    Modèle prédiction pour 90min

    @return: None
    """
    print("Model : v90min")
    # LSTM Inputs (CBN)
    lstm_input = tf.keras.layers.Input(shape=(None, main.specs['nb_cbn']), dtype='float32', name='lstm_input')
    lstm = tf.keras.layers.LSTM(250, activation='relu', return_sequences=True)(lstm_input)
    lstm_out = tf.keras.layers.LSTM(100, activation='relu')(lstm)

    # Catégoriques inputs (days of week, months, hours)
    cat_input = tf.keras.layers.Input(shape=(43,), dtype='float32', name='cat_input')

    # Assemble trained LSTM and categorical inputs
    x = tf.keras.layers.concatenate([lstm_out, cat_input])
    x = tf.keras.layers.Dense(250, activation='relu')(x)
    x = tf.keras.layers.Dense(200, activation='relu')(x)
    # x = tf.keras.layers.Dropout(0.2)(x)
    output = tf.keras.layers.Dense(main.specs['nb_cbn'], activation='relu')(x)

    # Création du modème
    main.model = tf.keras.Model(inputs=[lstm_input, cat_input], outputs=[output])

    # Création des inputs
    inputs_generation(main)


def model_v15min(main):
    """
    Modèle prédiction pour 15min

    @return: None
    """
    print("Modèle : v15min")
    # LSTM Inputs (CBN)
    lstm_input = tf.keras.layers.Input(shape=(None, main.specs['nb_cbn']), dtype='float32', name='lstm_input')
    lstm_out = tf.keras.layers.LSTM(200, activation='relu')(lstm_input)

    # Categorical inputs (days of week, months, hours)
    cat_input = tf.keras.layers.Input(shape=(43,), dtype='float32', name='cat_input')

    # Assemble trained LSTM and categorical inputs
    x = tf.keras.layers.concatenate([lstm_out, cat_input])
    x = tf.keras.layers.Dense(350, activation='relu')(x)
    # x = tf.keras.layers.Dense(250, activation='relu')(x)
    # x = tf.keras.layers.Dropout(0.2)(x)
    output = tf.keras.layers.Dense(main.specs['nb_cbn_predict'], activation='relu')(x)

    # Création du modèle
    main.model = tf.keras.Model(inputs=[lstm_input, cat_input], outputs=[output])

    # Création des inputs
    inputs_generation(main)


def inputs_generation(main):
    '''
    Céation des inputs et mise à jour des attributs de l'objet main

    @return: None
    '''
    # DataFrame
    df_path = os.path.join(data_path, "data_processed_{}_{}".format(main.specs['step_group'], main.specs['nb_cbn']))
    dataframe = pd.read_csv(df_path)
    main.data['cbn'] = dataframe.columns[1:main.specs['nb_cbn'] + 1].values
    print("Utilisation du dataframe : {}".format(df_path))

    # Création des inputs
    main.data['train'], main.data['val'], main.data['test'], dates = windowed_dataset_v1(dataframe,
                                                                                         main.specs['nb_cbn'],
                                                                                         **main.data_specs)

    # Ajout du nombre d'étapes par epoch pour les set d'entrainement et de validation
    main.data['steps_per_epoch'], main.data['validation_steps'] = count_steps(main)
