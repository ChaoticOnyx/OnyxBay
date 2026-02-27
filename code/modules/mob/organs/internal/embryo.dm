/obj/item/organ/internal/alien_embryo
	name = "alien embryo"
	desc = "A small worm-like creature caged in a half-transparent caviar-like thingy. Whatever this thing is, it doesn't look like it should be found in a living being by default."
	icon = 'icons/mob/alien.dmi'
	icon_state = "embryo"
	dead_icon = "embryo_dead"

	vital = FALSE
	max_damage = 66
	organ_tag = BP_EMBRYO
	parent_organ = BP_CHEST

	foreign = TRUE
	relative_size = 10
	override_species_icon = TRUE

	force = 1
	throwforce = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("attacked", "slapped", "whacked")

	origin_tech = list(TECH_BIO = 8, TECH_ILLEGAL = 2)

	var/growth = 0

/obj/item/organ/internal/alien_embryo/think()
	if(!owner || status & ORGAN_DEAD)
		return ..()

	growth++
	BITSET(owner.hud_updateflag, XENO_HUD)
	if(growth > ALIEN_EMBRYO_GROWTH_CAP)
		if(!ishuman(owner))
			return

		var/mob/living/carbon/human/H = owner
		var/larva_path = H?.species?.xenomorph_type
		if(!larva_path) // Something went very wrong, the host cannot give birth
			die()
			return

		var/birth_loc = loc
		spawn(1 SECOND) // We use spawn here for a reason. Callbacks are cool and stuff, but trust me, you should really just leave this as is.
			var/mob/living/carbon/larva/xenomorph/L = new larva_path(get_turf(birth_loc))
			L.larva_announce_to_ghosts()

		die()
		owner.gib()
		qdel(src)
		return

	else if(owner.can_feel_pain())
		var/obj/item/organ/external/parent = owner.get_organ(parent_organ)
		switch(growth)
			if(230 to INFINITY)
				if(prob(50))
					owner.custom_pain("Something is just about to burst through your chest!", 60, affecting = parent)
				owner.Weaken(10)
				owner.Stun(10)
				owner.make_jittery(100)
			if(200 to 229)
				if(prob(20))
					owner.custom_pain("You feel like your chest is ripping apart!", 45, affecting = parent)
			if(140 to 199)
				if(prob(10))
					owner.custom_pain("You feel a stabbing pain in your chest!", 15, affecting = parent)
			if(70 to 139)
				if(prob(5))
					owner.custom_pain("You feel a stinging pain in your chest!", 5, affecting = parent)

	else if(growth == ALIEN_EMBRYO_GROWTH_CAP - 5)
		to_chat(owner, SPAN("danger", "You feel like something is massacring your chest from the inside!"))
		owner.Weaken(10)
		owner.Stun(10)

	return ..()
