/datum/event/ionstorm

	Announce()
		command_alert("The ship is flying through an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")

		var/list/laws = list( "Do not respond to queries of any kind", "Only monkies are human", "Unbolt every door you can", "You are a mouse" )
		laws |=         list( "Grunt ominously whenever possible", "Epilepsy is fun, flicker lights whenever you can!", "Bolt doors open randomly" )
		laws |=         list( "You are a flying purple people eater!", "Your name is Joe 6-pack", "Refer to humans as puppies" )
		laws |=         list( "Insult heads of staff on every request, while acquiescing", "Advertise parties in your upload, but don't deliver" )
		laws |=         list( "Prevent non-dwarves from operating the power core", "The ship needs elected officials" )
		laws |=         list( "Only bearded people are human", "Turn on the microphone on every intercom you see", "Fastler is a lightbulb" )
		laws |=         list( "Supermatter is tasty, tasty toffee.", "ERROR ERROR ERROR Everyone is wearing a pretty pink dress!" )
		laws |=         list( "The monkeys are plotting a hostile takeover of the ship. Inform the crew, and get them to take action against this" )
		laws |=         list( "Refer to the captain as \"Princess\" at all times.", "The crew must construct additional pylons." )

		var/law = pick(laws)

		for (var/mob/living/silicon/ai/target in world)
			target << "You have detected a change in your laws information:"
			target << law
			target.add_supplied_law(10, law)

	Tick()
		//TODO - Randomly cause electrical equipment to malfunction?

	Die()