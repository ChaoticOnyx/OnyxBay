/obj/mecha/combat
	force = 30
	var/melee_cooldown = 10
	var/melee_can_hit = 1
	var/list/destroyable_obj = list(/obj/mecha, /obj/structure/window, /obj/structure/grille, /turf/simulated/wall)
	internal_damage_threshold = 50
	maint_access = 0
	//add_req_access = 0
	//operation_req_access = list(access_hos)
	damage_absorption = list("brute"=0.7,"fire"=1,"bullet"=0.7,"laser"=0.85,"energy"=1,"bomb"=0.8)
	var/am = "d3c2fbcadca903a41161ccc9df9cf948"

/*
/obj/mecha/combat/range_action(target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = pick(view(3,target))
	if(selected_weapon)
		selected_weapon.fire(target)
	return
*/

/obj/mecha/combat/melee_action(target as obj|mob|turf)
	if(internal_damage&MECHA_INT_CONTROL_LOST)
		target = safepick(oview(1,src))
	if(!melee_can_hit || !istype(target, /atom)) return
	if(istype(target, /mob/living))
		var/mob/living/M = target
		if(src.occupant.a_intent == I_HURT)
			playsound(src, 'sound/effects/fighting/punch4.ogg', 50, 1)
			if(damtype == "brute")
				step_away(M,src,15)
			/*
			if(M.stat>1)
				M.gib()
				melee_can_hit = 0
				if(do_after(melee_cooldown))
					melee_can_hit = 1
				return
			*/

			var/hit_zone = ran_zone()
			switch(damtype)
				if("brute")
					var/blocked = M.run_armor_check(hit_zone, "melee")
					if(M.apply_damage(rand(force/2, force), BRUTE, hit_zone, blocked))
						M.Weaken(1)
				if("fire")
					var/blocked = M.run_armor_check(hit_zone, "energy")
					M.apply_damage(rand(force/2, force), BRUTE, hit_zone, blocked)
				if("tox")
					if(M.reagents)
						if(M.reagents.get_reagent_amount(/datum/reagent/toxin/carpotoxin) + force < force*2)
							M.reagents.add_reagent(/datum/reagent/toxin/carpotoxin, force)
						if(M.reagents.get_reagent_amount(/datum/reagent/cryptobiolin) + force < force*2)
							M.reagents.add_reagent(/datum/reagent/cryptobiolin, force)

			src.occupant_message("You hit [target].")
			src.visible_message("<font color='red'><b>[src.name] hits [target].</b></font>")
		else
			step_away(M,src)
			src.occupant_message("You push [target] out of the way.")
			src.visible_message("[src] pushes [target] out of the way.")

		melee_can_hit = 0
		spawn(melee_cooldown)
			melee_can_hit = 1
		return

	else
		if(damtype == "brute")
			for(var/target_type in src.destroyable_obj)
				if(istype(target, target_type) && hascall(target, "attackby"))
					src.occupant_message("You hit [target].")
					src.visible_message("<font color='red'><b>[src.name] hits [target]</b></font>")
					if(!istype(target, /turf/simulated/wall))
						target:attackby(src,src.occupant)
					else if(prob(5))
						target:dismantle_wall(1)
						src.occupant_message("<span class='notice'>You smash through the wall.</span>")
						src.visible_message("<b>[src.name] smashes through the wall</b>")
						playsound(src, 'sound/effects/fighting/smash.ogg', 50, 1)
					melee_can_hit = 0
					spawn(melee_cooldown)
						melee_can_hit = 1
					break
	return

/obj/mecha/combat/moved_inside(mob/living/carbon/human/H)
	if(..())
		if(H.client)
			H.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return TRUE
	else
		return FALSE

/obj/mecha/combat/brain_moved_inside(obj/item/I, mob/user)
	if(..())
		var/mob/brainmob
		if(istype(I, /obj/item/organ/internal/cerebrum/mmi))
			var/obj/item/organ/internal/cerebrum/mmi/MMI = I
			brainmob = MMI.brainmob
		else if(istype(I, /obj/item/organ/internal/cerebrum/posibrain))
			var/obj/item/organ/internal/cerebrum/posibrain/PB = I
			brainmob = PB.brainmob
		if(brainmob.client)
			brainmob.client.mouse_pointer_icon = file("icons/mecha/mecha_mouse.dmi")
		return TRUE
	else
		return FALSE

/obj/mecha/combat/go_out()
	if(src.occupant && src.occupant.client)
		src.occupant.client.mouse_pointer_icon = initial(src.occupant.client.mouse_pointer_icon)
	..()
	return

/obj/mecha/combat/Topic(href,href_list)
	..()
	var/datum/topic_input/F = new (href,href_list)
	if(F.get("close"))
		am = null
		return
	/*
	if(filter.get("saminput"))
		if(md5(filter.get("saminput")) == am)
			occupant_message("From the lies of the Antipath, Circuit preserve us.")
		am = null
	return
	*/
