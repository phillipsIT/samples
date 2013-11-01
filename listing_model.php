<?php

class Listing_Model extends LN_Model {

	
	function __construct (){
        parent::__construct();
       
    }  
    
    //==========================================
    // Google Map CodeIgniter Model Example
    //==========================================
    
    // fetches surrounding listing points for markers on listing detail map based on Google map's viewport
    function getSurroundingPoints($boundsArray, $id, $type, $mlsIDs) {
    	
    	// if bounds does not have 4 coordinates something went wrong
    	if( count($boundsArray) != 4 )
    		return;
    		
		$swLat		= $boundsArray[0];
		$swLon		= $boundsArray[1];
		$neLat		= $boundsArray[2];
		$neLon		= $boundsArray[3];
		$bounds_sql = $this->db->query('
		SELECT 
			longitude, 
			latitude, 
			longitude_alt,
			latitude_alt,
			listing_unique_id
		FROM 
			xxxx 
		WHERE 
			mls2_id IN ("' . implode('","', $mlsIDs) . '")
		AND 
			listing_unique_id != "' . $id . '"
		AND 
			longitude >= ' . $swLon . ' 
		AND 
			longitude <= ' . $neLon . '
		AND 
			latitude >= ' . $swLat . ' 
		AND 
			latitude <= ' . $neLat . ' 
		
		AND 
			primary_listing_class = "' . $type . '" 
		AND 
			status_property LIKE "A%"
		LIMIT 
			0,25');	
			
		$result = $bounds_sql->result_array();
		
		
		return $result;
    }
    
    // gets preview when listing marker is clicked
    function getSurroundingPreview($id) {
    	$sp_sql = $this->db->query(' # surrounding listing photo and html for Google map
		SELECT 
			p.longitude, 
			p.latitude, 
			p.longitude_alt,
			p.latitude_alt,
			p.street_number, 
			p.StreetNumberModifier, 
			p.street_name, 
			p.governing_agency, 
			p.city, 
			p.state, 
			p.zip_code, 
			p.current_price,
			p.nu_beds_total,
			p.nu_baths_total,
			p.listing_unique_id,
			p.listing_number,
			p.MLNumber,
			p.tfla_square_footage,
			p.mls2_id,
			bImg.name AS bImageName, 
			bImg.thumb_height AS bImageHeight, 
			bImg.thumb_width AS bImageWidth,
			mImg.name AS mImageName, 
			mImg.thumb_height AS mImageHeight, 
			mImg.thumb_width AS mImageWidth
		FROM 
			xxxx AS p
		LEFT JOIN 
			ds_images.listing AS bImg 
		ON 
			bImg.listing_number = p.listing_number
		AND 
			bImg.mls_id = p.mls2_id
		AND 
			bImg.status = 1 
		AND 
			bImg.primary_image = 1
		AND 
			bImg.type = 1
		LEFT JOIN 
			ds_images.listing AS mImg 
		ON 
			mImg.listing_number = p.listing_number
		AND 
			mImg.mls_id = p.mls2_id
		AND 
			mImg.status = 1 
		AND 
			mImg.primary_image = 1
		AND 
			mImg.type = 0
		WHERE	
			listing_unique_id = "' . $id . '"');
			
		$listing = $sp_sql->row_array();
			
		return $listing;
    }
   
        
   }