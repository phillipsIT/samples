<?php if ( ! defined('BASEPATH')) exit('No direct script access allowed');

class Ajax extends LN_Controller {

	public function __construct(){
        parent::__construct();
        
    }
    
    //==========================================
    // Google Map CodeIgniter Controller Example
    //==========================================
   
    // gets points for surrounding listing markers on detail page Google map
    public function SurroundingListings() {	

    	$output		= '';
		$id			= isset($_GET['id']) ? $_GET['id'] : NULL;
		$type		= isset($_GET['type']) ? $_GET['type'] : NULL;		
		$mlsIDs 	= $this->data['gMLSArray'];	
		$boundsArray= isset($_GET['bounds']) ? explode(",",$_GET['bounds']) : array();
		
		$this->load->model('listing_model');
		
		// get surrounding listings points
		$points	= $this->listing_model->getSurroundingPoints($boundsArray, $id, $type, $mlsIDs);
		
		if($points) {
			foreach($points AS $marker) {
				$lon = $marker['longitude_alt'] != 0.000000 ? $marker['longitude_alt'] : $marker['longitude'];
				$lat = $marker['latitude_alt'] != 0.000000 ? $marker['latitude_alt'] : $marker['latitude'];
				$output .= $marker['listing_unique_id'] . '	' . $lon . '	' . $lat . "\n";
			}
		}

		echo trim($output);   
    }

   
    
    // loads the preview of listing when surrounding listing marker is clicked
    public function SurroundingPreview() {
   
    	$id	= $this->input->post('id');
    	
    	$this->load->model('listing_model');
    	
    	$ListingNotes = $this->data['gListingNotes'];
    	
		// get surrounding listing preview
		$this->data	= $this->listing_model->getSurroundingPreview($id); 
		
		// get listing offices
		$this->data['listingOffices']	= $this->listing_model->listingOffices($id);
			
		// get listing agents
		$this->data['listingAgents'] 	= $this->listing_model->listingAgents($id);
		
    	$this->data['gListingNotes'] = $ListingNotes;
				 
		$this->load->view('/MapSearch/previewer', $this->data); 	
    	
    }
 
    
}