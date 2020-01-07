#
# Remove pricing and valuation from position
#
ResetPricing = function(optport){
 
  
  # Get columns othen, than valuation and pricing columns
  to_stay= !(names(optport$position) %in% c('pl','delta','gamma','vega','theta','now','tilexp','iv','price','pricetype','ul_price'))
  
  optport$position  = optport$position[,to_stay]
  optport$ul_price = NA
  optport$now = NA
  return(optport)
  
}


### PORTFOLIO PRICING ###
# Add data frame with prices, volatility and date
# rpice_at - price type for portfolio valuation

PortPricing = function(optport, 
                       optmarket, 
                       price_at = '', 
                       calc_iv  = F)
{
 
  optport = ResetPricing(optport)
  #TODO: calc inner option prices for iv=0 or empty board
  
  # If market data exists
  # TODO: if no board, set iv=0, calc inner prices
  
  # Get portfolio position
  position = optport$position
  
  # Get current date
  now = optmarket$now
  ul_price = optmarket$ul_price
  
  
  # Find tickers in position
  tickers = unique(position$ticker)
  
  # Select price and iv columns from market board
  if(price_at=='') sep='' else sep='.'
  
  board_prices = optmarket$board %>% 
    dplyr::filter(ticker %in% tickers) %>% 
    dplyr::select(ticker, matches(paste0('price', sep, price_at) ) ) 
  
  # Return error if no price or iv column found
  # If the selection is done well, only 2 columns (ticker and price.) will be selected
  if(length(board_prices)==2)
  {

    # Rename price.price_at column to price
    board_prices = board_prices %>% rename(price = paste0('price', sep, price_at) )
    
    # Add new prices to position dataframe
    position = left_join(position, board_prices, by='ticker')
    
    #Calculate IV for the market price
    position = CalcIV(position, optmarket$ul_price, optmarket$now)
    
  } else {
    
    board_prices = optmarket$board %>% 
    filter(ticker %in% tickers) %>% 
    select(ticker, matches(paste0('iv', sep, price_at) ) ) 
    
    # Return error if no price or iv column found
    if(length(board_prices)==1)
      stop('No price or iv columns in Market $ Board dataframe found')
    
    #TODO: calc option prices based on iv
  }

  
  # Add pricing data to port
  optport$ul_price = ul_price
  optport$now = now
  #optport$board = board_prices
  optport$position = position
  optport$total_value = NA
  
  
  return(optport)
}


### PORTFOLIO VALUATION

PortValuation = function(optport, params = c('pl', 'delta' ,'gamma', 'theta', 'vega'))
{
 
    # Variables
   position = optport$position
   ul_price = optport$ul_price
   now = optport$now
   
   position[, params] = NA
   
   # Calc params for each option      
   position = Params(port = position, 
                     ba = ul_price, 
                     params = params, 
                     now = now)    
   
   position = position %>% mutate(pl = case_when(q==0 ~ amount, q!=0 ~ pl))
   
   # Calc sum of all params
   total_value = position %>% summarize(
     pl=sum(pl),  
     delta = sum(delta), 
     gamma=sum(gamma), 
     theta=sum(theta), 
     vega=sum(vega)
   )

   # Add Total row as a tickered row 
   total_value$ticker='Total'
   
   # Save position
   optport$position = position
   
   # Save total params
   optport$total_value = total_value %>% select(ticker,1:6)
   
  return(optport)
}




#
#' OptProfile-class constructor
#'
#' @param optport OptPort-class object
#' @param optmarket OptMarket-class object
#' @param ul_range underlying values range
#' @param params portfolio parametres vector to calculate: pl, delta, gamma, theta, vega
#'
#' @return
#' Function returns OptProfile-class object. Portfolio and market data are stored inside.
#' @export
#'
#' @examples
#' 
OptProfile = function(optport, 
                      ul_range = 0.05, 
                      params   = 'pl', 
                      if_dates = NULL, 
                      descr = '')
  {
  
  optprofile = structure(list(), class='OptProfile')
  
  # Variables
  position = optport$position
  
  if(!is.null(optport$ul_price) || !is.na(optport$ul_price))
    ul_price = optport$ul_price
  else
    ul_price = NA
  
  if(!is.null(optport$now) || !is.na(optport$now))
    now = optport$now
  else
    now = NA
  
  
  ul_array = UnderlyingRange(ports=position, range=ul_range)
  
  ### ONLY IF MARKET EXISTS
  at_dates = NearestExpiry(position)
  
  if(!is.null(now))
    at_dates = c(now, at_dates, if_dates)
  
  profile = ProfileAtDates( port = optport$position, 
                                       ba_values = ul_array,
                                       params = params, 
                                       dates = at_dates
                                      )
  
  if(descr!='')
    {
      descr = as.character(descr)
      profile$descr = descr
  }
  
  # Add portfolio name
  if(isEmpty(port$name))
    profile$port = 'Primary'
  else
    profile$port = port$name
  
  # Output  
  optprofile$profile  = profile
  optprofile$now      = now
  optprofile$ul_price = ul_price
  
  # Market condition
  # if(!is.null(optmarket))
  # optprofile$market = optmarket

  return(optprofile)
}




#' Test OptProfile class
#'
#' @param x OptProfile-class object
#'
#' @return
#' True / False if the input is the OptProfile class object.
#' @export
#'
#' @examples
is.OptProfile = function(x){
  if(class(x)=='OptProfile') return(TRUE) else return(FALSE)
}




