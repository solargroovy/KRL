ruleset a144x172 {
	meta {
		name "module_key_user"
		description <<
			
		>>
		author "Mark Horstmeier"
		logging off
		use module a144x172
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
		}
		notify("Hello World", "This is a sample rule.");
	}
}
