{smcl}
{* 29Dec2017}{...}
{hi:help candlestick}
{hline}

{title:Title}

{phang}
{bf:candlestick} {hline 2} draw a candlestick chart.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:candlestick} {it:varlist} {ifin} {it:using filename} {cmd:,} [{it:options}]

{marker description}{...}
{title:Description}

{pstd}
{cmd:candlestick} requires five variables, the date, the opening price, the closing price, the lowest price, the highest price.In addition to the date is the character type, the other is numeric type.{cmd:candlestick} can draw a candlestick chart on the web page.
In addition, {cmd:candlestick} can also draw the opening price, closing price, the lowest price and the highest price line chart.{p_end}


{marker options}{...}
{title:Options for candlestick}

{phang}
{opt replace} permits to overwrite an existing file. {p_end}

{phang}
{opt line(string)} specify which line chart to draw, in which there is opening price, closing price, lowest price, highest price.The opening price is the default. {p_end}

{phang}
{opt linecolor(string)} specifies the color of the line drawing. {p_end}

{phang}
{opt net} move the necessary files from disk c to the specified path. {p_end}
{marker example}{...}
{title:Example}

{pstd}Download the daily transaction data of deep vanke A

{phang}
{stata `"clear"'}
{p_end}

{phang}
{stata `"cntrade 000002"'}
{p_end}

{pstd}Turn dates into characters

{phang}
{stata `"local year =year(date)"'}
{p_end}

{phang}
{stata `"local month =month(date)"'}
{p_end}

{phang}
{stata `"local day =day(date)"'}
{p_end}

{phang}
{stata `"gen date1 = "`year'" + "-" + "`month'" + "-" + "`day'""'}
{p_end}

{pstd}draw a candlestick chart 

{phang}
{stata `"candlestick date1 opnprc clsprc lowprc hiprc using 14.html,replace line(opnprc) linecolor(#87CEEB)"'}
{p_end}

{title:Author}

{pstd}Chuntao LI{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Ming WANG{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}18895616030@163.com{p_end}

