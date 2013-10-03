ruleset a144x173 {
	meta {
		name "MK Ultra"
		description <<
			
		>>
		author "Mark Horstmeier"
		logging off
		key a "slartibartfast"
		key b "42"
		key c {
			"life" : "fjords",
			"universe" : "norway",
			"everything" : "magrathean"
		}
		key system_credentials {
			'root' : 'YmY4MTZiZTgzN2Q5ZmM1YmQzYWYyMzM1ZDBhM2E1MjljZjNiMTA5MGU3OTE3MDkzNmRjZTBkNTIzZGJkOTkxODYwZmE1M2Q4NDMyYWFlNzAwNWE5MzczYzVm'
		}
		provide keys a,b,c,system_credentials to a144x174
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
