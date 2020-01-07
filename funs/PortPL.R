




# --- PortPL ------------------------------------------------------------------

#' Portfolio risk profile function
#'
#' @param port - options portfolio table
#' @param ba_values - x-axis underlying values
#' @param param - parametre to calculate: pl, delta, gamma, vega, theta
#' @param total_only - output only sum value of the component
#' @param now - calculation date
#' @param r - money market rate
#'
#' @return
#' Returns single parametre profile dataframe.

PortPL = function(port, ba_values, param="pl", total_only=T, now = Sys.Date(), r=0){
  
  require(fOptions)
  
  # Lot Size = 1 by default (if no value given)
  if( is.null(port$lot) ) port$lot=1
  
  # No implied volatility input
  if( is.null(port$iv) ) port$iv=0

  # Calc days til expiry
  port = DaysTilExp(port, now=now)
  
  # Create table for profile values, set x-axis values
  pl.table = data.frame(ba = ba_values)
  
  # For every portfolio component...
  for( n in c(1:nrow(port)) ){
    
    nname = paste0("n", n)
    
    xtype  = substr( tolower( port$xtype[n] ), 1, 1 )
    strike = port$strike[n]
    tilexp = as.numeric( port$tilexp[n] )/365
    iv     = port$iv[n]
    
    if(is.na(strike)) strike=0
    if(is.na(xtype)) xtype='u'
    if(is.na(iv)) iv=0
    
    if(iv==0)  r=0
    
    tradeprice = port$tradeprice[n]
    q          = port$q[n]
    lot        = port$lot[n]
    
    
    # If the component is an option...
    if(xtype=='c' || xtype=='p'){
      
      # CALCULATE PNL
      if(param=='pl'){
        
         #pl.table = pl.table %>% mutate( !! nname := (GBSOption(xtype, ba, strike, tilexp, r, r, iv)@price - tradeprice)*q*lot )
        
        if(iv==0 || tilexp==0){
         
          if(xtype=='c')
            pl.table = pl.table %>% mutate(!! nname := pmax(ba-strike, 0, na.rm = T ))
          
          if(xtype=='p')
            pl.table = pl.table %>% mutate(!! nname := pmax(strike-ba, 0, na.rm = T ))
          
        } else {
          
          pl.table = pl.table %>% mutate( !! nname := GBSOption(xtype, ba, strike, tilexp, r, r, iv)@price )
          pl.table[is.nan(pl.table[[nname]]), nname]=0
          
        }
        
        # TODO: is amount !=0, then pl= amount - tradeprice * q * lot
        pl.table[[nname]] =(pl.table[[nname]]-tradeprice)*q*lot
      
        
      # CALCULATE GREEKS    
      } else if(param %in% c('gamma', 'delta') ){
        pl.table = pl.table %>% mutate( !! nname := GBSGreeks(param, xtype, ba, strike, tilexp, r, r, iv)*lot*q )
        
      } else if(param=='theta'){
        pl.table = pl.table %>% mutate( !! nname := GBSGreeks(param, xtype, ba, strike, tilexp, r, r, iv)*lot*q/365 ) 
        
      } else if(param=='vega'){
        pl.table = pl.table %>% mutate( !! nname := GBSGreeks(param, xtype, ba, strike, tilexp, r, r, iv)*lot*q/100 ) 
        
      }
      
   # If the component is not an option (underlying)...  
    } else {
      
      if(param=='pl'){
        pl.table = pl.table %>% mutate( !! nname := (ba-tradeprice)*q*lot )
        
      } else if(param %in% c('delta') ){
        pl.table = pl.table %>% mutate( !! nname := 1*lot*q ) 
        
      } else if(param  %in% c('gamma', 'theta', 'vega') ){
        pl.table = pl.table %>% mutate( !! nname := 0 ) 
        
      } 
    }
  }
  
  # Sum component parametres values
  pl.table = pl.table %>% mutate(total = rowSums(.[2:ncol(.)]))
  pl.table$total = signif(pl.table$total, 4)
  
  
  # Output only sum value of the components
  if(total_only)
    pl.table = pl.table %>% select(ba, total)
  
  return(pl.table)
  
}


