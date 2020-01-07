
# Функция: Разбить название опционного символа на параметры опциона
# Принимает аргументом opt_code код опциона из ТВС
# Возвращает лист с параметрами опциона

#
# Alias:
# ParamsFromTicker, algo = us
# ExpandTicker
# DecodeTicker

SymbolDesintegrate = function(opt_symbol){
  # NYSE ticker mask: GLD   190315C00124000
  
  tryCatch({
    
    split_code = strsplit(opt_symbol, " ", fixed = T)[[1]]
    
    symb = split_code[1]
    
    params = split_code[length(split_code)]
    
    expdate = as.Date(substr(params, 1, 6), format="%y%m%d")
    
    typeflag = substr(params, 7, 7)
    
    strike_int = substr(params, 8, 12)
    strike_dbl = substr(params, 13, 15)
    
    strike = as.double(paste(strike_int, strike_dbl, sep = ".") )
    
    code_list = list(Symbol = symb, ExpDate = expdate, OptType = typeflag, Strike = strike)
    
    return(code_list)
    
    
  })

  
}

# Example:
# SymbolDesintegrate("SPY  171215P00254050")


#
# Alias:
# ParamsFromTicker, algo = board
#
TradeTickerParams = function(trades, brd, ul){

  require(dplyr)

  params = brd %>% select(ticker, ul, xtype, strike, expdate)
  params$xtype = tolower(substr(params$xtype , 1, 1))
  
  res = refresh_join(trades, params, by='ticker')
  res$xtype[res$ticker==ul]='u'
  
  return(res)
}


# Ticker to params (from FORTS board) -------------------------------------

TickerToParams_fortsboard = function(tickers=NULL, board=NULL, search_by='ticker'){

  if(is.vector(tickers)) {
    
    tickers = data.frame(ticker=tickers)
    names(tickers$ticker) = search_by
}
  
  board = board[, c('ticker', 'ul', 'xtype', 'strike', 'expdate')]
  
  left_join(tickers, board, by=search_by)
}


DecodeTradesTickers = function(trades, market='forts') #market: forts, tws
  { 
  
    tickers = unique(trades$ticker)
    
    if (market=='forts'){
      decoded = lapply(tickers, function(x)DecodeTicker_forts(x)) 
      decoded = bind_rows(decoded)
    }
      

    trades = refresh_join(trades, decoded, by='ticker')
    
    return(trades)
  } 

# ExpandTicker.forts('SiZ9')
# refresh_join(trades, rowwise(trades) %>% do( ExpandTicker.forts(.$ticker)), by='ticker')
#
# Alias:
# ParamsFromTicker, algo = forts_short
#
DecodeTicker_forts = function(ticker){

  
  params = list( 
    ticker = ticker,
    ul = NA, 
    expdate = NA, 
    xtype = NA, 
    strike = NA , 
    stringsAsFactors=F)
  
  tryCatch({
    
    # Param: underlying
    ul = substr(ticker, 1, 2)

    # FUTURES
    if(nchar(ticker)==4){
      
      params$ul = ul
      
      exp_month = substr(ticker, nchar(ticker)-1, nchar(ticker)-1)
      
      if(exp_month == 'F' ) xmonth='01'
      if(exp_month == 'G' ) xmonth='02'
      if(exp_month == 'H' ) xmonth='03'
      if(exp_month == 'J' ) xmonth='04'
      if(exp_month == 'K' ) xmonth='05'
      if(exp_month == 'M' ) xmonth='06'
      if(exp_month == 'N' ) xmonth='07'
      if(exp_month == 'Q' ) xmonth='08'
      if(exp_month == 'U' ) xmonth='09'
      if(exp_month == 'V' ) xmonth='10'
      if(exp_month == 'X' ) xmonth='11'
      if(exp_month == 'Z' ) xmonth='12'
      
      exp_year = substr(ticker, nchar(ticker), nchar(ticker))
      exp_year = YearByLastDigit(exp_year)
      
      expdate = ThirdThursday(exp_year, xmonth)
      
      params = data.frame(
                    ticker = ticker,
                    ul = ul, 
                    expdate = as.Date(expdate), 
                    xtype = 'u', 
                    strike = NA,
                    stringsAsFactors=F)
      
      return(as.data.frame(params))
    }
    
    #OPTIONS
    w=0 # weekly options flag
    n_week = 3 # third thurstday is the exp date by default
    
   
    
    exp_year = substr(ticker, nchar(ticker)-w, nchar(ticker)-w)
    
    if(is.na(as.numeric(exp_year))==TRUE){ #options are weekly
      
      exp_week = substr(ticker, nchar(ticker), nchar(ticker))
      
      if(exp_week=='A') n_week = 1
      if(exp_week=='B') n_week = 2
      if(exp_week=='C') n_week = 3
      if(exp_week=='D') n_week = 4
      
      w=1
      exp_year = substr(ticker, nchar(ticker)-w, nchar(ticker)-w)
    }
      
    exp_month = substr(ticker, nchar(ticker)-1-w, nchar(ticker)-1-w)
    

    if(exp_month<='L') xtype = 'c'
    if(exp_month >'L') xtype = 'p'

    if(exp_month == 'A' ) xmonth='01'
    if(exp_month == 'B' ) xmonth='02'
    if(exp_month == 'C' ) xmonth='03'
    if(exp_month == 'D' ) xmonth='04'
    if(exp_month == 'E' ) xmonth='05'
    if(exp_month == 'F' ) xmonth='06'
    if(exp_month == 'G' ) xmonth='07'
    if(exp_month == 'H' ) xmonth='08'
    if(exp_month == 'I' ) xmonth='09'
    if(exp_month == 'J' ) xmonth='10'
    if(exp_month == 'K' ) xmonth='11'
    if(exp_month == 'L' ) xmonth='12'

    if(exp_month == 'M' ) xmonth='01'
    if(exp_month == 'N' ) xmonth='02'
    if(exp_month == 'O' ) xmonth='03'
    if(exp_month == 'P' ) xmonth='04'
    if(exp_month == 'Q' ) xmonth='05'
    if(exp_month == 'R' ) xmonth='06'
    if(exp_month == 'S' ) xmonth='07'
    if(exp_month == 'T' ) xmonth='08'
    if(exp_month == 'U' ) xmonth='09'
    if(exp_month == 'V' ) xmonth='10'
    if(exp_month == 'W' ) xmonth='11'
    if(exp_month == 'X' ) xmonth='12'


    
    exp_year = YearByLastDigit(exp_year)
    
    expdate = ThirdThursday(exp_year, xmonth, n_week)

    strike = substr(ticker, 3, nchar(ticker)-3-w)
     
    params = data.frame(
                  ticker = ticker,
                  ul = ul, 
                  expdate = as.Date(expdate), 
                  xtype = xtype, 
                  strike = as.numeric(strike), 
                  stringsAsFactors=F)
    
    return(as.data.frame(params))
  })
}

# ExpandTicker.forts('Si68250BS9D')

#
# Full year if wwe know only the last digit
#
YearByLastDigit = function(lastdig=0, now = Sys.Date()){
  
  lastdig = as.character(lastdig)
  now_y = format(now, '%Y')
  now_ys = seq(as.numeric(now_y)-4, as.numeric(now_y)+5, by=1)
  now_ys = as.character(now_ys)
  now__s = substr(now_ys,4,4)
  near_yn = which(now__s==lastdig)
  
  now_ys[near_yn]
  
}


#
# Finds the third thustday of a month
#
ThirdThursday = function(year, month, n_week=3){
  
  month = as.numeric(month)
  
  if(month>12 || month<1)
    stop('Wrong month number')
  
  
  month = formatC(month, width=2, flag='0')
  
  
  
  first_thurs = as.Date( paste(year,month, formatC(7*(n_week-1)+1, width=2, flag='0' ), sep='-') )
  last_thurs  = as.Date( paste(year,month, formatC(7*(n_week)+1,   width=2, flag='0' ), sep='-') )
  
  the_week = seq(first_thurs, last_thurs, by=1)
  the_days = as.POSIXlt(the_week)$wday
  
  the_thurs = the_week[which(the_days==4)]
  
  return(the_thurs)
  
}


