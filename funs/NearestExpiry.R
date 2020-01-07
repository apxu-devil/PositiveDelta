#
# NEAREST EXPIRATION DATE
#
#' Get the nearest expiration date
#'
#' @param optport OptPort-class object
#'
#' @return
#' Returns the nearest expiration date of an option in the portfolio position.
#' @export
#'
#' @examples
NearestExpiry = function(optport){
  
  return(min(optport$expdate, na.rm=T))
  
}
