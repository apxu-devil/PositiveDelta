#
# OPTION PORTFOLIO CLASS FUNCTIONS
#
#' Class OptPort constructor
#'
#' @param name portfolio name
#' @param ul underlying ticker
#' @param trades trades dataframe
#'
#' @return
#' Returns options portfolio object of the \code{OptPort} class
#' @export
#'
#' @examples
#' 
OptPort = function(name=NA, ul=NA, trades=NULL, sum_trades=T){
  
  x = structure(list(), class='OptPort')
  
  x$name = as.character(name)
  x$ul   = as.character(ul)
  x$position = data.frame()
  
  # trades:: ticker | xtype | strike | expdate | tradeprice | q  [ lot | amnt | num ]
  
  x = AddTrades(x, trades, sum_trades)
  
  return(x)
}


# OptPort(ul='SiU9',trades=trades)
#
# PRINT FOR CLASS OPTPORT
#
#' OptPort class print
#'
#' @param x OptPort-class object
#'
#' @return
#' Print output
#' @export
#'
#' @examples
# print.OptPort = function(x){
#   
#   if(!is.OptPort(x))
#     stop('Not option port')
#   
#   cat( paste0('Name:        ', x$name, ' \n') )
#   cat( paste0('Description: ', x$descr, ' \n') )
#   cat( paste0('Underlying:  ', x$ul, ' \n') )
#   cat('\n')
#   
#   cat('Position: \n')
#   print(x$position)
#   cat('\n')
#   
#   cat('Trades:      \n')
#   print(x$trades)  
#   
# }



#' Test OptPort class
#'
#' @param x OptPort-class object
#'
#' @return
#' True / False if the input is the OptPort class object.
#' @export
#'
#' @examples
is.OptPort = function(x){
  if(class(x)=='OptPort') return(TRUE) else return(FALSE)
}




