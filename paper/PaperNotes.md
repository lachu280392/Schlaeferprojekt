# Notes or ISiM Paper

## Introduction

* What do we want to do?
* What sensors/data do we have?
* What is OCT? Why do we use it?
* Why can't we use just a force sensor?

## Data Acquisition

### Measurement Set up

* Tissues (Gelatine)
* Measurement 
    * Set up (Picture)
    * Dimensions 
* OCT data
    * B-Scan
    * In tissue
        * No real ground truth data
    * Against metal plate
    * Why?
        * Measure force at tip of needle
    * Consequences?
        * Different in real application 
* Force data
    * 3D, only z used
    * Smoothen
* Matlab

### Preprocessing

* Synchronization
    * start and end point
    * frequency
        * interpolation
* Size
    * reflection
    * computational advantage
    * necessary for feature extraction 
* Feature extraction
    * Brightness
    * Max
    * Nearby area
    * Lowest
    * Why did we choose them?
* Data allocation 
    * Why cross validation? (overfitting)
* Scatter plot

## Modelling

* What models did we choose?
* Why? / What do we expect them to see?

### Linear Regression

### CNN

### RNN 


## Evalutaion

* Which performance metric?
* Why did we coose it?
* What does it tell us?
    * MSE (emphasizes large errors over small ones)
    * MAE (robust to outliers)
    * http://scikit-learn.org/stable/modules/classes.html#sklearn-metrics-metrics
* compare models
    * Learnig error rates
    * Learning curves
        * Size of training set increases -> testing error? 
        * See Thomas' report notes.
    * Testing error rates
        * See Thomas' report notes.
    * Model complexity graph
        * Thomas

## Conclusion

* Do we overfit/underfit?
* Show performances of models and grade.
* Make predictions on a dedicated test set.
    * Asked Gessert if we can get the force data of his last test set
* What is our final result with regard to different data in training and real world application?
* What can be done in future work? 
