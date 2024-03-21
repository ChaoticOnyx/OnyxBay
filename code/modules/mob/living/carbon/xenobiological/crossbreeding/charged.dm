/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/metroidcross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
	effect = "charged"
	icon_state = "charged"

/obj/item/metroidcross/charged/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/metroidcross/charged/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, SPAN_WARNING("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, SPAN_NOTICE("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	playsound(src, GET_SFX(SFX_SPARK_MEDIUM), 50, TRUE)
	do_effect(user)

/obj/item/metroidcross/charged/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/metroidcross/charged/green
	colour = "green"
	effect_desc = "Produces a metroid reviver potion, which revives dead metroids."

/obj/item/metroidcross/charged/green/do_effect(mob/user)
	new /obj/item/metroidpotion/metroid_reviver(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/orange
	colour = "orange"
	effect_desc = "Instantly makes a large burst of flame for a moment."

/obj/item/metroidcross/charged/orange/do_effect(mob/user)
	var/turf/targetturf = get_turf(user)
	for(var/turf/T in range(pick(RANGE_TURFS(5,targetturf)),1))
		if(!iswall(T))
			new /obj/effect/decal/cleanable/liquid_fuel(T)
			T.hotspot_expose((40 CELSIUS) + 380, 500)
	..()

/obj/item/metroidcross/charged/purple
	colour = "purple"
	effect_desc = "Creates a packet of omnizine."

/obj/item/metroidcross/charged/purple/do_effect(mob/user)
	new /obj/item/metroidcrossbeaker/tricordrazine(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] sparks, and floods with a regenerative solution!"))
	..()

/obj/item/metroidcross/charged/blue
	colour = "blue"
	effect_desc = "Creates a potion that neuters the mutation chance of a metroid, which passes on to new generations."

/obj/item/metroidcross/charged/blue/do_effect(mob/user)
	new /obj/item/metroidpotion/metroid/chargedstabilizer(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/metal
	colour = "metal"
	effect_desc = "Produces a bunch of metal and plasteel."

/obj/item/metroidcross/charged/metal/do_effect(mob/user)
	new /obj/item/stack/material/steel/ten(get_turf(user))
	new /obj/item/stack/material/steel/ten(get_turf(user))
	new /obj/item/stack/material/plasteel/ten(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] grows into a plethora of metals!"))
	..()

/obj/item/metroidcross/charged/yellow
	colour = "yellow"
	effect_desc = "Creates a hypercharged metroid cell battery, which has high capacity but takes longer to recharge."

/obj/item/metroidcross/charged/yellow/do_effect(mob/user)
	new /obj/item/cell/high/metroid_hypercharged(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] sparks violently, and swells with electric power!"))
	..()

/obj/item/metroidcross/charged/darkpurple
	colour = "dark purple"
	effect_desc = "Creates several sheets of plasma."

/obj/item/metroidcross/charged/darkpurple/do_effect(mob/user)
	new /obj/item/stack/material/plasma/ten(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] produces a large amount of plasma!"))
	..()

/obj/item/metroidcross/charged/darkblue
	colour = "dark blue"
	effect_desc = "Produces a pressure proofing potion."

/obj/item/metroidcross/charged/darkblue/do_effect(mob/user)
	new /obj/item/metroidpotion/spaceproof(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/silver
	colour = "silver"
	effect_desc = "Creates a metroid cake and some drinks."

/obj/item/metroidcross/charged/silver/do_effect(mob/user)
	new /obj/item/reagent_containers/food/sliceable/metroidcake(get_turf(user))
	for(var/i in 1 to 10)
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
		new drink_type(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] produces a party's worth of cake and drinks!"))
	..()

/obj/item/metroidcross/charged/bluespace
	colour = "bluespace"
	effect_desc = "Makes a bluespace polycrystal."

/obj/item/metroidcross/charged/bluespace/do_effect(mob/user)
	new /obj/item/stack/telecrystal/bluespace_crystal(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] produces a polycrystal!"))
	..()

/obj/item/metroidcross/charged/sepia
	colour = "sepia"
	effect_desc = "Creates a camera obscura."

/obj/item/metroidcross/charged/sepia/do_effect(mob/user)
	new /obj/item/device/camera/spooky(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] flickers in a strange, ethereal manner, and produces a camera!"))
	..()

/obj/item/metroidcross/charged/cerulean
	colour = "cerulean"
	effect_desc = "Creates an extract enhancer, giving whatever it's used on five more uses."

/obj/item/metroidcross/charged/cerulean/do_effect(mob/user)
	new /obj/item/metroidpotion/enhancer/max(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/pyrite
	colour = "pyrite"
	effect_desc = "Creates bananium. Oh no."

/obj/item/metroidcross/charged/pyrite/do_effect(mob/user)
	to_chat(user, SPAN_DANGER(FONT_LARGE("The higher beings don't like your actions, so they change the course of events")))
	new /obj/item/bananapeel(get_turf(user), 3)
	user.visible_message(SPAN_WARNING("[src] solidifies with a horrifying banana stench!"))
	..()

/obj/item/metroidcross/charged/red
	colour = "red"
	effect_desc = "Produces a several fireproof potions"

/obj/item/metroidcross/charged/red/do_effect(mob/user)
	new /obj/item/chill_potion(get_turf(user),3)
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/grey
	colour = "grey"
	effect_desc = "Lets you choose what metroid species you want to be."

/obj/item/metroidcross/charged/grey/do_effect(mob/user)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		to_chat(user, SPAN_WARNING("You must be a humanoid to use this!"))
		return
	var/list/choice_list = list(
		SPECIES_PROMETHEAN,
		SPECIES_STARGAZER,
		SPECIES_SLIMEPERSON,
		SPECIES_LUMINESCENT,
	)

	var/racechoice = tgui_input_list(human_user, "Choose your metroid subspecies", "metroid Selection", sort_list(choice_list))
	if(isnull(racechoice))
		to_chat(user, SPAN_NOTICE("You decide not to become a metroid for now."))
		return

	if(!CanUseTopic(user))
		return

	human_user.set_species(racechoice)
	human_user.visible_message(SPAN_WARNING("[human_user] suddenly shifts form as [src] dissolves into [human_user] skin!"))
	..()

/obj/item/metroidcross/charged/pink
	colour = "pink"
	effect_desc = "Produces a... lovepotion... no naughty thoughts."

/obj/item/metroidcross/charged/pink/do_effect(mob/user)
	new /obj/item/metroidpotion/lovepotion(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/gold
	colour = "gold"
	effect_desc = "Slowly spawns 10 hostile monsters."
	var/max_spawn = 10
	var/spawned = 0
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

/obj/item/metroidcross/charged/gold/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[src] starts shuddering violently!"))
	addtimer(CALLBACK(src, nameof(.proc/startTimer)), 50)

/obj/item/metroidcross/charged/gold/proc/startTimer()
	set_next_think(world.time + 1 SECONDS)

/obj/item/metroidcross/charged/gold/think()
	visible_message(SPAN_WARNING("[src] lets off a spark, and produces a living creature!"))
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(5, 1, src)
	s.start()
	playsound(get_turf(src), GET_SFX(SFX_SPARK_MEDIUM), 50, TRUE)

	var/spawned_mob = pick(possible_mobs)
	new spawned_mob(get_turf(src))

	spawned++
	if(spawned >= max_spawn)
		set_next_think(0)
		visible_message(SPAN_WARNING("[src] collapses into a puddle of goo."))
		qdel(src)

/obj/item/metroidcross/charged/oil
	colour = "oil"
	effect_desc = "Creates an explosion after a few seconds."

/obj/item/metroidcross/charged/oil/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] begins to shake with rapidly increasing force!"))
	addtimer(CALLBACK(src, nameof(.proc/boom)), 50)

/obj/item/metroidcross/charged/oil/proc/boom()
	explosion(src, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4) //Much smaller effect than normal oils, but devastatingly strong where it does hit.
	qdel(src)

/obj/item/metroidcross/charged/black
	colour = "black"
	effect_desc = "Randomizes the user's species."

/obj/item/metroidcross/charged/black/do_effect(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		to_chat(user, SPAN_WARNING("You have to be able to have a species to get your species changed."))
		return
	var/list/allowed_species = list(
		SPECIES_HUMAN,
		SPECIES_TAJARA,
		SPECIES_DIONA,
		SPECIES_UNATHI,
		SPECIES_SKRELL,
		SPECIES_PROMETHEAN,
		SPECIES_STARGAZER,
		SPECIES_SLIMEPERSON,
		SPECIES_LUMINESCENT,
		SPECIES_GRAVWORLDER,
		SPECIES_VATGROWN,
		SPECIES_SPACER,
		SPECIES_GOLEM,
		SPECIES_GOLEM_ADAMANTINE,
		SPECIES_GOLEM_PLASMA,
		SPECIES_GOLEM_DIAMOND,
		SPECIES_GOLEM_GOLD,
		SPECIES_GOLEM_SILVER,
		SPECIES_GOLEM_PLASTEEL,
		SPECIES_GOLEM_TITANIUM,
		SPECIES_GOLEM_PLASTITANIUM,
		SPECIES_GOLEM_WOOD,
		SPECIES_GOLEM_URANIUM,
		SPECIES_GOLEM_SAND,
		SPECIES_GOLEM_GLASS,
		SPECIES_GOLEM_BLUESPACE,
		SPECIES_GOLEM_CLOTH,
		SPECIES_GOLEM_PLASTIC,
		SPECIES_GOLEM_BRONZE,
		SPECIES_GOLEM_CARDBOARD,
		SPECIES_GOLEM_LEATHER,
		SPECIES_GOLEM_HYDROGEN,
		)

	var/datum/species/changed = pick(allowed_species)
	if(changed)
		H.set_species(changed)
		to_chat(H, SPAN_DANGER("You feel very different!"))
	..()

/obj/item/metroidcross/charged/lightpink
	colour = "light pink"
	effect_desc = "Produces a pacification potion, which works on monsters and humanoids."

/obj/item/metroidcross/charged/lightpink/do_effect(mob/user)
	new /obj/item/metroidpotion/peacepotion(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/metroidcross/charged/adamantine
	colour = "adamantine"
	effect_desc = "Creates a completed golem shell."

/obj/item/metroidcross/charged/adamantine/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] produces a fully formed golem shell!"))
	new /obj/effect/mob_spawn/ghost_role/human/golem/servant(get_turf(src), /datum/species/golem/adamantine, user)
	..()

/obj/item/metroidcross/charged/rainbow
	colour = "rainbow"
	effect_desc = "Produces three living metroids of random colors."

/obj/item/metroidcross/charged/rainbow/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[src] swells and splits into three new metroids!"))
	for(var/i in 1 to 3)
		var/color = pick(list(
		"green",
		"purple",
		"metal",
		"orange",
		"blue",
		"dark blue",
		"dark purple",
		"yellow",
		"silver",
		"pink",
		"red",
		"gold",
		"grey",
		"sepia",
		"bluespace",
		"cerulean",
		"pyrite",
		"light pink",
		"oil",
		"adamantine",
		"black"))
		new /mob/living/carbon/metroid(get_turf(user), color)
	return ..()
