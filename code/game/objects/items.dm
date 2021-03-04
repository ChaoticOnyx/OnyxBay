/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	w_class = ITEM_SIZE_NORMAL
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/image/blood_overlay = null //this saves our blood splatter overlay, which will be processed not to go over the edges of the sprite
	var/randpixel = 6
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/slot_flags = 0		//This is used to determine on which slots an item can fit.
	var/no_attack_log = 0			//If it's an item we don't want to log attack_logs with, set this to 1
	pass_flags = PASS_FLAG_TABLE
//	causeerrorheresoifixthis
	var/obj/item/master = null
	var/list/origin_tech = null	//Used by R&D to determine what research bonuses it grants.
	var/list/attack_verb = list("hit") //Used in attackby() to say how something was attacked "[x] has been [z.attack_verb] by [y] with [z]"
	var/lock_picking_level = 0 //used to determine whether something can pick a lock, and how well.

	//Totally Realistic Onyx Fighting System stuff
	var/force = 0
	var/attack_cooldown = DEFAULT_WEAPON_COOLDOWN // 0.5 second
	var/attack_cooldown_real //Debug variable
	var/mod_handy = 0.25 //Handiness modifier. i.e. 0.5 - pain in the ass to use, 1.0 - decent weapon, 1.5 - specialized for melee combat.
	var/mod_reach = 0.25 //Length modifier. i.e. 0.35 - knives, 0.75 - toolboxes, 1.0 - crowbars, 1.25 - batons, 1.5 - spears and mops.
	var/mod_weight = 0.25 //Weight modifier. i.e. 0.33 - knives, 0.67 - hatchets, 1.0 - crowbars and batons, 1.33 - tanks, 1.66 - toolboxes, 2.0 - axes.
	var/mod_speed = 1.0 //An artificial attack cooldown multiplier for certain weapons. Applied after the initial processing.
	var/mod_shield = 1.0 //Higher values reduce blocks' poise consumption. Values >= 1.3 allow to absorb bullets. Values >= 2.5 allow to reflect bullets.

	var/heat_protection = 0 //flags which determine which body parts are protected from heat. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/cold_protection = 0 //flags which determine which body parts are protected from cold. Use the HEAD, UPPER_TORSO, LOWER_TORSO, etc. flags. See setup.dm
	var/max_heat_protection_temperature //Set this variable to determine up to which temperature (IN KELVIN) the item protects against heat damage. Keep at null to disable protection. Only protects areas set by heat_protection flags
	var/min_cold_protection_temperature //Set this variable to determine down to which temperature (IN KELVIN) the item protects against cold damage. 0 is NOT an acceptable number due to if(varname) tests!! Keep at null to disable protection. Only protects areas set by cold_protection flags

	var/datum/action/item_action/action = null
	var/action_button_name //It is also the text which gets displayed on the action button. If not set it defaults to 'Use [name]'. If it's not set, there'll be no button.
	var/action_button_is_hands_free = 0 //If 1, bypass the restrained, lying, and stunned checks action buttons normally test for

	//This flag is used to determine when items in someone's inventory cover others. IE helmets making it so you can't see glasses, etc.
	//It should be used purely for appearance. For gameplay effects caused by items covering body parts, use body_parts_covered.
	var/flags_inv = 0
	var/body_parts_covered = 0 //see code/__defines/items_clothing.dm for appropriate bit flags

	var/item_flags = 0 //Miscellaneous flags pertaining to equippable objects.

	//var/heat_transfer_coefficient = 1 //0 prevents all transfers, 1 is invisible
	var/gas_transfer_coefficient = 1 // for leaking gas from turf to mask and vice-versa (for masks right now, but at some point, i'd like to include space helmets)
	var/permeability_coefficient = 1 // for chemicals/diseases
	var/siemens_coefficient = 1 // for electrical admittance/conductance (electrocution checks and shit)
	var/slowdown_general = 0 // How much clothing is slowing you down. Negative values speeds you up. This is a genera##l slowdown, no matter equipment slot.
	var/slowdown_per_slot[slot_last] // How much clothing is slowing you down. This is an associative list: item slot - slowdown
	var/slowdown_accessory // How much an accessory will slow you down when attached to a worn article of clothing.
	var/canremove = 1 //Mostly for Ninja code at this point but basically will not allow the item to be removed if set to 0. /N
	var/candrop = 1
	var/list/armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	var/list/allowed = null //suit storage stuff.
	var/obj/item/device/uplink/hidden_uplink = null // All items can have an uplink hidden inside, just remember to add the triggers.
	var/zoomdevicename = null //name used for message when binoculars/scope is used
	var/zoom = 0 //1 if item is actively being used to zoom. For scoped guns and binoculars.
	var/surgery_speed = 1 //When this item is used as a surgery tool, multiply the delay of the surgery step by this much.

	var/icon_override = null  //Used to override hardcoded clothing dmis in human clothing proc.

	var/use_alt_layer = FALSE // Use the slot's alternative layer when rendering on a mob

	//** These specify item/icon overrides for _slots_

	var/list/item_state_slots = list(slot_wear_id_str = "id") //overrides the default item_state for particular slots.

	// Used to specify the icon file to be used when the item is worn. If not set the default icon for that slot will be used.
	// If icon_override is set it will take precendence over this, assuming they apply to the slot in question.
	// Only slot_l_hand/slot_r_hand are implemented at the moment. Others to be implemented as needed.
	var/list/item_icons

	var/tmp/sprite_group = null

	// Species-specific sprite sheets for inventory sprites. Used in clothing/refit_for_species() proc.
	var/list/sprite_sheets_obj = list()

	var/pickup_sound = null

/obj/item/New()
	..()
	if(randpixel && (!pixel_x && !pixel_y) && isturf(loc)) //hopefully this will prevent us from messing with mapper-set pixel_x/y
		pixel_x = rand(-randpixel, randpixel)
		pixel_y = rand(-randpixel, randpixel)

/obj/item/Destroy()
	QDEL_NULL(hidden_uplink)
	if(ismob(loc))
		var/mob/m = loc
		m.drop_from_inventory(src)
	if(maptext)
		maptext = ""

	if(istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/storage = loc // some ui cleanup needs to be done
		storage.on_item_pre_deletion(src) // must be done before deletion
		. = ..()
		storage.on_item_post_deletion() // must be done after deletion
	else
		return ..()

/obj/item/device
	icon = 'icons/obj/device.dmi'

//Checks if the item is being held by a mob, and if so, updates the held icons
/obj/item/proc/update_twohanding()
	update_held_icon()

/obj/item/proc/update_held_icon()
	if(ismob(src.loc))
		var/mob/M = src.loc
		if(M.l_hand == src)
			M.update_inv_l_hand()
		else if(M.r_hand == src)
			M.update_inv_r_hand()

/obj/item/proc/is_held_twohanded(mob/living/M)
	var/check_hand
	if(M.l_hand == src && !M.r_hand)
		check_hand = BP_R_HAND //item in left hand, check right hand
	else if(M.r_hand == src && !M.l_hand)
		check_hand = BP_L_HAND //item in right hand, check left hand
	else
		return FALSE

	//would check is_broken() and is_malfunctioning() here too but is_malfunctioning()
	//is probabilistic so we can't do that and it would be unfair to just check one.
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/hand = H.organs_by_name[check_hand]
		if(istype(hand) && hand.is_usable())
			return TRUE
	return FALSE

/obj/item/ex_act(severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
		if(3)
			if (prob(5))
				qdel(src)

/obj/item/verb/move_to_top()
	set name = "Move To Top"
	set category = "Object"
	set src in oview(1)

	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return

	var/turf/T = src.loc

	src.loc = null

	src.loc = T

/obj/item/examine(mob/user)
	var/size
	switch(src.w_class)
		if(ITEM_SIZE_TINY)
			size = "tiny"
		if(ITEM_SIZE_SMALL)
			size = "small"
		if(ITEM_SIZE_NORMAL)
			size = "normal-sized"
		if(ITEM_SIZE_LARGE)
			size = "large"
		if(ITEM_SIZE_HUGE)
			size = "bulky"
		if(ITEM_SIZE_HUGE + 1 to INFINITY)
			size = "huge"
	var/desc_comp = "" //For "description composite"
	desc_comp += "It is a [size] item."

	if(force)
		var/desc_weight
		var/desc_reach
		var/desc_handy

		if(src.mod_weight < 0.4) desc_weight = "a really light"
		else if(src.mod_weight < 0.8) desc_weight = "quite light"
		else if(src.mod_weight < 1.25) desc_weight = "a normal-weight"
		else if(src.mod_weight < 1.65) desc_weight = "quite heavy"
		else desc_weight = "a really heavy"

		if(src.mod_reach < 0.4) desc_reach = "extremely short"
		else if(src.mod_reach < 0.8) desc_reach = "quite short"
		else if(src.mod_reach < 1.25) desc_reach = "average sized"
		else if(src.mod_reach < 1.65) desc_reach = "long"
		else desc_reach = "extremely long"

		if(src.mod_handy < 0.4) desc_handy = "unhandy"
		else if(src.mod_handy < 0.8) desc_handy = "not so handy"
		else if(src.mod_handy < 1.25) desc_handy = "handy"
		else if(src.mod_handy < 1.65) desc_handy = "really handy"
		else desc_handy = "outstandingly handy"
		desc_comp += "<BR>It makes [desc_weight], [desc_reach], and [desc_handy] weapon."

	if(hasHUD(user, HUD_SCIENCE)) //Mob has a research scanner active.
		desc_comp += "<BR>*--------* <BR>"

		if(origin_tech)
			desc_comp += SPAN("notice", "Testing potentials:<BR>")
			//var/list/techlvls = params2list(origin_tech)
			for(var/T in origin_tech)
				desc_comp += "Tech: Level [origin_tech[T]] [CallTechName(T)] <BR>"
		else
			desc_comp += "No tech origins detected.<BR>"

		if(LAZYLEN(matter))
			desc_comp += SPAN("notice", "Extractable materials:<BR>")
			for(var/mat in matter)
				desc_comp += "[get_material_by_name(mat)]<BR>"
		else
			desc_comp += SPAN("danger", "No extractable materials detected.<BR>")
		desc_comp += "*--------*"

	//if(weapon_desc)
	//	desc_comp += handle_weapon_desc()

	return ..(user, "", desc_comp)

/obj/item/attack_hand(mob/user as mob)
	if (!user)
		return
	if (anchored)
		return ..()
	if(istype(user, /mob/living/carbon/human/xenos))
		to_chat(user, SPAN("notice", "You're not smart enough to do that!"))
		return
	if (hasorgans(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (user.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(user, SPAN("notice", "You try to move your [temp.name], but cannot!"))
			return
		if(!temp)
			to_chat(user, SPAN("notice", "You try to use your hand, but realize it is no longer attached!"))
			return

	var/old_loc = src.loc

	src.pickup(user)
	if (istype(src.loc, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = src.loc
		S.remove_from_storage(src)

	src.throwing = 0
	if (src.loc == user)
		if(!user.unEquip(src))
			return
	else
		if(isliving(src.loc))
			return

	if(user.put_in_active_hand(src))
		if(isturf(old_loc))
			var/obj/effect/temporary/item_pickup_ghost/ghost = new /obj/effect/temporary/item_pickup_ghost(old_loc, src)
			ghost.animate_towards(user)
		if(randpixel)
			pixel_x = rand(-randpixel, randpixel)
			pixel_y = rand(-randpixel/2, randpixel/2)
			pixel_z = 0
		else if(randpixel == 0)
			pixel_x = 0
			pixel_y = 0
	return

/obj/item/attack_ai(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/robot_module))
		//If the item is part of a cyborg module, equip it
		if(!isrobot(user))
			return
		var/mob/living/silicon/robot/R = user
		R.activate_module(src)
		R.hud_used.update_robot_modules_display()

/obj/item/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = W
		if(S.use_to_pickup)
			if(S.collection_mode) //Mode is set to collect all items
				if(isturf(src.loc))
					S.gather_all(src.loc, user)
			else if(S.can_be_inserted(src, user))
				S.handle_item_insertion(src)

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

// apparently called whenever an item is removed from a slot, container, or anything else.
/obj/item/proc/dropped(mob/user as mob)
	if(randpixel)
		pixel_z = randpixel //an idea borrowed from some of the older pixel_y randomizations. Intended to make items appear to drop at a character

	update_twohanding()
	if(user)
		if(user.l_hand)
			user.l_hand.update_twohanding()
		if(user.r_hand)
			user.r_hand.update_twohanding()

// called just as an item is picked up (loc is not yet changed)
/obj/item/proc/pickup(mob/user)
	return

// called when this item is removed from a storage item, which is passed on as S. The loc variable is already set to the new destination before this is called.
/obj/item/proc/on_exit_storage(obj/item/weapon/storage/S as obj)
	return

// called when this item is added into a storage item, which is passed on as S. The loc variable is already set to the storage item.
/obj/item/proc/on_enter_storage(obj/item/weapon/storage/S as obj)
	return

// called when "found" in pockets and storage items. Returns 1 if the search should end.
/obj/item/proc/on_found(mob/finder as mob)
	return

// called after an item is placed in an equipment slot
// user is mob that equipped it
// slot uses the slot_X defines found in setup.dm
// for items that can be placed in multiple slots
// note this isn't called during the initial dressing of a player
/obj/item/proc/equipped(mob/user, slot)
	hud_layerise()
	if(user.client)	user.client.screen |= src
	if(user.pulling == src) user.stop_pulling()

	//Update two-handing status
	var/mob/M = loc
	if(!istype(M))
		return
	if(M.l_hand)
		M.l_hand.update_twohanding()
	if(M.r_hand)
		M.r_hand.update_twohanding()

//Defines which slots correspond to which slot flags
var/list/global/slot_flags_enumeration = list(
	"[slot_wear_mask]" = SLOT_MASK,
	"[slot_back]" = SLOT_BACK,
	"[slot_wear_suit]" = SLOT_OCLOTHING,
	"[slot_gloves]" = SLOT_GLOVES,
	"[slot_shoes]" = SLOT_FEET,
	"[slot_belt]" = SLOT_BELT,
	"[slot_glasses]" = SLOT_EYES,
	"[slot_head]" = SLOT_HEAD,
	"[slot_l_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_r_ear]" = SLOT_EARS|SLOT_TWOEARS,
	"[slot_w_uniform]" = SLOT_ICLOTHING,
	"[slot_wear_id]" = SLOT_ID,
	"[slot_tie]" = SLOT_TIE,
	)

//the mob M is attempting to equip this item into the slot passed through as 'slot'. Return 1 if it can do this and 0 if it can't.
//If you are making custom procs but would like to retain partial or complete functionality of this one, include a 'return ..()' to where you want this to happen.
//Set disable_warning to 1 if you wish it to not give you outputs.
//Should probably move the bulk of this into mob code some time, as most of it is related to the definition of slots and not item-specific
//set force to ignore blocking overwear and occupied slots
/obj/item/proc/mob_can_equip(M as mob, slot, disable_warning = 0, force = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!ishuman(M)) return 0

	var/mob/living/carbon/human/H = M
	var/list/mob_equip = list()
	if(H.species.hud && H.species.hud.equip_slots)
		mob_equip = H.species.hud.equip_slots

	if(H.species && !(slot in mob_equip))
		return 0

	//First check if the item can be equipped to the desired slot.
	if("[slot]" in slot_flags_enumeration)
		var/req_flags = slot_flags_enumeration["[slot]"]
		if(!(req_flags & slot_flags))
			return 0

	if(!force)
		//Next check that the slot is free
		if(H.get_equipped_item(slot))
			return 0

		//Next check if the slot is accessible.
		var/mob/_user = disable_warning? null : H
		if(!H.slot_is_accessible(slot, src, _user))
			return 0

	//Lastly, check special rules for the desired slot.
	switch(slot)
		if(slot_l_ear, slot_r_ear)
			var/slot_other_ear = (slot == slot_l_ear)? slot_r_ear : slot_l_ear
			if( (w_class > ITEM_SIZE_TINY) && !(slot_flags & SLOT_EARS) )
				return 0
			if( (slot_flags & SLOT_TWOEARS) && H.get_equipped_item(slot_other_ear) )
				return 0
		if(slot_belt, slot_wear_id)
			if(slot == slot_belt && (item_flags & ITEM_FLAG_IS_BELT))
				return 1
			else if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN("warning", "You need a jumpsuit before you can attach this [name]."))
				return 0
		if(slot_l_store, slot_r_store)
			if(!H.w_uniform && (slot_w_uniform in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN("warning", "You need a jumpsuit before you can attach this [name]."))
				return 0
			if(slot_flags & SLOT_DENYPOCKET)
				return 0
			if( w_class > ITEM_SIZE_SMALL && !(slot_flags & SLOT_POCKET) )
				return 0
			if(get_storage_cost() == ITEM_SIZE_NO_CONTAINER)
				return 0 //pockets act like storage and should respect ITEM_SIZE_NO_CONTAINER. Suit storage might be fine as is
		if(slot_s_store)
			if(!H.wear_suit && (slot_wear_suit in mob_equip))
				if(!disable_warning)
					to_chat(H, SPAN("warning", "You need a suit before you can attach this [name]."))
				return 0
			if(!H.wear_suit.allowed)
				if(!disable_warning)
					to_chat(usr, SPAN("warning", "You somehow have a suit with no defined allowed items for suit storage, stop that."))
				return 0
			if( !(istype(src, /obj/item/device/pda) || istype(src, /obj/item/weapon/pen) || is_type_in_list(src, H.wear_suit.allowed)) )
				return 0
		if(slot_handcuffed)
			if(!istype(src, /obj/item/weapon/handcuffs))
				return 0
		if(slot_in_backpack) //used entirely for equipping spawned mobs or at round start
			var/allow = 0
			if(H.back && istype(H.back, /obj/item/weapon/storage/backpack))
				var/obj/item/weapon/storage/backpack/B = H.back
				if(B.can_be_inserted(src,M,1))
					allow = 1
			if(!allow)
				return 0
		if(slot_tie)
			if((!H.w_uniform && (slot_w_uniform in mob_equip)) && (!H.wear_suit && (slot_wear_suit in mob_equip)))
				if(!disable_warning)
					to_chat(H, SPAN("warning", "You need something you can attach \the [src] to."))
				return 0
			if(H.w_uniform && (slot_w_uniform in mob_equip))
				var/obj/item/clothing/under/uniform = H.w_uniform
				if(uniform && !uniform.can_attach_accessory(src))
					if (!disable_warning)
						to_chat(H, SPAN("warning", "You cannot equip \the [src] to \the [uniform]."))
					return 0
			if(H.wear_suit && (slot_wear_suit in mob_equip))
				var/obj/item/clothing/suit/suit = H.wear_suit
				if(suit && !suit.can_attach_accessory(src))
					if (!disable_warning)
						to_chat(H, SPAN("warning", "You cannot equip \the [src] to \the [suit]."))
					return 0

	return 1

/obj/item/proc/return_item()
	return src

/obj/item/proc/mob_can_unequip(mob/M, slot, disable_warning = 0)
	if(!slot) return 0
	if(!M) return 0

	if(!canremove)
		return 0
	if(!M.slot_is_accessible(slot, src, disable_warning? null : M))
		return 0
	return 1

/obj/item/verb/verb_pickup()
	set src in oview(1)
	set category = "Object"
	set name = "Pick up"

	if(!(usr)) //BS12 EDIT
		return
	if(!CanPhysicallyInteract(usr))
		return
	if((!istype(usr, /mob/living/carbon)) || (istype(usr, /mob/living/carbon/brain)))//Is humanoid, and is not a brain
		to_chat(usr, SPAN("warning", "You can't pick things up!"))
		return
	if( usr.stat || usr.restrained() )//Is not asleep/dead and is not restrained
		to_chat(usr, SPAN("warning", "You can't pick things up!"))
		return
	if(src.anchored) //Object isn't anchored
		to_chat(usr, SPAN("warning", "You can't pick that up!"))
		return
	if(!usr.hand && usr.r_hand) //Right hand is not full
		to_chat(usr, SPAN("warning", "Your right hand is full."))
		return
	if(usr.hand && usr.l_hand) //Left hand is not full
		to_chat(usr, SPAN("warning", "Your left hand is full."))
		return
	if(!istype(src.loc, /turf)) //Object is on a turf
		to_chat(usr, SPAN("warning", "You can't pick that up!"))
		return
	//All checks are done, time to pick it up!
	usr.UnarmedAttack(src)
	return


//This proc is executed when someone clicks the on-screen UI button. To make the UI button show, set the 'icon_action_button' to the icon_state of the image of the button in screen1_action.dmi
//The default action is attack_self().
//Checks before we get to here are: mob is alive, mob is not restrained, paralyzed, asleep, resting, laying, item is on the mob.
/obj/item/proc/ui_action_click()
	attack_self(usr)

//RETURN VALUES
//handle_shield should return a positive value to indicate that the attack is blocked and should be prevented.
//If a negative value is returned, it should be treated as a special return value for bullet_act() and handled appropriately.
//For non-projectile attacks this usually means the attack is blocked.
//Otherwise should return 0 to indicate that the attack is not affected in any way.
/obj/item/proc/handle_shield(mob/user, damage, atom/damage_source = null, mob/attacker = null, def_zone = null, attack_text = "the attack")

	if(!user.blocking) return 0 // We weren't ready bruh
	if(istype(damage_source,/obj/item/projectile))
		var/obj/item/projectile/P = damage_source
		if(!P.blockable)
			return 0
		if(src.mod_shield >= 2.5)
			// some effects here
			var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
			spark_system.set_up(3, 0, user.loc)
			spark_system.start()
			if(istype(P,/obj/item/projectile/beam))
				visible_message(SPAN("warning", "\The [user] dissolves [P] with their [src.name]!"))
				proj_poise_drain(user, P)
				return PROJECTILE_FORCE_BLOCK // Beam reflections code is kinda messy, I ain't gonna touch it. ~Toby
			else if(P.starting)
				visible_message(SPAN("warning", "\The [user] reflects [P] with their [src.name]!"))

				// Find a turf near or on the original location to bounce to
				var/new_x = P.starting.x + rand(-2,2)
				var/new_y = P.starting.y + rand(-2,2)
				var/turf/curloc = get_turf(user)

				// redirect the projectile
				P.redirect(new_x, new_y, curloc, user)
				proj_poise_drain(user, P)
				return PROJECTILE_CONTINUE // complete projectile permutation
		else if(src.mod_shield >= 1.3)
			if(P.armor_penetration > (25*src.mod_shield)-5)
				visible_message(SPAN("warning", "\The [user] tries to block [P] with their [src.name]. <b>Not the best idea.</b>"))
				return 0
			visible_message(SPAN("warning", "\The [user] blocks [P] with their [src.name]!"))
			proj_poise_drain(user, P, TRUE)
			return PROJECTILE_FORCE_BLOCK
	return 0

/obj/item/proc/proj_poise_drain(mob/user, obj/item/projectile/P, weak_shield = FALSE)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		var/poise_dmg = P.damage/(src.mod_shield*2.5)
		if(weak_shield && P.damage_type == BRUTE)
			poise_dmg = P.damage+(P.agony/1.5)/(src.mod_shield*2.5)
		if(src != H.get_active_hand())
			poise_dmg *= 2
		H.poise -= poise_dmg
		if(H.poise < poise_dmg)
			shot_out(H, P)

/obj/item/proc/shot_out(mob/living/carbon/human/H, obj/item/projectile/P, msg = "shot", dist = 3) // item gets shot out of one's hands w/ a projectile
	H.useblock_off()
	H.poise -= 10
	if(!canremove)
		visible_message(SPAN("warning", "[H] blocks [P] with \the [src]!"))
		return
	visible_message(SPAN("danger", "\The [src] gets [msg] out of [H]'s hands by \a [P]!"))
	H.drop_from_inventory(src)
	if(src && istype(loc,/turf))
		throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,dist),5)

/obj/item/proc/knocked_out(mob/living/carbon/human/H, strong_knock = FALSE, dist = 2) // item gets knocked out of one's hands
	H.useblock_off()
	if(canremove)
		H.drop_from_inventory(src)
		if(src && istype(loc,/turf))
			throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1,dist),1)
		if(!strong_knock)
			H.visible_message(SPAN("warning", "[H]'s [src] flies off!"))
			return
	H.visible_message(SPAN("warning", "[H] falls down, unable to keep balance!"))
	H.apply_effect(3, WEAKEN, 0)

/obj/item/proc/get_loc_turf()
	var/atom/L = loc
	while(L && !istype(L, /turf/))
		L = L.loc
	return loc

/obj/item/proc/eyestab(mob/living/carbon/M as mob, mob/living/carbon/user as mob)

	var/mob/living/carbon/human/H = M
	if(istype(H))
		for(var/obj/item/protection in list(H.head, H.wear_mask, H.glasses))
			if(protection && (protection.body_parts_covered & EYES))
				// you can't stab someone in the eyes wearing a mask!
				to_chat(user, SPAN("warning", "You're going to need to remove the eye covering first."))
				return

	if(!M.has_eyes())
		to_chat(user, SPAN("warning", "You cannot locate any eyes on [M]!"))
		return

	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)

	src.add_fingerprint(user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		M = user

		to_chat(M, SPAN("warning", "You stab yourself in the eye."))
		M.sdisabilities |= BLIND
		M.weakened += 4
		M.adjustBruteLoss(10)


	if(istype(H))

		var/obj/item/organ/internal/eyes/eyes = H.internal_organs_by_name[BP_EYES]

		if(H != user)
			for(var/mob/O in (viewers(M) - user - M))
				O.show_message(SPAN("danger", "[M] has been stabbed in the eye with [src] by [user]."), 1)
			to_chat(M, SPAN("danger", "[user] stabs you in the eye with [src]!"))
			to_chat(user, SPAN("danger", "You stab [M] in the eye with [src]!"))
		else
			user.visible_message( \
				SPAN("danger", "[user] has stabbed themself with [src]!"), \
				SPAN("danger", "You stab yourself in the eyes with [src]!") \
			)

		eyes.damage += rand(3,4)
		if(eyes.damage >= eyes.min_bruised_damage)
			if(M.stat != 2)
				if(!BP_IS_ROBOTIC(eyes)) //robot eyes bleeding might be a bit silly
					to_chat(M, SPAN("danger", "Your eyes start to bleed profusely!"))
			if(prob(50))
				if(M.stat != 2)
					to_chat(M, SPAN("warning", "You drop what you're holding and clutch at your eyes!"))
					M.drop_item()
				M.eye_blurry += 10
				M.Paralyse(1)
				M.Weaken(4)
			if (eyes.damage >= eyes.min_broken_damage)
				if(M.stat != 2)
					to_chat(M, SPAN("warning", "You go blind!"))

		var/obj/item/organ/external/affecting = H.get_organ(eyes.parent_organ)
		affecting.take_external_damage(7)
	else
		M.take_organ_damage(7)
	M.eye_blurry += rand(3,4)
	return

/obj/item/clean_blood()
	. = ..()
	if(blood_overlay)
		overlays.Remove(blood_overlay)
	if(istype(src, /obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = src
		G.transfer_blood = 0

/obj/item/reveal_blood()
	if(was_bloodied && !fluorescent)
		fluorescent = 1
		blood_color = COLOR_LUMINOL
		blood_overlay.color = COLOR_LUMINOL
		update_icon()

/obj/item/add_blood(mob/living/carbon/human/M as mob)
	if (!..())
		return 0

	if(istype(src, /obj/item/weapon/melee/energy))
		return

	//if we haven't made our blood_overlay already
	if( !blood_overlay )
		generate_blood_overlay()

	//apply the blood-splatter overlay if it isn't already in there
	if(!blood_DNA.len)
		blood_overlay.color = blood_color
		overlays += blood_overlay

	//if this blood isn't already in the list, add it
	if(istype(M))
		if(blood_DNA[M.dna.unique_enzymes])
			return 0 //already bloodied with this blood. Cannot add more.
		blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
	return 1 //we applied blood to the item

GLOBAL_LIST_EMPTY(blood_overlay_cache)

/obj/item/proc/generate_blood_overlay(force = FALSE)
	if(blood_overlay && !force)
		return
	if(GLOB.blood_overlay_cache["[icon]" + icon_state])
		blood_overlay = GLOB.blood_overlay_cache["[icon]" + icon_state]
		return
	var/image/blood = image(icon = 'icons/effects/blood.dmi', icon_state = "itemblood")
	blood.filters += filter(type = "alpha", icon = icon(icon, icon_state))
	GLOB.blood_overlay_cache["[icon]" + icon_state] = blood
	blood_overlay = blood

/obj/item/proc/showoff(mob/user)
	for (var/mob/M in view(user))
		M.show_message("[user] holds up [src]. <a HREF=?src=\ref[M];lookitem=\ref[src]>Take a closer look.</a>",1)

/mob/living/carbon/verb/showoff()
	set name = "Show Held Item"
	set category = "Object"

	var/obj/item/I = get_active_hand()
	if(I && I.simulated)
		I.showoff(src)

/*
For zooming with scope or binoculars. This is called from
modules/mob/mob_movement.dm if you move you will be zoomed out
modules/mob/living/carbon/human/life.dm if you die, you will be zoomed out.
*/
//Looking through a scope or binoculars should /not/ improve your periphereal vision. Still, increase viewsize a tiny bit so that sniping isn't as restricted to NSEW
/obj/item/proc/zoom(mob/user, tileoffset = 14, viewsize = 9) //tileoffset is client view offset in the direction the user is facing. viewsize is how far out this thing zooms. 7 is normal view
	if(!user.client)
		return
	if(zoom)
		return

	var/devicename = zoomdevicename || name

	var/mob/living/carbon/human/H = user
	if(user.incapacitated(INCAPACITATION_DISABLED))
		to_chat(user, SPAN("warning", "You are unable to focus through the [devicename]."))
		return
	else if(!zoom && istype(H) && H.equipment_tint_total >= TINT_MODERATE)
		to_chat(user, SPAN("warning", "Your visor gets in the way of looking through the [devicename]."))
		return
	else if(!zoom && user.get_active_hand() != src)
		to_chat(user, SPAN("warning", "You are too distracted to look through the [devicename], perhaps if it was in your active hand this might work better."))
		return

	if(user.hud_used.hud_shown)
		user.toggle_zoom_hud()	// If the user has already limited their HUD this avoids them having a HUD when they zoom in
	user.client.view = viewsize
	zoom = 1

	var/viewoffset = WORLD_ICON_SIZE * tileoffset
	switch(user.dir)
		if (NORTH)
			user.client.pixel_x = 0
			user.client.pixel_y = viewoffset
		if (SOUTH)
			user.client.pixel_x = 0
			user.client.pixel_y = -viewoffset
		if (EAST)
			user.client.pixel_x = viewoffset
			user.client.pixel_y = 0
		if (WEST)
			user.client.pixel_x = -viewoffset
			user.client.pixel_y = 0

	user.visible_message("\The [user] peers through [zoomdevicename ? "the [zoomdevicename] of [src]" : "[src]"].")

	GLOB.destroyed_event.register(src, src, /obj/item/proc/unzoom)
	GLOB.moved_event.register(src, src, /obj/item/proc/zoom_move)
	GLOB.dir_set_event.register(src, src, /obj/item/proc/unzoom)
	GLOB.item_unequipped_event.register(src, src, /obj/item/proc/zoom_drop)
	GLOB.stat_set_event.register(user, src, /obj/item/proc/unzoom)

/obj/item/proc/zoom_drop(obj/item/I, mob/user)
	unzoom(user)

/obj/item/proc/zoom_move(atom/movable/AM)
	if(ismob(AM.loc))
		var/mob/M = AM.loc
		unzoom(M)

/obj/item/proc/unzoom(mob/user)
	if(!zoom)
		return
	zoom = 0

	GLOB.destroyed_event.unregister(src, src, /obj/item/proc/unzoom)
	GLOB.moved_event.unregister(src, src, /obj/item/proc/zoom_move)
	GLOB.dir_set_event.unregister(src, src, /obj/item/proc/unzoom)
	GLOB.item_unequipped_event.unregister(src, src, /obj/item/proc/zoom_drop)

	user = user == src ? loc : (user || loc)
	if(!istype(user))
		crash_with("[log_info_line(src)]: Zoom user lost]")
		return

	GLOB.stat_set_event.unregister(user, src, /obj/item/proc/unzoom)

	if(!user.client)
		return

	user.client.view = world.view
	if(!user.hud_used.hud_shown)
		user.toggle_zoom_hud()

	user.client.pixel_x = 0
	user.client.pixel_y = 0
	user.visible_message("[zoomdevicename ? "\The [user] looks up from [src]" : "\The [user] lowers [src]"].")

/obj/item/proc/pwr_drain()
	return 0 // Process Kill

/obj/item/proc/get_icon_state(slot)
	if (item_state_slots)
		if (item_state_slots[slot])
			return item_state_slots[slot]

		switch (slot)
			if (slot_l_hand_str, slot_r_hand_str)
				if (item_state_slots[slot_hand_str])
					return item_state_slots[slot_hand_str]
			if (slot_l_ear_str, slot_r_ear_str)
				if (item_state_slots[slot_ear_str])
					return item_state_slots[slot_ear_str]

	if (item_state)
		return item_state

	return icon_state

/obj/item/proc/dir_shift(icon/given_icon, dir_given, x = 0, y = 0)
	var/icon/I = new(given_icon, dir = dir_given)
	I.Shift(EAST, x)
	I.Shift(NORTH, y)
	given_icon.Insert(I, dir = dir_given)
	return given_icon

/obj/item/proc/get_mob_overlay(mob/user_mob, slot)
	var/mob/living/carbon/human/user_human
	if(ishuman(user_mob))
		user_human = user_mob

	var/mob_state = get_icon_state(slot)

	var/mob_icon

	if(icon_override)
		mob_icon = icon_override
		if(slot == 	slot_l_hand_str || slot == slot_l_ear_str)
			mob_state = "[mob_state]_l"
		if(slot == 	slot_r_hand_str || slot == slot_r_ear_str)
			mob_state = "[mob_state]_r"
	else
		if(item_icons && item_icons[slot])
			mob_icon = item_icons[slot]
		else if (user_human && user_human.body_build)
			mob_icon = user_human.body_build.get_mob_icon(slot, mob_state)

	var/image/ret_overlay = overlay_image(mob_icon,mob_state,color,RESET_COLOR)
	if(user_human && user_human.species && user_human.species.equip_adjust.len)
		var/list/equip_adjusts = user_human.species.equip_adjust
		if(equip_adjusts[slot])
			var/image_key = "[user_human.species] [user_human.body_build.name] [mob_icon] [mob_state] [color]"
			ret_overlay = user_human.species.equip_overlays[image_key]
			if(!ret_overlay)
				var/icon/final_I = new(mob_icon, icon_state = mob_state)
				var/list/shifts = equip_adjusts[slot]
				if(shifts && shifts.len)
					var/shift_facing
					for(shift_facing in shifts)
						var/list/facing_list = shifts[shift_facing]
						final_I = dir_shift(final_I, text2dir(shift_facing), facing_list["x"], facing_list["y"])
				ret_overlay = overlay_image(final_I, color, flags = RESET_COLOR)

				user_human.species.equip_overlays[image_key] = ret_overlay

	return ret_overlay

/obj/item/proc/get_examine_line()
	if(blood_DNA)
		. = SPAN("warning", "\icon[src] [gender==PLURAL?"some":"a"] [(blood_color != SYNTH_BLOOD_COLOUR) ? "blood" : "oil"]-stained [src]")
	else
		. = "\icon[src] \a [src]"

//Some explanation here.
/obj/item/proc/update_attack_cooldown()
	var/res_cd
	res_cd = (attack_cooldown + DEFAULT_WEAPON_COOLDOWN * (mod_weight / mod_handy)) * mod_speed // i.e. Default attack speed for the-most-generic-item is 1 hit/s
	attack_cooldown_real = res_cd //Debug
	return res_cd

/obj/item/proc/update_weapon_desc()
	return

/obj/item/proc/on_restraint_removal(mob/living/carbon/C) //Needed for syndicuffs
	return

/obj/item/proc/on_restraint_apply(mob/living/carbon/C)
	return
