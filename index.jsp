<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>

    <title>my leaflet Demo 0</title>

    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!--    <link rel="shortcut icon" type="image/x-icon" href="docs/images/favicon.ico" />-->

    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
          integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
          crossorigin=""/>
    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js"
            integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA=="
            crossorigin=""></script>
    <script src="jquery-3.6.0.min.js"></script>
    <script src="echarts.js"></script>

    <style type="text/css">
        #result {
            position: absolute;
            width: 375px;
            height: 600px;
            background: aliceblue;
            z-index: 998;
            left: 50px;
            top: 100px;
            display: none;
        }

        #location {
            width: 319px;
        }

        #searchbox {
            width: 375px;
            position: absolute;
            z-index: 999;
            left: 50px;
            top: 50px;
        }

        ul {
            list-style-type: none;
            left: 10px;
            padding: 1px;
            height: 550px;
            overflow: auto;
        }

        li {
            margin: 25px;
            padding: 10px;
            width: 275px;
            height: 50px;
            min-height: 50px;
            max-height: 150px;
            background: #ffffff;
        }

        /*#pic {*/
        /*    width: 300px;*/
        /*    height: 200px;*/
        /*    max-width: 300px;*/
        /*    max-height: 200px;*/
        /*    display: none;*/
        /*    position: center;*/
        /*}*/

        img {
            width: 150px;
            height: 100px;
            max-width: 150px;
            max-height: 100px;
            /*display: none;*/
            position: absolute;
        }

        .close {
            position: absolute;
            top: 11px;
            right: 11px;
            transform: translate(50%, -50%);
        }

    </style>

</head>

<body style=" margin: 0;overflow: hidden;background: #fff;width: 100%;height:100%;position: absolute;top: 0;z-index: 2">

<div id="result">
    <button class="close" onclick="closeDiv()">X</button>
    <ul id="resultList">

    </ul>
</div>

<%--<div id="pic">--%>

<%--</div>--%>

<form id="searchbox">
    <input type="text" id="location" name="location"/>
    <%--    <input type="submit" value="搜索" name="search"/>--%>
    <input type="button" id="search" name="search" value="搜索" onclick="myFunction()">
</form>

<div id="mapid" style="margin:0 auto;width: 100%; height: 100%"></div>
<script>

    var map = L.map('mapid').setView([30.659644, 104.063599], 14);

    //osm底图
    var baseLayers = {
        "OSM": L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            // attribution: '© <a href="http://osm.org/copyright">OpenStreetMap</a> contributors',
            // maxZoom: 18
            // zoomOffset: -1
        }).addTo(map),
    };

    //路网图层（使用tomcat的jsp项目时无法同时访问geoserver？需要修改配置加入tomcat中webapp的root和geoserver）
    var wmsLayer = L.tileLayer.wms("http://localhost:8080/geoserver/MyApp1/wms?", {
        layers: 'MyApp1:cdsm',
        format: 'image/png',
        transparent: true,
        interactive: true
        // attribution: "© <a href=\"http://osm.org/copyright\">OpenStreetMap</a> contributors"
    }).addTo(map).setOpacity(0.5);

    //加入图标与图形以及点击显示经纬度
    // L.marker([30.655725, 104.07692]).addTo(map)
    //     .bindPopup("<b>Hello world!</b><br />I am a popup.")
    //     .openPopup();
    //
    // L.circle([30.65, 104.06], 500, {
    //     color: 'red',
    //     fillColor: '#d000ff',
    //     fillOpacity: 0.3
    // }).addTo(map).bindPopup("I am a circle.");
    //
    // L.polygon([
    //     [30.66, 104.06],
    //     [30.65, 104.02],
    //     [30.67, 104.06]
    // ]).addTo(map).bindPopup("I am a polygon.");

    var popup = L.popup();

    function onMapClick(e) {
        popup
            .setLatLng(e.latlng)
            .setContent("You clicked the map at " + e.latlng.toString())
            .openOn(map);
    }

    map.on('click', onMapClick);

    //国内地图经纬度因保密需要不准，故百度地图拾取工具得到的经纬度是错误的，需根据osm上的更改，或是使用插件
    var si = L.marker([30.654728, 104.055904]).bindPopup("这里是四中"),
        qi = L.marker([30.637816, 104.072780]).bindPopup("这里是七中"),
        jiu = L.marker([30.678001, 104.054600]).bindPopup("这里是九中");
    var schools = L.layerGroup([si, qi, jiu]).addTo(map);

    //GeoJSON图层
    var geoJSONStyle = {
        "color": "#bde0f8",
        "weight": 5,
        "opacity": 0.3,
    };
    var JSONLayer;
    var JSONLayers = L.layerGroup();
    $.getJSON("data/GeoJSON_Chn.json", function (data) {
        JSONLayer = L.geoJSON(data, {style: geoJSONStyle});
        //用layerGroup实现对geojson图层的ZIndex控制，从而达到控制图层显示的功能
        JSONLayers.addLayer(JSONLayer).addTo(map);
    });
    //字符串GeoJSON图层
    var cdqz = {
        "type": "FeatureCollection",
        "features":
            [{
                "type": "Feature",
                "id": "cdqz.1",
                "geometry": {
                    "type": "MultiPolygon",
                    "coordinates": [[[[104.0715801, 30.6389176], [104.0725179, 30.6388505], [104.072515, 30.6388031], [104.0727031, 30.6387147], [104.0731882, 30.638751], [104.0733275, 30.6386107], [104.0733445, 30.6382482], [104.0732646, 30.6374194], [104.0730959, 30.6369828], [104.0723656, 30.6370388], [104.0719719, 30.6372557], [104.0716286, 30.6374602], [104.0712613, 30.6376461], [104.071038, 30.6377494], [104.0708868, 30.6378403], [104.0715457, 30.6385352], [104.0715801, 30.6389176]]]]
                },
                "geometry_name": "the_geom",
                "properties": {
                    "osm_id": "",
                    "osm_way_id": "288171059",
                    "name": "æé½å¸ç¬¬ä¸ä¸­å­¦æè«æ ¡åº",
                    "type": "",
                    "aeroway": "",
                    "amenity": "school",
                    "admin_leve": "",
                    "barrier": "",
                    "boundary": "",
                    "building": "",
                    "craft": "",
                    "geological": "",
                    "historic": "",
                    "land_area": "",
                    "landuse": "",
                    "leisure": "",
                    "man_made": "",
                    "military": "",
                    "natural": "",
                    "office": "",
                    "place": "",
                    "shop": "",
                    "sport": "",
                    "tourism": "",
                    "other_tags": ""
                }
            }],
        "totalFeatures": 1,
        "numberMatched": 1,
        "numberReturned": 1,
        "timeStamp": "2021-03-23T07:26:26.002Z",
        "crs": {"type": "name", "properties": {"name": "urn:ogc:def:crs:EPSG::4326"}}
    };
    var cdqzStyle = {
        "color": "#d92e51",
        "opacity": 0.6,
    };
    var cdqzLayer = L.geoJSON(cdqz, {style: cdqzStyle});
    JSONLayers.addLayer(cdqzLayer);


    var overlayMaps = {
        "Schools": schools,
        "Streets": wmsLayer,
        "GeoJSON": JSONLayers
    };

    //管理图层组的可见性
    var layerControl = L.control.layers(baseLayers, overlayMaps, {
        position: 'topleft',
        collapsed: true
    }).addTo(map);

    //添加比例尺（因为是墨卡托投影所以比例尺随纬度变化）
    L.control.scale().addTo(map);


</script>

<script type="text/javascript">
    var searchLayers = L.layerGroup();

    var newJsonStyle = {
        "color": "#ff4a00",
        "weight": 6,
        "opacity": 0.9,
    };

    function myFunction() {
        var location = $("#location").val();

        $.ajax({
            type: "get",
            url: "MapServlet",      //这就是使用的servlet的url
            // dataType:"json",
            data: {
                location: location
            },
            success: function (data) {
                searchLayers.clearLayers();
                $("#resultList").find("li").remove();
                var markersById = {};
                //JSON.stringify(data)转换失败，$.parseJSON(data)大成功
                var searchLayer = L.geoJSON($.parseJSON(data), {
                    pointToLayer: function (feature, latlng) {
                        return L.marker(latlng, {});
                    },
                    onEachFeature: function (feature, layer) {
                        if (feature.properties && feature.properties.name && feature.properties.id) {
                            var popupContent = '<div style="width:300px;height:200px" id="' + feature.properties.id + '"></div>';
                            layer.bindPopup(popupContent, {});
                            markersById[feature.properties.id] = layer;
                        }
                        // layer.on({
                        //     // mouseover: highlightFeature,//鼠标移入事件
                        //     // mouseout: resetHighlight,//鼠标移出事件
                        //     click: zoomToFeature//鼠标点击事件
                        // });
                        layer.on('click', function (e) {
                            // e = event
                            console.log(e);
                            map.setView(markersById[feature.properties.id].getLatLng(), 6);
                            // this.handleMapMarerClick(item);
                        });
                        // getWeather(feature);
                        //用于制作图表的气温和日期数组
                        var hList = [];
                        var lList = [];
                        var dList = [];

                        $.ajax({
                            type: "get",
                            url: "WeatherServlet",      //这就是使用的servlet的url
                            // dataType:"json",
                            data: {
                                pinyin: feature.properties.pinyin
                            },
                            success: function (data) {
                                var Wjson = $.parseJSON(data);
                                // $("#resultList").html(data);//test
                                $.each(Wjson.results[0].daily, function (idx, item) {
                                    if (idx == 0) {
                                        //如何改变指定的li元素？
                                        let high = item.high;
                                        let low = item.low;
                                        let text = item.text_day;
                                        // $("#resultList").append(low+"~"+high+": "+text+" \n");//test
                                        addLi(feature, high, low, text);
                                    }
                                    hList[idx] = item.high;
                                    lList[idx] = item.low;
                                    dList[idx] = item.date;
                                });
                                layer.on('popupopen', function (e) {
                                    drawDoubleLine(feature.properties.id, feature.properties.name, dList, "高温", hList, "低温", lList)
                                });
                            },
                            error: function () {
                                alert("请求失败2！");
                                // alert(XMLHttpRequest.status);
                                // alert(XMLHttpRequest.readyState);
                            }
                        });
                    }
                });
                searchLayers.addLayer(searchLayer).addTo(map);
                map.setView([30.659644, 104.063599], 4);
                document.getElementById("result").style.display = 'block';
            },
            error: function () {
                alert("请求失败1！");
            }
        });
    }

    //搜索结果框
    function addLi(feature, high, low, text) {
        let li = document.createElement("li");
        li.innerHTML = feature.properties.id + ": " + feature.properties.name + "(" + feature.properties.pinyin + ")\n"
            + low + " ~ " + high + " ℃  " + text + " \n";
        //图片
        // $.ajax({
        //     type: "get",
        //     url: "PictureServlet",      //这就是使用的servlet的url
        //     // dataType:"json",
        //     data: {
        //         location: feature.properties.name
        //     },
        //     success: function (data) {
        //         if (data == "no picture") {
        //             let noPic = document.createElement("div");
        //             noPic.innerHTML = data;
        //             li.appendChild(noPic);
        //         } else {
        //             var blob = data;
        //             var img = document.createElement("img");
        //             img.onload = function (e) {
        //                 window.URL.revokeObjectURL(img.src);
        //             };
        //             img.src = window.URL.createObjectURL(blob);
        //             li.appendChild(img);
        //             img.onclick = function(){
        //                 postPicture(feature);
        //             }
        //         }
        //     },
        //     error: function () {
        //         alert("图片请求失败！");
        //     }
        // });

        let ul = document.getElementById("resultList");
        ul.appendChild(li);
    }

    //查询天气
    function getWeather(feature) {
        //已直接将代码粘贴至myFunction

    }

    //绘制图表
    function drawDoubleLine(container, titleName, xData, seriesNameOne, seriesDataOne, seriesNameTwo, seriesDataTwo) {
        var doubleLine = echarts.init(document.getElementById(container));
        doubleLineOption = {
            tooltip: {
                trigger: 'axis',
                //指示器
                axisPointer: {
                    type: 'line',
                    lineStyle: {
                        color: '#7171C6'
                    }
                }
            },
            //标题样式
            title: {
                text: titleName,
                textStyle: {
                    color: 'black',
                },
                left: 'center'
            },
            //图形位置
            grid: {
                left: '4%',
                right: '6%',
                bottom: '4%',
                top: 50,
                containLabel: true
            },
            xAxis: [{
                type: 'category',
                //x轴坐标点开始与结束点位置都不在最边缘
                boundaryGap: true,
                axisLine: {
                    show: true,
                    //x轴线样式
                    lineStyle: {
                        color: '#17273B',
                        width: 1,
                        type: 'solid'
                    }
                },
                //x轴字体设置
                axisLabel: {
                    show: true,
                    fontSize: 12,
                    color: 'black'
                },
                data: xData
            }],
            yAxis: [{
                type: 'value',
                //y轴字体设置
                axisLabel: {
                    show: true,
                    color: 'black',
                    fontSize: 12,
                    formatter: function (value) {
                        if (value >= 1000) {
                            value = value / 1000 + 'k';
                        }
                        return value;
                    }
                },
                //y轴线设置显示
                axisLine: {
                    show: true
                },
                //与x轴平行的线样式
                splitLine: {
                    show: true,
                    lineStyle: {
                        color: '#17273B',
                        width: 1,
                        type: 'solid',
                    }
                }
            }],
            series: [{
                name: seriesNameOne,
                type: 'line',
                smooth: true,
                lineStyle: {
                    color: {
                        type: 'linear',
                        x: 0,
                        y: 0,
                        x2: 0,
                        y2: 1,
                        colorStops: [{
                            offset: 0,
                            color: '#00F2B1' // 0% 处的颜色
                        }, {
                            offset: 1,
                            color: '#00F2B1' // 100% 处的颜色
                        }],
                        globalCoord: false
                    },
                    width: 2,
                    type: 'solid',
                },
                //折线连接点样式
                itemStyle: {
                    color: '#00E5DE'
                },
                //折线堆积区域样式
                areaStyle: {
                    color: '#004c5E'
                },
                data: seriesDataOne
            }, {
                name: seriesNameTwo,
                type: 'line',
                smooth: true,
                lineStyle: {
                    color: {
                        type: 'linear',
                        x: 0,
                        y: 0,
                        x2: 0,
                        y2: 1,
                        colorStops: [{
                            offset: 0,
                            color: '#0AB2F9' // 0% 处的颜色
                        }, {
                            offset: 1,
                            color: '#0AB2F9' // 100% 处的颜色
                        }],
                        globalCoord: false
                    },
                    width: 2,
                    type: 'solid',
                },
                //折线连接点样式
                itemStyle: {
                    color: '#00E5DE'
                },
                //折线堆积区域样式
                areaStyle: {
                    color: '#004c5E'
                },
                data: seriesDataTwo
            }]
        };
        doubleLine.setOption(doubleLineOption);
    }

    //打开图片窗口（弃用）
    // function openPicture(feature) {
    //     let pic = document.getElementById("pic");
    //     let btn2 = document.createElement("button");
    //     //获取图片
    //     $.ajax({
    //         type: "get",
    //         url: "PictureServlet",      //这就是使用的servlet的url
    //         // dataType:"json",
    //         data: {
    //             location: feature.properties.name
    //         },
    //         success: function (data) {
    //             var blob = data;
    //             var img = document.createElement("img");
    //             img.onload = function (e) {
    //                 window.URL.revokeObjectURL(img.src);
    //             };
    //             img.src = window.URL.createObjectURL(blob);
    //
    //             pic.appendChild(img).appendChild(btn2);
    //             pic.style.display = 'block';
    //         },
    //         error: function () {
    //             alert("请求失败！");
    //         }
    //     });
    // }

    //上传图片
    // function postPicture(feature) {
    //     $.ajax({
    //         type: "post",
    //         url: "PictureServlet",      //这就是使用的servlet的url
    //         // dataType:"json",
    //         data: {
    //             location: feature.properties.name
    //         },
    //         success: function (data) {
    //             alert("上传情况：" + data);
    //         },
    //         error: function () {
    //             alert("请求失败！");
    //         }
    //     });
    // }

    function closeDiv() {
        let div = document.getElementById("result");
        div.style.display = 'none';
    }

    //geojson
    var json1 = {//测试用
        "type": "FeatureCollection",
        "features": [{
            "type": "Feature",
            "properties": {"name": "北京", "id": "61.0", "pinyin": "null"},
            "geometry": {"type": "Point", "coordinates": [116.380943298, 39.923614502]}
        }, {
            "type": "Feature",
            "properties": {"name": "天津", "id": "70.0", "pinyin": "null"},
            "geometry": {"type": "Point", "coordinates": [117.20349884, 39.131118774]}
        }, {
            "type": "Feature",
            "properties": {"name": "南京", "id": "594.0", "pinyin": "null"},
            "geometry": {"type": "Point", "coordinates": [118.772781372, 32.047615051]}
        }, {
            "type": "Feature",
            "properties": {"name": "济南", "id": "981.0", "pinyin": "null"},
            "geometry": {"type": "Point", "coordinates": [117.005599976, 36.667072296]}
        }],
        "totalFeatures": 4,
    };
    //天气json

    var json2 = {
            "results": [{
                "location": {
                    "id": "WX4FBXXFKE4F",
                    "name": "北京",
                    "country": "CN",
                    "path": "北京,北京,中国",
                    "timezone": "Asia/Shanghai",
                    "timezone_offset": "+08:00"
                },
                "daily": [{
                    "date": "2021-04-11",
                    "text_day": "多云",
                    "code_day": "4",
                    "text_night": "阴",
                    "code_night": "9",
                    "high": "19",
                    "low": "11",
                    "rainfall": "0.0",
                    "precip": "",
                    "wind_direction": "南",
                    "wind_direction_degree": "180",
                    "wind_speed": "3.0",
                    "wind_scale": "1",
                    "humidity": "41"
                }, {
                    "date": "2021-04-12",
                    "text_day": "多云",
                    "code_day": "4",
                    "text_night": "多云",
                    "code_night": "4",
                    "high": "21",
                    "low": "7",
                    "rainfall": "0.0",
                    "precip": "",
                    "wind_direction": "北",
                    "wind_direction_degree": "0",
                    "wind_speed": "23.4",
                    "wind_scale": "4",
                    "humidity": "40"
                }, {
                    "date": "2021-04-13",
                    "text_day": "晴",
                    "code_day": "0",
                    "text_night": "晴",
                    "code_night": "1",
                    "high": "17",
                    "low": "5",
                    "rainfall": "0.0",
                    "precip": "",
                    "wind_direction": "西南",
                    "wind_direction_degree": "225",
                    "wind_speed": "15.3",
                    "wind_scale": "3",
                    "humidity": "17"
                }],
                "last_update": "2021-04-11T11:00:00+08:00"
            }]
        }
    ;


</script>


</body>
</html>