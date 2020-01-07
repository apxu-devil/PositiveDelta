
#
#' Load FORTS trades from Excel
#'
#' @param filepath Excel source file name / path
#'
#' @return
#' @export
#'
#' @examples
GetTradesFortsExcel = function(filepath = "FortsData.xlsx")
  {
    library(readxl)
    library(dplyr)
    
    trades_from_excel = read_excel(filepath, sheet = 'trades',range = 'A1:L1000')
    
    # Refactor data for common format
    raw_trades = trades_from_excel
    
    # trades:: ticker | xtype | strike | expdate | tradeprice | q  [ lot | amnt | num ]
    names(raw_trades) = c('temp', "tradenum", "datetime", 'period', "ordernum", "ticker", "buysell", 'account', 'tradeprice', 'quant', 'amount', 'comment')
    
    Encoding(raw_trades$buysell)='UTF-8'
    raw_trades = raw_trades %>% 
      select(datetime, tradenum, ticker, buysell, quant, tradeprice, amount) 
    
    #mutate trade types to "Buy" or "Sell"
    raw_trades = raw_trades %>% dplyr::filter(!is.na(ticker)) 
   
    
    kuplya = "Купля"
    prodazha = "Продажа"
    
    # Encoding(kuplya)='CP1251'
    # Encoding(prodazha)='UTF-8'
    
    raw_trades$bs = 0
    raw_trades$bs[raw_trades$buysell==kuplya] = 1
    raw_trades$bs[raw_trades$buysell==prodazha] = -1
    
    # raw_trades = raw_trades %>% mutate(buysell = replace(buysell, buysell=="?????", 1)) 
    # raw_trades = raw_trades %>% mutate(buysell = ifelse(buysell=="???????", -1, buysell)) 
    # raw_trades = raw_trades %>% mutate(buysell = as.numeric(buysell)) 
    
    raw_trades = raw_trades %>% mutate(q = quant * bs) 
    raw_trades = raw_trades %>% select(-buysell, -quant, -bs)
    
    
    return(raw_trades)
  }

