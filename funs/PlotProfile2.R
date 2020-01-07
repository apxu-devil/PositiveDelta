

PlotProfile2 = function(optprofile, optmarket=NULL){
  require(ggplot2)
  
  plot_data = optprofile$profile
  
  ul_price = NULL
  
  if(!is.null(optmarket))
    ul_price = optmarket$ul_price
  
  gg = DrawChart(plot_data, ul_price)
  
  #plot_data$at_date = as.factor(plot_data$at_date)
  
  # gg = tryCatch(ggplot(data=plot_data, aes(x=ba, y=total)) + #, alpha=at_date, color=port)) + 
  #                 geom_line(size=1)+
  #                 facet_wrap(~param, scales = 'free') +
  #                 geom_hline(yintercept = 0, linetype='dotted') # +
  #               #scale_alpha_discrete(range = c(1, 0.3)), error = function(e){print(paste0('DrawChart error: ', e)) }
  # )
  # 
  # ba_price = optmarket$ul_price
  # # if(!is.null(ba_price) && !is.na(ba_price))
  # gg = gg + geom_vline(xintercept=ba_price)
  
  return(gg)
  
}
