#library(ggformula)
library(mgcv)
source("dateFormatRoutines.r")

# t, time points for which to infer the derivative
# gamToDerive, the spline/gam for which the derivatives are inferred
#gamDerivative <- function(tt.df, gamToDerive, outputpath) {
computeSplineDerivativeTable <- function(t, gamToDerive) {
  tt.df = data.frame(t=t)

  ## finite difference interval, delta t
  eps <- 1e-7

  #When type="lpmatrix" then a matrix is returned which yields the values of the linear predictor (minus any offset)
  #when postmultiplied by the parameter vector (in this case se.fit is ignored). The latter option is most useful for
  #getting variance estimates for quantities derived from the model: for example integrated quantities, or derivatives of smooths.
  X0 <- predict(gamToDerive, tt.df, type = 'lpmatrix')

  # super mall interval for derivation
  tt_eps.df <- tt.df + eps

  X1 <- predict(gamToDerive, tt_eps.df, type = 'lpmatrix')

  # finite difference approximation of first derivative
  # the design matrix
  Xp <- (X1 - X0) / eps

  # first derivative
  d1_gam <- Xp %*% coef(gamToDerive)

  d1_gam.table <- data.frame(t=t, value=d1_gam)

  return(d1_gam.table)
}

computeSpline <- function(input.table) {
    #input table must include a column with meanBinDate, value and variance
  # add day of year if not present yet
  #input.table <- addDayOfYearToTable(input.table)

  #number of data points
  N<-nrow(input.table)


  #weight: choose 1/variance, maybe better standard deviation?
  weights <- 1/input.table$variance
  #normalize splines by sum of weights
  weights = weights/sum(weights)

  #compute splines
  #s=smooth function
  gam_mod_cs <- gam(value ~ s(t,bs="cs"),
                    weights = weights,
                    data=input.table, method="REML")

  #return spline model
  return(gam_mod_cs)
}

computeSplineTable <- function(input.table) {
  pseudoNumber=10^-10
  #log transform, to avoid negative values
  input.table$value <- log(input.table$value + pseudoNumber)
  gam_mod_cs <- computeSpline(input.table)
  # vector for which the outcomes should be predicted
  xx<- seq(min(input.table$t), max(input.table$t), len = max(input.table$t) - min(input.table$t)+1)

  splinePred_gam_cs <- predict.gam(gam_mod_cs, data.frame(t=xx), se=T)
  
  splinePred_gam_cs$lower <- exp(splinePred_gam_cs$fit)-1.96*splinePred_gam_cs$se.fit
  splinePred_gam_cs$upper <- exp(splinePred_gam_cs$fit)+1.96*splinePred_gam_cs$se.fit
  #retransfrom
  gam.table <- data.frame(t=xx, value=exp(splinePred_gam_cs$fit), se=splinePred_gam_cs$se.fit, lower=splinePred_gam_cs$lower, upper=splinePred_gam_cs$upper)

  return(gam.table)
}

addSplineValuesForTrueN <- function(input.table, gam.table) {
  pseudoNumber=10^-10
  #log transform, to avoid negative values
  trueN_gam_cs <- gam(log(trueN + pseudoNumber) ~ s(t,bs="cs"),
                      data=input.table, method="REML")
  xx<- seq(min(input.table$t), max(input.table$t), len = max(input.table$t) - min(input.table$t)+1)
  trueN_spline_gam_cs <- predict.gam(trueN_gam_cs, data.frame(t=xx))
  # re-transform on normal scale
  gam.table["value_trueN"] <- exp(trueN_spline_gam_cs)

  return(gam.table)
}

computeRatio <- function(values, values_trueN) {
  return(values/values_trueN)
}
