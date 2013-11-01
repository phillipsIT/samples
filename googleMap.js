$(document).ready(function() {

	// Google Map API Example with clickable markers
	// AJAX call via jQuery loads surrounding markers based on longitude, latitude returned from MySQL query as map is dragged
	// Click event listeners show details in <div id="map-preview"></div> when markers are clicked
	
	mapload();
    
    function mapload() {  
  		var map;
  		var g			= google.maps;
		var centerlat 	= 45.460289;
		var centerlng 	= -85.036707;
		var center 		= new g.LatLng(centerlat, centerlng);
  		var myOptions = {
      		mapTypeId: g.MapTypeId.ROADMAP,
      		zoom: 14,
      		center: center,
			zoomControl: false,
			streetViewControl: false,
      		scrollwheel: false
   		};	
   		
		var map = new g.Map(document.getElementById("map"), myOptions);
		var marker = new g.Marker({
			map: map,
      		position: center,
      		clickable: false
 		});
 		 	
 		g.event.addListenerOnce(map, 'idle', function(){
 			getSurroundingListings();
 		});
 		 	
 		g.event.addListener(map, 'dragend', function() {
 			getSurroundingListings();
 		});
 		 	
 		function getSurroundingListings() {
 		 	var bounds 	= map.getBounds();
    		var corners	= bounds.toUrlValue();
    			
    		$.get('/SurroundingListings/Ajax/', {bounds: corners, id: "429815NM", type: "Residential"}, function(data)  {

				var listingRowsArray	= [];
				var listingRows			= data.split('\n');
	
				for (i in listingRows) {
	 				if (listingRows[i])
	 					listingRowsArray.push(listingRows[i]);	 	
	 			}
	 
	 			for (key in listingRowsArray) {
	 				var listingCols	= listingRowsArray[key].split('\t');
	 				var listingNum	= listingCols[0];
	 				var listingLng	= listingCols[1];
	 				var listingLat	= listingCols[2];	 				
					var center 		= new g.LatLng(listingLat, listingLng);
					var marker = new g.Marker({
						map: map,
      					position: center,
      					icon: "http://image.fasere.com/global/MapIcons/1/ResSale.png",
      					animation: g.Animation.DROP,
      					listing: listingNum
 		 			});
 		 				
 		 			g.event.addListener(marker, 'click', function() {
 		 				$('#map-preview').load('/SurroundingPreview/Ajax/', {id: this.listing}, function() {
 		 					$('#map-preview').slideDown("slow");
 		 				});
 		 			});
 		 				
 		 			$('#map-wrapper').mouseleave(function() {
 							$('#map-preview').slideUp("slow");
						});
	 				}
	 					
			});
		
 	}
 		 	

}

});
