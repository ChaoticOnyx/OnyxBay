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
	var/mineralSpawnChanceList = list("Uranium" = 10, "Platinum" = 10, "Iron" = 20, "Carbon" = 20, "Diamond" = 2, "Gold" = 10, "Silver" = 10, "Phoron" = 20)
	if(prob(20))
		var/mineral_name = pickweight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		var/ore = text2path("/obj/item/weapon/ore/[mineral_name]")
		for(var/i=1,i <= rand(2,6),i++)
			new ore(get_turf(src))
	..()
	
/obj/structure/rock/attackby(var/obj/item/I, var/mob/user)
	if (isMonkey(user))
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if (istype(I, /obj/item/weapon/pickaxe))
		if(!istype(user.loc, /turf))
			return

		var/obj/item/weapon/pickaxe/P = I
		if(last_act + P.digspeed > world.time)//prevents message spam
			return
		last_act = world.time

		playsound(user, P.drill_sound, 20, 1)

		to_chat(user, "<span class='notice'>You start [P.drill_verb].</span>")

		if(do_after(user,P.digspeed - P.digspeed/4, src))
			to_chat(user, "<span class='notice'>You finish [P.drill_verb] \the [src].</span>")
			Destroy(src)
	return ..()

/obj/structure/rock/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/weapon/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/weapon/pickaxe)) && H.hand)
			attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/weapon/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)