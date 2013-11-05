[
// routine that parses emails from a pop server
// stores the email parts including attachments
// logs email threads in MySQL for later review
  
var('db'='*********');
var('db_username'='********');
var('db_password'='*********');
var('thread_count' = 0);

var('connection'=array(
	-database=$db, 
	-username=$db_username, 
	-password=$db_password, 
	-maxrecords='all'));
Inline($Connection);	

// dependencies
library('EmailParserCheck.inc');
library('EmailParserAttachments.inc');

// connect to pop server and get new email
var('msgs') = email_check( 
    -host='pop.server.com', 
    -username='email@server.net', 
    -password='***********', 
    -delete=true 
); 

// iterate over new email list and parse out elements
iterate($msgs, local('emails'));

	local('email_id') = #emails->first; 
	local('email_content') = #emails->second; 
	
	local('attachments') = email_attachments(#email_content); 

	local('from') = #email_content->from;
	local('to') = #email_content->to;
	
	local('to_array') = #to->split('@');
	local('to_rebuild') = #to_array->first;
	#to_rebuild->replace('++', '@');
	#to_rebuild->removeleading('<');
	#to_rebuild->removeleading('"');
	
	local('from_array') = #from->split(' ');
	local('from_rebuild') = #from_array->last;
	#from_rebuild->replace('@', '++');
	#from_rebuild->replace('<', '');
	#from_rebuild->replace('>', '');
	#from_rebuild = #from_rebuild + '@ezsrv.net';
	
	local('subject') = #email_content->subject;
	local('body') = #email_content->body;
	local('begin') = #subject->find('[') + 1;
	local('end') = #subject->find(']') - 1;
	local('thread_id') = string_extract(#subject, -startposition=#begin, -endposition=#end);
	
	'From Rebuild: ' + #from_rebuild + '<br />';
	'From: ' + #from + '<br />';	
	'To: ' + #to + '<br />';
	'To ReBuild: ' +  #to_rebuild + '<br />';
	'Subject: ' + #subject + '<br />';
	'Thread ID: ' + #thread_id + '<br />';
	'Body: ' + #body + '<br />';
	'Attachments: ' + #attachments + '<br />';
	
// check prospect_email table for row and add to thread
	var('sql') = '	
		SELECT 
			website_id 
		FROM 
			*************.prospect_email
		WHERE 
			thread_id = "' + #thread_id + '"';
			
	inline($connection,   
		-Database='*************',  
		-SQL=$sql);
			$thread_count = Found_Count;
			var('website_id') = field('website_id');
	/inline;
	

	// if no thread id parsed from subject line or no record was found for the thread id
	// pass email to directly to sender and bypass email thread logging
	if(#thread_id == '' || $thread_count == 0);

	email_send( 
    	-host='smtp.server.com', 
    	-to=#to_rebuild,
    	-from=#from,
    	-subject=#subject,
    	-body=#body);
    	
	else;
	
		var('att_path_array') = array;
		
		if(#attachments->size > 0);
		
		// if there are attachments create folder for email_id and store file(s)
		
		Inline($Connection);
		
		Var('temp'='/dsImage/images/website/' + $website_id + '/');
		If(!File_Exists($temp));
			File_Create($temp);
			File_Chmod($temp, -u='rwx', -g='rwx', -o='rx');
			File_Create($temp + '.DS_Store');			
		/If;
		
		Var('temp'='/dsImage/images/website/' + $website_id + '/Attachments/');
		If(!File_Exists($temp));
			File_Create($temp);
			File_Chmod($temp, -u='rwx', -g='rwx', -o='rx');
			File_Create($temp + '.DS_Store');			
		/If;
		
		Var('temp'='/dsImage/images/website/' + $website_id + '/Attachments/' + #thread_id + '/');
		If(!File_Exists($temp));
			File_Create($temp);
			File_Chmod($temp, -u='rwx', -g='rwx', -o='rx');
			File_Create($temp + '.DS_Store');			
		/If;
		
		Var('temp'='/dsImage/images/website/' + $website_id + '/Attachments/' + #thread_id + '/' + #email_id + '/');
		If(!File_Exists($temp));
			File_Create($temp);
			File_Chmod($temp, -u='rwx', -g='rwx', -o='rx');
			File_Create($temp + '.DS_Store');			
		/If;
		
		
							
		iterate(#attachments, local('file_map'));
			file_write($temp + #file_map->find('name'), #file_map->find('data'), -fileoverwrite);
			File_Chmod($temp + #file_map->find('name'), -u='rwx', -g='rwx', -o='rx');
			#att_path_array->insert($temp + #file_map->find('name'));
		/iterate;

		/Inline;
		
		/if;
		
	
	// add email to thread table and forward email to recipient

	inline(
		$connection,  
		-table='prospect_email_thread', 
		-database='*************',
		'email_to' = #to_rebuild,
		'email_from' = #from,
		'subject' = #subject,
		'body'=#body,
		'thread_id' = #thread_id,
		'date_sent' = Date_Format(Date, -Format='%Q %T'),
		'email_id' = #email_id,
		-add
		);
		
	/inline;
	
	if(#att_path_array->size > 0);	
	
	// if there are attachments add file_name to related table
	
		iterate(#att_path_array, local('attach_name'));
		
		local('path_array') = #attach_name->split('/');
		
			inline(
				$connection,  
				-table='prospect_email_attachments', 
				-database='*************',
				'file_name' = #path_array->last,
				'email_id' = #email_id,
				-add
				);
			/inline;
		/iterate;
		
	/if;
		
	 email_send( 
    	-host='smtp.server.com', 
    	-to=#to_rebuild,
    	-from=#from,
    	-replyto=#from_rebuild, 
    	-subject=#subject,
    	-body=#body,
    	-attachments=#att_path_array);
	

	/if;

/iterate;

/Inline;

]
