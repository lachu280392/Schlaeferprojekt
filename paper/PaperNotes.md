# Notes or ISiM Paper

## Introduction

* What do we want to do?
    * Surgery, measure force, small equipment
    * OCT (because it is used for cancer classification for example)
    * Force acting at the tip of needle important for operator
* Why can't we use just a force sensor?
    * Force sensor somewehere else would also measure lateral forces acting on device.
    * Force sensor too large for needle tip. 
* What sensors/data do we have?
    * OCT data 
* What is OCT? Why do we use it?
    * medical usage for imaging using backreflection of coherent light
    * 1-3mm deep into surface of scattering medium

## Data Acquisition

* We want to investigate different approaches to build a model for force estimation.
* What data do we have? (As explained in introduction, we want to use OCT data of needle. However 
we need some ground truth data (for supervised learning and optimazation)

### Measurement Set up

* Tissues (Gelatine)
    * simulate biological tissue
* Measurement 
    * Force sensor at end of needle as ground truth data for training
    * Set up (Picture)
        * Poke against metal plate (Measures force only acting
        * Poke into gelatine
    * Dimensions 
        * up to 0.35mm deformation of transparent material
        * force (??? Ask Gessert)
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
    * Real world: tissue will have different signal, not so prominent surface recognizion? More layer?
* What can be done in future work? 

## Paper we used

* http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7784718 (Towards Retrieving Force Feedback in Robotic Assisted Surgery)
* http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=7393571 (
* https://www.osapublishing.org/ol/abstract.cfm?uri=ol-25-20-1520 (Imaging needle for optical coherence tomography)

