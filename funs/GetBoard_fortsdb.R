
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
GetBoard_fortsdb = function(ul='SiZ9', src="forts_64"){
  
  # TODO: GetBoard - common function (interface), depending on scr calls other functions, which return brd
  require(RODBC)
  require(dplyr)
  
  ul_ticker=ul
  
  # Get data from Access
  conn = odbcConnect('forts_64')
  brd = sqlQuery(conn, paste0('select * from board'),stringsAsFactors=FALSE)
  odbcClose(conn)
 
  names(brd) = c('ticker1','ticker','classcode','ul','xtype','strike','expdate','iv.theor','price.ask','price.bid','price.theor','price.last','oi')

  
  # Select options of the given underlying and the underlying itself
  brd = brd %>% dplyr::filter( (classcode %in% c('SPBOPT','OPTW') & ul==ul_ticker) || ticker==ul_ticker ) %>%
    mutate( xtype=tolower(substr(xtype,1,1)) ) 
  
  # Correct values
  brd$iv.theor = brd$iv.theor / 100
  brd$expdate = as.Date(brd$expdate, format='%d.%m.%Y')
  
  # Set underlying type 
  brd[ brd$ticker==ul_ticker, 'xtype']='f'
  
  # Set underlying theor price as last price
  ul_price = brd[ brd$ticker==ul_ticker, 'price.last']
  
  if(!is.null(brd$price.theor))
    brd[ brd$ticker==ul_ticker, 'price.theor'] = ul_price
  
  # TODO: grepls works with mistakes
  sel_cols = as.logical(grepl('price.', names(brd)) +
                          grepl('iv.', names(brd)) +
                          names(brd) %in% c('ticker', 'classcode', 'ul', 'xtype', 'strike', 'expdate','oi'))
  
  # Gather output 
  return( list(board = brd[,sel_cols], ul = ul_ticker, ul_price = ul_price) )
}

