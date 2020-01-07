#' Plots option portfolio profile chart
#'
#' @param optprofile OptProfile-class object
#' @param optmarket OptMarket-class object
#'
#' @return
#' Builds ggplot option portfolio profile chart
#' @export
#'
#' @examples
PlotProfile = function(optprofile, optmarket=NULL){
  
  require(ggplot2)
  
  # Main dataframe
  plot_data = optprofile$profile
 
  # Date to factor for proper alpha
  unique_dates = unique(plot_data$at_date)
  factors = as.character( sort(unique_dates))
  plot_data$at_date = factor(plot_data$at_date, levels = (factors))
  
  #Parameter name as factor
  plot_data$param = factor(plot_data$param, 
                           levels = c('pl', 'delta', 'gamma', 'theta', 'vega'), 
                           labels= c('PnL', 'Delta', 'Gamma', 'Theta', 'Vega') )
  
  # Add portfolio name column
  if(is.null(plot_data$port))
    plot_data$port = "Primary"
  
  # Main plot
  gg = tryCatch(ggplot(data=plot_data, aes(x=ba, y=total, alpha=at_date, color=port)) + 
                  geom_hline(yintercept = 0, linetype='dotted', alpha=0.5)  +
                  geom_line(size=1)+
                  facet_wrap(~param, scales = 'free') +
                  scale_alpha_manual(guide = guide_legend(reverse = T, title = 'Observation \ndate'), 
                                     values = seq(from=1, to=0.3, length.out = length(unique_dates) )) +
                  scale_color_discrete(guide = guide_legend(title = 'Portfolio')) + 
                  xlab(NULL) + ylab(NULL)
                
  , error = function(e){ 
                  print(paste0('DrawChart error: ', e)) 
    }
  )
  

  # Get ul price
  if(is.null(optmarket))
    ul_price = optprofile$ul_price
  else
    ul_price = optmarket$ul_price
  
  # Add vertical ul price line
  gg = gg + geom_vline(xintercept=ul_price)
  
  return(gg)
  
}
