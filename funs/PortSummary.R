

#
# PORTFOLIO SUMMARY
#

PortSummary = function(optport, optmrkt){
  browser()
  require(dplyr)
  
  optport = RefreshPositionPricing(optport, optmrkt, refreshmethod = 2)
  
  optport$position = CalcIV( board =optport$position, 
                             ul_price =optmrkt$ul_price, 
                             now =optmrkt$now
  )
  
  porttotal = Params(port = optport$position, 
                     ba = optmrkt$ul_price, 
                     params = c('pl', 'delta' ,'gamma', 'theta', 'vega'), 
                     now = optmrkt$now)
  
  
  smry = summarise(porttotal, pl=sum(pl), delta = sum(delta), theta=sum(theta), vega=sum(vega))
  
  list(porttotal, smry)
  
}

# PortSummary(optport, simrkt6)
