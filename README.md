# candlestick
candlestick: draw a candlestick chart.


`29Dec2017`

`Stata-Club`



candlestick requires five variables, the date, the opening price, the closing price, the lowest price, the highest price.In addition to the date is the character type, the other is numeric type.candlestick can draw a candlestick chart on the web page.
In addition, candlestick can also draw the opening price, closing price, the lowest price and the highest price line chart.



## Options for candlestick


`replace` permits to overwrite an existing file.


`line(string)` specify which line chart to draw, in which there is opening price, closing price, lowest price, highest price.The opening price is the default.

`linecolor(string)` specifies the color of the line drawing.

`net` move the necessary files from disk c to the specified path.


## Example

Download the daily transaction data of deep vanke A

```
clear

cntrade 000002


//Turn dates into characters

local year =year(date)
local month =month(date)
local day =day(date)

gen date1 = "`year'" + "-" + "`month'" + "-" + "`day'""


//draw a candlestick chart 

candlestick date1 opnprc clsprc lowprc hiprc using 14.html,replace line(opnprc) linecolor(#87CEEB)



```

## Author

{pstd}Chuntao LI{p_end}

{pstd}China Stata Club(爬虫俱乐部){p_end}

{pstd}Wuhan, China{p_end}

{pstd}chtl@zuel.edu.cn{p_end}

--------

{pstd}Ming WANG{p_end}

{pstd}China Stata Club(爬虫俱乐部){p_end}

{pstd}Wuhan, China{p_end}

{pstd}18895616030@163.com{p_end}

