# Project: Intelligent Systems in Medicine

*Status report for week 01*

Group3: Felix Wege, Yuria Konda, Lakshmanan Chockalingam

## Data

Oct and force data were measured in the week before holidays. In this week we preprocessed these data to start and end at the same time and to be synchronous.
Therefore the force data needed to be interpolated. In addition, some low-pass filtering is performed to deal with measurement noise.
Also the new data is split in several sets for cross validation. To test the generalization, the validation set consists of data from a different phantom than the training data.

## Linear Regression

First we tried to train a linear regression model with a very small set of data to test the functionality.
After this does to seem promising, we now will train the model with more different measurements of various phantoms.
The results of cross validation are pending.

## Tasks for the Next Week

On Wednesday we will take some measurements again, driving the oct against a hard beam to kind of calibrate the instrument.
Than we will be able to train a model with these data and test it on the gelatine phantom data.




 

