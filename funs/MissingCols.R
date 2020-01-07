
#' Test for missing columns in a dataframe
#'
#' @param df data frame to test
#' @param cols required colomn names vector
#' @param warn F (default) - returns error if a column is missing, else (warn=T) returns a warning
#'
#' @return
#' NULL if no missing cols, error or warning (depends on \code{warn} value) - if something is missed. Error (or warning) message
#' includes missed column names.
#' 
#' @export
#'
#' @examples
#' 
MissingCols = function(df, cols, warn=F){
  
  df=as.data.frame(df)
  
  req_cols = cols
  cols = names(df)

  missing_cols  = req_cols[!(req_cols %in% cols)]
  
  if(length(missing_cols)>0) 
    if(!warn)
      return( stop(missing_cols))
    else
      return( warning(missing_cols))
  else
    return(NULL)
  
}

# MissingCols(port, c('xsymbol', 'xtype', 'strike'), T)

