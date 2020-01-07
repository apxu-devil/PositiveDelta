


#' Refresh x with y values
#'
#' @param x 
#' @param y 
#' @param by 
#'
#' @return
#' 
#' 
#' @export
#'
#' @examples
refresh_join = function(x, y, by){
  
  require(dplyr)
  
  # Get unique columns
  not_doubles = !(names(x) %in% names(y))
  by_col = names(x)==by
  
  # Columns stay in the left side
  leave = names(x)[as.logical(not_doubles + by_col)]
  
  x = x[, leave]
  
  left_join(x, y, by)
  
  
}




