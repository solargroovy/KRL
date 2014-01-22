ruleset charOps {
  meta {
    name "charOps"
    description <<
	character manipulation for Kelly
      Copyright 2013 Kynetx, All Rights Reserved
    >>
    author "MEH"

	}
  dispatch {
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {
  
  }

  rule stepChar {
  	select when pageview ".*"
    pre {
    	div = <<
    		<div id="myHook"></div>
    	>>;
		str = "abc";
		charArray = str.split(re//);
		strCharArray = charArray.encode();
		single = charArray[0].sprintf("%d");
    }
    {
		notify("Char Operations",div) with sticky = true;
		after("#myHook","<br>str: " + str);
		after("#myHook","<br>array: " + strCharArray);
		after("#myHook","<br>char 0: " + single);
    }
  }

}
