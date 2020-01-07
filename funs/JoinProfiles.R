
# TODO: create silgele UL Range for multiple profiles

#' Join multiple profiles
#'
#' @param profiles list of OptProfile-class objects.
#'
#' @return
#' Dataframe: ba | total | at_date | port
#' @export
#'
#' @examples
JoinProfiles = function(profiles){   # profiles = list(profile1, profile2,...)
 
  require(dplyr)
  
  # Data frame for united profiles
  sum_prfl = NULL
  joined_profile = list()
  # 
  for (n in c(1:length(profiles))) {
    
    prfl = profiles[[n]]
    pdata = prfl$profile
    #pdata$at_date = prfl$now
    
    if(n==1)
      ul_price = prfl$ul_price
    
    
    # Column with portfolio name
    if(is.null(prfl$port))
      pdata$port = paste0('Portfolio_',n)
    else
      pdata$port = prfl$port[1]
    
    # Add profile to common dataframe
    if(!is.null(sum_prfl))
      sum_prfl = bind_rows(sum_prfl, pdata)
    else
      sum_prfl = pdata
    
  }
  
  joined_profile$profile = sum_prfl
  joined_profile$ul_price = ul_price
  
  return(joined_profile)
}
