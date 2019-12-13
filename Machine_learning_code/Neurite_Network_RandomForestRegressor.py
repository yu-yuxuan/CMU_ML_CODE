# -*- coding: utf-8 -*-
"""
Created on Sat Nov 30 20:30:46 2019

@author: KuanrenQian
"""

import numpy as np

print('****************************************\n')
print('Reading data ...\n')
data = np.genfromtxt('./Neurite_Network_Simulation.csv', delimiter=',')

x = data[:,0:37].copy()
y = data[:,37:74].copy()
c = data[:,74:111].copy()
t = data[:,111].reshape(-1,1)
d = data[:,112].reshape(-1,1)
k = data[:,113].reshape(-1,1)
    
print('****************************************\n')
print('Normalizing data ...\n')
# Data Normalization
x = np.delete(x,0,1)
y = np.delete(y,0,1)
c = np.delete(c,0,1)
x = np.delete(x,3,1)
y = np.delete(y,3,1)
c = np.delete(c,3,1)
x_norm = x.copy()
y_norm = y.copy()
c_norm = c.copy()
c_norm_ratio = np.zeros((1,x_norm.shape[1]))

for j in range(x_norm.shape[1]):
    x_col_max = np.max(x_norm[:,j])
    x_col_min = np.min(x_norm[:,j])
    y_col_max = np.max(y_norm[:,j])
    y_col_min = np.min(y_norm[:,j])
    c_col_max = np.max(c_norm[:,j])
    c_col_min = np.min(c_norm[:,j])

    for i in range(x_norm.shape[0]):
        x_norm[i,j] = (x_norm[i,j] - x_col_min)/(x_col_max - x_col_min)
        y_norm[i,j] = (y_norm[i,j] - y_col_min)/(y_col_max - y_col_min)
        c_norm[i,j] = (c_norm[i,j] - c_col_min)/(c_col_max - c_col_min)

    c_norm_ratio[0,j] = (c_col_max-c_col_min)/(max(c_norm[:,j])-min(c_norm[:,j]))
    
t_normalize_ratio = max(t).copy()
t = t/t_normalize_ratio

X = np.hstack((x_norm,y_norm,t))
# Y is different for each regr

from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

print('****************************************\n')
print('Start trainning with random forest regressor ...\n')
print('This algorithm has 35 random forest regressor models ...\n')

a = []
MSE = np.zeros((c.shape[1],1))
impt = np.zeros((c.shape[1],X.shape[1]))
for i in range(c.shape[1]):
    
    rand_seed = i
    
    Y = c_norm[:,i]
    
    X_train, X_test, y_train, y_test = train_test_split(X,Y,test_size=0.3,
                                                        random_state=rand_seed)
           
    regr = RandomForestRegressor(max_depth=10, random_state=rand_seed,
                                 n_estimators=100)
    regr.fit(X_train, y_train)
    
    a.append(regr)
    
    # report importances and mse
    impt[i,:] = regr.feature_importances_
    y_pred = regr.predict(X_test)
    MSE[i,0] = mean_squared_error(y_test, y_pred)
    print('\nProgress:', int(i/c.shape[1]*100),'%, Model #',i, 
          'and current model MSE is:',round(MSE[i,0],8), end='\r')

print('\n****************************************\n')
print('Completed ! ----------------------------\n')

###############################################################################
# To use this model for prediction, only run the entire code once, and then 
# re-run the following code. The following code prompts user to enter geometry
# index, a int value between 0 to 67, and time variable, a positive variable.
# A plt scatter plot will be generated to show all the nodes and the color on 
# these nodes represent the predicted concentration

print('****************************************\n')
print('Prediction for user input  ----------------------------\n')
import matplotlib.pyplot as plt

print('Please enter geometry index (int val, 0~67) :\n')
# Only these two need to be changed at inputs
index_geometry = int(input())
print('Please enter time (positive val) :\n')
t = float(input())/t_normalize_ratio

x_plot = x[index_geometry*67,:].copy().reshape(-1,1).T
y_plot = y[index_geometry*67,:].copy().reshape(-1,1).T
c_plot = np.zeros((x_plot.shape[1],1)).T

xx = np.hstack((x_plot,y_plot))
xx = np.append(xx,t).reshape(-1,1).T

for i in range(len(a)):
    c_plot[0,i] = a[i].predict(xx)*c_norm_ratio[0,i]

cm = plt.cm.get_cmap('plasma')
fig0 = plt.figure(0)
plot = plt.scatter(x_plot,y_plot,c=c_plot,cmap=cm)
plt.colorbar(plot)
plt.xlabel('x position (mm)')
plt.ylabel('y position (mm)')
plt.title('Predicted Concentration Distribution at t = 8')
plt.show()

fig0.savefig('C_pred__geo_35_8.jpg')

