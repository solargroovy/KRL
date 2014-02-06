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
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {
  }

  rule hasLogging {
  	select when pageview 
    pre {
	  	getLoggingForm = <<
	  		<div id="myDIV"> 
	    			  <form id="myFORM" onsubmit="return false"> 
	    				  <input type="input" name="eci" placeholder="Developer ECI"><br/> 
	    					<input type="submit" value="Submit"> 
	    				</form> 
			</div> 
			<div id="myStatus"> </div> 
	  	>>;
		
    }
    {
		notify("Logging ECI!",getLoggingForm) with sticky = true;
		watch("#myFORM","submit");
    }
  }
  
  rule sub_hasLogging {
  	select when web submit "#myFORM"
  	pre {
  		deci = event:attr("eci");
  	}
  	{
  		replace_inner("#myStatus",deci);
  	}
  }
	
}
