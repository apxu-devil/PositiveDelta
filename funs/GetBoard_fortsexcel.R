

#' Loads current option board
#'
#' @param ul underlying ticker
#' @param src source excel name
#'
#' @return
#' @export
#'
#' @examples
#' 
GetBoard = function(ul='SiM9', src="FortsData.xlsx"){
  
  # TODO: GetBoard - common function (interface), depending on scr calls other functions, which return brd
  require(readxl)
  require(dplyr)
  
  myul=ul
  
  # Get data from Excel
  brd = read_excel(src, sheet = 'board',range = 'A1:L1000') #read.csv(text=readClipboard(), header = T, sep='\t', dec = ',',stringsAsFactors = F)[-1]
  
  names(brd) = c('ticker1','ticker','classcode','ul','xtype','strike','expdate','iv.moex','price.ask','price.bid','price.theor','price.last')
  
  # Set values
  #brd$price = brd$theor
  brd$iv = brd$iv.moex / 100
  brd$expdate = as.Date(brd$expdate, format='%d.%m.%Y')
  
  brd = brd %>% dplyr::filter(classcode=='SPBOPT' & ul==myul) %>%
    mutate( xtype=tolower(substr(xtype,1,1)) ) #%>%
  #select(ticker, ul, xtype, strike, expdate, iv, ask, bid, theor, price)
  
  # TODO: grepls works with mistakes
  sel_cols = as.logical(grepl('p.', names(brd)) +
                          grepl('iv.', names(brd)) +
                          names(brd) %in% c('ticker', 'classcode', 'ul', 'xtype', 'strike', 'expdate'))
  
  
  
  brd = brd[,sel_cols]
  
  return(brd)
  
}
