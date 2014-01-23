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
		single = this2that:ord(str);
		ordArray = this2that:unpack(str);
		strOrdArray = ordArray.encode();
    }
    {
		notify("Char Operations",div) with sticky = true;
		before("#myHook","<br>str: " + str);
		before("#myHook","<br>array: " + strCharArray);
		before("#myHook","<br>char 0: " + single);
		before("#myHook","<br>array: " + strOrdArray);
    }
  }

}
