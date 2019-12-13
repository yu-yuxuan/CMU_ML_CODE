# -*- coding: utf-8 -*-
"""
Created on Sat Nov 30 20:30:46 2019

@author: KuanrenQian
"""

import numpy as np

data = np.genfromtxt('./Neurite_Network_Simulation.csv', delimiter=',')

data_size = data.shape[0]
x = data[:,0:37].copy()
y = data[:,37:74].copy()
c = data[:,74:111].copy()
t = data[:,111].reshape(-1,1)
d = data[:,112].reshape(-1,1)
k = data[:,113].reshape(-1,1)
 
x = np.delete(x,4,1)
y = np.delete(y,4,1)
c = np.delete(c,4,1)   

x_r = np.zeros((6,6,x.shape[0]))
y_r = np.zeros((6,6,y.shape[0]))
c_r = np.zeros((6,6,c.shape[0]))
t_r = np.zeros((6,6,x.shape[0]))
d_r = np.zeros((6,6,y.shape[0]))
k_r = np.zeros((6,6,c.shape[0]))

for i in range(x.shape[0]): 
    x_r[:,:,i] = x[i,:].reshape(6,6)
    y_r[:,:,i] = y[i,:].reshape(6,6)
    c_r[:,:,i] = c[i,:].reshape(6,6)
    for j in range(6):
        for l in range(6):
            t_r[j,l,i] = t[i,0]
            d_r[j,l,i] = d[i,0]
            k_r[j,l,i] = k[i,0]
            
c_z = np.zeros((6,6))

print('************************************')    
print('Finished Data Generation.')

import torch
import torch.nn as nn

device = torch.device('cpu')
if torch.cuda.is_available():
    device = torch.device('cuda')

model = nn.Sequential(
        nn.Conv2d(3,2,3,stride=1,padding=1),
        nn.ReLU(),
        nn.Conv2d(2,1,3,stride=1,padding=1),
        nn.ReLU()
        ).to(device)

print(model)

epoch = 200
learning_rate = 5e-05

print('************************************\n')    
print('Train & Test ratio (0~1) :\n')
split_ratio = float(input())
train_size = int(data_size*split_ratio)

x_Train = np.zeros((1,3,6,6,data_size))
y_Train = np.zeros((1,6,6,data_size))

for n in range(data_size):
    x_Train[:,0,:,:,n] = x_r[:,:,n]
    x_Train[:,1,:,:,n] = y_r[:,:,n]
    x_Train[:,2,:,:,n] = t_r[:,:,n]
    
    y_Train[:,:,:,n] = c_r[:,:,n]

x_Train = torch.from_numpy(x_Train).float().to(device)
y_Train = torch.from_numpy(y_Train).float().to(device)

# Loss and optimizer
criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

print('************************************')    

for k in range(epoch):
    LOSS = 0
    for n in range(train_size):
         
        optimizer.zero_grad()
        
        output = model(x_Train[:,:,:,:,n])
        
        loss = criterion(output, y_Train[:,:,:,n])
        
        model.zero_grad()
        
        loss.backward()
        optimizer.step()
          
        LOSS += loss.item()
    
    LOSS = LOSS/train_size
    print(k,round(LOSS,6),device)


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
t = float(input())

x_plot = x_Train[:,0,:,:,index_geometry*67].numpy().copy()
y_plot = x_Train[:,1,:,:,index_geometry*67].numpy().copy()
t_plot = np.zeros((x_plot.shape[1],x_plot.shape[1]))
c_plot = np.zeros((x_plot.shape[1],x_plot.shape[1]))

xx = np.zeros((1,3,6,6))
xx[:,0,:,:] = x_plot
xx[:,1,:,:] = y_plot
xx[:,2,:,:] = t_plot
xx = torch.from_numpy(xx).float()

c_plot = model(xx)
c_plot = c_plot.detach().numpy().reshape(-1,1).copy().T

x_plot = x_plot.reshape(-1,1).T
y_plot = y_plot.reshape(-1,1).T

cm = plt.cm.get_cmap('plasma')
fig0 = plt.figure(0)
plot = plt.scatter(x_plot,y_plot,c=c_plot,cmap=cm)
plt.colorbar(plot)
plt.xlabel('x position (mm)')
plt.ylabel('y position (mm)')
plt.title('Predicted Concentration Distribution at t = ？')
plt.show()
