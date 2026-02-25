/obj/item/clothing/mask/smokable/ecig
	name = "electronic cigarette"
	desc = "Device with modern approach to smoking."
	icon = 'icons/obj/ecig.dmi'
	item_state = "ecigoff1"
	var/base_icon = ""

	attack_verb = list("attacked", "poked", "battered")
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS | SLOT_MASK
	body_parts_covered = NO_BODYPARTS

	chem_volume = 0 //ecig has no storage on its own but has reagent container created by parent obj
	filter_trans = 0.5
	smokeamount = 0.5

	var/active = FALSE
	var/obj/item/cell/cigcell = null
	var/obj/item/reagent_containers/ecig_cartridge/ec_cartridge = null

	var/cell_type = /obj/item/cell/device/standard
	var/cartridge_type = /obj/item/reagent_containers/ecig_cartridge/med_nicotine

	var/brightness_on = 1
	var/power_usage = 225 //value for simple ecig, enough for about 1 cartridge, in JOULES!
	var/idle_time = 0
	var/idle_treshold = 10
	var/opened = FALSE
	var/overlay_state = ""

/obj/item/clothing/mask/smokable/ecig/Initialize()
	. = ..()
	if(ispath(cell_type))
		cigcell = new cell_type(src)
	if(ispath(cartridge_type))
		ec_cartridge = new cartridge_type(src)
	update_icon()

/obj/item/clothing/mask/smokable/ecig/think()
	if(idle_treshold != -1 && idle_time >= idle_treshold) //idle too long -> automatic shut down
		idle_time = 0
		visible_message(SPAN("notice", "\The [src] powered down automatically."), null, 2)
		active = FALSE // autodisable the cigarette
		update_icon()
		return

	idle_time++

	if(ishuman(loc))
		var/mob/living/carbon/human/C = loc

		if(!active || !ec_cartridge || !ec_cartridge.reagents.total_volume)//no cartridge
			if(!ec_cartridge.reagents.total_volume)
				to_chat(C, SPAN("notice", "There is no liquid left in \the [src], so it powers down."))
			active = FALSE // autodisable the cigarette
			update_icon()
			return

		if(C.wear_mask == src && C.check_has_mouth()) // transfer, but only when not disabled
			idle_time = 0
			smoke(1)
			ec_cartridge.reagents.trans_to_mob(C, REM, CHEM_INGEST, 0.4) // Most of it is not inhaled... balance reasons.

	set_next_think(world.time + 1 SECOND)

/obj/item/clothing/mask/smokable/ecig/smoke(amount, manual = FALSE)
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/C = loc
	idle_time = 0
	if(!cigcell.check_charge(power_usage * CELLRATE)) //if this passes, there's not enough power in the battery
		active = FALSE
		update_icon()
		to_chat(C, SPAN("notice", "Battery in \the [src] ran out and it powered down."))
		return

	ec_cartridge.reagents.trans_to_mob(C, smokeamount*amount, CHEM_INGEST, filter_trans)

	smoke_effect++
	if((smoke_effect >= 3 || manual) && isturf(C.loc))
		smoke_effect = 0
		new /obj/effect/effect/cig_smoke/vapor(C.loc)

	cigcell.use(power_usage * CELLRATE)
	if(!cigcell.check_charge(power_usage * CELLRATE)) // Checking again after smoking
		active = FALSE
		to_chat(C, SPAN("notice", "Battery in \the [src] ran out and it powered down."))

	update_icon()

/obj/item/clothing/mask/smokable/ecig/attack(mob/living/M, mob/user, def_zone)
	if(active && M == user && ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/blocked = H.check_mouth_coverage()

		if(blocked)
			to_chat(H, SPAN("warning", "\The [blocked] is in the way!"))
			return TRUE

		user.visible_message("[user] takes a [pick("drag","puff","pull")] from \his [name].", \
							 "You take a [pick("drag","puff","pull")] on your [name].")

		smoke(3, TRUE)
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return TRUE

	return ..()

/obj/item/clothing/mask/smokable/ecig/on_update_icon()
	if(active)
		set_light(0.6, 0.5, brightness_on)
		icon_state = "[base_icon]_on"

		var/new_overlay_state = "[base_icon]_charge1"
		if(CELL_PERCENT(cigcell) >= 50)
			new_overlay_state = "[base_icon]_charge3"
		else if(CELL_PERCENT(cigcell) >= 25)
			new_overlay_state = "[base_icon]_charge2"

		if(new_overlay_state != overlay_state)
			overlay_state = new_overlay_state
			ClearOverlays()
			if(overlay_state)
				AddOverlays(image('icons/obj/ecig.dmi', overlay_state))
	else
		set_light(0)
		if(opened)
			icon_state = "[base_icon]_open[!!ec_cartridge]"
		else
			icon_state = "[base_icon]_off"
		overlay_state = ""
		ClearOverlays()

	if(ismob(loc))
		var/mob/living/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_l_hand(0)
		M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/ecig/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/ecig_cartridge))
		if(!opened)
			to_chat(user, SPAN("notice", "\The [src] must be opened first!"))
		else if(ec_cartridge)// can't add the second one
			to_chat(user, SPAN("notice", "There's already a cartridge in \the [src]."))
		else if(user.drop(I, src)) // fits in a new one
			ec_cartridge = I
			update_icon()
			to_chat(user, SPAN("notice", "You insert \the [I] into \the [src]."))

	if(isScrewdriver(I))
		if(cigcell) // if contains a powercell
			cigcell.update_icon()
			cigcell.dropInto(loc)
			cigcell = null
			to_chat(user, SPAN("notice", "You remove the cell from \the [src]."))
		else // does not contain a cell
			to_chat(user, SPAN("notice", "There is no powercell in \the [src]."))

	if(istype(I, /obj/item/cell/device))
		if(!cigcell && user.drop(I, src))
			cigcell = I
			to_chat(user, SPAN("notice", "You install a powercell into the [src]."))
			update_icon()
		else
			to_chat(user, SPAN("notice", "[src] already has a powercell."))

/obj/item/clothing/mask/smokable/ecig/attack_self(mob/user)
	if(opened)
		to_chat(user, SPAN("notice", "You close \the [src]."))
		opened = FALSE
		update_icon()
		return

	if(active)
		active = FALSE
		set_next_think(0)
		to_chat(user, SPAN("notice", "You turn off \the [src]."))
		update_icon()
		return

	if(!cigcell)
		to_chat(user, SPAN("notice", "\The [src] does not have a powercell installed."))
		return

	if(!cigcell.check_charge(power_usage * CELLRATE))
		to_chat(user, SPAN("notice", "Battery of \the [src] is too depleted to use."))
		return

	if(!ec_cartridge)
		to_chat(user, SPAN("notice", "You can't use \the [src] with no cartridge installed!"))
		return

	if(!ec_cartridge.reagents.total_volume)
		to_chat(user, SPAN("notice", "You can't use \the [src] with no liquid left!"))
		return

	to_chat(user, SPAN("notice", "You turn on \the [src]."))
	active = TRUE
	update_icon()
	set_next_think(world.time)

/obj/item/clothing/mask/smokable/ecig/attack_hand(mob/user)// Open lid or eject cartridge
	if(user.has_in_passive_hand(src) && !istype(src, /obj/item/clothing/mask/smokable/ecig/disposable))// If being hold
		active = FALSE
		if(!opened)
			opened = TRUE
			to_chat(user, SPAN("notice", "You open \the [src]."))
			update_icon()
			return
		else if(ec_cartridge)
			user.pick_or_drop(ec_cartridge)
			to_chat(user, SPAN("notice", "You eject \the [ec_cartridge] from \the [src]."))
			ec_cartridge = null
			update_icon()
			return
	..()

/obj/item/clothing/mask/smokable/ecig/AltClick()
	if(!Adjacent(usr))
		return
	opened = !opened
	active = FALSE
	to_chat(usr, SPAN("notice", "You [opened ? "open" : "close"] \the [src]."))
	update_icon()
	return

/// Types
/obj/item/clothing/mask/smokable/ecig/simple
	name = "cheap electronic cigarette"
	desc = "A cheap Lucky 1337 electronic cigarette, styled like a traditional cigarette."
	icon_state = "cheap_off"
	base_icon = "cheap"

/obj/item/clothing/mask/smokable/ecig/simple/examine(mob/user, infix)
	. = ..()

	if(ec_cartridge)
		. += SPAN("notice", "There is roughly [round((ec_cartridge.reagents.total_volume / ec_cartridge.volume) * 100, 25)]% of liquid remaining.")
	else
		. += SPAN("notice", "There is no cartridge connected.")

/obj/item/clothing/mask/smokable/ecig/util
	name = "electronic cigarette"
	desc = "A popular utilitarian model electronic cigarette, the ONI-55. Has configurable LED lights."
	icon_state = "mid_off"
	base_icon = "mid"
	cell_type = /obj/item/cell/device/high // Enough for four cartridges
	var/list/led_colors = list("b", "o", "g", "p")
	var/list/led_descs = list("blue flames", "blazing embers", "green venom", "royal purple")
	var/current_color = 2

/obj/item/clothing/mask/smokable/ecig/util/on_update_icon()
	..()
	if(active)
		icon_state = "[base_icon]_on_[led_colors[current_color]]"

/obj/item/clothing/mask/smokable/ecig/util/examine(mob/user, infix)
	. = ..()

	if(ec_cartridge)
		. += SPAN("notice", "There are [round(ec_cartridge.reagents.total_volume, 1)] ml of liquid remaining.")
	else
		. += SPAN("notice", "There is no cartridge connected.")

	. += SPAN("notice", "Gauge shows about [round(CELL_PERCENT(cigcell), 25)]% energy remaining.")
	. += SPAN("notice", "LEDs are set to \"[led_descs[current_color]]\" mode.")

/obj/item/clothing/mask/smokable/ecig/util/verb/change_LED_mode()
	set name = "Change LEDs mode"
	set category = "Object"
	set src in view(0)

	current_color++
	if(current_color > 4)
		current_color = 1
	var/_led = led_descs[current_color]
	to_chat(usr, SPAN("notice", "\The [src]'s LEDs are set to \"[_led]\" mode now."))
	update_icon()

/obj/item/clothing/mask/smokable/ecig/deluxe
	name = "deluxe electronic cigarette"
	desc = "A premium model eGavana MK3 electronic cigarette, shaped like a smoking pipe."
	icon_state = "pipe_off"
	base_icon = "pipe"
	item_state = "pipeoff"
	cell_type = /obj/item/cell/device/high // Enough for four catridges

/obj/item/clothing/mask/smokable/ecig/deluxe/examine(mob/user, infix)
	. = ..()

	if(ec_cartridge)
		. += SPAN("notice", "There are [round(ec_cartridge.reagents.total_volume, 1)] ml of liquid remaining.")
	else
		. += SPAN("notice", "There is no cartridge connected.")

	. += SPAN("notice", "Gauge shows [round(CELL_PERCENT(cigcell), 1)]% energy remaining.")


/// Cartridges
/obj/item/reagent_containers/ecig_cartridge
	name = "tobacco flavour cartridge"
	desc = "A small metal cartridge, used with electronic cigarettes, which contains an atomizing coil and a solution to be atomized."
	w_class = ITEM_SIZE_TINY
	icon = 'icons/obj/ecig.dmi'
	icon_state = "ecartridge"
	matter = list(MATERIAL_STEEL = 50, MATERIAL_GLASS = 10)
	volume = 20
	atom_flags = ATOM_FLAG_OPEN_CONTAINER
	var/flavor = "flavorless"
	var/label_color = "#ffffff"

/obj/item/reagent_containers/ecig_cartridge/examine(mob/user, infix)
	. = ..()
	. += "The cartridge has [reagents.total_volume] ml of liquid remaining."

/obj/item/reagent_containers/ecig_cartridge/Initialize()
	. = ..()
	var/image/over = image('icons/obj/ecig.dmi', "[icon_state]_over")
	over.color = label_color
	AddOverlays(over)

/obj/item/reagent_containers/ecig_cartridge/proc/make_disposable() // Sweet hacks
	volume *= 4
	reagents.maximum_volume *= 4
	for(var/thing in reagents.reagent_list)
		var/datum/reagent/R = thing
		R.volume *= 4

//flavours
/obj/item/reagent_containers/ecig_cartridge/blank
	name = "ecigarette cartridge"
	desc = "A small metal cartridge which contains an atomizing coil."

/obj/item/reagent_containers/ecig_cartridge/blanknico
	name = "flavorless nicotine cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says you can add whatever flavoring agents you want."

/obj/item/reagent_containers/ecig_cartridge/blanknico/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)

/obj/item/reagent_containers/ecig_cartridge/med_nicotine
	name = "tobacco flavour cartridge"
	desc =  "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its tobacco flavored."
/obj/item/reagent_containers/ecig_cartridge/med_nicotine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 15)
	flavor = "tobacco"
	label_color = "#7C512E"

/obj/item/reagent_containers/ecig_cartridge/high_nicotine
	name = "high nicotine tobacco flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its tobacco flavored, with extra nicotine."
	flavor = "strong tobacco"
	label_color = "#7A3A0F"

/obj/item/reagent_containers/ecig_cartridge/high_nicotine/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco, 10)
	reagents.add_reagent(/datum/reagent/glycerol, 10)

/obj/item/reagent_containers/ecig_cartridge/orange
	name = "orange flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its orange flavored."
	flavor = "orange"
	label_color = "#FF6A00"

/obj/item/reagent_containers/ecig_cartridge/orange/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/drink/juice/orange, 5)

/obj/item/reagent_containers/ecig_cartridge/mint
	name = "mint flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its mint flavored."
	flavor = "mint"
	label_color = "#00FF90"

/obj/item/reagent_containers/ecig_cartridge/mint/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/menthol, 5)

/obj/item/reagent_containers/ecig_cartridge/watermelon
	name = "watermelon flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its watermelon flavored."
	flavor = "watermelon"
	label_color = "#FF4C70"

/obj/item/reagent_containers/ecig_cartridge/watermelon/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/drink/juice/watermelon, 5)

/obj/item/reagent_containers/ecig_cartridge/grape
	name = "grape flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its grape flavored."
	flavor = "grape"
	label_color = "#B200FF"

/obj/item/reagent_containers/ecig_cartridge/grape/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/drink/juice/grape, 5)

/obj/item/reagent_containers/ecig_cartridge/lemonlime
	name = "lemon-lime flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its lemon-lime flavored."
	flavor = "lemon-lime"
	label_color = "#B6FF00"

/obj/item/reagent_containers/ecig_cartridge/lemonlime/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/drink/lemon_lime, 5)

/obj/item/reagent_containers/ecig_cartridge/coffee
	name = "coffee flavour cartridge"
	desc = "A small metal cartridge which contains an atomizing coil and a solution to be atomized. The label says its coffee flavored."
	flavor = "coffee"
	label_color = "#7F3300"

/obj/item/reagent_containers/ecig_cartridge/coffee/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/tobacco/liquid, 5)
	reagents.add_reagent(/datum/reagent/glycerol, 10)
	reagents.add_reagent(/datum/reagent/caffeine/coffee, 5)


// Disposables
/obj/item/clothing/mask/smokable/ecig/disposable
	name = "disposable electronic cigarette"
	desc = "A cheap SkrellBar electronic cigarette, designed to be disposed after use."
	icon_state = "disp"
	base_icon = "disp"
	cell_type = /obj/item/cell/device/high
	cartridge_type = null
	idle_treshold = -1
	active = TRUE
	smokeamount = 1
	power_usage = 450

/obj/item/clothing/mask/smokable/ecig/disposable/Initialize()
	. = ..()
	var/flavor_roulette = pick(/obj/item/reagent_containers/ecig_cartridge/high_nicotine,\
							/obj/item/reagent_containers/ecig_cartridge/orange,\
							/obj/item/reagent_containers/ecig_cartridge/mint,\
							/obj/item/reagent_containers/ecig_cartridge/watermelon,\
							/obj/item/reagent_containers/ecig_cartridge/grape,\
							/obj/item/reagent_containers/ecig_cartridge/lemonlime,\
							/obj/item/reagent_containers/ecig_cartridge/coffee)
	ec_cartridge = new flavor_roulette(src)
	ec_cartridge.make_disposable()
	color = ec_cartridge.label_color
	desc += " This one is [ec_cartridge.flavor] flavored."

/obj/item/clothing/mask/smokable/ecig/disposable/on_update_icon()
	icon_state = base_icon

	if(active)
		var/new_overlay_state = "[base_icon]_charge1"
		if(CELL_PERCENT(cigcell) >= 50)
			new_overlay_state = "[base_icon]_charge3"
		else if(CELL_PERCENT(cigcell) >= 25)
			new_overlay_state = "[base_icon]_charge2"

		if(new_overlay_state != overlay_state)
			overlay_state = new_overlay_state
			if(overlay_state)
				AddOverlays(OVERLAY('icons/obj/ecig.dmi', overlay_state, alpha, RESET_COLOR))
	else
		overlay_state = ""
		ClearOverlays()

	if(ismob(loc))
		var/mob/living/M = loc
		M.update_inv_wear_mask(0)
		M.update_inv_l_hand(0)
		M.update_inv_r_hand(1)

/obj/item/clothing/mask/smokable/ecig/disposable/attack_self(mob/user)
	return

/obj/item/clothing/mask/smokable/ecig/disposable/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/reagent_containers/ecig_cartridge))
		to_chat(user, SPAN("notice", "\The [src] is sealed and cannot be refilled."))

	if(isScrewdriver(I))
		to_chat(user, SPAN("notice", "\The [src] is sealed, there's no way to remove the cell."))

	if(istype(I, /obj/item/cell/device))
		to_chat(user, SPAN("notice", "\The [src] is sealed, there's no way to replace the cell."))

/obj/item/clothing/mask/smokable/ecig/disposable/AltClick()
	return

/obj/item/clothing/mask/smokable/ecig/disposable/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	set_next_think(world.time + 1 SECOND)

/obj/item/clothing/mask/smokable/ecig/disposable/dropped(mob/user)
	set_next_think(0)
	return ..()
