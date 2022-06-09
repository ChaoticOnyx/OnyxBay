
//Syndicate Barrier
/obj/item/device/energybarrier
	name = "energy barrier"
	desc = "A simple yet effective one-use energy barrier generator. Quite effective as a battlefield cover, but explodes upon recieving too much damage."
	icon_state = "ebarrier"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 6.0
	mod_weight = 0.6
	mod_reach = 0.5
	mod_handy = 0.85
	w_class = ITEM_SIZE_SMALL
	throwforce = 5.0
	throw_range = 8

/obj/item/device/energybarrier/attack_self(mob/living/user)
	var/obj/structure/energybarrier/E = new /obj/structure/energybarrier(user.loc)
	E.add_fingerprint(user)
	qdel(src)

/obj/structure/energybarrier
	name = "energy barrier"
	desc = "An energy barrier. It doesn't look like there's a way to disable it without destroying it with brute force."
	icon = 'icons/obj/objects.dmi'
	anchored = 1.0
	density = TRUE
	icon_state = "ebarrier"
	var/health = 250.0
	var/maxhealth = 250.0

/obj/structure/energybarrier/proc/explode()
	visible_message(SPAN("warning", "\The [src] blows apart!"))
	var/turf/t_loc = get_turf(src)
	new /obj/item/stack/rods(t_loc)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()

	qdel(src)
	explosion(t_loc, -1, 0, 1)

/obj/structure/energybarrier/proc/take_damage(dmg = 0)
	health -= dmg
	if(health <= 0)
		explode()

/obj/structure/energybarrier/attackby(obj/item/W, mob/user)
	var/dmg = 0
	switch(W.damtype)
		if("fire")
			dmg = W.force * 1
		if("brute")
			dmg = W.force * 0.75
	..()
	take_damage(dmg)

/obj/structure/energybarrier/ex_act(severity)
	switch(severity)
		if(1.0)
			explode()
		if(2.0)
			take_damage(25)

/obj/structure/energybarrier/bullet_act(obj/item/projectile/Proj)
	var/proj_damage = Proj.get_structure_damage()
	if(!proj_damage)
		return
	..()
	take_damage(proj_damage)

/obj/structure/energybarrier/emp_act(severity)
	take_damage(50 / severity)
