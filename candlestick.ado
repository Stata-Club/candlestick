program define candlestick 
	version 14.0
	syntax varlist(min=5 max=5) [if] [in] using/, [replace line(string) linecolor(string) net]
	marksample touse, strok
	qui count if `touse'
	if `r(N)' == 0 exit 2000
	if !strpos(`"`using'"', ".") local using `"`using.html'"'

	if !ustrregexm(`"`using'"', "\.html$") {
		disp as error "the file generated must be a .html file"
		exit 198
	}
	
	if fileexists(`"`using'"') & "`replace'" == "" {
		disp as error "file `using' already exists"
		exit 602
	}
	else if fileexists(`"`using'"') {
		cap erase `"`using'"'
		if _rc != 0 {
			! del `"`using'"' /F
		}
	}
 	if "`linecolor'" == "" local linecolor "#aaa" 
 	local count = 0

	token `varlist'

	if "`line'" == "" {
		local line "``i''"
		scalar linenumber = 0
	}
	else {
		forvalues i = 2/5 {
			if "`line'" == "``i''"{
				scalar linenumber = `i'-2
			}
			else local count = `count' + 1
		}
		if `count' == 4 {
			disp as error "The `line' are not found"
			exit 101
		}

	}
	
	forvalues i = 1/1 {
		if !strpos(`"`: type ``i'''"', "str") {
			disp as error "type mismatch, ``i'' must be a string variable"
			exit 109
		}
	}
	forvalues i = 2/5 {
		if strpos(`"`: type ``i'''"', "str") {
			disp as error "type mismatch, ``i'' must be a numeric variable"
			exit 109
		}
	}

	
	if "`net'" == "" {
		if !ustrregexm(`"`using'"', "(/)|(\\)") {
			qui copy "`=c(sysdir_plus)'e/echarts.js" "./echarts.js", replace
			qui copy "`=c(sysdir_plus)'e/esl.js" "./esl.js", replace
			qui copy "`=c(sysdir_plus)'c/config.js" "./config.js", replace
			qui copy "`=c(sysdir_plus)'f/facePrint.js" "./facePrint.js", replace
			
		}
		else {
			if ustrregexm(`"`using'"', ".+((/)|(\\))") local path = ustrregexs(0)
			qui copy "`=c(sysdir_plus)'e/echarts.js" "`path'/echarts.js", replace
			qui copy "`=c(sysdir_plus)'e/esl.js" "`path'/esl.js", replace
			qui copy "`=c(sysdir_plus)'c/config.js" "`path'/config.js", replace
			qui copy "`=c(sysdir_plus)'c/facePrint.js" "`path'/facePrint.js", replace
		}
	}

	mata candlestick(`"`using'"')
	if ustrregexm(`"`using'"', ".+((/)|(\\))") local path = ustrregexs(0)
	local usings "`path'security.js"
	if fileexists(`"`usings'"') {
		cap erase `"`usings'"'
		if _rc != 0 {
			! del `"`usings'"' /F
		}
	}
	mata security("`usings'") 
end




cap mata mata drop security()
mata
	function security(string scalar fileusing) {

		real scalar outputmap
		real scalar i
		string matrix var1
		real matrix var2
		real matrix var3
		real matrix var4
		real matrix var5

		var1 = st_sdata(., (st_local("1")), st_local("touse"))
		var2 = st_data(., (st_local("2")), st_local("touse"))
		var3 = st_data(., (st_local("3")), st_local("touse"))
		var4 = st_data(., (st_local("4")), st_local("touse"))
		var5 = st_data(., (st_local("5")), st_local("touse"))
		outputmap = fopen(fileusing, "rw")
		fwrite(outputmap, sprintf(`"define([\r\n"'))
		for (i = 1; i <= rows(var1); i++) {
			if (i != rows(var1)) fwrite(outputmap, sprintf(`"\t['%s',%g,%g,%g,%g],\r\n"',var1[i],var2[i],var3[i],var4[i],var5[i]))
			else fwrite(outputmap, sprintf(`"\t['%s',%g,%g,%g,%g]\r\n"',var1[i],var2[i],var3[i],var4[i],var5[i]))
		}	
		fwrite(outputmap, sprintf(`"]);\r\n"'))
		fclose(outputmap)
	}
end







cap mata mata drop candlestick()
mata
    function candlestick(fileusing) {
        outputmap = fopen(fileusing, "rw")
		fwrite(outputmap, sprintf(`"<html>\r\n"'))
		fwrite(outputmap, sprintf(`"<head>\r\n"'))
		fwrite(outputmap, sprintf(`"<meta charset="utf-8">\r\n"'))
		fwrite(outputmap, sprintf(`"<meta name="viewport" content="width=device-width, initial-scale=1" />\r\n"'))
		fwrite(outputmap, sprintf(`"<script src="esl.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"<script src="config.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"<script src="./facePrint.js"></script>\r\n"'))
		fwrite(outputmap, sprintf(`"</head>\r\n"'))
		fwrite(outputmap, sprintf(`"<body>\r\n"'))
		fwrite(outputmap, sprintf(`"<style>\r\n"'))
		fwrite(outputmap, sprintf(`"html, body, #main {\r\n"'))
		fwrite(outputmap, sprintf(`"width: %s;\r\n"',"100%"))
		fwrite(outputmap, sprintf(`"height: %s;\r\n"',"100%"))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"</style>\r\n"'))
		fwrite(outputmap, sprintf(`"<div id="info"></div>\r\n"'))
		fwrite(outputmap, sprintf(`"<div id="main"></div>\r\n"'))
		fwrite(outputmap, sprintf(`"<script>\r\n"'))
		fwrite(outputmap, sprintf(`"var chart;\r\n"'))
		fwrite(outputmap, sprintf(`"var data;\r\n"'))
		fwrite(outputmap, sprintf(`"require([\r\n"'))
		fwrite(outputmap, sprintf(`"'echarts',\r\n"'))
		fwrite(outputmap, sprintf(`"'security'\r\n"'))
		fwrite(outputmap, sprintf(`"], function (echarts, rawData) {\r\n"'))
		fwrite(outputmap, sprintf(`"chart = echarts.init(document.getElementById('main'), null, {\r\n"'))
		fwrite(outputmap, sprintf(`"renderer: 'canvas'\r\n"'))
		fwrite(outputmap, sprintf(`"});\r\n"'))
		fwrite(outputmap, sprintf(`"data = splitData(rawData);\r\n"'))
		fwrite(outputmap, sprintf(`"update();\r\n"'))
		fwrite(outputmap, sprintf(`"chart.on('click', function (info) {\r\n"'))
		fwrite(outputmap, sprintf(`"console.log(info);\r\n"'))
		fwrite(outputmap, sprintf(`"if (info.data && info.data.length === 4) {\r\n"'))
		fwrite(outputmap, sprintf(`"alert([\r\n"'))
		fwrite(outputmap, sprintf(`"'clicked on: ',\r\n"'))
		fwrite(outputmap, sprintf(`"'DATA: ' + info.name,\r\n"'))
		fwrite(outputmap, sprintf(`"'OPEN: ' + info.data[0],\r\n"'))
		fwrite(outputmap, sprintf(`"'CLOSE: ' + info.data[1],\r\n"'))
		fwrite(outputmap, sprintf(`"'LOWEST: ' + info.data[2],\r\n"'))
		fwrite(outputmap, sprintf(`"'HIGHEST: ' + info.data[3]\r\n"'))
		fwrite(outputmap, sprintf(`"].join('\\n'));\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"else if (info.data && info.data.length === 2) {\r\n"'))
		fwrite(outputmap, sprintf(`"alert('mark point');\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"});\r\n"'))
		fwrite(outputmap, sprintf(`"})\r\n"'))
		fwrite(outputmap, sprintf(`"function splitData(rawData) {\r\n"'))
		fwrite(outputmap, sprintf(`"var categoryData = [];\r\n"'))
		fwrite(outputmap, sprintf(`"var values = []\r\n"'))
		fwrite(outputmap, sprintf(`"for (var i = 0; i < rawData.length; i++) {\r\n"'))
		fwrite(outputmap, sprintf(`"categoryData.push(rawData[i].splice(0, 1)[0]);\r\n"'))
		fwrite(outputmap, sprintf(`"values.push(rawData[i])\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"return {\r\n"'))
		fwrite(outputmap, sprintf(`"categoryData: categoryData,\r\n"'))
		fwrite(outputmap, sprintf(`"values: values\r\n"'))
		fwrite(outputmap, sprintf(`"};\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"function parseDate(timestamp) {\r\n"'))
		fwrite(outputmap, sprintf(`"var date = new Date(timestamp);\r\n"'))
		fwrite(outputmap, sprintf(`"return date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"function update() {\r\n"'))
		fwrite(outputmap, sprintf(`"chart.setOption({\r\n"'))
		fwrite(outputmap, sprintf(`"legend: {\r\n"'))
		fwrite(outputmap, sprintf(`"data: ['上证指数', '%s']\r\n"',st_local("line")))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"tooltip: {\r\n"'))
		fwrite(outputmap, sprintf(`"trigger: 'axis',\r\n"'))
		fwrite(outputmap, sprintf(`"axisPointer: {\r\n"'))
		fwrite(outputmap, sprintf(`"type: 'line'\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"grid: {\r\n"'))
		fwrite(outputmap, sprintf(`"left: '%s',\r\n"',"10%"))
		fwrite(outputmap, sprintf(`"right: '%s',\r\n"',"10%"))
		fwrite(outputmap, sprintf(`"bottom: '%s'\r\n"',"15%"))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"xAxis: {\r\n"'))
		fwrite(outputmap, sprintf(`"type: 'category',\r\n"'))
		fwrite(outputmap, sprintf(`"data: data.categoryData,\r\n"'))
		fwrite(outputmap, sprintf(`"scale: true,\r\n"'))
		fwrite(outputmap, sprintf(`"boundaryGap : false,\r\n"'))
		fwrite(outputmap, sprintf(`"axisLine: {onZero: false},\r\n"'))
		fwrite(outputmap, sprintf(`"splitLine: {show: false},\r\n"'))
		fwrite(outputmap, sprintf(`"splitNumber: 20,\r\n"'))
		fwrite(outputmap, sprintf(`"min: 'dataMin',\r\n"'))
		fwrite(outputmap, sprintf(`"max: 'dataMax'\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"yAxis: {\r\n"'))
		fwrite(outputmap, sprintf(`"scale: true,\r\n"'))
		fwrite(outputmap, sprintf(`"splitArea: {\r\n"'))
		fwrite(outputmap, sprintf(`"show: true\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"dataZoom: [\r\n"'))
		fwrite(outputmap, sprintf(`"{\r\n"'))
		fwrite(outputmap, sprintf(`"type: 'inside',\r\n"'))
		fwrite(outputmap, sprintf(`"start: 50,\r\n"'))
		fwrite(outputmap, sprintf(`"end: 100\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"{\r\n"'))
		fwrite(outputmap, sprintf(`"show: true,\r\n"'))
		fwrite(outputmap, sprintf(`"type: 'slider',\r\n"'))
		fwrite(outputmap, sprintf(`"y: '%s',\r\n"',"90%"))
		fwrite(outputmap, sprintf(`"start: 50,\r\n"'))
		fwrite(outputmap, sprintf(`"end: 100\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"],\r\n"'))
		fwrite(outputmap, sprintf(`"series: [\r\n"'))
		fwrite(outputmap, sprintf(`"{\r\n"'))

		fwrite(outputmap, sprintf(`"name: '%s',\r\n"',st_local("line")))
		fwrite(outputmap, sprintf(`"type: 'line',\r\n"'))
		fwrite(outputmap, sprintf(`"data: (function () {\r\n"'))
		fwrite(outputmap, sprintf(`"opens = [];\r\n"'))
		fwrite(outputmap, sprintf(`"for (var i = 0, len = data.values.length; i < len; i++) {\r\n"'))
		fwrite(outputmap, sprintf(`"opens.push(data.values[i][%g]);\r\n"',st_numscalar("linenumber")))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"return opens;\r\n"'))
		fwrite(outputmap, sprintf(`"})(),\r\n"'))
		fwrite(outputmap, sprintf(`"smooth: true,\r\n"'))
		fwrite(outputmap, sprintf(`"lineStyle: {\r\n"'))
		fwrite(outputmap, sprintf(`"normal: {color: '%s'}\r\n"',st_local("linecolor")))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"{\r\n"'))
		fwrite(outputmap, sprintf(`"name: '上证指数',\r\n"'))
		fwrite(outputmap, sprintf(`"type: 'candlestick',\r\n"'))
		fwrite(outputmap, sprintf(`"data: data.values,\r\n"'))
		fwrite(outputmap, sprintf(`"tooltip: {\r\n"'))
		fwrite(outputmap, sprintf(`"formatter: function (param) {\r\n"'))
		fwrite(outputmap, sprintf(`"var param = param[0];\r\n"'))
		fwrite(outputmap, sprintf(`"return [\r\n"'))
		fwrite(outputmap, sprintf(`"'%s：' + param.name + '<hr size=1 style="margin: 3px 0">',\r\n"',st_local("1")))
		fwrite(outputmap, sprintf(`"'%s：' + param.data[0] + '<br/>',\r\n"',st_local("2")))
		fwrite(outputmap, sprintf(`"'%s：' + param.data[1] + '<br/>',\r\n"',st_local("3")))
		fwrite(outputmap, sprintf(`"'%s：' + param.data[2] + '<br/>',\r\n"',st_local("4")))
		fwrite(outputmap, sprintf(`"'%s：' + param.data[3] + '<br/>'\r\n"',st_local("5")))
		fwrite(outputmap, sprintf(`"].join('')\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"markPoint: {\r\n"'))
		fwrite(outputmap, sprintf(`"data: [           \r\n"'))
		fwrite(outputmap, sprintf(`"{\r\n"'))
		
		fwrite(outputmap, sprintf(`"label: {\r\n"'))
		fwrite(outputmap, sprintf(`"normal: {\r\n"'))
		fwrite(outputmap, sprintf(`"show: false\r\n"'))
		fwrite(outputmap, sprintf(`"},\r\n"'))
		fwrite(outputmap, sprintf(`"emphasis: {\r\n"'))
		fwrite(outputmap, sprintf(`"show: true,\r\n"'))
		fwrite(outputmap, sprintf(`"position: 'top',\r\n"'))
		fwrite(outputmap, sprintf(`"formatter: 'zxcv'\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},        \r\n"'))
		fwrite(outputmap, sprintf(`"],\r\n"'))
		fwrite(outputmap, sprintf(`"tooltip: {\r\n"'))
		fwrite(outputmap, sprintf(`"formatter: function (param) {\r\n"'))
		fwrite(outputmap, sprintf(`"return param.name + '<br>' + (param.data.coord || '');\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"},   \r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"]\r\n"'))
		fwrite(outputmap, sprintf(`"});\r\n"'))
		fwrite(outputmap, sprintf(`"}\r\n"'))
		fwrite(outputmap, sprintf(`"</script>\r\n"'))
		fwrite(outputmap, sprintf(`"</body>\r\n"'))
		fwrite(outputmap, sprintf(`"</html>\r\n"'))
    }
end
