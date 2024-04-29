
# Beta_binomial function

Bayesian_beta_binomial_1way = function(list1, list2, textfile, 
                                       max.score1, max.score2, 
                                       nchains, niter, nburns, nthin,
                                       prior_alpha, prior_beta){
  
  
  cat('
  model{

      for(i in 1:N1) {
        y1[i] ~ dbin(p1, n1[i])
      }
      
       for(i in 1:N2) {
        y2[i] ~ dbin(p2, n2[i])
       }
       
      p1 ~ dbeta(alpha, beta)
      p2 ~ dbeta(alpha, beta)

    delta <- p1 - p2}
', file=textfile)
  
  
  # Data
  data.list <- list(
    y1 = list1 
    , y2 = list2
    , n1 = max.score1
    , n2 = max.score2
    , N1 = length(list1)
    , N2 = length(list2)
    , alpha = prior_alpha
    , beta = prior_beta
  )
  
  
  ## Parameters to store
  params <- c(
    "p1"
    , "p2"
    , "delta"
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
  
  return(out)
  
}