###################################################################
# 2018 ST540 Take Home Exam Code
# Author: James Lee
# ID: 200203022
# Abstract: The goal of this question is to estimate the NDVI
# in 6 pixels over the course of 365 days.
# Three datasets from different satellites is given (Y1.Y2.Y3)
# Y1 is gold standard, unbiased, 80% missing value
# Y2 is potentially biased, single pixel(pixel1), 10% missing value
# Y3 is potentially biased, entire spatial avg, 10% missing value
###################################################################

#load dataset
#change directory if needed

load("D:/E2.Rdata")

###data preprocessing

##adjust Y2 Y3 based on Y1 by subtract the difference in mean

#Y2 only have observation on pixel1, compare it with Y1[,1]
Y2_mean<-mean(Y2, na.rm=TRUE)
Y1p1_mean<-mean(Y1[,1], na.rm=TRUE)
bias_Y2<-Y2_mean-Y1p1_mean

#Y3 is the average of pixels, compare it with the whole Y1 dataset
Y3_mean<-mean(Y3, na.rm=TRUE)
Y1_mean<-mean(Y1, na.rm=TRUE)
bias_Y3<-Y3_mean-Y1_mean

#Create new datasets for Y2.Y3
Y2_revise<-Y2-bias_Y2
Y3_revise<-Y3-bias_Y3

#construct the full dataset Y_proc: average of {Y1.Y2.Y3}

Y_proc<-matrix(, nrow = 365, ncol = 6)

Y_proc[,1]<-rowMeans(cbind(Y1[,1],Y2_revise,Y3_revise),na.rm=TRUE)
Y_proc[,2]<-rowMeans(cbind(Y1[,2],Y3_revise),na.rm=TRUE)
Y_proc[,3]<-rowMeans(cbind(Y1[,3],Y3_revise),na.rm=TRUE)
Y_proc[,4]<-rowMeans(cbind(Y1[,4],Y3_revise),na.rm=TRUE)
Y_proc[,5]<-rowMeans(cbind(Y1[,5],Y3_revise),na.rm=TRUE)
Y_proc[,6]<-rowMeans(cbind(Y1[,6],Y3_revise),na.rm=TRUE)

#fill in grand mean to the rest of the NaNs
Y_proc[is.nan(Y_proc)]<-mean(Y_proc,na.rm = TRUE)

#store grand mean for further usage
Y_bar=mean(Y_proc,na.rm = TRUE)

#store W(sigma prior) for further usage
W<-0.01*diag(6)

###Bayesian modeling- 

##process layer
#theta(1,j) ~ Normal(mu1,sigma1)
#theta(t,j)|theta(t-1,j) ~ Normal(mu2+rho*theta(t-1),sigma2)

##prior layer
#mu1 ~ Normal(0,100)
#mu2 ~ Normal(0,100)
#sigma1 ~ InvWishart
#sigma2 ~ InvWishart
#rho ~ uniform(0,1)


#JAGs code
NDVI_model <- "model{

# Likelihood
for(j in 1:6){
Y[1,6]    ~ dmnorm(mu1[1:6],sigma1[1:6,1:6])
}
for(i in 2:365){for(j in 1:6){
Y[i,j]    ~ dmnorm(mu2[1:6]+rho[1:6]*Y[i-1,j],sigma2[1:6,1:6])
}}

# Priors
mu1[1] ~ dnorm(0,0.01)
mu1[2] ~ dnorm(0,0.01)
mu1[3] ~ dnorm(0,0.01)
mu1[4] ~ dnorm(0,0.01)
mu1[5] ~ dnorm(0,0.01)
mu1[6] ~ dnorm(0,0.01)
mu2[1] ~ dnorm(0,0.01)
mu2[2] ~ dnorm(0,0.01)
mu2[3] ~ dnorm(0,0.01)
mu2[4] ~ dnorm(0,0.01)
mu2[5] ~ dnorm(0,0.01)
mu2[6] ~ dnorm(0,0.01)
for(k in 1:6){
rho[k] ~ dunif(0,1)
}
sigma1[1:6,1:6] ~ dwish(R[,],100)
sigma2[1:6,1:6] ~ dwish(R[,],100)
R[1,1]<-0.01
R[1,2]<-0
R[1,3]<-0
R[1,4]<-0
R[1,5]<-0
R[1,6]<-0
R[2,1]<-0
R[2,2]<-0.01
R[2,3]<-0
R[2,4]<-0
R[2,5]<-0
R[2,6]<-0
R[3,1]<-0
R[3,2]<-0
R[3,3]<-0.01
R[3,4]<-0
R[3,5]<-0
R[3,6]<-0
R[4,1]<-0
R[4,2]<-0
R[4,3]<-0
R[4,4]<-0.01
R[4,5]<-0
R[4,6]<-0
R[5,1]<-0
R[5,2]<-0
R[5,3]<-0
R[5,4]<-0
R[5,5]<-0.01
R[5,6]<-0
R[6,1]<-0
R[6,2]<-0
R[6,3]<-0
R[6,4]<-0
R[6,5]<-0
R[6,6]<-0.01

# Output the parameters of interest

}"

#run rjags package
library(rjags)
dat    <- list(Y=Y_proc,pix=6,N=365)
init   <- list(mu1=Y_bar)
model1 <- jags.model(textConnection(NDVI_model),inits=init,data = dat, n.chains=1)

###convergence diagnostics



###final result

