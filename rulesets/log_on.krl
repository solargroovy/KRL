ruleset b144x1 {
  meta {
    name "Developer Logging"
    description <<

      Copyright 2013 Kynetx, All Rights Reserved
    >>
    author "MEH"

    key system_credentials {
      "root": 'YmY4MzNlZWQzN2Q3ZmQ1YTg1YWE3MDYyZGJmMGEwN2M5YzM0NGVjNmU2YzIyNzk0NmRjZTAzNWMyMWJjODgxMTYzZTE0OWMyNTYxOWEyNzcxN2FmM2YzYjRl'    }

    logging on
  }

  dispatch {
    domain "heroku.com"
    domain "fabysdf.com"
    // domain "example.com"
    // domain "other.example.com"
  }

  global {
  }

  rule hasLogging {
  	select when pageview 
    pre {
    	self_eci = pci:session_token();
	  	getLoggingForm = <<
	  		<div id="myDIV"> 
	    			  <form id="myFORM" onsubmit="return false"> 
	    			  	<label for="eci">Session user eci: #{self_eci}</label>
	    				  <input type="input" name="eci" placeholder="Developer ECI"><br/> 
	    					<input type="button" id="check_log" name="cl" value="Check Logging"> 
	    					<input type="button" id="add_log" name="add" value="add Logging"> 
	    					<input type="button" id="show_log" name="add" value="Show Logs">
	    				</form> 
			</div> 
			<div id="myStatus"> </div> 
	  	>>;
		
    }
    {
		notify("Logging ECI77777777777777",getLoggingForm) with sticky = true and width=600;
		watch("#check_log","click");
		watch("#add_log","click");
		watch("#show_log","click");
    }
  }
  
  rule sub_hasLogging {
  	select when web click "#check_log"
  	pre {
  		deci = event:attr("eci");
  		action = event:attr("cl");
  		a2 = event:attr("submit");
  		uname = pci:get_username(deci);
  		hasLogging = pci:get_logging(deci);
  		blob = <<
  			User (#{uname}) has logging #{hasLogging} <br/>
  			- #{action} - #{a2}  -
  			
  		>>;
  	}
  	{
  		replace_inner("#myStatus",blob);
  	}
  }
  
   rule sub_addLogging {
  	select when web click "#add_log"
  	pre {
  		deci = event:attr("eci");
  		uname = pci:get_username(deci);
  		hasLogging = pci:get_logging(deci);
  		log_eci = (hasLogging) =>  null | pci:set_logging(deci);
  		blob = <<
  			User (#{uname}) has logging eci #{log_eci} <br/>
  			- write it down  -  			
  		>>;
  	}
  	{
  		replace_inner("#myStatus",blob);
  	}
  }
 
 
   rule sub_showLogs {
  	select when web click "#show_log"
  	pre {
  		deci = event:attr("eci");
  		uname = pci:get_username(deci);
  		hasLogging = pci:get_logging(deci);
  		log_eci = (hasLogging) =>  null | pci:get_logs(deci);
  		logstr = log_eci.encode();
  		blob = <<
  			User (#{uname}) has logging eci #{log_eci} <br/>
  			- #{logstr}  -  			
  		>>;
  	}
  	{
  		replace_inner("#main",blob);
  	}
  }
  
}
