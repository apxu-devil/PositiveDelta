#
#  Function returns parameter for each contract in the port
#

Params = function(port, params='pl', ba, now){
  
  trueparams = c('pl','delta','gamma','vega','theta')
  
  for (param in trueparams) {
    
    if(param %in% trueparams){
      
      #vals = port %>% PortPL(ba, param, total_only=F, now=now) %>% select(-c(ba, total)) %>% unlist(use.names = F)
      
      vals =  PortPL(port, ba, param, total_only=F, now=now)
      vals = vals %>% select(-c(ba, total))
      vals = vals %>% unlist(use.names = F)
      
      port[[param]] = signif(vals, 4)
    }
    
  }
  
  return(port)
  
}
