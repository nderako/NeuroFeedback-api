<!doctype html>
<html>
<head>
	<meta name="layout" content="main"/>
</head>
<body>
<content tag="nav">
	<li class="dropdown">
		<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Application Status <span class="caret"></span></a>
		<ul class="dropdown-menu">
			<li><a href="#">Environment: ${grails.util.Environment.current.name}</a></li>
			<li><a href="#">App profile: ${grailsApplication.config.grails?.profile}</a></li>
			<li><a href="#">App version:
				<g:meta name="info.app.version"/></a>
			</li>
			<li role="separator" class="divider"></li>
			<li><a href="#">Grails version:
				<g:meta name="info.app.grailsVersion"/></a>
			</li>
			<li><a href="#">Groovy version: ${GroovySystem.getVersion()}</a></li>
			<li><a href="#">JVM version: ${System.getProperty('java.version')}</a></li>
			<li role="separator" class="divider"></li>
			<li><a href="#">Reloading active: ${grails.util.Environment.reloadingAgentEnabled}</a></li>
		</ul>
	</li>
	<li class="dropdown">
		<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Artefacts <span class="caret"></span></a>
		<ul class="dropdown-menu">
			<li><a href="#">Controllers: ${grailsApplication.controllerClasses.size()}</a></li>
			<li><a href="#">Domains: ${grailsApplication.domainClasses.size()}</a></li>
			<li><a href="#">Services: ${grailsApplication.serviceClasses.size()}</a></li>
			<li><a href="#">Tag Libraries: ${grailsApplication.tagLibClasses.size()}</a></li>
		</ul>
	</li>
	<li class="dropdown">
		<a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false">Installed Plugins <span class="caret"></span></a>
		<ul class="dropdown-menu">
			<g:each var="plugin" in="${applicationContext.getBean('pluginManager').allPlugins}">
				<li><a href="#">${plugin.name} - ${plugin.version}</a></li>
			</g:each>
		</ul>
	</li>
</content>

<div class="row">
	<div class="col-md-12">
		<div class="row">
			<h1>NeuroCare</h1>
		</div>
		<div class="row">
            <div id="containerMain" style="height: 350px"></div>
			<div class="column">
				<div id="container1" style="height: 250px; width: 550px; display: inline-block"></div>
				<div id="container2" style="height: 250px; width: 550px; display: inline-block"></div>
			</div>
			<div class="column">
				<div id="container3" style="height: 250px; width: 550px; display: inline-block"></div>
				<div id="container4" style="height: 250px; width: 550px; display: inline-block"></div>
			</div>
			<div class="column">
				<div id="container5" style="height: 250px; width: 550px; display: inline-block"></div>
				<div id="container6" style="height: 250px; width: 550px; display: inline-block"></div>
			</div>
			<div class="column">
				<div id="container7" style="height: 250px; width: 550px; display: inline-block"></div>
				<div id="container8" style="height: 250px; width: 550px; display: inline-block"></div>
			</div>
		</div>
	</div>
</div>
<script src="https://code.highcharts.com/highcharts.js"></script>

<script type="text/javascript">

    /** ******************************************************************** **/
    /**              Creating high chart for EEG data                        **/
    /** ******************************************************************** **/

    function createAjax(series, channel_number) {
        setInterval(function () {
            $.ajax({
                url: '/liveTreatment/data/${params.id}?channel=' + channel_number,
                type: 'get',
                success: function (json) {
                    var source = json.sourceData;
                    series.setData(source, true, false, false);
                }
            });
        }, 1000);
    }

    Highcharts.chart('containerMain', {
        chart: {
            backgroundColor: 'transparent',
            type: 'spline',
            animation: Highcharts.svg,
            marginRight: 10,
            events: {
                load: function () {
                    for(var i = 0; i < ${analyzedDatasCount}; i++) {
                        createAjax(this.series[i], i)
                    }
                }
            }
        },
        title: {
            text: 'Real time EEG'
        },
        xAxis: {
            tickAmount: 100,
            type: 'datetime'
        },
        yAxis: {
            title: {
                text: 'Hz'
            },
            plotLines: [{
                value: 0,
                width: 1,
                color: '#808080'
            }]
        },
        tooltip: {
            formatter: function () {
                return '<b>' + this.series.name + '</b><br/>' +
                    Highcharts.dateFormat('%Y-%m-%d %H:%M:%S', this.x) + '<br/>'
                    +
                    Highcharts.numberFormat(this.y, 2);
            }
        },
        legend: {
            enabled: false
        },
        exporting: {
            enabled: false
        },
        series: getSeries()
    });

    function getSeries() {
        var series = [];

        for(var k = 1; k <= ${analyzedDatasCount}; k++){
            series.push({
                name: 'channel ' + k,
                data: (function () {
                    var data = [],
                        time = (new Date()).getTime(),
                        i;

                    for (i = -10; i <= 0; i += 1) {
                        data.push({
                            x: time + i * 1000,
                            y: k
                        });
                    }
                    return data;
                }()),
                turboThreshold: 10000000
            });
        }

        return series;
    }

    /** ******************************************************************** **/
    /**              Creating high chart for analyzed data                   **/
    /** ******************************************************************** **/

    createHighCharts(${analyzedDatasCount});

    function createHighCharts(quantity) {

        for (var i = 1; i <= quantity; i++) {
            createHighChart(i);
        }
    }

    function createHighChart(channel_number) {
        Highcharts.chart('container' + channel_number, {
            chart: {
                type: 'line',
                backgroundColor: 'transparent',
                animation: false,
                events: {
                    load: function () {
                        var chart = this;
                        setInterval(function () {
                            $.ajax({
                                url: '/liveTreatment/data/${params.id}?channel=' + channel_number,
                                type: 'get',
                                success: function (json) {

                                    var powerBand = json.powerBand;

                                    chart.legend.update(getLegend(powerBand.totalPower, powerBand.alphaPower,
                                        powerBand.betaPower, powerBand.deltaPower, powerBand.thetaPower));

                                    chart.series[0].update({
                                        data: (function () {
                                            var data = [], i;
                                            for (i = 0; i < json.spd.length; i += 1) {
                                                data.push({
                                                    x: json.frequencies[i],
                                                    y: json.spd[i]
                                                });
                                            }
                                            return data;
                                        }()),
                                        turboThreshold: json.spd.max
                                    }, true, true);
                                }
                            });
                        }, 1000);
                    }
                }
            },
            title: {
                text: 'Analyzed Data ch' + channel_number
            },
            xAxis: {
                title: {
                    text: 'Frequency [Hz]'
                }
            },
            yAxis: {
                title: {
                    text: 'Power Spectral Density [μV²/HZ]'
                },
                plotLines: [{
                    value: 0,
                    width: 1,
                    color: '#808080'
                }]
            },
            legend: getLegend(0,0,0,0,0),
            series: [{
                name: 'Analyzed data',
                data: []
            }]
        });
    }

    function getLegend(totalPower, alpha, beta, delta, theta) {
        return {
            layout: 'vertical',
            backgroundColor: '#FFFFFF',
            floating: true,
            align: 'right',
            verticalAlign: 'top',
            x: 0,
            y: 0,
            labelFormatter: function () {
                return "Total power:" + (totalPower.toFixed(0)) + "<br>\n" +
                    "                    Delta power:" + ((delta / (totalPower ? totalPower : 1)) * 100).toFixed(2) + "%<br>\n" +
                    "                    Theta power:" + ((theta / (totalPower ? totalPower : 1)) * 100).toFixed(2) + "%<br>\n" +
                    "                    Alpha power:" + ((alpha / (totalPower ? totalPower : 1)) * 100).toFixed(2) + "%<br>\n" +
                    "                    Beta power:" + ((theta / (totalPower ? totalPower : 1)) * 100).toFixed(2) + "%<br>";
            }
        };
    }

</script>
</body>
</html>