/datum/evolution_holder/sloth
	evolution_categories = list(
		/datum/evolution_category/sloth
	)
	default_modifiers = list(/datum/modifier/sin/sloth)

/datum/evolution_category/sloth
	name = "Sin of Sloth"
	items = list(
		/datum/evolution_package/expand_sight,
		/datum/evolution_package/teleport,
	)

/datum/evolution_package/expand_sight
	name = "Expand Sight"
	desc = "Bother fighting your opponents no more, you will see them coming from afar. Forget about using binoculars and other optics."
	actions = list(
		/datum/action/cooldown/expand_sight
	)

/datum/evolution_package/teleport
	name = "Teleport"
	desc = "Build statues that allow your fellow sinners to teleport between them."
	actions = list(
		/datum/action/cooldown/spell/devilsteleport
	)

/datum/modifier/sin/sloth/New()
	set_next_think(world.time + 10 MINUTES)

/datum/modifier/sin/sloth/think()
	sin_stage++

/datum/modifier/sin/sloth/tick()
	if(prob(1))
		holder.emote("yawn")
	switch(sin_stage)
		if(SIN_STAGE_BLASPHEMY)
			if(prob(1))
				holder.sleeping = 3
		if(SIN_STAGE_SACRILEGE)
			if(prob(1))
				holder.sleeping = 5
