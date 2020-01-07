
#' Check for various empty values
#'
#' @param x variable to test
#' @param is_zero test for zero value?
#' @param is_na test for NA value?
#' @param is_nan test for NaN value?
#' @param is_null test for NULL value?
#' @param is_notext test for '' value?
#'
#' @return
#' Returns TRUE if any empty (NULL, NA, NaN, 0 or '') value is found.
#' 
#' 
#' @export
#'
#' @examples
isEmpty = function(x, is_zero=T, is_na=T, is_nan=T, is_null=T, is_notext=T ){
  
  #if(is.null(r) || r=='' || r==0 || is.na(r))
  
  if(is_null & is.null(x) )
    return(TRUE)
  
  if(is_na & is.na(x))
    return(TRUE)
  
  if(is_nan & is.nan(x))
    return(TRUE)
  
  if(is_zero & x==0)
    return(TRUE)
  
  if(is_notext & as.character(x)=='' )
    return(TRUE)
  
  return(FALSE)
  
}

