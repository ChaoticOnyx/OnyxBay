/obj/structure/rock
	name = "huge rock"
	desc = "Huge rocky chunk of asteroid minerals."
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "big_asteroid1"
	opacity = 0
	density = 1
	anchored = 1
	var/list/iconlist = list("big_asteroid1","big_asteroid2","big_asteroid3","big_asteroid4")
	var/health = 40
	var/last_act = 0

/obj/structure/rock/Initialize()
	. = ..()
	icon_state = "big_asteroid[rand(1, 4)]"

/obj/structure/rock/add_debris_element()
	AddElement(/datum/element/debris, DEBRIS_ROCK, -10, 5, 1)

/obj/structure/rock/Destroy()
	var/mineralSpawnChanceList = list(uranium = 10, osmium = 10, iron = 20, coal = 20, diamond = 2, gold = 10, silver = 10, plasma = 20)
	if(prob(20))
		var/mineral_name = util_pick_weight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		var/ore = text2path("/obj/item/ore/[mineral_name]")
		for(var/i=1,i <= rand(2,6),i++)
			new ore(get_turf(src))
	return ..()

/obj/structure/rock/attackby(obj/item/I, mob/user)
	if (isMonkey(user))
		to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
		return
	if (istype(I, /obj/item/pickaxe/drill))
		if(!istype(user.loc, /turf))
			return

		var/obj/item/pickaxe/drill/D = I
		if(last_act + D.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		playsound(user, D.drill_sound, 20, 1)

		to_chat(user, "<span class='notice'>You start [D.drill_verb].</span>")

		if(do_after(user,D.digspeed - D.digspeed / 4, src))
			to_chat(user, "<span class='notice'>You finish [D.drill_verb] \the [src].</span>")
			qdel(src)
	return ..()

/obj/structure/rock/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)

/obj/structure/rock/basalt
	name = "basalt"
	desc = "Huge chunk of gray rock that contain various minerals."
	icon_state = "big_basalt1"

/obj/structure/rock/basalt/Initialize()
	. = ..()
	icon_state = "big_basalt[rand(1, 3)]"

/obj/structure/rock/basalt/pile
	name = "lava rocks"
	desc = "Small pile of grey rocks that contain various minerals."
	icon_state = "pile_basalt1"
	density = 0

/obj/structure/rock/basalt/pile/Initialize()
	. = ..()
	icon_state = "pile_basalt[rand(1, 3)]"

/obj/structure/rock/rockplanet
	name = "russet stone"
	desc = "A raised knurl of red rock."
	icon_state = "big_red1"

/obj/structure/rock/rockplanet/Initialize()
	. = ..()
	icon_state = "big_red[rand(1, 3)]"

/obj/structure/rock/rockplanet/Destroy()
	var/mineralSpawnChanceList = list(glass = 10)
	if(prob(20))
		var/mineral_name = util_pick_weight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		var/ore = text2path("/obj/item/ore/[mineral_name]")
		for(var/i=1,i <= rand(2,6),i++)
			new ore(get_turf(src))
	return ..()

/obj/structure/rock/rockplanet/pile
	name = "russet stones"
	desc = "A pile of rust-red rocks."
	icon_state = "plie_red1"
	density = 0

/obj/structure/rock/rockplanet/pile/Initialize()
	. = ..()
	icon_state = "pile_red[rand(1, 3)]"

/obj/structure/rock/icy
	name = "icy rock"
	icon_state = "big_icy1"

/obj/structure/rock/icy/Initialize()
	. = ..()
	icon_state = "big_icy[rand(1, 3)]"

/obj/structure/rock/icy/pile
	name = "icy rock"
	icon_state = "pile_icy1"
	density = 0

/obj/structure/rock/lava
	name = "lavatic rock"
	desc = "A volcanic rock. Lava is gushing from it."
	icon_state = "big_lava1"

/obj/structure/rock/lava/Initialize()
	. = ..()
	icon_state = "big_lava[rand(1, 3)]"

/obj/structure/rock/lava/pile
	name = "rock shards"
	desc = "Jagged shards of volcanic rock protuding from the ground."
	icon_state = "pile_lava1"
	density = 0

/obj/structure/rock/lava/pile/Initialize()
	. = ..()
	icon_state = "pile_lava[rand(1, 3)]"

/obj/structure/rock/pile
	name = "pebbles"
	desc = "Some small pebbles, sheared off a larger rock."
	icon_state = "asteroid1"
	density = 0

/obj/structure/rock/pile/Initialize()
	. = ..()
	icon_state = "pile_asteroid[rand(1, 10)]"
