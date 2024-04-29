
# Define the Bayesian normalfunction

Bayesian_normal_1way = function(list1, list2, textfile, 
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
        w1[i] ~ dnorm(mu1, tau)
      }
      
       for(i in 1:N2) {
        w2[i] ~ dnorm(mu2, tau)
       }
       
      mu1 ~ dunif(mu_prior_min, mu_prior_max)
      mu2 ~ dunif(mu_prior_min, mu_prior_max)
      tau = 1/S^2
      S ~ dt(0, 1 / scale^2, 1)T(0, )

    delta <- mu1 - mu2
    Cohens_d <- (mu1 - mu2)/S    }
', file=textfile)
  
  
  ## The data
  data.list <- list(
    w1 = list1
    , w2 = list2
    , N1 = length(list1)
    , N2 = length(list2)
    , mu_prior_min = mu_prior_min
    , mu_prior_max = mu_prior_max
    , scale = scale
  )
  
  ## Parameters to store
  params <- c(
    "mu1"
    , "mu2"
    , "tau"
    , "S"
    , "delta"
    , "Cohens_d"
  )
  
  ## MCMC settings
  out <- jags(
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