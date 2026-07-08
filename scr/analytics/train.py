# %% 

import pandas as pd
import sqlalchemy
from sklearn import model_selection, tree, metrics, ensemble
from feature_engine import selection, imputation, encoding


con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")


# %% 

# Importing data

df = pd.read_sql("SELECT * FROM tb_faithful", con=con)


# %% 

# SAMPLE - OOT

df_oot = df[df['dtRef'] == df['dtRef'].max()].reset_index(drop=True)

# %% 

target = "fl_faithful"

features = df.columns.tolist()[3:]

df_train_test = df[df['dtRef'] != df['dtRef'].max()].reset_index()


X = df_train_test[features]  # this is a dataframe (matrix)
y = df_train_test[target]  # this is a series (vetor)


X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y
)

print(f"Base Training: {y_train.shape[0]} Unid. | Tx.Target {100*y_train.mean() :.2f}%")
print(f"Base Test: {y_test.shape[0]} Unid. | Tx.Target {100*y_test.mean() :.2f}%")

# %% 

# EXPLORE - missing

# %% 

cols_categorical = ['descLifeCycleAtual', 'descLifeCycleAtual_D28', 'qtd_days_last_activity']

num_features = list(set(features) - set(cols_categorical))

df_train = X_train.copy()

df_train[target] = y_train.copy()

df_train[num_features] = df_train[num_features].astype(float)

bivariada = df_train.groupby(target)[num_features].median().T

bivariada['ratio'] = (bivariada[1] + 0.001) / (bivariada[0] + 0.001)

bivariada.sort_values(by='ratio', ascending=False)


# %%

# MODIFY DROP

# removing features that are not useful

to_remove = bivariada[bivariada['ratio'] == 1].index.tolist()

drop_features = selection.DropFeatures(to_remove)

X_train_transform = drop_features.fit_transform(X_train)

# converting and defining features format

X_train_transform[cols_categorical] = X_train_transform[cols_categorical].astype(object)

# %% 

# redefining features, num_features and cat_features

num_features = list(set(X_train_transform.columns) - set(cols_categorical))

X_train_transform[num_features] = X_train_transform[num_features].astype(float)


# %%

fill_0 = ['SlugCourse', 
          'github2025', 
          'python2025', 
          'pct_completion', 
          'TotalOfCompletedCourses']

fill_thousand = ['dif_day',
                 'dif_day_D28',
                 'frequency', 
                 'avg_Group_frequency', 
                 'ratio_Freq_Group']


input_0 = imputation.ArbitraryNumberImputer(arbitrary_number=0, 
                                            variables=fill_0)

input_new = imputation.CategoricalImputer(fill_value='NotUser', 
                                          variables=cols_categorical)

input_thousand = imputation.ArbitraryNumberImputer(arbitrary_number=1000, 
                                                   variables=fill_thousand)


# %% MODIFY - ONEHOT

onehot = encoding.OneHotEncoder(variables=cols_categorical)

X_train_transform = input_new.fit_transform(X_train_transform)
X_train_transform = input_0.fit_transform(X_train_transform)
X_train_transform = input_thousand.fit_transform(X_train_transform)
X_train_transform = onehot.fit_transform(X_train_transform)

# %%
X_train_transform


# %% 

# MODEL

model = ensemble.AdaBoostClassifier(random_state=42,
                                    n_estimators=150,
                                    learning_rate=0.01)
model.fit(X_train_transform, y_train)

# %% ASSESS

y_pred_train = model.predict(X_train_transform)
y_proba_train = model.predict_proba(X_train_transform)

acc_train = metrics.accuracy_score(y_train, y_pred_train)
auc_train = metrics.roc_auc_score(y_train,y_proba_train[:,1])
print("Accuracy train:", acc_train)
print("AUC train:", auc_train)

# %% 

X_test_transform = drop_features.transform(X_test)
X_test_transform = input_new.transform(X_test_transform)
X_test_transform = input_0.transform(X_test_transform)
X_test_transform = input_thousand.transform(X_test_transform)
X_test_transform = onehot.transform(X_test_transform)


y_pred_test = model.predict(X_test_transform)
y_proba_test = model.predict_proba(X_test_transform)

acc_test = metrics.accuracy_score(y_test, y_pred_test)
auc_train = metrics.roc_auc_score(y_test,y_proba_test[:,1])

print("Accuracy test:", acc_test)
print("AUC test:", auc_train)

# %% 


y_predict = pd.Series([0]*y_test.shape[0])
y_proba = pd.Series([y_train.mean()]*y_test.shape[0])


acc = metrics.accuracy_score(y_test,y_predict)
auc = metrics.roc_auc_score(y_test,y_predict)

print("Accuracy test:", acc)
print("AUC test:", auc)


# %% 

features_names = X_train_transform.columns.tolist()

feature_importance = pd.Series(model.feature_importances_, index=features_names)
print(feature_importance)