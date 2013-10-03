ruleset a144x172 {
	meta {
		name "module_key_user"
		description <<
			
		>>
		author "Mark Horstmeier"
		logging off
		use module a144x173
	}

	dispatch {
		// domain "exampley.com"
	}

	global {
		a_me = keys:a();
		c_me = keys:c();
	}

	rule first_rule {
		select when pageview ".*" setting ()
		pre {
			b_me = keys:b();
			myStr = c_me.encode();
			ksc = keys:system_credentials();
			kStr = ksc.encode();
			blob = <<#{a_me}<br>#{b_me}<br>#{myStr}<br>#{kStr} >>;
			foo = pci:exists("meh@kynetx.com");
			
		}
		{
		notify("Hello World",blob );
		notify("Authorized: ", foo);
		}
	}
}
