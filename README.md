# NDVI Prediction
The data for this analysis are simulated to represent satellite measurements of Normalized Difference
Vegetation Index (NDVI), which is a common measure of greenness used in many fields ranging
from ecology to agriculture. The goal of this project is to predict the value of NDVI was simulated for 6 pixels 
over the course of 365 days.

## Statistical Method
In this section I will separate the method into two procedures, data preprocessing and the Bayesian modeling.
Based on the description of the three datasets Y1, Y2, Y3, Y1 is unbiased but Y2 and Y3 are not. Therefore, I try to “eliminate” the bias by calculate the difference between the means. Note that Y2 only measure pixel 1, thus its mean is compared only with Y1[,1], the first column of Y1. I then construct a Y dataset by simply averaging from all unbiased Y1, Y2 and Y3. Lastly, I filled rest of the missing values (which is less than 3%) with grand mean to finish the data preprocessing part.

The Bayesian model I use is 2 way random effects model. Denote αi∼Normal(0,σ^2) is random effect between time, γj ∼ Normal(0,σ^2) is random effect between pixel, and σe^2 is the error variance. All unknown prior are denote as uninformative prior. (mu ~ N(0,100) and tau ~ Gamma(0.1,0.1))

The Code in this repository should allow anyone to reproduce the results.

## Improvements for further projects
By fitting coefficients, we can have predictions for all 365*6 entries. It is interesting to see how data preprocessing will affect final results. Y_proc, the dataset after data preprocessing is actually very familiar to the final results already. And NaNs fill with grand mean does somewhat affect certain unfortunate columns where there isn’t any observations on all three satellites. One improvement may be done is take average around the missing value to fill in. 
Another important point that needs to be mentioned is the model I was using are not how it was generated. The data was generated with lag-1 time dependence, where pixel in time t is related to time t-1. Where I used 2-way random effects did wasted that precious information.

## Author
James Lee - jlee73@ncsu.edu
