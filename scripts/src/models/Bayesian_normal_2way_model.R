
# Define the Bayesian normal function

Bayesian_normal_2way = function(list1, list2, list3, list4, 
                                textfile, 
                                nchains, niter, nburns, nthin,
                                mu_prior_min, mu_prior_max,
                                scale){
  
  # Group-level parameters (parameters of dnorm):
  # mu is taken from a uniform distribution with priors for min and max: [0 10]
  # tau (inverse of SD) is used instead of sigma (SD), as is often the case in Bayesian analyses
  # gamma(shape, rate) is commonly used as a prior distribution for the precision (1/sd^2). However Half-cauchy is better advised
  
  # We use half-Cauchy distributions for the priors of sigma, rather than gamma, following Gelman 2006
  # This half-Cauchy / half-student-t distribution is computed with a student distribution
  # The half-t distribution is centered on 0 (location = 0), with a scale parameter of 1
  # and with 1 degree of freedom. It is followed by the truncature command T(0,).
  # It can be coded in JAGS with dt() (dt() is for student distribution)
  
  
  cat('
  model{

      for(i in 1:N1) {
        y1[i] ~ dnorm(mu1, tau)
      }
      
       for(i in 1:N2) {
        y2[i] ~ dnorm(mu2, tau)
       }
       
       
       for(i in 1:N3) {
        y3[i] ~ dnorm(mu3, tau)
      }
      
       for(i in 1:N4) {
        y4[i] ~ dnorm(mu4, tau)
       }
       
      mu1 ~ dunif(mu_prior_min, mu_prior_max)
      mu2 ~ dunif(mu_prior_min, mu_prior_max)
      mu3 ~ dunif(mu_prior_min, mu_prior_max)
      mu4 ~ dunif(mu_prior_min, mu_prior_max)
      tau = 1/S^2
      S ~ dt(0, 1 / scale^2, 1)T(0, )

    delta_Nr <- mu1 - mu3
    delta_r <- mu2 - mu4
    
    Cohens_d_y1 <- (mu1 - mu2)/S
    Cohens_d_y2 <- (mu3 - mu4)/S }
', file=textfile)
  
  
  ## The data
  data.list <- list(
    y1 = list1
    , y2 = list2
    , y3 = list3
    , y4 = list4
    , N1 = length(list1)
    , N2 = length(list2)
    , N3 = length(list3)
    , N4 = length(list4)
    , mu_prior_min=mu_prior_min
    , mu_prior_max=mu_prior_max
    , scale = scale
  )
  
  ## Parameters to store
  params <- c(
    "mu1", "mu2", "mu3", "mu4"
    , "tau", "S"
    , "delta_r", "delta_Nr"
    , "Cohens_d_y1", "Cohens_d_y2"
  )
  
  ## MCMC settings
  out_WTP_rec_years <- jags(
    data                 = data.list
    , parameters.to.save = params
    , model.file         = textfile
    , n.chains           = nchains
    , n.iter             = niter
    , n.burnin           = nburn
    , n.thin             = nthin
    # , inits              = jags.inits
    , progress.bar       = "text")
}