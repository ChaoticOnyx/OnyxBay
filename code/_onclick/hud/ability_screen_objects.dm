/atom/movable/screen/movable/ability_master
	name = "Abilities"
	icon = 'icons/hud/screen_spells.dmi'
	icon_state = "grey_spell_ready"
	var/list/atom/movable/screen/ability/ability_objects = list()
	var/list/atom/movable/screen/ability/spell_objects = list()
	var/list/atom/movable/screen/ability/changeling_power_objects = list()
	var/list/atom/movable/screen/ability/vampire_power_objects = list()
	var/showing = 0 // If we're 'open' or not.

	var/open_state = "master_open"		// What the button looks like when it's 'open', showing the other buttons.
	var/closed_state = "master_closed"	// Button when it's 'closed', hiding everything else.

	screen_loc = ui_spell_master // TODO: Rename

	var/mob/my_mob = null // The mob that possesses this hud object.

/atom/movable/screen/movable/ability_master/New(newloc,owner)
	if(owner)
		my_mob = owner
		update_abilities(0, owner)
	else
		CRASH("ERROR: ability_master's New() was not given an owner argument.  This is a bug.")
	..()

/atom/movable/screen/movable/ability_master/Destroy()
	. = ..()
	//Get rid of the ability objects.
	remove_all_abilities()
	ability_objects.Cut()

	remove_all_changeling_powers()
	changeling_power_objects.Cut()

	remove_all_vampire_powers()
	vampire_power_objects.Cut()

	for(var/atom/movable/screen/ability/spell/spell in spell_objects)
		remove_ability(spell)
	spell_objects.Cut()

	// After that, remove ourselves from the mob seeing us, so we can qdel cleanly.
	if(my_mob)
		my_mob.ability_master = null
		if(my_mob.client && my_mob.client.screen)
			my_mob.client.screen -= src
		my_mob = null

/atom/movable/screen/movable/ability_master/MouseDrop()
	if(showing)
		return

	return ..()

/atom/movable/screen/movable/ability_master/Click()
	if(!ability_objects.len) // If we're empty for some reason.
		return

	toggle_open()

/atom/movable/screen/movable/ability_master/proc/toggle_open(forced_state = 0)
	if(showing && (forced_state != 2)) // We are closing the ability master, hide the abilities.
		for(var/atom/movable/screen/ability/O in ability_objects)
			if(my_mob && my_mob.client)
				my_mob.client.screen -= O
//			O.handle_icon_updates = 0
		showing = 0
		ClearOverlays()
		AddOverlays(closed_state)
	else if(forced_state != 1) // We're opening it, show the icons.
		open_ability_master()
		update_abilities(1)
		showing = 1
		ClearOverlays()
		AddOverlays(open_state)
	update_icon()

/atom/movable/screen/movable/ability_master/proc/open_ability_master()
	var/list/screen_loc_xy = splittext(screen_loc,",")

	//Create list of X offsets
	var/list/screen_loc_X = splittext(screen_loc_xy[1],":")
	var/x_position = decode_screen_X(screen_loc_X[1], my_mob)
	var/x_pix = screen_loc_X[2]

	//Create list of Y offsets
	var/list/screen_loc_Y = splittext(screen_loc_xy[2],":")
	var/y_position = decode_screen_Y(screen_loc_Y[1], my_mob)
	var/y_pix = screen_loc_Y[2]

	for(var/i = 1; i <= ability_objects.len; i++)
		var/atom/movable/screen/ability/A = ability_objects[i]
		var/xpos = x_position + (x_position < 8 ? 1 : -1)*(i%7)
		var/ypos = y_position + (y_position < 8 ? round(i/7) : -round(i/7))
		A.screen_loc = "[encode_screen_X(xpos, my_mob)]:[x_pix],[encode_screen_Y(ypos, my_mob)]:[y_pix]"
		if(my_mob && my_mob.client)
			my_mob.client.screen += A
//			A.handle_icon_updates = 1

/atom/movable/screen/movable/ability_master/proc/update_abilities(forced = 0, mob/user)
	update_icon()
	if(user && user.client)
		if(!(src in user.client.screen))
			user.client.screen += src
	var/i = 1
	for(var/atom/movable/screen/ability/ability in ability_objects)
		ability.update_icon(forced)
		if(istype(ability, /atom/movable/screen/ability/changeling_power))
			continue // Lings' powers display chemcost and stuff
		else if(istype(ability, /atom/movable/screen/ability/vampire_power))
			continue // The same with vamps' powers.
		ability.maptext = "[i]" // Slot number
		i++

/atom/movable/screen/movable/ability_master/on_update_icon()
	if(ability_objects.len)
		set_invisibility(0)
	else
		set_invisibility(101)

/atom/movable/screen/movable/ability_master/proc/add_ability(name_given)
	if(!name) return
	var/atom/movable/screen/ability/new_button = new /atom/movable/screen/ability
	new_button.ability_master = src
	new_button.SetName(name_given)
	new_button.ability_icon_state = name_given
	new_button.update_icon(1)
	ability_objects.Add(new_button)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/atom/movable/screen/movable/ability_master/proc/remove_ability(atom/movable/screen/ability/ability)
	if(!ability)
		return
	ability_objects.Remove(ability)
	if(istype(ability,/atom/movable/screen/ability/spell))
		spell_objects.Remove(ability)
	if(istype(ability, /atom/movable/screen/ability/changeling_power))
		changeling_power_objects.Remove(ability)
	if(istype(ability, /atom/movable/screen/ability/vampire_power))
		vampire_power_objects.Remove(ability)
	qdel(ability)


	if(ability_objects.len)
		toggle_open(showing + 1)
	update_icon()
//	else
//		qdel(src)

/atom/movable/screen/movable/ability_master/proc/remove_all_abilities()
	for(var/atom/movable/screen/ability/A in ability_objects)
		remove_ability(A)

/atom/movable/screen/movable/ability_master/proc/remove_all_changeling_powers()
	for(var/atom/movable/screen/ability/changeling_power/CP in changeling_power_objects)
		remove_ability(CP)

/atom/movable/screen/movable/ability_master/proc/remove_all_vampire_powers()
	for(var/atom/movable/screen/ability/vampire_power/VP in vampire_power_objects)
		remove_ability(VP)

/atom/movable/screen/movable/ability_master/proc/get_ability_by_name(name_to_search)
	for(var/atom/movable/screen/ability/A in ability_objects)
		if(A.name == name_to_search)
			return A
	return null

/atom/movable/screen/movable/ability_master/proc/get_ability_by_proc_ref(proc_ref)
	for(var/atom/movable/screen/ability/verb_based/V in ability_objects)
		if(V.verb_to_call == proc_ref)
			return V
	return null

/atom/movable/screen/movable/ability_master/proc/get_ability_by_instance(obj/instance/)
	for(var/atom/movable/screen/ability/obj_based/O in ability_objects)
		if(O.object == instance)
			return O
	return null

/atom/movable/screen/movable/ability_master/proc/get_ability_by_spell(datum/spell/s)
	for(var/screen in spell_objects)
		var/atom/movable/screen/ability/spell/S = screen
		if(S.spell == s)
			return S
	return null

/atom/movable/screen/movable/ability_master/proc/get_ability_by_changeling_power(datum/changeling_power/cp)
	for(var/screen in changeling_power_objects)
		var/atom/movable/screen/ability/changeling_power/CP = screen
		if(CP.power == cp)
			return CP
	return null

/atom/movable/screen/movable/ability_master/proc/get_ability_by_vampire_power(datum/vampire_power/vp)
	for(var/screen in vampire_power_objects)
		var/atom/movable/screen/ability/vampire_power/VP = screen
		if(istype(VP) && VP.power == vp)
			return VP
	return null

/mob/Initialize()
	. = ..()
	ability_master = new /atom/movable/screen/movable/ability_master(null,src)

///////////ACTUAL ABILITIES////////////
//This is what you click to do things//
///////////////////////////////////////
/atom/movable/screen/ability
	icon = 'icons/hud/screen_spells.dmi'
	icon_state = "grey_spell_base"
	maptext_x = 3
	var/background_base_state = "grey"
	var/ability_icon_state = null
	var/atom/movable/screen/movable/ability_master/ability_master

/atom/movable/screen/ability/Destroy()
	if(ability_master)
		ability_master.ability_objects -= src
		if(ability_master.my_mob && ability_master.my_mob.client)
			ability_master.my_mob.client.screen -= src
	if(ability_master && !ability_master.ability_objects.len)
		ability_master.update_icon()
//		qdel(ability_master)
	ability_master = null
	return ..()

/atom/movable/screen/ability/on_update_icon()
	ClearOverlays()
	icon_state = "[background_base_state]_spell_base"

	AddOverlays(ability_icon_state)

/atom/movable/screen/ability/Click()
	if(!usr)
		return

	activate()

// Makes the ability be triggered.  The subclasses of this are responsible for carrying it out in whatever way it needs to.
/atom/movable/screen/ability/proc/activate()
	to_world("[src] had activate() called.")
	return

// This checks if the ability can be used.
/atom/movable/screen/ability/proc/can_activate()
	return 1

/client/verb/activate_ability(slot as num)
	set name = ".activate_ability"
//	set hidden = 1
	if(!mob)
		return // Paranoid.
	if(isnull(slot) || !isnum(slot))
		to_chat(src,"<span class='warning'>.activate_ability requires a number as input, corrisponding to the slot you wish to use.</span>")
		return // Bad input.
	if(!mob.ability_master)
		return // No abilities.
	if(slot > mob.ability_master.ability_objects.len || slot <= 0)
		return // Out of bounds.
	var/atom/movable/screen/ability/A = mob.ability_master.ability_objects[slot]
	A.activate()

//////////Verb Abilities//////////
//Buttons to trigger verbs/procs//
//////////////////////////////////

/atom/movable/screen/ability/verb_based
	var/verb_to_call = null
	var/object_used = null
	var/arguments_to_use = list()

/atom/movable/screen/ability/verb_based/activate()
	if(object_used && verb_to_call)
		call(object_used,verb_to_call)(arguments_to_use)

/atom/movable/screen/movable/ability_master/proc/add_verb_ability(object_given, verb_given, name_given, ability_icon_given, arguments)
	if(!object_given)
		message_admins("ERROR: add_verb_ability() was not given an object in its arguments.")
	if(!verb_given)
		message_admins("ERROR: add_verb_ability() was not given a verb/proc in its arguments.")
	if(get_ability_by_proc_ref(verb_given))
		return // Duplicate
	var/atom/movable/screen/ability/verb_based/A = new /atom/movable/screen/ability/verb_based()
	A.ability_master = src
	A.object_used = object_given
	A.verb_to_call = verb_given
	A.ability_icon_state = ability_icon_given
	A.SetName(name_given)
	if(arguments)
		A.arguments_to_use = arguments
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/////////Obj Abilities////////
//Buttons to trigger objects//
//////////////////////////////

/atom/movable/screen/ability/obj_based
	var/obj/object = null

/atom/movable/screen/ability/obj_based/activate()
	if(object)
		object.Click()


// Wizard
/atom/movable/screen/ability/spell
	var/datum/spell/spell
	var/spell_base
	var/last_charge = 0
	var/icon/last_charged_icon

/atom/movable/screen/ability/spell/Destroy()
	if(spell)
		spell.connected_button = null
		spell = null
	return ..()

/atom/movable/screen/movable/ability_master/proc/add_spell(datum/spell/spell)
	if(!spell) return

	if(spell.spell_flags & NO_BUTTON) //no button to add if we don't get one
		return

	if(get_ability_by_spell(spell))
		return

	var/atom/movable/screen/ability/spell/A = new()
	A.ability_master = src
	A.spell = spell
	A.SetName(spell.name)
	spell.connected_button = A

	if(!spell.override_base) //if it's not set, we do basic checks
		if(spell.spell_flags & CONSTRUCT_CHECK)
			A.spell_base = "const" //construct spells
		else
			A.spell_base = "wiz" //wizard spells
	else
		A.spell_base = spell.override_base
	A.update_charge(1)
	spell_objects.Add(A)
	ability_objects.Add(A)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/mob/Life()
	..()
	if(ability_master)
		ability_master.update_spells(0)

/atom/movable/screen/movable/ability_master/proc/update_spells(forced = 0)
	for(var/atom/movable/screen/ability/spell/spell in spell_objects)
		spell.update_charge(forced)

/atom/movable/screen/ability/spell/proc/update_charge(forced_update = 0)
	if(!spell)
		qdel(src)
		return

	if(last_charge == spell.charge_counter && !forced_update)
		return //nothing to see here

	CutOverlays(spell.icon_state)

	if(spell.charge_type == SP_RECHARGE || spell.charge_type == SP_CHARGES)
		if(spell.charge_counter < spell.charge_max)
			icon_state = "[spell_base]_spell_base"
			if(spell.charge_counter > 0)
				var/icon/partial_charge = icon(src.icon, "[spell_base]_spell_ready")
				partial_charge.Crop(1, 1, partial_charge.Width(), round(partial_charge.Height() * spell.charge_counter / spell.charge_max))
				AddOverlays(partial_charge)
				if(last_charged_icon)
					CutOverlays(last_charged_icon)
				last_charged_icon = partial_charge
			else if(last_charged_icon)
				CutOverlays(last_charged_icon)
				last_charged_icon = null
		else
			icon_state = "[spell_base]_spell_ready"
			if(last_charged_icon)
				CutOverlays(last_charged_icon)
	else
		icon_state = "[spell_base]_spell_ready"

	AddOverlays(spell.icon_state)

	last_charge = spell.charge_counter

	CutOverlays("silence")
	if(spell.silenced)
		AddOverlays("silence")

/atom/movable/screen/ability/spell/on_update_icon(forced = 0)
	update_charge(forced)

	if(istype(spell, /datum/spell/toggled))
		ClearOverlays()
		var/datum/spell/toggled/attached_spell = spell
		AddOverlays(spell.icon_state)
		if(attached_spell.toggled)
			AddOverlays("vampire_spell_active")
		if(attached_spell.mana_drain_per_tick)
			var/image/T = image(icon, "blank")
			T.maptext = MAPTEXT("[attached_spell.mana_current]/[attached_spell.mana_max]")
			AddOverlays(T)
	return

/atom/movable/screen/ability/spell/activate()
	spell.perform(usr)

/atom/movable/screen/movable/ability_master/proc/silence_spells(amount)
	for(var/atom/movable/screen/ability/spell/spell in spell_objects)
		spell.spell.silenced = amount
		spell.spell.process()
		spell.update_charge(1)


/mob/Life()
	..()
	if(ability_master)
		ability_master.update_changeling_powers()
		ability_master.update_vampire_powers()

// Changeling

/atom/movable/screen/movable/ability_master/proc/reskin_changeling()
	icon_state = "changeling_spell_base"
	open_state = "ling_open"
	closed_state = "ling_closed"
	ClearOverlays()
	AddOverlays(open_state)

/atom/movable/screen/ability/changeling_power
	background_base_state = "changeling"
	var/datum/changeling_power/power
	var/chemical_cost = 0
	var/icon/last_charged_icon

/atom/movable/screen/ability/changeling_power/Destroy()
	power = null
	return ..()

/atom/movable/screen/movable/ability_master/proc/add_changeling_power(datum/changeling_power/power)
	if(!power)
		return

	if(istype(power, /datum/changeling_power/passive))
		return

	if(get_ability_by_changeling_power(power))
		return

	var/atom/movable/screen/ability/changeling_power/P = new()
	P.ability_master = src
	P.power = power
	P.SetName("[power.name] ([power.required_chems])")

	changeling_power_objects.Add(P)
	ability_objects.Add(P)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/atom/movable/screen/movable/ability_master/proc/update_changeling_powers()
	for(var/atom/movable/screen/ability/changeling_power/P in changeling_power_objects)
		P.update_icon()

/atom/movable/screen/ability/changeling_power/on_update_icon()
	if(!power)
		qdel(src)
		return

	ClearOverlays()

	icon_state = "[background_base_state]_spell_[power.is_usable(TRUE) ? "ready" : "base"]"
	AddOverlays(power.icon_state)

	if(istype(power, /datum/changeling_power/toggled))
		if(power.active)
			AddOverlays("changeling_spell_active")

	var/image/T = image(icon, "blank")
	if(!power.chems_drain)
		if(power.required_chems)
			T.maptext = "[power.required_chems]" // Slot number not needed, chem cost holds more importance.
		else
			T.maptext = ""
	else
		T.maptext = "[power.required_chems] ([power.chems_drain])"

	AddOverlays(T)

/atom/movable/screen/ability/changeling_power/activate()
	power.use(usr)

// Vampire

/atom/movable/screen/movable/ability_master/proc/reskin_vampire()
	icon_state = "vampire_spell_base"
	open_state = "vamp_open"
	closed_state = "vamp_closed"
	ClearOverlays()
	AddOverlays(open_state)

/atom/movable/screen/ability/vampire_power
	background_base_state = "vampire"
	var/datum/vampire_power/power
	var/blood_cost = 0
	var/icon/last_charged_icon

/atom/movable/screen/ability/vampire_power/Destroy()
	power = null
	return ..()

/atom/movable/screen/movable/ability_master/proc/add_vampire_power(datum/vampire_power/power)
	if(!power)
		return

	if(get_ability_by_vampire_power(power))
		return

	var/atom/movable/screen/ability/vampire_power/P = new()
	P.ability_master = src
	P.power = power
	P.SetName("[power.name] ([power.blood_cost])")

	vampire_power_objects.Add(P)
	ability_objects.Add(P)
	if(my_mob.client)
		toggle_open(2) //forces the icons to refresh on screen

/atom/movable/screen/movable/ability_master/proc/update_vampire_powers()
	for(var/atom/movable/screen/ability/vampire_power/P in vampire_power_objects)
		P.update_icon()

/atom/movable/screen/ability/vampire_power/on_update_icon()
	if(!power)
		qdel(src)
		return

	ClearOverlays()

	icon_state = "[background_base_state]_spell_[power.is_usable(TRUE) ? "ready" : "base"]"
	AddOverlays(power.icon_state)

	if(power.cooldown > 0)
		AddOverlays("vampire_cooldown")

	if(istype(power, /datum/vampire_power/toggled))
		if(power.active)
			AddOverlays("vampire_spell_active")

	var/image/T = image(icon, "blank")
	if(!power.blood_drain)
		if(power.blood_cost)
			T.maptext = " [power.blood_cost]" // Slot number not needed, blood cost holds more importance.
		else
			T.maptext = ""
	else
		T.maptext = " [power.blood_cost] ([power.blood_drain])"

	AddOverlays(T)

/atom/movable/screen/ability/vampire_power/activate()
	power.use(usr)
