/obj/machinery/optable
	name = "Operating Table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "table2-idle"
	density = 1
	anchored = 1.0
	idle_power_usage = 1
	active_power_usage = 5
	var/mob/living/carbon/human/victim = null
	var/strapped = 0.0
	var/busy = FALSE

	var/obj/machinery/computer/operating/computer = null

	beepsounds = "medical_beep"

/obj/machinery/optable/Initialize()
	. = ..()
	for(dir in list(NORTH,EAST,SOUTH,WEST))
		computer = locate(/obj/machinery/computer/operating, get_step(src, dir))
		if (computer)
			computer.table = src
			break

/obj/machinery/optable/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				qdel(src)
				return
		if(3.0)
			if (prob(25))
				src.set_density(0)
		else
	return

/obj/machinery/optable/attack_hand(mob/user as mob)
	if (MUTATION_HULK in usr.mutations)
		visible_message("<span class='danger'>\The [usr] destroys \the [src]!</span>")
		src.set_density(0)
		qdel(src)
	return

/obj/machinery/optable/CanPass(atom/movable/mover, turf/target)
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE
	return FALSE


/obj/machinery/optable/MouseDrop_T(obj/O as obj, mob/user as mob)

	if ((!( istype(O, /obj/item/weapon) ) || user.get_active_hand() != O))
		return
	user.drop_item()
	if (O.loc != src.loc)
		step(O, get_dir(O, src))
	return

/obj/machinery/optable/verb/remove_clothes()
	set name = "Remove Clothes"
	set category = "IC"
	set src in oview(1)

	if(!ishuman(usr) && !issilicon(usr))
		return
	if(usr.incapacitated())
		return
	if(!victim)
		to_chat(usr, SPAN_DANGER("There is no patient on the table."))
		return
	if(!ishuman(victim))
		to_chat(usr, SPAN_DANGER("[victim] can't be undressed for some biological reasons."))
		return
	if(istype(victim.back, /obj/item/weapon/rig) && !victim.back.mob_can_unequip(victim, slot_back, TRUE))
		to_chat(usr, SPAN_DANGER("\The [victim.back] must be removed."))
		return
	if(!locate(/obj/item/clothing) in victim.contents)
		to_chat(usr, SPAN_DANGER("[victim] has no clothes to remove."))
		return
	if(stat & (BROKEN|NOPOWER))
		to_chat(usr, SPAN_DANGER("\The [src] is unpowered."))
		return
	if(busy)
		to_chat(usr, SPAN_DANGER("[victim] is already undressing."))
		return

	busy = TRUE
	usr.visible_message(SPAN_DANGER("[usr] begins to undress [victim] on the table with the built-in tool."),
						SPAN_NOTICE("You begin to undress [victim] on the table with the built-in tool."))
	if(do_after(usr, 5 SECONDS, victim))
		if(!victim)
			return
		for(var/obj/item/clothing/C in victim.contents)
			if(istype(C, /obj/item/clothing/mask/breath/anesthetic))
				continue
			victim.drop_from_inventory(C)
			use_power_oneoff(100)
		usr.visible_message(SPAN_DANGER("[usr] successfully removes all clothing from [victim]."),
							SPAN_NOTICE("You successfully remove all clothing from [victim]."))
	busy = FALSE

/obj/machinery/optable/proc/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		play_beep()
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(M.lying)
			src.victim = M
			icon_state = M.pulse() ? "table2-active" : "table2-idle"
			return 1
	src.victim = null
	icon_state = "table2-idle"
	return 0

/obj/machinery/optable/Process()
	check_victim()

/obj/machinery/optable/proc/take_victim(mob/living/carbon/C, mob/living/carbon/user as mob)
	if (C == user)
		user.visible_message("[user] climbs on \the [src].","You climb on \the [src].")
	else
		visible_message("<span class='notice'>\The [C] has been laid on \the [src] by [user].</span>")
	if (C.client)
		C.client.perspective = EYE_PERSPECTIVE
		C.client.eye = src
	C.resting = 1
	C.dropInto(loc)
	for(var/obj/O in src)
		O.dropInto(loc)
	src.add_fingerprint(user)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		src.victim = H
		icon_state = H.pulse() ? "table2-active" : "table2-idle"
	else
		icon_state = "table2-idle"

/obj/machinery/optable/MouseDrop_T(mob/target, mob/user)

	var/mob/living/M = user
	if(user.stat || user.restrained() || user.incapacitated(INCAPACITATION_ALL) || !check_table(user) || !iscarbon(target))
		return
	if(istype(M))
		take_victim(target,user)
	else
		return ..()

/obj/machinery/optable/climb_on()
	if(usr.stat || !ishuman(usr) || usr.restrained() || !check_table(usr))
		return

	take_victim(usr,usr)

/obj/machinery/optable/attackby(obj/item/weapon/W as obj, mob/living/carbon/user as mob)
	if (istype(W, /obj/item/grab))
		var/obj/item/grab/G = W
		if(iscarbon(G.affecting) && check_table(G.affecting))
			take_victim(G.affecting,usr)
			qdel(W)
			return

/obj/machinery/optable/proc/check_table(mob/living/carbon/patient as mob)
	check_victim()
	if(src.victim && get_turf(victim) == get_turf(src) && victim.lying)
		to_chat(usr, "<span class='warning'>\The [src] is already occupied!</span>")
		return 0
	if(patient.buckled)
		to_chat(usr, "<span class='notice'>Unbuckle \the [patient] first!</span>")
		return 0
	return 1
