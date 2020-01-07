
#' Add new trades to OptPort object
#'
#' @param port an object of the class OptPort
#' @param trades data.frame with the trades$ required columns \code{ticker, xtype, strike, expdate, q, tradeprice}
#' @param  sum_trades if TRUE, the function returns sum of all trades in position; else - the added trades are seen in position
#'
#' @return
#' OptPort object with new added trades and refreshed position
#' @export
#'
#' @examples
#' 
#' 
AddTrades = function(port, trades, sum_trades=T){
  
   require(dplyr)
  
  # Check for required columns
  trades = as.data.frame(trades, stringAsFactors = F)
  MissingCols(trades, c('ticker', 'ul', 'xtype', 'strike', 'expdate', 'q', 'tradeprice'))
  
  # Test column format
  with(trades, {
    expdate = as.Date(expdate)
    strike = as.numeric(strike)
    q = as.numeric(q)
    tradeprice = as.numeric(tradeprice)
  })
  
  # Add new trades to trades in portfolio
  port$trades = bind_rows(port$trades, trades)
  
  # Trades summation
  if(sum_trades==T)
    position = SumTrades(port$trades)
  else 
    position = bind_rows(port$position, trades)
  
  position = position %>% dplyr::select('ticker', 'ul', 'xtype', 'strike', 'expdate', 'q', 'tradeprice', 'amount', 'pl')
  port$position = as.data.frame(position)
  
  return(port)
}

