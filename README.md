---
title: "PositiveDelta Engine"
author: "ArkhipovAA"
date: '17 декабря 2019 г '
output: 
  html_document: 
    toc: true
    highlight: tango
---

```{r setup, echo=FALSE, warning=FALSE, message=FALSE}
#knitr::opts_chunk$set(echo = FALSE)

require(dplyr)
require(plotly)
require(DT)
require(knitr)

source_funs = lapply(as.list(dir(path='funs')), function(x) source(file = paste0('funs\\', x) ) )
rm(source_funs)

```

# Описание

Механизм OptionProfile позволяет анализировать портфели опционов: стоить профили портфелей, сравнивать их, расчитывать сценарии на изменение срока до экспирации и волатильности.

Портфель и текущие цены могут быть загружены из любого источника (база, эксель, торговый терминал).
Для применения механизма, эти данные должны иметь определённую структуру. 

Фреймворк использует несколько основных объектов:

* `OptPort` - портфель опционов;

* `OptMarket` - текущее состояние рынка;

* `OptProfile` - профиль портфеля.
  

# Исходные данные

## Портфель OptPort

Портфель опционов состоит из сделок с опционами и базовым активом, которые суммируются в общую позицию.

```{r load_trades,warning=FALSE, message=FALSE}

ul = 'SiZ9'
trades = GetTrades_fortsdb() %>% select(ticker, tradeprice, q, amount)
trades = DecodeTradesTickers(trades, 'forts')

#kable(trades)

```

`r kable(trades)`

На основании сделок создаём объект OptPort:

* `ul` - тикер базисного актива (обязательно)

* `trades` - таблица сделок с обязательными полями ticker, xtype, strike, expdate, tradeprice, q ;

* `sumtrades` - сальдировать сделки (только уникальные контракты в позиции) или добавить в позицию как есть;

* `name` - имя портфеля (опционально, нужно для идентификации портфеля в случае сравнения нескольких)

```{r make_port, warning=FALSE, message=FALSE}

port = OptPort(ul = 'SiZ9', 
               trades = trades, 
               sum_trades = T, 
               name = 'Spread')

port

```


Псосле создания объект содержит поля:

* name - наименование портфеля;

* ul - тикер базисного актива;

* position - портфель опционов и базисного актива;

* trades - сделки, на основании которых была сформирована позиция.

При создании объекта, проверяется наличие наобходимых полей в таблице сделок trades, типы полей и т.д.


## Рыночные цены - OptMarket

Рыночные данные хранятся в объекте класса OptMarket. Без рыночных цен портфель переоценивается только по его внутренней стоимости.

Объект OptMarket (наследует от list) содержит информацию о текущих котировках опционов и базисном активе:

* `board` - доска опционов, минимально необходимые поля - ticker, price;

* `ul` - тикер базисного актива;

* `ul_price` - цена базисного актива;

* `now` - текущая дата.

```{r make_mrkt, warning=FALSE, message=FALSE}

brd  = GetBoard_fortsdb2(ul)
mrkt = OptMarket(ul = ul, 
                 ul_price = brd$ul_price, 
                 board = brd$board, 
                 now   = as.Date('2019-11-12'))

head(mrkt$board)
```


# Анализ портфеля

## Оценка портфеля
Функция PortPricing связывает портфель и рыночные данные. Она добавляет цены и волатильность к позиции. На их основе проходит переоценка портфеля и рачёт профиля.

```{r price_port, warning=FALSE, message=FALSE}
port = PortPricing(port, mrkt, price_at = 'theor')
```

price_at - тип цены для переоценки портфеля. Это префикс названия колонки цены или волатильности в OptMarket$board. 

## Прибыль и "греки" 
Функция PortValuation расчитывает параменты портфеля по текущим ценам. 
Результаты сохраняются в поле total_value объекта OptPort. 

```{r value_port, warning=FALSE, message=FALSE}
port = PortValuation(port)

port$total_value
```

## Профиль портфеля - OptProfile

Профиль портфеля опционов - основной инструмент анализа. 
В классическом варинате, он отражает зависимость прибыли и "греков" портфеля от цены базисного актива.

Объект OptProfile содержит профиль портфеля на интервале цен базисного актива.

Функция PlotProfile строит график профиля на базе ggplot2.


```{r calc_profile, warning=FALSE , message=FALSE, fig.width=5, fig.height=2, fig.align='center' }
myprofile = OptProfile(optport  = port, 
                       params   = c('pl', 'delta'), 
                       ul_range = 0.05) 

PlotProfile(myprofile)
```



# Анализ сценариев

Механизм позволяет вносить изменения в портфель, сравнивать несколько портфелей с одним базисным активом, а также использовать сценарии What-if для разных сроков до погашения или изменения волательности.


## Манипуляции с портфелем

Новые сделки можно добавлять в портфель функцией AddTrades:

* port - портфель (объект OptPort), в которые добавить сделку;

* trades - dataframe со сделками;

* sum_trades - расчитывать чистую позицию из сделок; если FALSE - новая сделка появится в позиции отдельной строкой.

```{r add_trade, warning=FALSE, message=FALSE}
newtrade = data.frame(ul='SiZ9', 
                      ticker='Si63500BX9', 
                      xtype='p', 
                      strike=63500, 
                      expdate=as.Date('2019-12-19'), 
                      tradeprice=500, 
                      q=-1 )

port2 = AddTrades(port = port, 
                  trades = newtrade, 
                  sum_trades = T)

port2
```


После внесения изменений в портфель, можно сравнить профили старого и нового портфелей. 
Функция JoinProfiles объединяет данные профилей для построения общего графика.
Первый профиль в списке - приоритетный. 

```{r compare_profiles}
port2 = port2 %>% PortPricing(., mrkt, price_at = 'theor') %>% PortValuation(.)

myprofile2 = OptProfile(optport  = port2, 
                       params   = c('pl', 'delta'), 
                       ul_range = 0.05) 

profiles = JoinProfiles(list(myprofile, myprofile2))

PlotProfile(profiles)
```




## What if (Что если)
