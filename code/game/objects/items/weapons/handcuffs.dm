#define SYNDICUFFS_ON_APPLY 0
#define SYNDICUFFS_ON_REMOVE 1

/obj/item/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	force = 5.0
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.5
	mod_reach = 0.5
	mod_handy = 0.5
	throw_range = 5
	origin_tech = list(TECH_MATERIAL = 1)
	matter = list(MATERIAL_STEEL = 500)
	var/elastic
	var/dispenser = 0
	var/breakouttime = 1200 //Deciseconds = 120s = 2 minutes
	var/cuff_sound = "handcuffs"
	var/cuff_type = "handcuffs"

	drop_sound = SFX_DROP_ACCESSORY
	pickup_sound = SFX_PICKUP_ACCESSORY

/obj/item/handcuffs/get_icon_state(slot)
	if(slot == slot_handcuffed_str)
		return "handcuff1"
	if(slot == slot_legcuffed_str)
		return "legcuff1"
	return ..()

/obj/item/handcuffs/attack(mob/living/carbon/C, mob/living/user)

	if(!user.IsAdvancedToolUser())
		return

	if ((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, "<span class='warning'>Uh ... how do those things work?!</span>")
		place_handcuffs(user, user)
		return

	// only carbons can be handcuffed
	if(istype(C))
		if(!C.handcuffed)
			if (C == user)
				place_handcuffs(user, user)
				return

			//check for an aggressive grab (or robutts)
			if(can_place(C, user))
				place_handcuffs(C, user)
			else
				to_chat(user, "<span class='danger'>You need to have a firm grip on [C] before you can put \the [src] on!</span>")
		else
			to_chat(user, "<span class='warning'>\The [C] is already handcuffed!</span>")
	else
		..()

/obj/item/handcuffs/proc/can_place(mob/target, mob/user)
	if(user == target || istype(user, /mob/living/silicon/robot) || istype(user, /mob/living/bot))
		return 1
	else
		for (var/obj/item/grab/G in target.grabbed_by)
			if (G.force_danger())
				return 1
	return 0

/obj/item/handcuffs/proc/place_handcuffs(mob/living/carbon/target, mob/user)
	playsound(src.loc, cuff_sound, 30, 1, -2)

	var/mob/living/carbon/human/H = target
	if(!istype(H))
		return 0

	if (!H.has_organ_for_slot(slot_handcuffed))
		to_chat(user, "<span class='danger'>\The [H] needs at least two wrists before you can cuff them together!</span>")
		return 0

	if(istype(H.gloves,/obj/item/clothing/gloves/rig) && !elastic) // Can't cuff someone who's in a deployed powersuit.
		to_chat(user, "<span class='danger'>\The [src] won't fit around \the [H.gloves]!</span>")
		return 0

	user.visible_message("<span class='danger'>\The [user] is attempting to put [cuff_type] on \the [H]!</span>")

	if(!do_after(user,30, target, , luck_check_type = LUCK_CHECK_COMBAT))
		return 0

	if(!can_place(target, user)) // victim may have resisted out of the grab in the meantime
		return 0

	admin_attack_log(user, H, "Attempted to handcuff the victim", "Was target of an attempted handcuff", "attempted to handcuff")
	feedback_add_details("handcuffs","H")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(H)

	user.visible_message("<span class='danger'>\The [user] has put [cuff_type] on \the [H]!</span>")

	// Apply cuffs.
	var/obj/item/handcuffs/cuffs = src
	if(dispenser)
		cuffs = new(get_turf(user))
	else
		user.drop(cuffs, force = TRUE)
	target.equip_to_slot(cuffs, slot_handcuffed)
	on_restraint_apply(src)
	return 1

var/last_chew = 0
/mob/living/carbon/human/RestrainedClickOn(atom/A)
	if(A != src) return ..()
	if(last_chew + 26 > world.time) return

	var/mob/living/carbon/human/H = A
	if(!H.handcuffed) return
	if(H.a_intent != I_HURT) return
	if(H.zone_sel.selecting != BP_MOUTH) return
	if(H.wear_mask) return
	if(istype(H.wear_suit, /obj/item/clothing/suit/straight_jacket)) return

	var/obj/item/organ/external/O = H.organs_by_name[(H.hand ? BP_L_HAND : BP_R_HAND)]
	if (!O) return

	H.visible_message("<span class='warning'>\The [H] chews on \his [O.name]!</span>", "<span class='warning'>You chew on your [O.name]!</span>")
	admin_attacker_log(H, "chewed on their [O.name]!")

	O.take_external_damage(3,0, DAM_SHARP|DAM_EDGE ,"teeth marks")

	last_chew = world.time

/obj/item/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff_white"
	breakouttime = 300 //Deciseconds = 30s
	cuff_sound = SFX_USE_CABLE_HANDCUFFS
	cuff_type = "cable restraints"
	elastic = 1

/obj/item/handcuffs/cable/red
	color = "#dd0000"

/obj/item/handcuffs/cable/yellow
	color = "#dddd00"

/obj/item/handcuffs/cable/blue
	color = "#0000dd"

/obj/item/handcuffs/cable/green
	color = "#00dd00"

/obj/item/handcuffs/cable/pink
	color = "#dd00dd"

/obj/item/handcuffs/cable/orange
	color = "#dd8800"

/obj/item/handcuffs/cable/cyan
	color = "#00dddd"

/obj/item/handcuffs/cable/white
	color = "#ffffff"

/obj/item/handcuffs/cable/attackby(obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = I
		if (R.use(1))
			var/obj/item/material/wirerod/W = new(get_turf(user))
			user.pick_or_drop(W)
			to_chat(user, "<span class='notice'>You wrap the cable restraint around the top of the rod.</span>")
			qdel(src)
			update_icon(user)

/obj/item/handcuffs/cyborg
	dispenser = 1

/obj/item/handcuffs/cyborg/afterattack(atom/A, mob/user, proximity)
	if (istype(A,/obj/item/handcuffs))
		qdel(A)

/obj/item/handcuffs/cable/tape
	name = "tape restraints"
	desc = "DIY!"
	icon_state = "tape_cross"
	item_state = null
	icon = 'icons/obj/bureaucracy.dmi'
	breakouttime = 200
	cuff_type = "duct tape"

//Syndicate Cuffs. Disguised as regular cuffs, they are pretty explosive
/obj/item/handcuffs/syndicate
	var/countdown_time   = 3 SECONDS
	var/mode             = SYNDICUFFS_ON_APPLY //Handled at this level, Syndicate Cuffs code
	var/charge_detonated = FALSE

/obj/item/handcuffs/syndicate/attack_self(mob/user)

	mode = !mode

	switch(mode)
		if(SYNDICUFFS_ON_APPLY)
			to_chat(user, "<span class='notice'>You pull the rotating arm back until you hear two clicks. \The [src] will detonate a few seconds after being applied.</span>")
		if(SYNDICUFFS_ON_REMOVE)
			to_chat(user, "<span class='notice'>You pull the rotating arm back until you hear one click. \The [src] will detonate when removed.</span>")

/obj/item/handcuffs/syndicate/on_restraint_apply(mob/user, slot)
	if(mode == SYNDICUFFS_ON_APPLY && !charge_detonated)
		detonate(1)

	..()

/obj/item/handcuffs/syndicate/on_restraint_removal(mob/living/carbon/C)
	if(mode == SYNDICUFFS_ON_REMOVE && !charge_detonated)
		detonate(0) //This handles cleaning up the inventory already
		return //Don't clean up twice, we don't want runtimes

//C4 and EMPs don't mix, will always explode at severity 1, and likely to explode at severity 2
/obj/item/handcuffs/syndicate/emp_act(severity)

	switch(severity)
		if(1)
			if(prob(80))
				detonate(1)
			else
				detonate(0)
		if(2)
			if(prob(50))
				detonate(1)

/obj/item/handcuffs/syndicate/ex_act(severity)

	switch(severity)
		if(1)
			if(!charge_detonated)
				detonate(0)
		if(2)
			if(!charge_detonated)
				detonate(0)
		if(3)
			if(!charge_detonated && prob(50))
				detonate(1)
		else
			return

	qdel(src)

/obj/item/handcuffs/syndicate/proc/detonate(countdown)
	set waitfor = FALSE
	if(charge_detonated)
		return

	charge_detonated = TRUE // Do it before countdown to prevent spam fuckery.
	if(countdown)
		sleep(countdown_time)

	if(istype(src.loc, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src.loc

		if(H.get_inventory_slot(src) == slot_handcuffed)
			var/obj/item/organ/external/l_hand = H.get_organ(BP_L_HAND)
			var/obj/item/organ/external/r_hand = H.get_organ(BP_R_HAND)
			if(l_hand)
				l_hand.droplimb(0, DROPLIMB_BLUNT)
			if(r_hand)
				r_hand.droplimb(0, DROPLIMB_BLUNT)

	explosion(get_turf(src), -1, 1, 3, 0)
	qdel(src)
