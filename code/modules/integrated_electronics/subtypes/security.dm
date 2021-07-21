/obj/item/integrated_circuit/security
	category_text = "Security"

/obj/item/integrated_circuit/security/weapon_firing
	name = "weapon firing mechanism"
	desc = "This somewhat complicated system allows one to slot in a gun, direct it towards a position, and remotely fire it."
	extended_desc = "The firing mechanism can slot in any energy weapon. \
	The first input pin need to be ref which correspond to target for the gun to fire. \
	The 'fire' activator will cause the mechanism to attempt to fire the weapon at the ref, if possible. Mode will switch between \
	lethal (TRUE) or stun (FALSE) modes. It uses the internal battery of the weapon itself, not the assembly. If you wish to fire the gun while the circuit is in \
	hand, you will need to use an assembly that is a gun."
	complexity = 20
	w_class = ITEM_SIZE_SMALL
	size = 15
	inputs = list(
		"target"       = IC_PINTYPE_REF,
		"bodypart"	   = IC_PINTYPE_STRING
	)
	outputs = list(
		"reference to gun"	= IC_PINTYPE_REF,
		"Weapon mode"		= IC_PINTYPE_STRING
	)
	activators = list(
		"Fire"			= IC_PINTYPE_PULSE_IN,
		"Switch mode"	= IC_PINTYPE_PULSE_IN,
		"On fired"		= IC_PINTYPE_PULSE_OUT
	)
	var/obj/item/weapon/gun/energy/installed_gun = null
	spawn_flags = IC_SPAWN_RESEARCH
	action_flags = IC_ACTION_COMBAT
	power_draw_per_use = 0
	ext_cooldown = 1

	demands_object_input = TRUE		// You can put stuff in once the circuit is in assembly,passed down from additem and handled by attackby()

/obj/item/integrated_circuit/security/weapon_firing/Initialize()
	. = ..()
	extended_desc += "\nThe second input pin used for selection of target body part, the list of body parts: "
	extended_desc += jointext(BP_ALL_LIMBS, ", ")

/obj/item/integrated_circuit/security/weapon_firing/Destroy()
	qdel(installed_gun)
	return ..()

/obj/item/integrated_circuit/security/weapon_firing/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/gun = O
		if(installed_gun)
			to_chat(user, SPAN("warning", "There's already a weapon installed."))
			return
		user.drop_item(gun)
		gun.forceMove(src)
		installed_gun = gun
		to_chat(user, SPAN("notice", "You slide \the [gun] into the firing mechanism."))
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		if(installed_gun.fire_delay)
			cooldown_per_use = installed_gun.fire_delay * 10
		if(cooldown_per_use < 30)
			cooldown_per_use = 30 //If there's no defined fire delay let's put some
		if(installed_gun.charge_cost)
			power_draw_per_use = installed_gun.charge_cost
		if(installed_gun.firemodes.len)
			var/datum/firemode/fm = installed_gun.firemodes[installed_gun.sel_mode]
			set_pin_data(IC_OUTPUT, 2, fm.name)
		set_pin_data(IC_OUTPUT, 1, weakref(installed_gun))
		push_data()
	else
		..()

/obj/item/integrated_circuit/security/weapon_firing/attack_self(mob/user)
	if(installed_gun)
		installed_gun.forceMove(get_turf(user))
		to_chat(user, SPAN("notice", "You slide \the [installed_gun] out of the firing mechanism."))
		size = initial(size)
		playsound(src, 'sound/items/Crowbar.ogg', 50, 1)
		installed_gun = null
		set_pin_data(IC_OUTPUT, 1, weakref(null))
		push_data()
	else
		to_chat(user, SPAN("notice", "There's no weapon to remove from the mechanism."))

/obj/item/integrated_circuit/security/weapon_firing/do_work(ord)
	if(!installed_gun)
		return
	if(!isturf(assembly.loc) && !(assembly.can_fire_equipped))
		return
	set_pin_data(IC_OUTPUT, 1, weakref(installed_gun))
	push_data()
	if(assembly)
		switch(ord)
			if(1)
				var/atom/target = get_pin_data(IC_INPUT, 1)
				if(!istype(target))
					return
				var/bodypart = sanitize(get_pin_data(IC_INPUT, 2))
				if(!(bodypart in BP_ALL_LIMBS))
					bodypart = pick(BP_ALL_LIMBS)

				assembly.visible_message(SPAN("danger", "[assembly] fires [installed_gun]!"))
				var/obj/item/projectile/P = shootAt(target, bodypart)
				if(P)
					installed_gun.play_fire_sound(assembly, P)
					activate_pin(3)
			if(2)
				var/datum/firemode/next_firemode = installed_gun.switch_firemodes()
				set_pin_data(IC_OUTPUT, 2, next_firemode ? next_firemode.name : null)
				push_data()

/obj/item/integrated_circuit/security/weapon_firing/proc/shootAt(atom/target, bodypart)
	var/turf/T = get_turf(assembly)
	if(!istype(T) || !istype(target))
		return
	if(!installed_gun.power_supply)
		return
	if(!installed_gun.power_supply.charge)
		return
	if(installed_gun.power_supply.charge < installed_gun.charge_cost)
		return
	update_icon()
	var/obj/item/projectile/A = installed_gun.consume_next_projectile()
	if(!A)
		return
	//Shooting Code:
	A.shot_from = assembly.name
	A.firer = assembly
	A.launch(target, bodypart)
	var/atom/AM = get_object()
	AM.investigate_log("fired [installed_gun] to [A] with [src].", INVESTIGATE_CIRCUIT)
	log_attack("[assembly] [any2ref(assembly)] has fired [installed_gun].", notify_admin = FALSE)
	return A

/obj/item/integrated_circuit/security/microscope
	name = "Microscope"
	desc = "Bluat pomogite!"
	complexity = 25
	w_class = ITEM_SIZE_SMALL
	size = 20
	inputs = list("sample" = IC_PINTYPE_REF)
	outputs = list("data" = IC_PINTYPE_STRING)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	ext_cooldown = 1

/obj/item/integrated_circuit/security/microscope/do_work(ord)
	var/obj/item/weapon/sample = get_pin_data(IC_INPUT, 1)
	if(!istype(sample))
		return
	if(get_dist(sample, src) > 1)
		return
	var/output = ""

	if(istype(sample, /obj/item/weapon/forensics/swab))
		var/obj/item/weapon/forensics/swab/swab = sample

		output = "GSR report. Scanned item:<br>[swab.name]<br><br>"

		if(swab.gsr)
			output += "Residue from a [swab.gsr] bullet detected."
		else
			output += "No gunpowder residue found."

	else if(istype(sample, /obj/item/weapon/sample/fibers))
		var/obj/item/weapon/sample/fibers/fibers = sample
		output = "Scanned item:<br>[fibers.name]<br><br>"
		if(fibers.evidence)
			output = "Molecular analysis on provided sample has determined the presence of unique fiber strings.<br><br>"
			for(var/fiber in fibers.evidence)
				output += "Most likely match for fibers: [fiber]</span><br><br>"
		else
			output += "No fibers found."
	else if(istype(sample, /obj/item/weapon/sample/print))
		output = "Fingerprint analysis report: [sample.name]<br>"
		var/obj/item/weapon/sample/print/card = sample
		if(card.evidence && card.evidence.len)
			output += "Surface analysis has determined unique fingerprint strings:<br><br>"
			for(var/prints in card.evidence)
				output += "Fingerprint string: "
				if(!is_complete_print(prints))
					output += "INCOMPLETE PRINT"
				else
					output += "[prints]"
				output += "<br>"
		else
			output += "No information available."

	set_pin_data(IC_OUTPUT, 1, output)
	push_data()
	activate_pin(2)

/obj/item/integrated_circuit/security/dnascanner
	name = "DNA analyzer"
	desc = "Bluat pomogite!"
	complexity = 25
	w_class = ITEM_SIZE_SMALL
	size = 20
	inputs = list("sample" = IC_PINTYPE_REF)
	outputs = list("data" = IC_PINTYPE_STRING)
	activators = list("scan" = IC_PINTYPE_PULSE_IN, "on scanned" = IC_PINTYPE_PULSE_OUT)
	spawn_flags = IC_SPAWN_RESEARCH
	power_draw_per_use = 50
	ext_cooldown = 1

/obj/item/integrated_circuit/security/dnascanner/do_work(ord)
	var/obj/item/weapon/forensics/swab/bloodsamp = get_pin_data(IC_INPUT, 1)
	if(!istype(bloodsamp))
		return
	if(get_dist(bloodsamp, src) > 1)
		return
	var/output = ""
	//dna data itself
	var/data = "No scan information available."
	if(bloodsamp.dna != null)
		data = "Spectometric analysis on provided sample has determined the presence of [bloodsamp.dna.len] strings of DNA.<br><br>"
		for(var/blood in bloodsamp.dna)
			data += "Blood type: [bloodsamp.dna[blood]]<br>\nDNA: [blood]<br><br>"
	else
		data += "No DNA found.<br>"
	output = "[src] analysis report<br>"
	output += "Scanned item:<br>[bloodsamp.name]<br>[bloodsamp.desc]<br><br>" + data

	set_pin_data(IC_OUTPUT, 1, output)
	push_data()
	activate_pin(2)
