
#
#' Load FORTS trades from Excel
#'
#' @param filepath Excel source file name / path
#'
#' @return
#' @export
#'
#' @examples
GetTrades_fortsdb = function(src = "forts_64")
  {
  # TODO: GetBoard - common function (interface), depending on scr calls other functions, which return brd
  require(RODBC)
  require(dplyr)
  
  # Get data from Excel
  conn = odbcConnect('forts_64')
  trades = sqlQuery(conn, paste0('select * from trades'),stringsAsFactors=FALSE)
  odbcClose(conn)
    
    # trades:: ticker | xtype | strike | expdate | tradeprice | q  [ lot | amnt | num ]
    # names(trades) = c('temp', "tradenum", "datetime", 'period', "ordernum", "ticker", "buysell", 'account', 'tradeprice', 'quant', 'amount', 'comment')
    
    
    trades = trades %>% 
      select(tradedate, -tradetime, tradenum, ticker, buysell, quant, tradeprice, amount) 
    
    trades = trades %>% mutate(datetime = tradedate)
    
    #mutate trade types to "Buy" or "Sell"
    trades = trades %>% dplyr::filter(!is.na(ticker)) 
   
    
    kuplya = "BUY"
    prodazha = "SELL"
    
    # Encoding(kuplya)='CP1251'
    # Encoding(prodazha)='UTF-8'
    
    trades$bs = 0
    trades$bs[trades$buysell==kuplya] = 1
    trades$bs[trades$buysell==prodazha] = -1
    
    # raw_trades = raw_trades %>% mutate(buysell = replace(buysell, buysell=="?????", 1)) 
    # raw_trades = raw_trades %>% mutate(buysell = ifelse(buysell=="???????", -1, buysell)) 
    # raw_trades = raw_trades %>% mutate(buysell = as.numeric(buysell)) 
    
    trades = trades %>% mutate(q = quant * bs) 
    trades = trades %>% select(-buysell, -quant, -bs)
    
    
    return(trades)
  }

