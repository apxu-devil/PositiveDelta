#
# Function calculates implied volatility for portfolio
# board ::: xtype | strike | expdate | price
#
CalcIV = function(board, ul_price, now=Sys.Date(), r=0){
  
  require(fOptions)
  
  suppressWarnings({
    
    #board$iv = NA
    # Test inputs  
    if(isEmpty(ul_price)) {
      warning('Implied2 - Invalid ul_price value')
      return(board)
    }
    ul_price = as.numeric(ul_price) 
    
    if(isEmpty(now)){
      warning('Implied2 - Invalid now value')
      return(board)
    }
    now = as.Date(now)
    
    if(isEmpty(r)){
      r = 0
      message('Implied2 - Zero rate')
    }  
    r = as.numeric(r)
    
    
    ### Test for required columns in port
    MissingCols(board, c('xtype', 'strike', 'expdate'))
    
    board = DaysTilExp(board, now)
    
    # Get columns names with price values
    prices = names(board)[startsWith(names(board),'price')]
    
    ### If no market price, then nothing to calculate
    if(length(prices)==0){
      
      message('Implied2 - No price column(s)')
      #board$price=NA #TODO: calc inner price
      board$iv = 0
      return(board)
      
    } 
    
    
    # Calculate IV for every price.* column
    for (prc in prices) {
      
      # Extract price 
      suffix = substr(prc, 6, nchar(prc))
      ivname = paste0('iv',suffix)
      board[[ivname]] = NA
      
      for( n in c(1:nrow(board)) ){
        
        xtype  = substr(tolower(board$xtype[n]), 1, 1)
        strike = as.numeric(board$strike[n])
        tilexp = as.numeric(board$tilexp[n])/365
        price   = as.numeric(board[[prc]][n])
        
        #if(price>0){
          board[[ivname]][n] = tryCatch({
            iv = GBSVolatility(price, xtype, ul_price, strike, tilexp, r, r)
            iv = round(iv, digits = 4)
          }, error = function(e) 0)#, .Machine$double.eps^0.25,1000 )
          
        #}
        
        
      }
      
    }
    
  })
  
  return(board)
}

