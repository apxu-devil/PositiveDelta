
#' Loads current underlying data
#'
#' @param ul underlying ticker
#' @param src source excel name
#'
#' @return
#' Returns dataframe w/ columns \code{ticker, ul, expdate, ask, bid, price}.
#' @export
#'
#' @examples
#' 
GetUl = function(ul='SiM9', src="FortsData.xlsx"){
  
  # TODO: GetUl - common function (interface), depending on scr calls other functions, which return ulnerlying info
  require(readxl)
  require(dplyr)
  
  myul=ul
  
  # Get data from excel file
  brd = read_excel(src, sheet = 'board',range = 'A1:L1000') #read.csv(text=readClipboard(), header = T, sep='\t', dec = ',',stringsAsFactors = F)[-1]
  names(brd) = c('ticker1', 'ticker', 'classcode', 'ul', 'xtype', 'strike', 'expdate', 'iv.moex', 'price.ask', 'price.bid', 'price.theor', 'price.last')
  
  
  
  # Remove unused columns and values (rows)
  brd = brd %>% dplyr::filter(ticker==myul & classcode=='SPBFUT')  %>%
    select(-ticker1, -classcode, -iv.moex)
  
  # Set known values
  brd$price.theor = brd$price.last
  brd$xtype = 'u'
  brd$expdate = as.Date(brd$expdate, format='%d.%m.%Y')
  
  return(brd)
}

