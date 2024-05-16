/obj/structure/flora/tree/swamp
	name = "old tree"
	desc = "An old, wicked tree that not even elves could love."
	icon = 'icons/obj/swamptree.dmi'
	icon_state = "t1"

/obj/structure/flora/tree/swamp/Initialize()
	. = ..()
	icon_state = "t[rand(6, 16)]"
	if(prob(1))
		icon_state = "mystical"

/obj/structure/swamprock
	name = "rock"
	desc = "A rock protuding from the ground."
	icon_state = "rock1"
	icon = 'icons/obj/swamp_flora.dmi'
	opacity = 0
	density = TRUE
	layer = TABLE_LAYER
	alpha = 255

/obj/structure/swamprock/Initialize()
	. = ..()
	icon_state = "rock[rand(1, 4)]"

/obj/structure/flora/thorn_bush
	name = "thorn bush"
	desc = "A thorny bush, watch your step!"
	icon_state = "thornbush"
	icon = 'icons/obj/swamp_flora.dmi'

/obj/structure/flora/thorn_bush/Crossed(atom/movable/AM) // Fuck this, fuck optimization, fuck common sense. ~Filatelele
	. = ..()
	playsound(get_turf(src), GET_SFX(SFX_PLANTCROSS), 100, FALSE, -1)

	if(isliving(AM))
		var/mob/living/L = AM
		var/datum/species/crossed_species = all_species[L.get_species()]
		if(L?.cached_slowdown >= crossed_species.walk_speed_perc * config.movement.walk_speed)
			return

		if(!ishuman(L))
			to_chat(L, SPAN_WARNING("You are cut on a thorn!"))
			L.apply_damage(5, BRUTE)
			return

		var/mob/living/carbon/human/H = L
		var/obj/item/organ/external/organ = pick(H.organs)
		if(!(crossed_species.species_flags & SPECIES_FLAG_NO_EMBED) && prob(20))
			var/obj/item/thorn/thorn = new()
			thorn.forceMove(organ)
			organ.embed(thorn)
			to_chat(H, SPAN_DANGER("\A [thorn] impales your [organ]!"))
		else
			to_chat(H, SPAN_WARNING("A thorn [pick("slices","cuts","nicks")] your [organ.name]!"))
			organ.take_external_damage(10, 0, DAM_SHARP, src)

		if(H.can_feel_pain())
			H.emote("scream")

/obj/item/thorn
	name = "thorn"
	icon_state = "thorn"
	desc = "This bog-grown thorn is sharp and resistant like a needle."
	force = 10
	throwforce = 0
	sharp = TRUE

/obj/structure/flora/swampgrass
	name = "grass"
	desc = "Green, soft and lively."
	icon = 'icons/obj/swamp_flora.dmi'
	icon_state = "grass1"

/obj/structure/flora/swampgrass/Initialize()
	. = ..()
	icon_state = "grass[rand(1, 6)]"

/obj/structure/flora/swampgrass/bush
	name = "bush"
	desc = "A bush, I think I can see some spiders crawling in it."
	icon_state = "bush1"

/obj/structure/flora/swampgrass/bush/Initialize()
	. = ..()
	icon_state = "bush[rand(1, 4)]"
