/*
Charged extracts:
	Have a unique, effect when filled with
	10u plasma and activated in-hand, related to their
	normal extract effect.
*/
/obj/item/slimecross/charged
	name = "charged extract"
	desc = "It sparks with electric power."
	effect = "charged"
	icon_state = "charged"

/obj/item/slimecross/charged/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/slimecross/charged/attack_self(mob/user)
	if(!reagents.has_reagent(/datum/reagent/toxin/plasma,10))
		to_chat(user, SPAN_WARNING("This extract needs to be full of plasma to activate!"))
		return
	reagents.remove_reagent(/datum/reagent/toxin/plasma,10)
	to_chat(user, SPAN_NOTICE("You squeeze the extract, and it absorbs the plasma!"))
	playsound(src, 'sound/effects/bubbles.ogg', 50, TRUE)
	//FIXME playsound(src, 'sound/effects/light_flicker.ogg', 50, TRUE)
	do_effect(user)

/obj/item/slimecross/charged/proc/do_effect(mob/user) //If, for whatever reason, you don't want to delete the extract, don't do ..()
	qdel(src)
	return

/obj/item/slimecross/charged/grey
	colour = "grey"
	effect_desc = "Produces a slime reviver potion, which revives dead slimes."

/obj/item/slimecross/charged/grey/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/slime_reviver(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/orange
	colour = "orange"
	effect_desc = "Instantly makes a large burst of flame for a moment."

/obj/item/slimecross/charged/orange/do_effect(mob/user)
	var/turf/targetturf = get_turf(user)
	/* FIXME for(var/turf/turf as anything in RANGE_TURFS(5,targetturf))
		if(!locate(/obj/effect/hotspot) in turf)
			new /obj/effect/hotspot(turf)*/
	..()

/obj/item/slimecross/charged/purple
	colour = "purple"
	effect_desc = "Creates a packet of omnizine."

/obj/item/slimecross/charged/purple/do_effect(mob/user)
	//FIXME new /obj/item/slimecrossbeaker/omnizine(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] sparks, and floods with a regenerative solution!"))
	..()

/obj/item/slimecross/charged/blue
	colour = "blue"
	effect_desc = "Creates a potion that neuters the mutation chance of a slime, which passes on to new generations."

/obj/item/slimecross/charged/blue/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/slime/chargedstabilizer(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/metal
	colour = "metal"
	effect_desc = "Produces a bunch of metal and plasteel."

/obj/item/slimecross/charged/metal/do_effect(mob/user)
	//FIXME new /obj/item/stack/sheet/iron(get_turf(user), 25)
	//FIXME new /obj/item/stack/sheet/plasteel(get_turf(user), 10)
	user.visible_message(SPAN_NOTICE("[src] grows into a plethora of metals!"))
	..()

/obj/item/slimecross/charged/yellow
	colour = "yellow"
	effect_desc = "Creates a hypercharged slime cell battery, which has high capacity but takes longer to recharge."

/obj/item/slimecross/charged/yellow/do_effect(mob/user)
	//FIXME new /obj/item/stock_parts/cell/high/slime_hypercharged(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] sparks violently, and swells with electric power!"))
	..()

/obj/item/slimecross/charged/darkpurple
	colour = "dark purple"
	effect_desc = "Creates several sheets of plasma."

/obj/item/slimecross/charged/darkpurple/do_effect(mob/user)
	//FIXME new /obj/item/stack/sheet/mineral/plasma(get_turf(user), 10)
	user.visible_message(SPAN_NOTICE("[src] produces a large amount of plasma!"))
	..()

/obj/item/slimecross/charged/darkblue
	colour = "dark blue"
	effect_desc = "Produces a pressure proofing potion."

/obj/item/slimecross/charged/darkblue/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/spaceproof(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/silver
	colour = "silver"
	effect_desc = "Creates a slime cake and some drinks."

/obj/item/slimecross/charged/silver/do_effect(mob/user)
	/*FIXME new /obj/item/food/cake/slimecake(get_turf(user))
	for(var/i in 1 to 10)
		var/drink_type = get_random_drink()
		new drink_type(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] produces a party's worth of cake and drinks!"))*/
	..()

/obj/item/slimecross/charged/bluespace
	colour = "bluespace"
	effect_desc = "Makes a bluespace polycrystal."

/obj/item/slimecross/charged/bluespace/do_effect(mob/user)
	//FIXME new /obj/item/stack/sheet/bluespace_crystal(get_turf(user), 10)
	user.visible_message(SPAN_NOTICE("[src] produces several sheets of polycrystal!"))
	..()

/obj/item/slimecross/charged/sepia
	colour = "sepia"
	effect_desc = "Creates a camera obscura."

/obj/item/slimecross/charged/sepia/do_effect(mob/user)
	//FIXME new /obj/item/camera/spooky(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] flickers in a strange, ethereal manner, and produces a camera!"))
	..()

/obj/item/slimecross/charged/cerulean
	colour = "cerulean"
	effect_desc = "Creates an extract enhancer, giving whatever it's used on five more uses."

/obj/item/slimecross/charged/cerulean/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/enhancer/max(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/pyrite
	colour = "pyrite"
	effect_desc = "Creates bananium. Oh no."

/obj/item/slimecross/charged/pyrite/do_effect(mob/user)
	//FIXME new /obj/item/stack/sheet/mineral/bananium(get_turf(user), 10)
	user.visible_message(SPAN_WARNING("[src] solidifies with a horrifying banana stench!"))
	..()

/obj/item/slimecross/charged/red
	colour = "red"
	effect_desc = "Produces a lavaproofing potion"

/obj/item/slimecross/charged/red/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/lavaproof(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/green
	colour = "green"
	effect_desc = "Lets you choose what slime species you want to be."

/obj/item/slimecross/charged/green/do_effect(mob/user)
	var/mob/living/carbon/human/human_user = user
	if(!istype(human_user))
		to_chat(user, SPAN_WARNING("You must be a humanoid to use this!"))
		return
	var/list/choice_list = list()
	for(var/datum/species/species_type as anything in subtypesof(/datum/species/shapeshifter/promethean))
		choice_list[initial(species_type.name)] = species_type
	var/racechoice = tgui_input_list(human_user, "Choose your slime subspecies", "Slime Selection", sort_list(choice_list))
	if(isnull(racechoice))
		to_chat(user, SPAN_NOTICE("You decide not to become a slime for now."))
		return
	if(!CanUseTopic(user))
		return
	human_user.set_species(choice_list[racechoice])
	human_user.visible_message(SPAN_WARNING("[human_user] suddenly shifts form as [src] dissolves into [human_user] skin!"))
	..()

/obj/item/slimecross/charged/pink
	colour = "pink"
	effect_desc = "Produces a... lovepotion... no ERP."

/obj/item/slimecross/charged/pink/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/lovepotion(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/gold
	colour = "gold"
	effect_desc = "Slowly spawns 10 hostile monsters."
	var/max_spawn = 10
	var/spawned = 0

/obj/item/slimecross/charged/gold/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[src] starts shuddering violently!"))
	addtimer(CALLBACK(src, .proc/startTimer), 50)

/obj/item/slimecross/charged/gold/proc/startTimer()
	//FIXME START_PROCESSING(SSobj, src)

/obj/item/slimecross/charged/gold/think()
	visible_message(SPAN_WARNING("[src] lets off a spark, and produces a living creature!"))
	//FIXME new /obj/effect/particle_effect/sparks(get_turf(src))
	//FIXME playsound(get_turf(src), SFX_SPARKS, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	//FIXME create_random_mob(get_turf(src), HOSTILE_SPAWN)
	spawned++
	if(spawned >= max_spawn)
		visible_message(SPAN_WARNING("[src] collapses into a puddle of goo."))
		qdel(src)

/obj/item/slimecross/charged/gold/Destroy()
	//FIXME STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/slimecross/charged/oil
	colour = "oil"
	effect_desc = "Creates an explosion after a few seconds."

/obj/item/slimecross/charged/oil/do_effect(mob/user)
	user.visible_message(SPAN_DANGER("[src] begins to shake with rapidly increasing force!"))
	addtimer(CALLBACK(src, .proc/boom), 50)

/obj/item/slimecross/charged/oil/proc/boom()
	explosion(src, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4) //Much smaller effect than normal oils, but devastatingly strong where it does hit.
	qdel(src)

/obj/item/slimecross/charged/black
	colour = "black"
	effect_desc = "Randomizes the user's species."

/obj/item/slimecross/charged/black/do_effect(mob/user)
	var/mob/living/carbon/human/H = user
	if(!istype(H))
		to_chat(user, SPAN_WARNING("You have to be able to have a species to get your species changed."))
		return
	var/list/allowed_species = list()
	for(var/stype in subtypesof(/datum/species))
		var/datum/species/X = stype
		/*FIXME if(initial(X.changesource_flags) & SLIME_EXTRACT)
			allowed_species += stype*/

	var/datum/species/changed = pick(allowed_species)
	if(changed)
		H.set_species(changed)
		to_chat(H, SPAN_DANGER("You feel very different!"))
	..()

/obj/item/slimecross/charged/lightpink
	colour = "light pink"
	effect_desc = "Produces a pacification potion, which works on monsters and humanoids."

/obj/item/slimecross/charged/lightpink/do_effect(mob/user)
	//FIXME new /obj/item/slimepotion/peacepotion(get_turf(user))
	user.visible_message(SPAN_NOTICE("[src] distills into a potion!"))
	..()

/obj/item/slimecross/charged/adamantine
	colour = "adamantine"
	effect_desc = "Creates a completed golem shell."

/obj/item/slimecross/charged/adamantine/do_effect(mob/user)
	user.visible_message(SPAN_NOTICE("[src] produces a fully formed golem shell!"))
	//FIXME new /obj/effect/mob_spawn/ghost_role/human/golem/servant(get_turf(src), /datum/species/golem/adamantine, user)
	..()

/obj/item/slimecross/charged/rainbow
	colour = "rainbow"
	effect_desc = "Produces three living slimes of random colors."

/obj/item/slimecross/charged/rainbow/do_effect(mob/user)
	user.visible_message(SPAN_WARNING("[src] swells and splits into three new slimes!"))
	for(var/i in 1 to 3)
		var/mob/living/carbon/metroid/S = new(get_turf(user))
		//FIXME S.random_colour()
	return ..()
