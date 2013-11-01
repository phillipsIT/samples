// Google Chart API example
// Creates a line chart of average prices for active and sold real estate listing during a 1 year period 

google.load("visualization", "1", {packages:["corechart"]});

function drawChart() {

var data = new google.visualization.DataTable();

        data.addColumn("date", "Year");
        data.addColumn("number", "Active");
        data.addColumn("number", "Sold");
        data.addRows([[new Date(2012, 10, 1),251978,171205],[new Date(2012, 11, 1),247145,149875],[new Date(2013, 0, 1),247390,140801],[new Date(2013, 1, 1),248521,141729],[new Date(2013, 2, 1),253648,144143],[new Date(2013, 3, 1),255219,142988],[new Date(2013, 4, 1),256184,147243],[new Date(2013, 5, 1),257243,152951],[new Date(2013, 6, 1),261349,156411]]);
       
  var date_formatter = new google.visualization.DateFormat({pattern: "MMM yy"});
  date_formatter.format(data, 0);
  
  var formatter = new google.visualization.NumberFormat({prefix:"$", fractionDigits:0});  
  formatter.format(data, 1); // Apply formatter to active column
  formatter.format(data, 2); // Apply formatter to sold column
  
  // Create and draw the visualization.
  var table = new google.visualization.LineChart(document.getElementById("listing_chart"));
      
  table.draw(data, {      
        title: "Market Trends Chart",
        titleTextStyle:{color:"#666", fontName:"Helvetica", fontSize:14},
        axisTitlesPosition:"out",
        gridlineColor: "#ccc",
        baselineColor:"#ccc",
        backgroundColor:{stroke: "#ccc",strokeWidth: 0},
        legend:"bottom",
    	hAxis:{slantedText: true, slantedTextAngle:45, showTextEvery:1},
    	vAxis:{textPosition:"out",format:"$#,###", viewWindowMode:"explicit", viewWindow:{max:261349, min:140801}},
        chartArea:{left: 80},
        width: 300,
        height: 335,
    	tooltipTextStyle:{color:"#900"},
    	pointSize: 2,
    	lineWidth: 1
    	}
	);
}	