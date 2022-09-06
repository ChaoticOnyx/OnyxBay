/mob/living/proc/convert_to_rev(mob/M in able_mobs_in_oview(src))
	set name = "Convert Bourgeoise"
	set category = "Abilities"

	if(!(M in able_mobs_in_oview(src)))
		return
	if(!M.mind || !M.client)
		return
	if(!ishuman(M))
		return
	if(!(src in able_mobs_in_oview(M)))
		to_chat(src, SPAN_WARNING("\The [M] can't see you."))
		return

	var/datum/antagonist/antag
	for(var/antag_type in GLOB.all_antag_types_)
		antag = GLOB.all_antag_types_[antag_type]
		if(antag.is_antagonist(M.mind))
			to_chat(src, SPAN_DANGER("\The [M] doesn't seem even remotely interested in your offer. Seems like you won't be able to convert them..."))
			return

	convert_to_faction(M.mind, GLOB.revs)

/mob/living/proc/convert_to_faction(datum/mind/player, datum/antagonist/faction)
	if(!player || !faction || !player.current)
		return

	if(!faction.faction_verb || !faction.faction_descriptor || !faction.faction_verb)
		return

	if(faction.is_antagonist(player))
		to_chat(src, SPAN("notice", "\The [player.current] is already \a [faction.faction_role_text]!"))
		return

	if(!faction.can_become_antag(player, TRUE) || player_is_antag(player))
		to_chat(src, SPAN_WARNING("\The [player.current] cannot be \a [faction.faction_role_text]!"))
		return

	if(world.time < player.rev_cooldown)
		to_chat(src, SPAN_DANGER("You must wait ten seconds between attempts."))
		return

	to_chat(src, SPAN_DANGER("You are attempting to convert \the [player.current]..."))
	log_and_message_admins("attempted to convert [player.current] to the [faction.faction_role_text] faction.")

	player.rev_cooldown = world.time + 10 SECONDS
	var/choice = alert(player.current, "Asked by [src]: Do you want to join the [faction.faction_descriptor]?","Join the [faction.faction_descriptor]?","No!","Yes!")
	if(!(player.current in able_mobs_in_oview(src)))
		return
	if(choice == "Yes!" && faction.add_antagonist_mind(player, TRUE, faction.faction_role_text, faction.faction_welcome))
		to_chat(src, SPAN_NOTICE("\The [player.current] joins the [faction.faction_descriptor]!"))
		return
	if(choice == "No!")
		to_chat(player, SPAN_DANGER("You reject this traitorous cause!"))
	to_chat(src, SPAN_DANGER("\The [player.current] does not support the [faction.faction_descriptor]!"))

/mob/living/proc/convert_to_loyalist(mob/M in able_mobs_in_oview(src))
	set name = "Convert Recidivist"
	set category = "Abilities"

	if(!(M in able_mobs_in_oview(src)))
		return
	if(!M.mind || !M.client)
		return
	if(!ishuman(M))
		return
	if(!(src in able_mobs_in_oview(M)))
		to_chat(src, SPAN_WARNING("\The [M] can't see you."))
		return

	convert_to_faction(M.mind, GLOB.loyalists)
