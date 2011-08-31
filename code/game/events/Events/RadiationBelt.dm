/datum/event/radiation
	Lifetime = 10
	Announce()
		command_alert("The ship is now travelling through a radiation belt", "Medical Alert")

	Tick()
		for(var/mob/living/L in world)
			L.radiate(rand(1,7))

	Die()
		command_alert("The ship has cleared the radiation belt", "Medical Alert")