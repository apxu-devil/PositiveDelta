# Update function

#update_df(xtrades, brd, 'ticker', c('price2','price3') )

update_df = function(df, new_data, key_column, cols_to_update, cols_w_data=cols_to_update){
  # cols_to_update = 'price' # Columns names to be matched, must have in both DF
  # key_column = 'ticker'  # Column name the DFs are matched by 
  ### Add columns for refresh, if no such
  empty_cols_names =cols_to_update[ which( !( cols_to_update %in% names(df) ) ) ] # Column to update not in dataframe 
  
  df[, empty_cols_names] = NA
  
  
  if(length(cols_to_update)!=length(cols_w_data) )
    stop('Columns with data and update differ in number')
  
  rows_with_data = match( df[[key_column]], new_data[[key_column]]) # row numbers in new_data, which coerse with key values in existing DF 
  
  rows_to_update = which(!is.na(rows_with_data))# only matching tickers will be updates (if no this, uknow key will have NA data)
  rows_with_data = rows_with_data[!is.na(rows_with_data)]
  
  # df[prices_row, cols_to_update]  # test data selection
  
  # brd[rows_with_data, cols_to_update] # test data
  
  df[rows_to_update, cols_to_update]  = new_data[rows_with_data, cols_w_data]
  
  return(df)
}
