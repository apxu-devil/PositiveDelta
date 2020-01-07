# --- UnderlyingRange----------------------------------------------------------

#' Vector of the underlying values
#'
#' @param ports - list of portfolios
#' @param range - width of the underlying range for x-axis
#' @param strikes - ???
#' @param ba_max - upper limit for x-axis
#' @param ba_min - lower limit for x-axis
#' @param ba_points - number of x-axis 
#'
#' @return - vector of underlying values for the profile


UnderlyingRange = function(ports=NULL, range=0.05, strikes=NULL, ba_max=NULL, ba_min=NULL, ba_points=50){
  
  require(dplyr)
  
  port_strikes = NULL
  custom_strikes = NULL
  
  # If portfolios exist, merge them and take the strike values.
  if(!is.null(ports)) {
    ports = bind_rows(ports)
    port_strikes = ports$strike
  }
  
  if(length(port_strikes[!is.na(port_strikes)])==0 )
    return(NA)
  
  # Add custom ul-points to the x-axis vector and exclude NA values from it
  real_strikes = unique(c(port_strikes, custom_strikes))
  real_strikes = real_strikes[!is.na(real_strikes)]
  
  if( is.null(ba_max) & is.null(ba_min) ){
    
    ba_1 = min(real_strikes)*max((1-range),0)
    ba_2 = max(real_strikes)*(1+range)
    
  } else {
    ba_1 = ba_min
    ba_2 = ba_max
  }
  
  ba_values = sort(
    unique(
      c(seq(ba_1, 
            ba_2, 
            length.out = ba_points), 
        real_strikes
        )  
      ) 
    )
  
  return(ba_values)
}

