# %% 
import pandas as pd
import sqlalchemy
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn import cluster,preprocessing


engine = sqlalchemy.create_engine("sqlite:///../../data/loyalty-system/database.db")

# %% 

def import_query(path): 
    with open(path) as open_file:
        return open_file.read()
    
query = import_query("frequency_value.sql")


# %% 

df = pd.read_sql(query,engine)
df = df[df['SumOfPointsPos'] < 4000] # removing outlier due to a bug in the database

# %% 

plt.plot(df['frequency'], df['SumOfPointsPos'],'o')
plt.grid(True)
plt.xlabel("Frequencia")
plt.ylabel("valor")
plt.show()

# %% 

minmax=preprocessing.MinMaxScaler()

x = minmax.fit_transform(df[['frequency','SumOfPointsPos']])


df_X=pd.DataFrame(x, columns=['normFreq','normValue'])

df_X

# %% 
kmean = cluster.KMeans(n_clusters=5,
                       random_state = 42, 
                       max_iter=1000)
kmean.fit(x)

df['cluster_calc'] = kmean.labels_

df_X['cluster'] = kmean.labels_


df.groupby(by='cluster_calc')['idCliente'].count()


# %% 

sns.scatterplot(
    data=df,
    x='frequency',
    y='SumOfPointsPos',
    hue='cluster_calc',
    palette='deep'

)

plt.hlines(y=1500,xmin=0,xmax=25,colors='black')
plt.hlines(y=750,xmin=0,xmax=25,colors='black')
plt.vlines(x=4,ymin=0,ymax=750,colors='black')
plt.vlines(x=10,ymin=0,ymax=3000,colors='black')



plt.grid()

# %% 


# %% 

sns.scatterplot(
    data=df,
    x='frequency',
    y='SumOfPointsPos',
    hue='Cluster',
    palette='deep'

)

plt.hlines(y=1500,xmin=0,xmax=25,colors='black')
plt.hlines(y=750,xmin=0,xmax=25,colors='black')
plt.vlines(x=4,ymin=0,ymax=750,colors='black')
plt.vlines(x=10,ymin=0,ymax=3000,colors='black')



plt.grid()