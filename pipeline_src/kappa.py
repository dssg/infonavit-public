#http://stats.stackexchange.com/questions/82162/kappa-statistic-in-plain-english

import numpy as np

#cm1 = np.array([[10.0,7.0],[5.0,8.0]])
#print kappa(cm1)

#cm2 = np.array([[22.0,9.0],[7.0,13.0]])
#print kappa(cm2)

def kappa(cm):
    #This script assumes rows as predictions
    #and columns as ground truth, scikit-learn
    #does the opposite, first transpose the
    #confusion matrix
    cm = cm.transpose()
    #Cast confusion matrix as float
    cm = cm.astype('float')
    t = sum(sum(cm))
    observed_acc = (cm[0,0]+cm[1,1])/t
    a = (cm[0,0]+cm[1,0])*(cm[0,0]+cm[0,1])/t
    b = (cm[0,1]+cm[1,1])*(cm[1,0]+cm[1,1])/t
    expected_acc = (a+b)/t
    kappa_val = (observed_acc - expected_acc)/(1 - expected_acc)
    kappa_val = round(kappa_val,3)
    return (kappa_val, label_for_kappa(kappa_val))

#0-0.20 as slight
#0.21-0.40 as fair
#0.41-0.60 as moderate
#0.61-0.80 as substantial
#0.81-1 as almost perfect. 
def label_for_kappa(kappa_val):
    if 0 < kappa_val <= 0.20:
        return 'slight'
    elif 0.20 < kappa_val <= 0.40:
        return 'fair'
    elif 0.40 < kappa_val <= 0.60:
        return 'moderate'
    elif 0.60 < kappa_val <= 0.80:
        return 'substantial'
    elif 0.80 < kappa_val <= 1:
        return 'almost perfect'
    else:
        return 'invalid kappa value'