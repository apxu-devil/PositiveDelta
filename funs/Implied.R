



#
# Function calculates implied volatility for portfolio
#
Implied = function(port, baprice, now=Sys.Date(), r=0){
  
  suppressWarnings({
  port$iv = 0
  # Test inputs  
  if(is.null(baprice) || baprice=='' || baprice==0 || is.na(baprice)) {
    warning('Implied2 - Invalid baprice value')
    return(port)
  }
    baprice = as.numeric(baprice) 
    
  if(is.null(now) || now==0 || is.na(now)){
    warning('Implied2 - Invalid now value')
    return(port)
  }
  now = as.Date(now)
  
  if(is.null(r) || r=='' || r==0 || is.na(r)){
    r = 0
    message('Implied2 - Zero rate')
  }  
  r = as.numeric(r)
    
  ### Test for required columns in port
  cols = names(port)
  required_cols = c('xtype', 'strike', 'expdate')
  missing_cols  = required_cols[!(required_cols %in% cols)]
  if(length(missing_cols)>0) 
    message( paste0( c('Implied - Missing required columns in port: ', missing_cols) , collapse=' ') )
  
  ### If no market price, then nothing to calculate
  if(is.null(port$mrkt)){
    message('Implied2 - Unknown options market price / no price column')
    port$mrkt=NA
    port$iv = 0
    return(port)
  } 
  
  port = DaysTilExp(port, now)
  
  #port$xtype = substr(tolower(port$xtype), 1, 1)
  
  
  for( n in c(1:nrow(port)) ){
    
    xtype  = substr(tolower(port$xtype[n]), 1, 1)
    strike = as.numeric(port$strike[n])
    tilexp = as.numeric(port$tilexp[n])/365
    mrkt   = as.numeric(port$mrkt[n])
    
    #if(xtype == "c" || xtype == "p"){
      
        port$iv[n] = tryCatch(GBSVolatility(mrkt, xtype, baprice, strike, tilexp, r, r), error = function(e) 0)#, .Machine$double.eps^0.25,1000 )
    #} 
  }
  
  })
  
  return(port)
}

