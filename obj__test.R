# 
# OOO Model
#
require(dplyr)
require(plotly)

setwd("C:\\Users\\Andrey\\Documents\\MyR\\PositiveDelta")
source_funs = lapply(as.list(dir(path='funs')), function(x) source(file = paste0('funs\\', x) ) )
rm(source_funs)

# Main logic
ul = 'SiZ9'

trades = GetTrades_fortsdb() %>% select(ticker, tradeprice, q, amount)
trades = DecodeTradesTickers(trades, 'forts') # TODO: function DefineOptParams (data.frame with tickers, by_ticker = T (F - from board))

# Create a portfolio, based on the trades
port = OptPort(ul='SiZ9', trades=trades, sum_trades=T, name='Spread')

# For now the market conditions are:
brd  = GetBoard_fortsdb(ul)
mrkt = OptMarket(ul = ul, 
                 ul_price = brd$ul_price, 
                 board = brd$board, 
                 now   = as.Date('2019-11-12'))


# Portfolio pricing
port = PortPricing(port, mrkt, price_at = 'theor')

port = PortValuation(port)

port$total_value

myprofile = OptProfile(optport  = port, 
                       if_dates = as.Date('2019-12-01'),
                       params   = c('pl', 'delta'), 
                       ul_range = 0.05) 

### PLOT PROFILE ###
gg1 = PlotProfile(myprofile)



### 
newtrade = data.frame(ul='SiZ9', ticker='Si63500BX9', xtype='p', strike=63500, expdate=as.Date('2019-12-19'), tradeprice=500, q=-1, amount=500 )

port2 = AddTrades(port = port, trades = newtrade, sum_trades = T)
port2$name = 'Changed'
port2 = PortPricing(port2, mrkt, price_at = 'theor')

port2 = PortValuation(port2)

port2$total_value

myprofile2 = OptProfile(optport  = port2, 
                       if_dates = as.Date('2019-12-01'),
                       params   = c('pl', 'delta'), 
                       ul_range = 0.05) 

PlotProfile(myprofile2)  %>% ggplotly(.)

gg2 = PlotProfile(myprofile2) 

profiles = JoinProfiles(list(myprofile, myprofile2))

View(profiles)

PlotProfile(profiles) %>% ggplotly(.)






### Pretty Trades DataTable

pretty_names = c('Ticker'='ticker', 
                 'Contract'='xtype', 
                 'Quant'='q', 
                 'Underly'='ul', 
                 'Expiry'='expdate', 
                 'Strike'='strike',
                 'Amount'='amount',
                 'Trade price'='tradeprice',
                 'Price'='price',
                 'IV'='iv',
                 'PnL'='pl',
                 'Delta'='delta'
                 )

t_names =names(trades)

#pretty_names[which(pretty_names=='ticker')]

trades %>% datatable( options = list(
  columnDefs = list(
    #list(className = 'dt-center', targets = which(t_names=='ticker')),
    list(title='Ticker', className = 'dt-center', targets = which(t_names=='ticker')),
    list(title='PnL', className = 'dt-center', targets = which(t_names=='pl')),
    list(title='PnL', className = 'dt-center', targets = which(t_names=='delta'))
  ), #columnDefs
  dom=''
  
 ) #options

)

