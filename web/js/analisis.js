
if(!!(window.addEventListener)) window.addEventListener('DOMContentLoaded', main);
else window.attachEvent('onload', main);

var graph_colors = [ "85,98,112", "78,205,196", "159,194,100", "255,107,107", "196,77,88" ]
var labels =  ["0", "22.5", "45", "67.5", "90", "112.5", "135", "157.5","180", "202.5","225", "247.5","270", "292.5", "315" ,"337.5"]
var search_aux = "";

function legend(parent, data, active_label) {
    parent.className = 'legend';
    var datas = data.hasOwnProperty('datasets') ? data.datasets : data;

    // remove possible children of the parent
    while(parent.hasChildNodes()) {
        parent.removeChild(parent.lastChild);
    }
    var list = document.createElement('ul');
    list.style.listStyleType = 'none';
    parent.appendChild(list);

    datas.forEach(function(d) {
        var title = document.createElement('li');
        title.className = 'title';
        title.style.color = '#fff';
        if (d.label == active_label) { 
            transpa = 'A'
        } else {
            transpa = 0.25
        }
        title.style.backgroundColor = d.hasOwnProperty('strokeColor') ? d.strokeColor : d.color;
        title.style.backgroundColor = title.style.backgroundColor.replace(')', ', '+transpa+')').replace('rgb', 'rgba');
        title.style.margin = "1px 1px 1px 1px"
        title.onclick = function(e){
            radarChart(d.label);
        };
        title.onmouseover = function(d) {
            this.style.color= '#eee'
        }
        title.onmouseout = function(d) {
            this.style.color= '#fff'
        }        
        list.appendChild(title);

        var text = document.createTextNode(d.label);
        title.appendChild(text);
    });
}



function main() {
    var s = document.getElementById("search")
    s.onkeyup = function(e){
        if (this.value != search_aux) {
            search_aux = this.value
            radarChart("");
        }
    }
    radarChart("");
}
    
function radarChart(activeLabel) {
    var searchPattern = document.getElementById("search").value
    var d = { labels: labels }
    setData(d, datasets,activeLabel,searchPattern,graph_colors)
    var ctx = document.getElementById("chart").getContext("2d");
    new Chart(ctx).Radar(d, {
            responsive: true,
            animation: false,
            scaleShowLabels: true
        });
    legend(document.getElementById("legend"), d, activeLabel);   
}

function setData(objecte, ds, active_label, pattern, graph_colors){
    myarray = [];
    counter = 0;
    ds.forEach(function(e){
        if (pattern == "" || e.label.indexOf(pattern) >= 0) {
            c = graph_colors[counter % graph_colors.length];
            if (active_label == e.label || active_label == ""){
                mydata = e.data;
            } else {
                mydata = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
            }
            myarray[counter] = { 
                                label: e.label , 
                                data: mydata, 
                                fillColor: "rgba("+c+",0.2)",               
                                strokeColor: "rgba("+c+",1)",
                                pointColor: "rgba("+c+",1)",
                                pointStrokeColor: "#fff",
                                pointHighlightFill: "#fff",
                                pointHighlightStroke: "rgba("+c+",1)"
                            };
            counter++;
        }
    });
    objecte['datasets'] = myarray;
}
