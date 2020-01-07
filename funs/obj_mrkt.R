

#' 
#' OptMarket-class constructor
#'
#' @param ul underlying ticker
#' @param ul_price underlying price (used for options valuation)
#' @param board options price board, inclusing underlying
#' @param now valuation / current date
#' @param descr market description
#'
#' @return
#' OptMarket-class object.
#' @export
#'
#' @examples
#' 
# TODO: Add market symbol: forts, nyse, etc.
OptMarket = function(ul, ul_price, board, now=Sys.Date(), descr=NULL, 
                     calc_iv=F ){
  
  x = structure(list(), class='OptMarket')
  
  # Underlying ticker
  x$ul = as.character(ul)
  
  # Extract UL params from ul_data dataframe
  x$ul_price = as.numeric(ul_price)
  
  # Current market date
  x$now = as.Date(now)
  
  # TODO: test if the option board has the right underlying
  x$board = board 
  
  # OPTION: calc IV for board
  if(calc_iv)
    x$board = CalcIV(board, ul_price, now)

  # Market description (not required)
  x$descr=descr
  
  if(is.na(ul)) warning('Underlying ticker not set')
  return(x)
}




#' Test OptMarket class
#'
#' @param x OptMarket-class object
#'
#' @return
#' True / False if the input is the OptMarket class object.
#' @export
#'
#' @examples
is.OptMarket = function(x){
  if(class(x)=='OptMarket') return(TRUE) else return(FALSE)
}



