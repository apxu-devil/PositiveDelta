#' What if date or IV changes
#'
#' @param optmarket OptMarket-object constructor
#' @param ifdate a date to calculate for
#'
#' @return
#' Returns OptMarket object with changed date (and IV in future).
#' @export
#'
#' @examples
WhatIf = function(optmarket, ifdate = as.Date('2100-01-01')){ #IV_change=0.1
  
  optmarket$now = ifdate
  
  return(optmarket)
}
