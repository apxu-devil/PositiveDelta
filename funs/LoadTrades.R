#
# LOAD TRADES INTERFACE
#


LoadTrades = function(src = '', ...){
  
  
  if(src=='Forts.Excel')
    return(GetTradesFortsExcel(...))
  
  
  if(src=='Forts.sample'){
    
    if(!exists(deparse(substitute(path))))
      path='..\\fortssample.RData'
    
    load(path)
    return(trades)
  }
    
  
  return(NULL)
  
}


