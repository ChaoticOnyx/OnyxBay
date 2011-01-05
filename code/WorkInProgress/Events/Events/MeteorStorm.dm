/datum/event/meteorstorm

	Announce()
		command_alert("The ship is now travelling through a meteor shower", "Meteor Alert")

	Tick()
		if (prob(40))
			meteor_wave()

	Die()
		command_alert("The ship has cleared the meteor shower", "Meteor Alert")
