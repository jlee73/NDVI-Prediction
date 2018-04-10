
###################################################################
# NDVI Project
# Author: James Lee (jlee73@ncsu.edu
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

#store grand mean.col.row for further usage
Y_bar=mean(Y_proc,na.rm = TRUE)
ns<-nrow(Y_proc)
nt<-ncol(Y_proc)

###Bayesian modeling- 2 way random effects model
##Yij~Normal(mu+alphai+gammaj,taue^2) 

#JAGs code
NDVI_model <- "model{

   # Likelihood
   for(i in 1:ns){for(j in 1:nt){
      Y[i,j]    ~ dnorm(mean[i,j],taue)
      mean[i,j] <- mu + alpha[i] + gamma[j]
   }}

   # Random effects
   for(i in 1:ns){
    alpha[i] ~ dnorm(0,taus)
   }
   for(j in 1:nt){
    gamma[j] ~ dnorm(0,taut)
   }

   # Priors
   mu   ~ dnorm(0,0.01)
   taue ~ dgamma(0.1,0.1)
   taus ~ dgamma(0.1,0.1)
   taut ~ dgamma(0.1,0.1)

   # Output the parameters of interest
   sigma2[1] <- 1/taue
   sigma2[2] <- 1/taus
   sigma2[3] <- 1/taut
   sigma[1]  <- 1/sqrt(taue)
   sigma[2]  <- 1/sqrt(taus)
   sigma[3]  <- 1/sqrt(taut)
   pct[1]    <- sigma2[1]/sum(sigma2[])   
   pct[2]    <- sigma2[2]/sum(sigma2[])   
   pct[3]    <- sigma2[3]/sum(sigma2[])   

  }"
###run rjags package & convergence diagnostics
library(rjags)
   dat    <- list(Y=Y_proc,ns=ns,nt=nt)
   init   <- list(mu=Y_bar)
   model1 <- jags.model(textConnection(NDVI_model),inits=init,data = dat, n.chains=1)
   update(model1, 10000, progress.bar="none")

   samp   <- coda.samples(model1, 
             variable.names=c("sigma","pct","gamma"), 
             n.iter=20000, progress.bar="none")

   plot(samp)


