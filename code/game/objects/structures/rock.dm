/obj/structure/rock
	name = "huge rock"
	desc = "Huge rocky chunk of asteroid minerals."
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "asteroid_bigstone1"
	opacity = 0
	density = 1
	anchored = 1
	var/list/iconlist = list("asteroid_bigstone1","asteroid_bigstone2","asteroid_bigstone3","asteroid_bigstone4")
	var/health = 40
	var/last_act = 0

/obj/structure/rock/New()
	..()
	icon_state = pick(iconlist)

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
