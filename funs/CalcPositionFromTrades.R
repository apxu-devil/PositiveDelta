
#
# CALCULATE POSITION FROM TRADES
#
CalcPositionFromTrades = function(trades)
{
  
  library(dplyr)
  position = trades %>% 
    group_by(Symbol) %>% 
    summarise(Amount = sum(Amount*(-BuySell)),  #<---- !!!!! ?????? ?????
              Q = sum(Quant*BuySell), 
              AvgPrice = sum(Price*Quant*BuySell)/sum(Quant*BuySell) ) %>%
    filter(Q!=0)
  
  return(position)
}

