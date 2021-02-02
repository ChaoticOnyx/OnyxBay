//True gamer gear, protects user from bullets and lasers.
//BUT YOU CAN ONLY GO MELEE!

//Interface, don't use in actual game
/obj/item/weapon/shield/shield_belt
	name = "shield belt"
	desc = "Protects user from bullets and lasers, but don't allow you to shoot"
	icon = 'icons/obj/clothing/belts.dmi' //to be changed
	icon_state = "utilitybelt"
	item_state = "utility"
	item_flags = ITEM_FLAG_IS_BELT
	//belt slot, yea balance
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	//aura of shield, if not null you are protected
	var/obj/aura/shields/shield_belt/shield
	var/max_power = 3000
	var/current_power = 3000
	//used only in science shield, but added to interface to
	//not duplicate take_charge()
	var/obj/item/weapon/cell/bcell
	//syndy shield regen
	var/restored_power_per_tick = 5

//icon of belt
/obj/item/weapon/shield/shield_belt/proc/update_icon_state()
	var/mob/M = src.loc
	M.update_inv_belt()
	if(istype(src, /obj/item/weapon/shield/shield_belt/syndicate_shield_belt))
		if(shield)
			icon_state = "syndi_shield_belt"
			M.update_action_buttons()
		else
			icon_state = "syndi_shield_belt_off"
			M.update_action_buttons()
	else
		if(shield)
			switch(round(bcell.charge / bcell.maxcharge * 100))
				if(50 to 100)
					icon_state = "science_shield_belt_full"
					M.update_action_buttons()
					return
				if(20 to 49)
					icon_state = "science_shield_belt_half"
					M.update_action_buttons()
					return
				if(0 to 19)
					icon_state = "science_shield_belt_almost_empty"
					M.update_action_buttons()
					return
		else
			if(bcell)
				if(bcell.charge < 300)
					icon_state = "science_shield_belt_empty"
					M.update_action_buttons()
					return
				switch (round(bcell.charge / bcell.maxcharge * 100))
					if(50 to 100)
						icon_state = "science_shield_belt_off_green"
						M.update_action_buttons()
						return
					if(20 to 49)
						icon_state = "science_shield_belt_off_yellow"
						M.update_action_buttons()
						return
					if(0 to 20)
						icon_state = "science_shield_belt_off_red"
						M.update_action_buttons()
						return
			else
				icon_state = "science_shield_belt_nobattery"

/obj/item/weapon/shield/shield_belt/proc/toggle(var/mob/user)
	if(!shield)
		turn_on(user)
	else
		turn_off()

/obj/item/weapon/shield/shield_belt/proc/turn_off()
	QDEL_NULL(shield)
	update_icon_state()

/obj/item/weapon/shield/shield_belt/proc/turn_on(var/mob/user)
	shield = new(user, src)
	update_icon_state()

/obj/item/weapon/shield/shield_belt/dropped()
	turn_off()

//turns off if not at belt slot
/obj/item/weapon/shield/shield_belt/equipped(var/mob/user, var/slot)
	if(slot != slot_belt)
		turn_off()
	. = ..()

/obj/item/weapon/shield/shield_belt/Destroy()
	QDEL_NULL(shield)
	if(!ispath(bcell))
		QDEL_NULL(bcell)
	STOP_PROCESSING(SSobj, src)
	return ..()

//when got hit
/obj/item/weapon/shield/shield_belt/proc/take_charge(obj/item/projectile/P)
	START_PROCESSING(SSobj, src)
	if(istype(src, /obj/item/weapon/shield/shield_belt/syndicate_shield_belt))
		take_internal_charge(P)
	else
		take_cell_charge(P)

//for syndy one
/obj/item/weapon/shield/shield_belt/proc/take_internal_charge(obj/item/projectile/P)
	current_power = current_power - P.damage * 10
	if(current_power <= 0)
		current_power = 0
		to_chat(loc, SPAN_DANGER("The [src] begins to spark as it turns off!</span>"))
		turn_off()

//for RND one
/obj/item/weapon/shield/shield_belt/proc/take_cell_charge(obj/item/projectile/P)
	if(bcell)
		if(bcell.checked_use(current_power - P.damage * 10))
			update_icon_state()
		else
			bcell.charge = 0
			QDEL_NULL(shield)
			to_chat(loc, SPAN_DANGER("The [src] begins to spark as it turns off!"))
			turn_off()


//syndicate gamer gear, can regenerate battery over time, but can't change it
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt
	icon_state = "syndi_shield_belt_off"
	item_state = "shield_sindy_off"
	name = "strange shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot. This one appears to have mini-reactor and able to restore itself after some time. Looks suspicious."
	description_info = "ALT+CLICK when weared at belt slot to use the shield."
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6, TECH_ILLEGAL = 4)
	action_button_name = "Toggle Shield"

//how belt looks at mob
obj/item/weapon/shield/shield_belt/syndicate_shield_belt/get_mob_overlay(mob/user_mob, slot)
	if(shield)
		item_state = "shield_sindy_on"
	else
		item_state = "shield_sindy_off"
	var/image/ret = ..()
	if(slot == slot_belt_str)
		ret.overlays += image("icon" = 'icons/inv_slots/belts/mob.dmi', "icon_state" = "[item_state]")
	return ret

//procent of charge
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/examine(mob/user, distance)
	. = ..()
	. += "\nThe internal capacitor currently has [round(current_power/max_power * 100)]% charge."

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/proc/toggle_belt(mob/living/user)
	if(user.get_inventory_slot(src) == slot_belt)
		if(current_power > 300 && !shield)
			current_power -= 300
			START_PROCESSING(SSobj, src)
			toggle(user)
		else if(shield)
			toggle(user)
		else
			to_chat(loc, SPAN_DANGER("The [src] has no energy!"))
	else
		to_chat(loc, SPAN_DANGER("\The [src] must be weared at belt to be used"))

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/proc/change_status(mob/living/user)
	to_chat(loc,SPAN_NOTICE("The [user] touches the button on belt!"))
	addtimer(CALLBACK(src, .proc/toggle_belt, user), 20, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/ui_action_click()
	toggle_shield()

obj/item/weapon/shield/shield_belt/syndicate_shield_belt/verb/toggle_shield()
	set name = "Toggle Shield"
	set category = "Object"
	src.change_status(src.loc)

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/AltClick(mob/living/user)
	change_status(user)

/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/Process(wait)
	if(!shield)
		if(current_power >= max_power)
			return PROCESS_KILL
		current_power += min(restored_power_per_tick * wait, max_power - current_power)

//Lose some charge and turn off
/obj/item/weapon/shield/shield_belt/syndicate_shield_belt/emp_act(severity)
	current_power = max(current_power / (2 * severity), max_power / (4 * severity))
	turn_off()

//RND belt, can change battery, but can't regenerate
//AND ALSO IT EXPLODES IF EMI HITS IT WHEN IT ACTIVE
/obj/item/weapon/shield/shield_belt/experimental_shield_belt
	icon_state = "science_shield_belt_off_green"
	item_state = "science_shield_off"
	name = "experimental shield belt"
	desc = "Protects user from bullets and lasers, but doesn't allow you to shoot. Powered by battery. This one looks unstable."
	description_info = "ALT+CLICK when weared at belt slot to use the shield, use Screwdriver to change battery "
	origin_tech = list(TECH_MATERIAL = 6, TECH_MAGNET = 6)
	bcell = /obj/item/weapon/cell/high/empty
	action_button_name = "Toggle Shield"

obj/item/weapon/shield/shield_belt/experimental_shield_belt/get_mob_overlay(mob/user_mob, slot)
	if(shield)
		item_state = "science_shield_on"
	else
		item_state = "science_shield_off"
	var/image/ret = ..()
	if(slot == slot_belt_str)
		ret.overlays += image("icon" = 'icons/inv_slots/belts/mob.dmi', "icon_state" = "[item_state]")
	return ret

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/Initialize()
	. = ..()
	if(ispath(bcell))
		bcell = new bcell(src)

//battery changing
/obj/item/weapon/shield/shield_belt/experimental_shield_belt/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/cell))
		if(!bcell && user.unEquip(W))
			W.forceMove(src)
			bcell = W
			to_chat(user, SPAN_NOTICE("You install a cell into the [src]."))
			update_icon_state()
		else
			to_chat(user, SPAN_NOTICE("[src] already has a cell."))
	else if(isScrewdriver(W))
		if(bcell)
			turn_off()
			bcell.update_icon()
			bcell.dropInto(loc)
			to_chat(user, SPAN_NOTICE("You remove the cell from the [src]"))
			bcell = null
			update_icon_state()

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/examine(mob/user, distance)
	. = ..()
	if(bcell)
		. += "\nThere is \a [bcell] in \the [src]."
		. += "\nThe internal capacitor currently has [round(bcell.charge/bcell.maxcharge * 100)]% charge."
	else
		. += "\nThere is no cell in \the [src]."

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/proc/toggle_belt(mob/living/user)
	if(user.get_inventory_slot(src) == slot_belt)
		if(bcell)
			if(!shield && bcell.checked_use(300))
				toggle(user)
			else if(shield)
				toggle(user)
			else
				to_chat(loc, SPAN_DANGER("The [src] has no energy!"))
		else
			to_chat(loc, SPAN_DANGER("\The [src] has no battery!"))
	else
		to_chat(loc, SPAN_DANGER("\The [src] must be weared at belt to be used"))

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/proc/change_status(mob/living/user)
	to_chat(loc, SPAN_NOTICE("The [user] touches the button on belt!"))
	addtimer(CALLBACK(src, .proc/toggle_belt, user), 20, TIMER_UNIQUE | TIMER_OVERRIDE)

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/ui_action_click()
	toggle_shield()

obj/item/weapon/shield/shield_belt/experimental_shield_belt/verb/toggle_shield()
	set name = "Toggle Shield"
	set category = "Object"
	src.change_status(src.loc)

/obj/item/weapon/shield/shield_belt/experimental_shield_belt/AltClick(mob/living/user)
	change_status(user)

//explosion if active
/obj/item/weapon/shield/shield_belt/experimental_shield_belt/emp_act(severity)
	if(bcell)
		if(shield)
			visible_message(SPAN_DANGER("\The [src] explodes!"))
			explosion(src.loc, 0, 1, 3)
			qdel(src)
			return
		bcell.emp_act(severity)
		update_icon_state()
