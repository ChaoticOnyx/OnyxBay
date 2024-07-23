/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube"
	origin_tech = list(TECH_MATERIAL = 4, TECH_ENGINEERING = 3)
	amount = 10
	max_amount = 10
	w_class = ITEM_SIZE_SMALL

/obj/item/stack/nanopaste/proc/fix_robot(mob/living/silicon/robot/R, mob/user)
	if(R.getBruteLoss() || R.getFireLoss())
		R.adjustBruteLoss(-15)
		R.adjustFireLoss(-15)
		R.updatehealth()
		use(1)
		user.visible_message(SPAN_NOTICE("\The [user] applied some [src] on [R]'s damaged areas."), SPAN_NOTICE("You apply some [src] at [R]'s damaged areas."))
	else
		to_chat(user, SPAN_NOTICE("All [R]'s systems are nominal."))

/obj/item/stack/nanopaste/attack(mob/living/M, mob/user)
	if (!istype(M) || !istype(user))
		return 0
	if (istype(M,/mob/living/silicon/robot))	//Repairing cyborgs
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/mob/living/silicon/robot/R = M
		if(user != R)
			fix_robot(R, user)
		else
			if(R.opened)
				fix_robot(R, user)
			else
				if(do_after(user, 10, luck_check_type = LUCK_CHECK_MED))
					fix_robot(R, user)

	if (istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/S = H.get_organ(user.zone_sel.selecting)

		if(!S)
			to_chat(user, "<span class='warning'>\The [M] is missing that body part.</span>")

		if(S && BP_IS_ROBOTIC(S) && S.hatch_state == HATCH_OPENED)
			if(!S.get_damage())
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
			else if(can_use(1))
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
				S.heal_damage(15, 15, robo_repair = 1)
				H.updatehealth()
				use(1)
				user.visible_message("<span class='notice'>\The [user] applies some nanite paste on [user != M ? "[M]'s [S.name]" : "[S]"] with [src].</span>",\
				"<span class='notice'>You apply some nanite paste on [user == M ? "your" : "[M]'s"] [S.name].</span>")

/obj/item/stack/nanopaste/get_storage_cost()
	return base_storage_cost(w_class)
