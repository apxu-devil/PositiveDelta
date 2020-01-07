
#' Portfolio pricing function with market prices
#'
#' @param optport OptPort-class object
#' @param market_data bind_rows(GetBoard(), GetUl())
#'
#' @return
#' @export
#'
#' @examples
# TODO: Add pricing method. Primitive - use price and iv cols; by suffix - last, mid; market - complex logic - use ask, bid, if no ask bid use mid,last, theor....

RefreshPositionPricing = function(optport, optmarket, refreshmethod=1) # TODO: Add ul pricing
  # refreshmethod: 1 - refresh_join, 2 - update_df
{
  require(dplyr)
  
  # Set option port
  if(is(optport, 'OptPort'))
    position = optport$position
  else
    position = optport
  
  # Set option market
  if(is(optmarket, 'OptMarket'))
    board = optmarket$board
  else
    board = optmarket
  
  if(refreshmethod==1){
    # Exclude existing price and iv columns from position dataframe
    poscols =!as.logical(startsWith(names(position), c('price')) + 
                           startsWith(names(position), c('iv')) +
                           (names(position)=='tilexp') 
    )
    #cols = !(names(position) %in% c('price', 'iv'))
    
    # Select board columns: ticker, price*
    brdnames = names(board)
    marketcols = as.logical((brdnames=='ticker') + startsWith(brdnames, c('price')))
    
    ### Primitive solution
    
    position = position[,poscols]
    position = refresh_join(position, 
                            board[, marketcols], 
                            by='ticker')
    
  }
  
  if(refreshmethod==2){
    
    position = update_df(position, 
                         board,
                         'ticker',
                         'price',
                         'price.theor')
    
  }
  
  optport$position = position
  return(optport)
}

# xprt = RefreshPositionPricing(optport, simrkt6)
# RefreshPositionPricing(xprt, simrkt6)
# xprt$position  =CalcIV(xprt$position, 64351,  "2019-04-22")

