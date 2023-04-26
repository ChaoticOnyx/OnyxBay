/obj/item/metroid_extract
	name = "metroid extract"
	desc = "Goo extracted from a metroid. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/metroids.dmi'
	icon_state = "green metroid extract"
	force = 1.0
	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_range = 6
	origin_tech = list(TECH_BIO = 4)
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
	var/effectmod = ""
	var/recurring = FALSE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

/obj/item/metroid_extract/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/metroidsteroid2))
		if(enhanced == 1)
			to_chat(user, "<span class='warning'> This extract has already been enhanced!</span>")
			return ..()
		if(Uses == 0)
			to_chat(user, "<span class='warning'> You can't enhance a used extract!</span>")
			return ..()
		to_chat(user, "You apply the enhancer. It now has triple the amount of uses.")
		Uses = 3
		enhanced = 1
		qdel(O)

	if(O.type == /obj/item/metroidpotion/enhancer/max)
		to_chat(user, SPAN_NOTICE("You dump the maximizer on the metroid extract. It can now be used a total of 5 times!"))
		Uses = 5
		enhanced = 1
		qdel(O)

/obj/item/metroid_extract/New()
	..()
	create_reagents(100)

/obj/item/metroid_extract/proc/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	to_chat(user, SPAN_WARNING("Nothing happened... This metroid extract cannot be activated this way."))
	return FALSE

/obj/item/metroid_extract/grey
	name = "grey metroid extract"
	icon_state = "grey metroid extract"
	effectmod = "reproductive"

/obj/item/metroid_extract/grey/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/reagent_containers/food/monkeycube/M = new
			if(!user.put_in_active_hand(M))
				M.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			to_chat(user, SPAN_NOTICE("You spit out a monkey cube."))
			return 120
		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_NOTICE("Your [name] starts pulsing..."))
			if(do_after(user, 40, target = user))
				var/mob/living/carbon/metroid/S = new(get_turf(user), "grey")
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				to_chat(user, SPAN_NOTICE("You spit out [S]."))
				return 350
			else
				return 0

/obj/item/metroid_extract/gold
	name = "gold metroid extract"
	icon_state = "gold metroid extract"
	effectmod = "symbiont"
/*FIXME
/obj/item/metroid_extract/gold/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.visible_message(SPAN_WARNING("[user] starts shaking!"),SPAN_NOTICE("Your [name] starts pulsing gently..."))
			if(do_after(user, 40, target = user))
				var/mob/living/spawned_mob = create_random_mob(user.drop_location(), FRIENDLY_SPAWN)
				spawned_mob.faction |= FACTION_NEUTRAL
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(SPAN_WARNING("[user] spits out [spawned_mob]!"), SPAN_NOTICE("You spit out [spawned_mob]!"))
				return 300

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user] starts shaking violently!"),SPAN_WARNING("Your [name] starts pulsing violently..."))
			if(do_after(user, 50, target = user))
				var/mob/living/spawned_mob = create_random_mob(user.drop_location(), HOSTILE_SPAWN)
				if(!user.combat_mode)
					spawned_mob.faction |= FACTION_NEUTRAL
				else
					spawned_mob.faction |= FACTION_METROID
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(SPAN_WARNING("[user] spits out [spawned_mob]!"), SPAN_WARNING("You spit out [spawned_mob]!"))
				return 600
*/
/obj/item/metroid_extract/silver
	name = "silver metroid extract"
	icon_state = "silver metroid extract"
	effectmod = "consuming"
/*FIXME
/obj/item/metroid_extract/silver/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/food_type = get_random_food()
			var/obj/item/food/food_item = new food_type
			ADD_TRAIT(food_item, TRAIT_FOOD_SILVER, INNATE_TRAIT)
			if(!user.put_in_active_hand(food_item))
				food_item.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [food_item]!"), SPAN_NOTICE("You spit out [food_item]!"))
			return 200
		if(METROID_ACTIVATE_MAJOR)
			var/drink_type = get_random_drink()
			var/obj/O = new drink_type
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 200
*/
/obj/item/metroid_extract/metal
	name = "metal metroid extract"
	icon_state = "metal metroid extract"
	effectmod = "industrial"

/obj/item/metroid_extract/metal/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/stack/material/glass/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/obj/item/stack/material/iron/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 200

/obj/item/metroid_extract/purple
	name = "purple metroid extract"
	icon_state = "purple metroid extract"
	effectmod = "regenerative"

/obj/item/metroid_extract/purple/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.nutrition+=50
			user.regenerate_blood(50)
			to_chat(user, SPAN_NOTICE("You activate [src], and your body is refilled with fresh metroid jelly!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_NOTICE("You activate [src], and it releases regenerative chemicals!"))
			user.reagents.add_reagent(/datum/reagent/regen_jelly,10)
			return 600

/obj/item/metroid_extract/darkpurple
	name = "dark purple metroid extract"
	icon_state = "dark purple metroid extract"
	effectmod = "self-sustaining"

/obj/item/metroid_extract/darkpurple/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/stack/material/plasma/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/turf/T = get_turf(user)
			if(istype(T))
				T.assume_gas("plasma",20)
			to_chat(user, SPAN_WARNING("You activate [src], and a cloud of plasma bursts out of your skin!"))
			return 900

/obj/item/metroid_extract/orange
	name = "orange metroid extract"
	icon_state = "orange metroid extract"
	effectmod = "burning"

/obj/item/metroid_extract/orange/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_NOTICE("You activate [src]. You start feeling hot!"))
			user.reagents.add_reagent(/datum/reagent/capsaicin,10)
			return 150

		if(METROID_ACTIVATE_MAJOR)
			user.reagents.add_reagent(/datum/reagent/phosphorus,5)//
			user.reagents.add_reagent(/datum/reagent/potassium,5) // = smoke, along with any reagents inside mr. metroid
			user.reagents.add_reagent(/datum/reagent/sugar,5)     //
			to_chat(user, SPAN_WARNING("You activate [src], and a cloud of smoke bursts out of your skin!"))
			return 450

/obj/item/metroid_extract/yellow
	name = "yellow metroid extract"
	icon_state = "yellow metroid extract"
	effectmod = "charged"

/obj/item/metroid_extract/yellow/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(species.glow_intensity != LUMINESCENT_DEFAULT_GLOW)
				to_chat(user, SPAN_WARNING("Your glow is already enhanced!"))
				return
			species.update_glow(user, 5)
			addtimer(CALLBACK(species, /datum/species/promethean/luminescent/proc/update_glow, user, LUMINESCENT_DEFAULT_GLOW), 600)
			to_chat(user, SPAN_NOTICE("You start glowing brighter."))

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user]'s skin starts flashing intermittently..."), SPAN_WARNING("Your skin starts flashing intermittently..."))
			if(do_after(user, 25, target = user))
				empulse(user, 1, 2)
				user.visible_message(SPAN_WARNING("[user]'s skin flashes!"), SPAN_WARNING("Your skin flashes as you emit an electromagnetic pulse!"))
				return 600

/obj/item/metroid_extract/red
	name = "red metroid extract"
	icon_state = "red metroid extract"
	effectmod = "sanguine"

/obj/item/metroid_extract/red/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_NOTICE("You activate [src]. You start feeling fast!"))
			user.reagents.add_reagent(/datum/reagent/inaprovaline,5)
			return 450

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user]'s skin flashes red for a moment..."), SPAN_WARNING("Your skin flashes red as you emit rage-inducing pheromones..."))
			for(var/mob/living/carbon/metroid/metroid in viewers(get_turf(user), null))
				metroid.rabid = TRUE
				metroid.visible_message(SPAN_DANGER("The [metroid] is driven into a frenzy!"))
			return 600

/obj/item/metroid_extract/blue
	name = "blue metroid extract"
	icon_state = "blue metroid extract"
	effectmod = "stabilized"

/obj/item/metroid_extract/blue/obj/item/metroid_extract/blue/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_NOTICE("You activate [src]. Your genome feels more stable!"))
			user.adjustCloneLoss(-15)
			/*FIXME
			user.reagents.add_reagent(/datum/reagent/mutadone, 10)
			user.reagents.add_reagent(/datum/reagent/potass_iodide, 10)
			*/
			return 250

		if(METROID_ACTIVATE_MAJOR)
			/*FIXME
			user.reagents.create_foam(/datum/effect_system/fluid_spread/foam, 20, log = TRUE)
			user.visible_message(SPAN_DANGER("Foam spews out from [user]'s skin!"), SPAN_WARNING("You activate [src], and foam bursts out of your skin!"))
			*/
			return 600

/obj/item/metroid_extract/darkblue
	name = "dark blue metroid extract"
	icon_state = "dark blue metroid extract"
	effectmod = "chilling"

/obj/item/metroid_extract/darkblue/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_NOTICE("You activate [src]. You start feeling colder!"))
			user.ExtinguishMob()
			user.adjust_fire_stacks(-20)
			user.reagents.add_reagent(/datum/reagent/frostoil,6)
			user.reagents.add_reagent(/datum/reagent/regen_jelly,7)
			return 100

		if(METROID_ACTIVATE_MAJOR)
			var/turf/T = get_turf(user)
			if(istype(T))
				T.assume_gas("nitrogen",40,2.7)
			to_chat(user, SPAN_WARNING("You activate [src], and icy air bursts out of your skin!"))
			return 900

/obj/item/metroid_extract/pink
	name = "pink metroid extract"
	icon_state = "pink metroid extract"
	effectmod = "gentle"

/obj/item/metroid_extract/pink/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(user.gender != MALE && user.gender != FEMALE)
				to_chat(user, SPAN_WARNING("You can't swap your gender!"))
				return

			if(user.gender == MALE)
				user.gender = FEMALE
				user.visible_message(SPAN("bold", SPAN_NOTICE("[user] suddenly looks more feminine!")), SPAN("bold", SPAN_WARNING("You suddenly feel more feminine!")))
			else
				user.gender = MALE
				user.visible_message(SPAN("bold", SPAN_NOTICE("[user] suddenly looks more masculine!")), SPAN("bold", SPAN_WARNING("You suddenly feel more masculine!")))
			return 100

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user]'s skin starts flashing hypnotically..."), SPAN_NOTICE("Your skin starts forming odd patterns, pacifying creatures around you."))
			for(var/mob/living/carbon/C in viewers(user, null))
				if(C != user)
					C.reagents.add_reagent(/datum/reagent/paroxetine,2)
			return 600

/obj/item/metroid_extract/green
	name = "green metroid extract"
	icon_state = "green metroid extract"
	effectmod = "mutative"

/obj/item/metroid_extract/green/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_WARNING("You feel yourself reverting to human form..."))
			if(do_after(user, 120, target = user))
				to_chat(user, SPAN_WARNING("You feel human again!"))
				user.set_species(/datum/species/human)
				return
			to_chat(user, SPAN_NOTICE("You stop the transformation."))

		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_WARNING("You feel yourself radically changing your metroid type..."))
			if(do_after(user, 120, target = user))
				to_chat(user, SPAN_WARNING("You feel different!"))
				user.set_species(pick(/datum/species/promethean/slime, /datum/species/promethean/stargazer))
				return
			to_chat(user, SPAN_NOTICE("You stop the transformation."))

/obj/item/metroid_extract/lightpink
	name = "light pink metroid extract"
	icon_state = "light pink metroid extract"
	effectmod = "loyal"

/obj/item/metroid_extract/lightpink/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/metroidpotion/renaming/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			//FIXME var/obj/item/metroidpotion/metroid/sentience/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 450

/obj/item/metroid_extract/black
	name = "black metroid extract"
	icon_state = "black metroid extract"
	effectmod = "transformative"

/obj/item/metroid_extract/black/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_DANGER("You feel something <i>wrong</i> inside you..."))
			user.ForceContractDisease(new /datum/disease/transformation/metroid(), FALSE, TRUE)
			return 100

		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_WARNING("You feel your own light turning dark..."))
			if(do_after(user, 120, target = user))
				to_chat(user, SPAN_WARNING("You feel a longing for darkness."))
				user.set_species(pick(/datum/species/shadow))
				return
			to_chat(user, SPAN_NOTICE("You stop feeding [src]."))

/obj/item/metroid_extract/oil
	name = "oil metroid extract"
	icon_state = "oil metroid extract"
	effectmod = "detonating"

/obj/item/metroid_extract/oil/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_WARNING("You vomit slippery oil."))
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			new /obj/effect/decal/cleanable/oil/slippery(get_turf(user))
			return 450

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user]'s skin starts pulsing and glowing ominously..."), SPAN_DANGER("You feel unstable..."))
			if(do_after(user, 60, target = user))
				to_chat(user, SPAN_DANGER("You explode!"))
				explosion(user, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6, explosion_cause = src)
				user.investigate_log("has been gibbed by an oil metroid extract explosion.", INVESTIGATE_DEATHS)
				user.gib()
				return
			to_chat(user, SPAN_NOTICE("You stop feeding [src], and the feeling passes."))


/obj/item/metroid_extract/adamantine
	name = "adamantine metroid extract"
	icon_state = "adamantine metroid extract"
	effectmod = "crystalline"

/obj/item/metroid_extract/adamantine/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(species.armor > 0)
				to_chat(user, SPAN_WARNING("Your skin is already hardened!"))
				return
			to_chat(user, SPAN_NOTICE("You feel your skin harden and become more resistant."))
			species.armor += 25
			addtimer(CALLBACK(src, PROC_REF(reset_armor), species), 1200)
			return 450

		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_WARNING("You feel your body rapidly crystallizing..."))
			if(do_after(user, 120, target = user))
				to_chat(user, SPAN_WARNING("You feel solid."))
				user.set_species(pick(/datum/species/golem/adamantine))
				return
			to_chat(user, SPAN_NOTICE("You stop feeding [src], and your body returns to its metroidlike state."))

/obj/item/metroid_extract/adamantine/proc/reset_armor(datum/species/promethean/luminescent/species)
	if(istype(species))
		species.armor -= 25

/obj/item/metroid_extract/bluespace
	name = "bluespace metroid extract"
	icon_state = "bluespace metroid extract"
	effectmod = "warping"

/obj/item/metroid_extract/bluespace/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			to_chat(user, SPAN_WARNING("You feel your body vibrating..."))
			if(do_after(user, 25, target = user))
				to_chat(user, SPAN_WARNING("You teleport!"))
				do_teleport(user, get_turf(user), 6, asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
				return 300

		if(METROID_ACTIVATE_MAJOR)
			if(!teleport_ready)
				to_chat(user, SPAN_NOTICE("You feel yourself anchoring to this spot..."))
				var/turf/T = get_turf(user)
				teleport_x = T.x
				teleport_y = T.y
				teleport_z = T.z
				teleport_ready = TRUE
			else
				teleport_ready = FALSE
				if(teleport_x && teleport_y && teleport_z)
					var/turf/T = locate(teleport_x, teleport_y, teleport_z)
					to_chat(user, SPAN_NOTICE("You snap back to your anchor point!"))
					do_teleport(user, T,  asoundin = 'sound/weapons/emitter2.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
					return 450

/obj/item/metroid_extract/pyrite
	name = "pyrite metroid extract"
	icon_state = "pyrite metroid extract"
	effectmod = "prismatic"

/obj/item/metroid_extract/pyrite/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/chosen = pick(difflist(subtypesof(/obj/item/toy/crayon),typesof(/obj/item/toy/crayon/spraycan)))
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/blacklisted_cans = list(/obj/item/toy/crayon/spraycan/borg, /obj/item/toy/crayon/spraycan/infinite)
			var/chosen = pick(subtypesof(/obj/item/toy/crayon/spraycan) - blacklisted_cans)
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 250

/obj/item/metroid_extract/cerulean
	name = "cerulean metroid extract"
	icon_state = "cerulean metroid extract"
	effectmod = "recurring"

/obj/item/metroid_extract/cerulean/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.reagents.add_reagent(/datum/reagent/medicine/salbutamol,15)
			to_chat(user, SPAN_NOTICE("You feel like you don't need to breathe!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/turf/T = get_turf(user)
			if(istype(T))
				T.atmos_spawn_air("o2=11;n2=41;TEMP=293.15")
				to_chat(user, SPAN_WARNING("You activate [src], and fresh air bursts out of your skin!"))
				return 600

/obj/item/metroid_extract/sepia
	name = "sepia metroid extract"
	icon_state = "sepia metroid extract"
	effectmod = "lengthened"

/obj/item/metroid_extract/sepia/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/camera/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			to_chat(user, SPAN_WARNING("You feel time slow down..."))
			if(do_after(user, 30, target = user))
				new /obj/effect/timestop(get_turf(user), 2, 50, list(user))
				return 900

/obj/item/metroid_extract/rainbow
	name = "rainbow metroid extract"
	icon_state = "rainbow metroid extract"
	effectmod = "hyperchromatic"

/obj/item/metroid_extract/rainbow/activate(mob/living/carbon/human/user, datum/species/promethean/luminescent/species, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.dna.features["mcolor"] = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
			user.dna.update_uf_block(DNA_MUTANT_COLOR_BLOCK)
			user.updateappearance(mutcolor_update=1)
			species.update_glow(user)
			to_chat(user, SPAN_NOTICE("You feel different..."))
			return 100

		if(METROID_ACTIVATE_MAJOR)
			var/chosen = pick(subtypesof(/obj/item/metroid_extract))
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150
