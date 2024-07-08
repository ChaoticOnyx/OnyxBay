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
	can_get_wet = FALSE
	can_be_wrung_out = FALSE
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
	var/effectmod = ""
	var/recurring = FALSE
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/list/activate_reagents = list()

/obj/item/metroid_extract/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/metroidsteroid2))
		if(enhanced == 1)
			show_splash_text(user, SPAN_WARNING("This extract has already been enhanced!"))
			return ..()
		if(Uses == 0)
			show_splash_text(user, SPAN_WARNING("You can't enhance a used extract!"))
			return ..()
		show_splash_text(user, "You apply the enhancer. It now has triple the amount of uses.")
		Uses = 3
		enhanced = 1
		qdel(O)

	if(O.type == /obj/item/metroidpotion/enhancer/max)
		show_splash_text(user, SPAN_NOTICE("You dump the maximizer on the metroid extract. It can now be used a total of 5 times!"))
		Uses = 5
		enhanced = 1
		qdel(O)

/obj/item/metroid_extract/New()
	..()
	create_reagents(100)

/obj/item/metroid_extract/proc/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	show_splash_text(user, SPAN_WARNING("Nothing happened... This metroid extract cannot be activated this way."))
	return FALSE

/obj/item/metroid_extract/grey
	name = "grey metroid extract"
	icon_state = "grey metroid extract"
	effectmod = "mutative"

/obj/item/metroid_extract/grey/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_WARNING("You feel yourself reverting to human form..."))
			if(do_after(user, 120, target = user))
				show_splash_text(user, SPAN_WARNING("You feel human again!"))
				user.set_species(SPECIES_HUMAN)
				return
			show_splash_text(user, SPAN_NOTICE("You stop the transformation."))

		if(METROID_ACTIVATE_MAJOR)
			show_splash_text(user, SPAN_WARNING("You feel yourself radically changing your metroid type..."))
			if(do_after(user, 120, target = user))
				show_splash_text(user, SPAN_WARNING("You feel different!"))
				user.set_species(pick(SPECIES_SLIMEPERSON, SPECIES_STARGAZER))
				return
			show_splash_text(user, SPAN_NOTICE("You stop the transformation."))

/obj/item/metroid_extract/gold
	name = "gold metroid extract"
	icon_state = "gold metroid extract"
	effectmod = "symbiont"

/obj/item/metroid_extract/gold/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.visible_message(SPAN_WARNING("[user] starts shaking!"),SPAN_NOTICE("Your [name] starts pulsing gently..."))
			if(do_after(user, 40, target = user))
				var/list/possible_mobs = list(
					/mob/living/simple_animal/cat,
					/mob/living/simple_animal/cat/kitten,
					/mob/living/simple_animal/corgi,
					/mob/living/simple_animal/corgi/puppy,
					/mob/living/simple_animal/cow,
					/mob/living/simple_animal/chick,
					/mob/living/simple_animal/chicken
					)
				var/mob/living/path = pick(possible_mobs)
				var/mob/living/spawned_mob = new path(get_turf(user))
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(SPAN_WARNING("[user] spits out [spawned_mob]!"), SPAN_NOTICE("You spit out [spawned_mob]!"))
				return 300

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user] starts shaking violently!"),SPAN_WARNING("Your [name] starts pulsing violently..."))
			if(do_after(user, 50, target = user))
				var/list/possible_mobs = list(
							/mob/living/simple_animal/hostile/faithless,
							/mob/living/simple_animal/hostile/creature,
							/mob/living/simple_animal/hostile/bear,
							/mob/living/simple_animal/hostile/maneater,
							/mob/living/simple_animal/hostile/mimic,
							/mob/living/simple_animal/hostile/carp/pike,
							/mob/living/simple_animal/hostile/tree,
							/mob/living/simple_animal/hostile/vagrant,
							/mob/living/simple_animal/hostile/voxslug
							)
				var/mob/living/path = pick(possible_mobs)
				var/mob/living/spawned_mob = new path(get_turf(user))
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				user.visible_message(SPAN_WARNING("[user] spits out [spawned_mob]!"), SPAN_WARNING("You spit out [spawned_mob]!"))
				return 600

/obj/item/metroid_extract/silver
	name = "silver metroid extract"
	icon_state = "silver metroid extract"
	effectmod = "consuming"

/obj/item/metroid_extract/silver/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/path = pick(typesof(/obj/item/reagent_containers/food) - /obj/item/reagent_containers/food)
			var/obj/item/reagent_containers/food/food_item = new path(get_turf(user))
			if(!user.put_in_active_hand(food_item))
				food_item.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [food_item]!"), SPAN_NOTICE("You spit out [food_item]!"))
			return 200
		if(METROID_ACTIVATE_MAJOR)
			var/drink_type = pick(list(
				/obj/item/reagent_containers/vessel/bottle/patron,
				/obj/item/reagent_containers/vessel/bottle/goldschlager,
				/obj/item/reagent_containers/vessel/bottle/specialwhiskey,
				/obj/item/reagent_containers/vessel/bottle/small/ale,
				/obj/item/reagent_containers/vessel/bottle/small/beer,
				/obj/item/reagent_containers/vessel/coffee,
				/obj/item/reagent_containers/vessel/tea,
				/obj/item/reagent_containers/vessel/h_chocolate
			))
			var/obj/O = new drink_type
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 200

/obj/item/metroid_extract/metal
	name = "metal metroid extract"
	icon_state = "metal metroid extract"
	effectmod = "industrial"

/obj/item/metroid_extract/metal/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/stack/material/glass/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/obj/item/stack/material/steel/O = new(null, 5)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 200

/obj/item/metroid_extract/purple
	name = "purple metroid extract"
	icon_state = "purple metroid extract"
	effectmod = "regenerative"

/obj/item/metroid_extract/purple/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.nutrition+=50
			user.reagents.add_reagent(/datum/reagent/metroidjelly, 50)
			show_splash_text(user, SPAN_NOTICE("You activate [src], and your body is refilled with fresh metroid jelly!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			show_splash_text(user, SPAN_NOTICE("You activate [src], and it releases regenerative chemicals!"))
			user.reagents.add_reagent(/datum/reagent/regen_jelly,10)
			return 600

/obj/item/metroid_extract/darkpurple
	name = "dark purple metroid extract"
	icon_state = "dark purple metroid extract"
	effectmod = "self-sustaining"

/obj/item/metroid_extract/darkpurple/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
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
			show_splash_text(user, SPAN_WARNING("You activate [src], and a cloud of plasma bursts out of your skin!"))
			return 900

/obj/item/metroid_extract/orange
	name = "orange metroid extract"
	icon_state = "orange metroid extract"
	effectmod = "burning"

/obj/item/metroid_extract/orange/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_NOTICE("You activate [src]. You start feeling hot!"))
			user.reagents.add_reagent(/datum/reagent/capsaicin,10)
			return 150

		if(METROID_ACTIVATE_MAJOR)
			user.reagents.add_reagent(/datum/reagent/phosphorus,5)//
			user.reagents.add_reagent(/datum/reagent/potassium,5) // = smoke, along with any reagents inside mr. metroid
			user.reagents.add_reagent(/datum/reagent/sugar,5)     //
			show_splash_text(user, SPAN_WARNING("You activate [src], and a cloud of smoke bursts out of your skin!"))
			return 450

/obj/item/metroid_extract/yellow
	name = "yellow metroid extract"
	icon_state = "yellow metroid extract"
	effectmod = "charged"

/obj/item/metroid_extract/yellow/Initialize()
	. = ..()
	add_think_ctx("update_glow", )

/obj/item/metroid_extract/yellow/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/datum/species/promethean/luminescent/species = user.species
			if(extract_eater_comp.glow_intensity != LUMINESCENT_DEFAULT_GLOW)
				show_splash_text(user, SPAN_WARNING("Your glow is already enhanced!"))
				return

			species.update_glow(user, LUMINESCENT_ENHANCED_GLOW)
			species.set_next_think_ctx("update_glow", world.time + 40 SECONDS, user, LUMINESCENT_DEFAULT_GLOW)
			show_splash_text(user, SPAN_NOTICE("You start glowing brighter."))
			return 600

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

/obj/item/metroid_extract/red/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_NOTICE("You activate [src]. You start feeling fast!"))
			user.reagents.add_reagent(/datum/reagent/hyperzine, 5)
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

/obj/item/metroid_extract/blue/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_NOTICE("You activate [src]. Your genome feels more stable!"))
			user.adjustCloneLoss(-15)
			return 250

		if(METROID_ACTIVATE_MAJOR)
			var/datum/effect/effect/system/foam_spread/FS = new
			FS.set_up(20, get_turf(user), user.reagents)
			user.reagents.remove_any(user.reagents.total_volume)
			FS.start()
			log_admin("[user]([user.ckey]) started foam spread", get_turf(user), TRUE)
			user.visible_message(SPAN_DANGER("Foam spews out from [user]'s skin!"), SPAN_WARNING("You activate [src], and foam bursts out of your skin!"))
			return 600

/obj/item/metroid_extract/darkblue
	name = "dark blue metroid extract"
	icon_state = "dark blue metroid extract"
	effectmod = "chilling"

/obj/item/metroid_extract/darkblue/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_NOTICE("You activate [src]. You start feeling colder!"))
			user.ExtinguishMob()
			user.reagents.add_reagent(/datum/reagent/frostoil,6)
			user.reagents.add_reagent(/datum/reagent/regen_jelly,7)
			return 100

		if(METROID_ACTIVATE_MAJOR)
			var/turf/T = get_turf(user)
			if(istype(T))
				T.assume_gas("nitrogen",40,2.7)
			show_splash_text(user, SPAN_WARNING("You activate [src], and icy air bursts out of your skin!"))
			return 900

/obj/item/metroid_extract/pink
	name = "pink metroid extract"
	icon_state = "pink metroid extract"
	effectmod = "gentle"

/obj/item/metroid_extract/pink/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(user.gender != MALE && user.gender != FEMALE)
				show_splash_text(user, SPAN_WARNING("You can't swap your gender!"))
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
	effectmod = "reproductive"

/obj/item/metroid_extract/green/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/reagent_containers/food/monkeycube/M = new
			if(!user.put_in_active_hand(M))
				M.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			show_splash_text(user, SPAN_NOTICE("You spit out a monkey cube."))
			return 120
		if(METROID_ACTIVATE_MAJOR)
			show_splash_text(user, SPAN_NOTICE("Your [name] starts pulsing..."))
			if(do_after(user, 40, target = user))
				var/mob/living/carbon/metroid/S = new(get_turf(user), "green")
				playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
				show_splash_text(user, SPAN_NOTICE("You spit out [S]."))
				return 350
			else
				return 0

/obj/item/metroid_extract/lightpink
	name = "light pink metroid extract"
	icon_state = "light pink metroid extract"
	effectmod = "loyal"

/obj/item/metroid_extract/lightpink/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/metroidpotion/renaming/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			for(var/mob/living/carbon/C in viewers(user, null))
				C.add_modifier(/datum/modifier/trait/pacifism, 450)
			return 450

/obj/item/metroid_extract/black
	name = "black metroid extract"
	icon_state = "black metroid extract"
	effectmod = "transformative"

/obj/item/metroid_extract/black/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_DANGER("You feel something <i>wrong</i> inside you..."))
			var/datum/spell/targeted/shapeshift/metroid_form/transform = new()
			transform.cast(user)
			return 100

		if(METROID_ACTIVATE_MAJOR)
			show_splash_text(user, SPAN_WARNING("You feel your own light turning dark..."))
			if(do_after(user, 120, target = user))
				if(!player_is_antag(user.mind))
					show_splash_text(user, SPAN_WARNING("You feel a longing for darkness."))
					user.set_species(pick(
						SPECIES_HUMAN,
						SPECIES_GRAVWORLDER,
						SPECIES_SPACER,
						SPECIES_VATGROWN,
						SPECIES_TAJARA,
						SPECIES_UNATHI,
						SPECIES_SKRELL,
						SPECIES_SWINE,
					))
					user.make_vampire()
					return
			show_splash_text(user, SPAN_NOTICE("You don't fell linkage with darkness"))

/obj/item/metroid_extract/oil
	name = "oil metroid extract"
	icon_state = "oil metroid extract"
	effectmod = "detonating"

/obj/item/metroid_extract/oil/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_WARNING("You vomit slippery oil."))
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			var/turf/simulated/T = get_turf(user)
			new /obj/effect/decal/cleanable/blood/oil(T)
			T.wet_floor(2)
			return 450

		if(METROID_ACTIVATE_MAJOR)
			user.visible_message(SPAN_WARNING("[user]'s skin starts pulsing and glowing ominously..."), SPAN_DANGER("You feel unstable..."))
			if(do_after(user, 60, target = user))
				show_splash_text(user, SPAN_DANGER("You explode!"))
				explosion(user, devastation_range = 1, heavy_impact_range = 3, light_impact_range = 6)
				user.gib()
				return
			show_splash_text(user, SPAN_NOTICE("You stop feeding [src], and the feeling passes."))


/obj/item/metroid_extract/adamantine
	name = "adamantine metroid extract"
	icon_state = "adamantine metroid extract"
	effectmod = "crystalline"

/obj/item/metroid_extract/adamantine/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(HAS_TRAIT(user, /datum/modifier/status_effect/adamantine))
				show_splash_text(user, SPAN_WARNING("Your skin is already hardened!"))
				return
			show_splash_text(user, SPAN_NOTICE("You feel your skin harden and become more resistant."))
			ADD_TRAIT(user, /datum/modifier/status_effect/adamantine)
			return 450

		if(METROID_ACTIVATE_MAJOR)
			show_splash_text(user, SPAN_WARNING("You feel your body rapidly crystallizing..."))
			if(do_after(user, 120, target = user))
				show_splash_text(user, SPAN_WARNING("You feel solid."))
				user.set_species(SPECIES_GOLEM_ADAMANTINE)
				return
			show_splash_text(user, SPAN_NOTICE("You stop feeding [src], and your body returns to its metroidlike state."))

/obj/item/metroid_extract/bluespace
	name = "bluespace metroid extract"
	icon_state = "bluespace metroid extract"
	effectmod = "warping"
	var/teleport_ready = FALSE
	var/teleport_x = 0
	var/teleport_y = 0
	var/teleport_z = 0

/obj/item/metroid_extract/bluespace/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			show_splash_text(user, SPAN_WARNING("You feel your body vibrating..."))
			if(do_after(user, 25, target = user))
				show_splash_text(user, SPAN_WARNING("You teleport!"))
				var/turf/T = get_turf(user)
				playsound(T,'sound/effects/weapons/energy/emitter.ogg')
				do_teleport(user, T, 8)
				playsound(get_turf(user),'sound/effects/weapons/energy/emitter.ogg')
				return 300

		if(METROID_ACTIVATE_MAJOR)
			if(!teleport_ready)
				show_splash_text(user, SPAN_NOTICE("You feel yourself anchoring to this spot..."))
				var/turf/T = get_turf(user)
				teleport_x = T.x
				teleport_y = T.y
				teleport_z = T.z
				teleport_ready = TRUE
			else
				teleport_ready = FALSE
				if(teleport_x && teleport_y && teleport_z)
					var/turf/T = locate(teleport_x, teleport_y, teleport_z)
					show_splash_text(user, SPAN_NOTICE("You snap back to your anchor point!"))
					playsound(get_turf(user),'sound/effects/weapons/energy/emitter.ogg')
					do_teleport(user, T)
					playsound(T,'sound/effects/weapons/energy/emitter.ogg')
					return 450

/obj/item/metroid_extract/pyrite
	name = "pyrite metroid extract"
	icon_state = "pyrite metroid extract"
	effectmod = "prismatic"

/obj/item/metroid_extract/pyrite/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/crayon_type = pick(subtypesof(/obj/item/pen/crayon) - /obj/item/pen/crayon/random)
			var/obj/item/O = new crayon_type
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/chosen = pick(subtypesof(/obj/item/reagent_containers/vessel/paint))
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

/obj/item/metroid_extract/cerulean/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			if(!istype(user.get_active_hand(), /obj/item/tank))
				show_splash_text(user, SPAN_NOTICE("You need to hold something capable to hold gases!"))
				return 0

			var/obj/item/tank/tank = user.get_active_hand()
			visible_message(SPAN_NOTICE("\The [user] started to blow into \the [tank]."), SPAN_NOTICE("You started to blow into \the [tank]."))
			if(!do_after(user, 30 SECONDS, target = user))
				return

			var/datum/gas_mixture/GM = new
			GM.adjust_gas("oxygen", (ONE_ATMOSPHERE*tank.volume / (R_IDEAL_GAS_EQUATION * (30 CELSIUS))))
			var/datum/gas_mixture/tank_GM = tank.return_air()
			tank_GM.add(GM)
			show_splash_text(user, SPAN_NOTICE("You're feeling some dizziness, and decided to stop!"))
			return 300

		if(METROID_ACTIVATE_MAJOR)
			var/turf/T = get_turf(user)
			if(istype(T))
				T.assume_gas("oxygen", 11, 293.15)
				T.assume_gas("nitrogen", 41, 293.15)
				show_splash_text(user, SPAN_WARNING("You activate [src], and fresh air bursts out of your skin!"))
				return 600

/obj/item/metroid_extract/sepia
	name = "sepia metroid extract"
	icon_state = "sepia metroid extract"
	effectmod = "lengthened"

/obj/item/metroid_extract/sepia/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			var/obj/item/device/camera/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

		if(METROID_ACTIVATE_MAJOR)
			var/obj/item/device/camera/spooky/O = new(null, 1)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150

/obj/item/metroid_extract/rainbow
	name = "rainbow metroid extract"
	icon_state = "rainbow metroid extract"
	effectmod = "hyperchromatic"

/obj/item/metroid_extract/rainbow/activate(mob/living/carbon/human/user, datum/component/extract_eater/extract_eater_comp, activation_type)
	switch(activation_type)
		if(METROID_ACTIVATE_MINOR)
			user.dna.mcolor = "#[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]"
			user.UpdateAppearance(mutcolor_update=1)
			var/datum/species/promethean/luminescent/species = user.species
			species.update_glow(user)
			show_splash_text(user, SPAN_NOTICE("You feel different..."))
			return 100

		if(METROID_ACTIVATE_MAJOR)
			var/chosen = pick(subtypesof(/obj/item/metroid_extract))
			var/obj/item/O = new chosen(null)
			if(!user.put_in_active_hand(O))
				O.forceMove(user.drop_location())
			playsound(user, 'sound/effects/splat.ogg', 50, TRUE)
			user.visible_message(SPAN_WARNING("[user] spits out [O]!"), SPAN_NOTICE("You spit out [O]!"))
			return 150
