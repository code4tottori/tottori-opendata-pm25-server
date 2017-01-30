var params = {
    "type": "serial",
    "theme": "light",
    "legend": {
        "horizontalGap": 10,
        "position": "bottom",
        "markerSize": 10
    },
    marginLeft: 0,
    marginRight: 0,
    marginBottm: 0,
    panEventsEnabled: false,
    pathToImages: 'images/amcharts/',
    "valueAxes": [
        {
            "position": "left",
            "title": "PM2.5 [μg/m3]",
            "guides": [
                {
                    "fillAlpha": 0.15,
                    "fillColor": "#dddddd",
                    "lineAlpha": 0,
                    "value": 0,
                    "toValue": 12
                }, {
                    "fillAlpha": 0.15,
                    "fillColor": "#FFFF00",
                    "lineAlpha": 0,
                    "value": 12,
                    "toValue": 35
                }, {
                    "fillAlpha": 0.15,
                    "fillColor": "#FFA500",
                    "lineAlpha": 0,
                    "value": 35,
                    "toValue": 55
                }, {
                    "fillAlpha": 0.15,
                    "fillColor": "#FF0000",
                    "lineAlpha": 0,
                    "value": 55,
                    "toValue": 150
                }, {
                    "fillAlpha": 0.15,
                    "fillColor": "#800080",
                    "lineAlpha": 0,
                    "value": 150,
                    "toValue": 250
                }, {
                    "fillAlpha": 0.15,
                    "fillColor": "#800000",
                    "lineAlpha": 0,
                    "value": 250,
                    "toValue": 1000
                }
            ]
        }
    ],
    "graphs": [],
    "dataProvider": [],
    "categoryField": "time",
    "categoryAxis": {
        "minPeriod": "mm",
        "minorGridEnabled": true,
        "parseDates": true
    },
    "balloon": {
        "borderThickness": 1,
        "shadowAlpha": 0
    },
    "chartCursor": {
        "valueLineEnabled": true,
        "valueLineBalloonEnabled": true,
        "cursorAlpha": 0
    }
}

function addGraph(name) {
    console.log(name);
    $.each(params.graphs, function(data) {
        if (data.valueField == name) {
            return
        }
    });
    params.graphs.push({
        "id": name,
        "title": name,
        "valueField": name,
        "fillAlphas": 0.2,
        "balloon": {
            "drop": true,
            "adjustBorderColor": false,
            "color": "#ffffff",
            "type": "smoothedLine"
        },
        "balloonText": "<span'>[[title]]: [[value]] μg/m3</span>"
    });
}

$(document).ready(function() {
    $.getJSON('graph.json', function(data, status, value) {
        $.each(data.names, function(index, name) {
            addGraph(name);
        })
        params.dataProvider = data.values;
        var chart = AmCharts.makeChart("chart", params);
    })
});
