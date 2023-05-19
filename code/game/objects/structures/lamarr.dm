/obj/structure/lamarr
	name = "Lab Cage"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "labcage1"
	desc = "A glass lab container for storing interesting creatures."
	density = 1
	anchored = 1
	unacidable = 1//Dissolving the case would also delete the gun.
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

/obj/structure/lamarr/ex_act(severity)
	switch(severity)
		if(1)
			new /obj/item/material/shard(get_turf(src))
			if(prob(50) && occupied)
				new /mob/living/simple_animal/hostile/facehugger/lamarr(get_turf(src))
				occupied = 0
			qdel(src)
		if(2)
			health -= rand(15, 30)
			healthcheck()
		if(3)
			health -= rand(5, 10)
			healthcheck()


/obj/structure/lamarr/bullet_act(obj/item/projectile/Proj)
	health -= Proj.get_structure_damage()
	..()
	src.healthcheck()
	return

/obj/structure/lamarr/proc/healthcheck()
	if(health <= 0)
		if(!destroyed)
			set_density(0)
			destroyed = 1
			new /obj/item/material/shard(get_turf(src))
			if(occupied)
				new /mob/living/simple_animal/hostile/facehugger/lamarr(get_turf(src))
				occupied = 0
			playsound(src, SFX_BREAK_WINDOW, 70, 1)
			update_icon()
	else
		playsound(src.loc, GET_SFX(SFX_GLASS_HIT), 75, 1)
	return

/obj/structure/lamarr/update_icon()
	if(destroyed)
		icon_state = "labcageb[occupied]"
	else
		icon_state = "labcage[occupied]"
	return

/obj/structure/lamarr/attackby(obj/item/W, mob/user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	health -= W.force
	healthcheck()
	..()
	return

/obj/structure/lamarr/attack_hand(mob/user)
	if(destroyed)
		return
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	visible_message(SPAN("warning", "[usr] kicks the display case."))
	health -= 2
	healthcheck()
