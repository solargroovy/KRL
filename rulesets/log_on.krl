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
	    					<input type="submit" value="Submit"> 
	    				</form> 
			</div> 
			<div id="myStatus"> </div> 
	  	>>;
		
    }
    {
		notify("Logging ECIqwerty",getLoggingForm) with sticky = true and width=600;
		watch("#myFORM","submit");
    }
  }
  
  rule sub_hasLogging {
  	select when web submit "#myFORM"
  	pre {
  		deci = event:attr("eci");
  		uname = pci:get_username(deci);
  		hasLogging = pci:get_logging(deci);
  		blob = <<
  			User (#{uname}) has logging #{hasLogging}
  		>>;
  	}
  	{
  		replace_inner("#myStatus",blob);
  	}
  }
}
