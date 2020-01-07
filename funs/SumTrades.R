#
# CALCULATE POSITION FROM TRADES
# CalcPositionFromTrades (trades) - the same
# TradesToPosition = function(trades)
# {
#   
#   library(dplyr)
#   position = trades %>% 
#     group_by(Symbol) %>% 
#     summarise(Amount = sum(Amount*(-BuySell)),  #<---- !!!!!
#               Q = sum(Quant*BuySell), 
#               AvgPrice = sum(Price*Quant*BuySell)/sum(Quant*BuySell) ) %>%
#     filter(Q!=0)
#   
#   return(position)
# }


# Function sums trades at the same ticker: total quantity, average price, amount
SumTrades = function(trades){
  
  library(dplyr)
  
  position = trades %>% 
    group_by(ticker) %>% 
    mutate(amount = - q * tradeprice ) %>% 
    summarise(ul=ul[1], xtype=xtype[1], strike = strike[1], expdate = expdate[1], q = sum(q), amount=sum(amount))
  
  position = position %>% mutate( tradeprice = case_when(q!=0 ~ -amount/q, q==0 ~ 0) )
  
  position = position %>% mutate(pl = case_when(q==0 ~ amount, q!=0 ~ as.numeric(NA) ))
  
  position
}

#