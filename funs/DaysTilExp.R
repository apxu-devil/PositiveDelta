#
# Function calculates number of days until expiration
#
DaysTilExp = function(port, now=Sys.Date()){
  
  if(isEmpty(now)){
    port$tilexp = 0
    return(port)    
  }
    
  
  if( is.null(port$expdate) )
    port$expdate = 0
  
  tilexp = as.numeric(as.Date(port$expdate) - now)
  tilexp[tilexp<0]=0
  
  port$tilexp = tilexp
  return(port)
  
}
