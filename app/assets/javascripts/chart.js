var params = {
    "type": "serial",
    "theme": "light",
    "legend": {
        "horizontalGap": 10,
        "position": "bottom",
        "markerSize": 10
    },
    "valueAxes": [
        {
            "position": "left",
            "title": "PM2.5 [μg/m3]",
            "guides": [
                {
                    "fillAlpha": 0.1,
                    "fillColor": "#dddddd",
                    "lineAlpha": 0,
                    "value": 0,
                    "toValue": 15
                }, {
                    "fillAlpha": 0.1,
                    "fillColor": "#999999",
                    "lineAlpha": 0,
                    "value": 15,
                    "toValue": 35
                }, {
                    "fillAlpha": 0.1,
                    "fillColor": "#999900",
                    "lineAlpha": 0,
                    "value": 35,
                    "toValue": 50
                }, {
                    "fillAlpha": 0.1,
                    "fillColor": "#990099",
                    "lineAlpha": 0,
                    "value": 50,
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