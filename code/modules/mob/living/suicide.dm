/mob/living/proc/suicide_log()
	admin_victim_log(src, "committed suicide as [src.type]")

/mob/living/carbon/human/suicide_log()
	admin_victim_log(src, "committed suicide as job: [src.job ? "[src.job]" : "None"]")

/mob/living/proc/canSuicide()
	if(stat == DEAD)
		to_chat(src, "<span class='warning'>You're already dead!</span>")
		return
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't commit suicide while incapacitated!</span>")
		return
	return TRUE

/mob/living/carbon/human/canSuicide()
	if(!..())
		return
	if(handcuffed)
		to_chat(src, "<span class='warning'>You can't commit suicide while incapacitated!</span>")
		return
	return TRUE

/mob/living/silicon/robot/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/confirm = alert(src, "Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(!canSuicide())
		return
	if(confirm == "Yes")
		visible_message("<span class='danger'>[src] is powering down. It looks like they're trying to commit suicide.</span>", \
				"<span class='warning'>You are powering down, trying to commit suicide.</span>")
		suicide_log()
		death(FALSE, null, "You have suffered a critical system failure, and are dead.")

/mob/living/carbon/human/verb/suicide()
	set hidden = 1
	if(!canSuicide())
		return
	var/oldkey = ckey
	var/confirm = alert("Are you sure you want to commit suicide?", "Confirm Suicide", "Yes", "No")
	if(ckey != oldkey)
		return
	if(!canSuicide())
		return
	if(confirm == "Yes")
		var/suicide_message = "commits suicide!"
		var/zone
		if(zone_sel)
			zone = zone_sel.selecting
		else
			zone = BP_CHEST
		if(!get_organ(zone))
			zone = BP_CHEST
		var/obj/item/I = get_active_hand()
		var/success = FALSE
		if(I)
			if(zone == BP_EYES)
				if(I.sharp || I.edge || istype(I, /obj/item/weapon/material/kitchen/utensil) || istype(I, /obj/item/weapon/pen) || istype(I, /obj/item/weapon/reagent_containers/syringe))
					success = TRUE
					suicide_message = pick("[src] stabs \himself into the eye with \his [I]!",
										   "[src] shoves the [I] into \his eye socket!",
										   "[src] eyestabs \himself with the [I]!")

					var/obj/item/organ/internal/eyes/eyes = internal_organs_by_name[BP_EYES]
					if(eyes)
						eyes.damage += 35
					var/obj/item/organ/internal/brain/brain = internal_organs_by_name[BP_BRAIN]
					brain.damage += 50
					var/obj/item/organ/external/A = get_organ(eyes.parent_organ)
					A.take_external_damage(rand(30,50))
			else if(zone == (BP_HEAD || BP_MOUTH))
				if(I.sharp || I.edge)
					success = TRUE
					var/obj/item/organ/external/A = get_organ(BP_HEAD)
					if(prob(50))
						suicide_message = pick("[src] slits \his throat with the [I]!",
											   "[src] stabs \himself in the throat with \his [I]!")
						adjustOxyLoss(75)
						A.take_external_damage(rand(20,40))
						A.createwound(CUT, 30, FALSE)
						A.sever_artery()
						var/obj/item/organ/internal/brain/brain = internal_organs_by_name[BP_BRAIN]
						brain.damage += 25
					else
						suicide_message = pick("[src] forcefully thrusts the [I] into \his temple!",
											   "[src] slams the [I] into \his head!")
						A.take_external_damage(rand(40,60))
						var/obj/item/organ/internal/brain/brain = internal_organs_by_name[BP_BRAIN]
						brain.damage += 75
			else if(zone == (BP_L_HAND || BP_L_ARM || BP_R_HAND || BP_R_ARM))
				if(I.sharp || I.edge)
					success = TRUE
					var/obj/item/organ/external/A = get_organ(zone)
					suicide_message = pick("[src] forcefully slits \his [zone] with the [I]!",
										   "[src] hacks \his [zone] open with the [I]!",
										   "[src] slashes across \his [zone] with the [I]!",
										   "[src] cuts the veins in \his [zone] open with the[I]!")
					A.take_external_damage(15)
					A.createwound(CUT, 30, FALSE)
					A.sever_artery()
			else
				if(I.sharp || I.edge)
					success = TRUE
					var/obj/item/organ/external/A = get_organ(zone)
					suicide_message = pick("[src] forcefully stabs \himself with the [I]!",
										   "[src] dips \his [I] deep into \his abdomen!",
										   "[src] drops himself onto \his [I]!",
										   "[src] raises the [I] over \his head and shoves it into \his belly!",
										   "[src] cuts \his stomach open with the [I]!",
										   "[src] massacres \himself with \his [I]!",
										   "[src] thrusts the [I] right under \his ribs!")
					A.take_external_damage(75)
					A.createwound(CUT, 50, FALSE)
			if(success)
				visible_message("<span class='warning'>[suicide_message] It looks like \he is trying to commit suicide.</span>", "<span class='danger'>You have attempted to commit suicide!</span>")
				drop_item()
				Paralyse(1)
				Weaken(4)
				update_icons()
			else
				to_chat(src, "<span class='notice'>You have no idea how to do this right now.</span>")
