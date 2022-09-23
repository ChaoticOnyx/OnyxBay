/mob/living/carbon/metroid/death(gibbed, deathmessage, show_dead_message)

	if(stat == DEAD) return

	if(Leader)
		Leader = null
		walk_to(src, 0)

	if(!gibbed && is_adult)
		var/mob/living/carbon/metroid/M = new /mob/living/carbon/metroid(loc, colour)
		M.rabid = 1
		M.Friends = Friends.Copy()
		step_away(M, src)
		is_adult = 0
		maxHealth = 150
		revive()
		if (!client) rabid = 1
		number = rand(1, 1000)
		SetName("[colour] [is_adult ? "adult" : "baby"] metroid ([number])")
		return

	. = ..(gibbed, deathmessage, show_dead_message)
	mood = null
	regenerate_icons()

	return
