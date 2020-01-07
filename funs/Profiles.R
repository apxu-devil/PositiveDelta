#
# Makes profile table for options portfolio.
# 
# 

# Profile_params
Profile = function(port, ba_values, params=c('pl', 'delta'),now=Sys.Date()){
  
  # Create empty result dataframe
  alldata = data.frame()
  
  # Calculate profile for every given parametre (pl or greek)
  for (param in params){
    
    data = PortPL(port, ba_values, param, now=now)
    data$param  = param 
    
    alldata = rbind(alldata, data)
  }
  
 return(alldata)
}



#
# Makes profile table at multiple dates 
#
#Profile_dates
ProfileAtDates = function(port, ba_values, params=c('pl', 'delta'), dates=NULL){
  

  alldata = data.frame()
  
  if(is.null(dates))
    dates = Sys.Date()
  
  for(n in c(1:length(dates)) ){
    
    now = dates[n]
    
    data = Profile(port, ba_values, params, now)
    data$at_date = now
    
    alldata = rbind(alldata, data)
  }
  
  return(alldata)
}



#
# Make profile table  for multiple portfolios
# range_type: percent, values
# Profile_ports
MultipleProfile = function(ports, ba_range=0.05, params=c('pl', 'delta'),dates=Sys.Date(), range_type='percent'){
  
  # Calculate points for profile calculation, if no points
  if( range_type=='percent' ) {
    ba_values=UnderlyingRange(ports,ba_range) }
  else {
    ba_values=ba_range }
  
  # Create empty result dataframe
  alldata = data.frame()
  
  # Make portfolio names as number in list if they are not named
  if(is.null(names(ports)))
    names(ports) = c(1:length(ports))
  
  # Calc profile for every portfolio
  for(n in c(1:length(ports)) ){
    
    port = ports[[n]]

    
    if(!is.null(port)){
      data = ProfileAtDates(port, ba_values, params, dates)
      
      if(names(ports)[n]==''){
        
        portname = paste0('port',n)
      }else{
        
        portname = names(ports)[n]
      }
      
      data$port = portname
      alldata = rbind(alldata, data) 
    }

  }
  
  return(alldata)
}

