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

	}

	rule first_rule {
		select when pageview ".*" setting ()
		pre {
		
		}
		notify("Hello World", "This is a sample rule.");
	}
}
