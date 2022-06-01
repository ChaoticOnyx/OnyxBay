#define VEST_STEALTH 1
#define VEST_COMBAT 2
#define GIZMO_SCAN 1
#define GIZMO_MARK 2
#define MIND_DEVICE_MESSAGE 1
#define MIND_DEVICE_CONTROL 2

//AGENT VEST
/obj/item/clothing/suit/armor/abductor/vest
	name = "agent vest"
	desc = "A vest outfitted with advanced stealth technology. It has two modes - combat and stealth."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "vest_stealth"
	item_state_slots = list(
					slot_l_hand_str = "armor",
					slot_r_hand_str = "armor",
				)
	blood_overlay_type = "armor"
	armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 25, BOMB = 15, BIO = 15, RAD = 15)
	species_restricted = list(SPECIES_ABDUCTOR)
	allowed = list(
		/obj/item/abductor,
		/obj/item/melee/baton,
		/obj/item/gun/energy,
		/obj/item/handcuffs
		)
	var/mode = VEST_STEALTH
	var/stealth_active = FALSE
	var/lock_mode = FALSE
	/// Cooldown in seconds
	var/combat_cooldown = 20 SECONDS
	var/cooldown = 0
	var/datum/icon_snapshot/disguise
	action_button_name = "Activate Vest"
	var/stealth_armor = list(MELEE = 15, BULLET = 15, LASER = 15, ENERGY = 25, BOMB = 15, BIO = 15, RAD = 15)
	var/combat_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 50, RAD = 50)

/obj/item/clothing/suit/armor/abductor/vest/equipped(mob/user)
	DeactivateStealth()
	return ..()

/obj/item/clothing/suit/armor/abductor/vest/proc/toggle_nodrop()
	canremove = !canremove
	if(ismob(loc))
		to_chat(loc, SPAN_NOTICE("Your vest is now [canremove ? "unlocked" : "locked"]."))

/obj/item/clothing/suit/armor/abductor/vest/proc/flip_mode()
	switch(mode)
		if(VEST_STEALTH)
			mode = VEST_COMBAT
			DeactivateStealth()
			armor = combat_armor
			icon_state = "vest_combat"
			body_parts_covered = UPPER_TORSO|LOWER_TORSO
		if(VEST_COMBAT)// TO STEALTH
			mode = VEST_STEALTH
			armor = stealth_armor
			body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|HANDS|LEGS
			icon_state = "vest_stealth"
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		H.update_inv_wear_suit()

/obj/item/clothing/suit/armor/abductor/vest/ui_action_click()
	switch(mode)
		if(VEST_COMBAT)
			Adrenaline()
		if(VEST_STEALTH)
			if(stealth_active)
				DeactivateStealth()
			else
				ActivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/SetDisguise(entry)
	disguise = entry

/obj/item/clothing/suit/armor/abductor/vest/proc/ActivateStealth()
	if(disguise == null)
		return
	stealth_active = TRUE
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		playsound(get_turf(M), 'sound/effects/phasein.ogg', 50, 1)
		anim(get_turf(M), M,'icons/mob/mob.dmi',,"phasein",,M.dir)
		M.real_name = disguise.real_name
		M.name = disguise.name
		M.icon = disguise.icon
		M.stand_icon = disguise.stand_icon
		M.icon_state = disguise.icon_state
		M.overlays.Cut()
		M.overlays = disguise.overlays.Copy()
		M.overlays_standing = disguise.overlays_standing.Copy()
		M.update_inv_l_hand()
		M.update_inv_r_hand()

/obj/item/clothing/suit/armor/abductor/vest/proc/DeactivateStealth()
	if(!stealth_active)
		return
	stealth_active = FALSE
	if(ishuman(loc))
		var/mob/living/carbon/human/M = loc
		playsound(get_turf(M), 'sound/effects/phasein.ogg', 50, 1)
		anim(get_turf(M), M,'icons/mob/mob.dmi',,"phaseout",,M.dir)
		M.real_name = "[M.mind.abductor.team.name] [M.mind.special_role]"
		M.name = M.real_name
		M.overlays.Cut()
		M.regenerate_icons()

/obj/item/clothing/suit/armor/abductor/vest/handle_shield(mob/user, damage, atom/damage_source, mob/attacker, def_zone, attack_text)
	DeactivateStealth()

/obj/item/clothing/suit/armor/abductor/vest/proc/Adrenaline()
	if(ishuman(loc))
		if(world.time < cooldown)
			to_chat(loc, SPAN_WARNING("Combat injection is still recharging."))
			return
		var/mob/living/carbon/human/M = loc
		to_chat(M, "<span class='notice'>You feel a sudden surge of energy!</span>")
		M.SetStunned(0)
		M.SetWeakened(0)
		M.SetParalysis(0)
		cooldown = world.time + combat_cooldown

/obj/item/clothing/suit/armor/abductor/Destroy()
	for(var/obj/machinery/abductor/console/C in GLOB.machines)
		if(C.vest == src)
			C.vest = null
			break
	. = ..()

/obj/item/abductor
	icon = 'icons/obj/abductor.dmi'
	item_icons = list(
					slot_l_hand_str = 'icons/inv_slots/items/abductor_lefthand.dmi',
					slot_r_hand_str = 'icons/inv_slots/items/abductor_righthand.dmi',
				)

/obj/item/proc/AbductorCheck(mob/user)
	if(user.mind.abductor != null)
		return TRUE
	to_chat(user, SPAN_WARNING("You can't figure out how this works!"))
	return FALSE

/obj/item/abductor/proc/ScientistCheck(mob/user)
	var/training = AbductorCheck(user)
	var/sci_training = training ? user.mind.abductor.scientist : FALSE

	if(training && !sci_training)
		to_chat(user, SPAN_WARNING("You're not trained to use this!"))
		. = FALSE
	else if(!training && !sci_training)
		to_chat(user, SPAN_WARNING("You can't figure how this works!"))
		. = FALSE
	else
		. = TRUE

/obj/item/abductor/gizmo
	name = "science tool"
	desc = "A dual-mode tool for retrieving specimens and scanning appearances. Scanning can be done through cameras."
	icon_state = "gizmo_scan"
	item_state = "silencer"
	var/mode = GIZMO_SCAN
	var/weakref/marked_target_weakref
	var/obj/machinery/abductor/console/console

/obj/item/abductor/gizmo/attack_self(mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, SPAN_WARNING("The device is not linked to console!"))
		return

	if(mode == GIZMO_SCAN)
		mode = GIZMO_MARK
		icon_state = "gizmo_mark"
	else
		mode = GIZMO_SCAN
		icon_state = "gizmo_scan"
	to_chat(user, SPAN_NOTICE("You switch the device to [mode==GIZMO_SCAN? "SCAN": "MARK"] MODE"))

/obj/item/abductor/gizmo/attack(mob/living/M, mob/user)
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, SPAN_WARNING("The device is not linked to console!"))
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(M, user)
		if(GIZMO_MARK)
			mark(M, user)

/obj/item/abductor/gizmo/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(flag)
		return
	if(!ScientistCheck(user))
		return
	if(!console)
		to_chat(user, SPAN_WARNING("The device is not linked to console!"))
		return

	switch(mode)
		if(GIZMO_SCAN)
			scan(target, user)
		if(GIZMO_MARK)
			mark(target, user)

/obj/item/abductor/gizmo/proc/scan(atom/target, mob/living/user)
	if(ishuman(target))
		console.AddSnapshot(target)
		to_chat(user, SPAN_NOTICE("You scan [target] and add \him to the database."))

/obj/item/abductor/gizmo/proc/mark(atom/target, mob/living/user)
	var/mob/living/marked = marked_target_weakref?.resolve()
	if(marked == target)
		to_chat(user, SPAN_WARNING("This specimen is already marked!"))
		return
	if(isabductor(target))
		marked_target_weakref = weakref(target)
		to_chat(user, SPAN_NOTICE("You mark [target] for future retrieval."))
	else
		prepare(target,user)

/obj/item/abductor/gizmo/proc/prepare(atom/target, mob/living/user)
	if(get_dist(target,user)>1)
		to_chat(user, SPAN_WARNING("You need to be next to the specimen to prepare it for transport!"))
		return
	to_chat(user, SPAN_NOTICE("You begin preparing [target] for transport..."))
	if(do_after(user, 100, target = target))
		marked_target_weakref = weakref(target)
		to_chat(user, SPAN_NOTICE("You finish preparing [target] for transport."))

/obj/item/abductor/gizmo/Destroy()
	if(console)
		console.gizmo = null
		console = null
	. = ..()

/obj/item/abductor/silencer
	name = "abductor silencer"
	desc = "A compact device used to shut down communications equipment."
	icon_state = "silencer"
	item_state = "gizmo"

/obj/item/abductor/silencer/attack(mob/living/M, mob/user)
	if(!AbductorCheck(user))
		return
	radio_off(M, user)

/obj/item/abductor/silencer/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(flag)
		return
	if(!AbductorCheck(user))
		return
	radio_off(target, user)

/obj/item/abductor/silencer/proc/radio_off(atom/target, mob/living/user)
	if( !(user in (viewers(7,target))) )
		return

	var/turf/targloc = get_turf(target)

	var/mob/living/carbon/human/M
	for(M in view(2,targloc))
		if(M == user)
			continue
		to_chat(user, SPAN_NOTICE("You silence [M]'s radio devices."))
		radio_off_mob(M)
//YEP THAT'S SUCK
/obj/item/abductor/silencer/proc/radio_on_mob(obj/item/device/radio/radio)
		radio.on = 1

/obj/item/abductor/silencer/proc/radio_off_mob(mob/living/carbon/human/M)
	var/list/all_items = M.get_contents()

	for(var/obj/item/device/radio/radio in all_items)
		radio.on = 0
		addtimer(CALLBACK(src, .proc/radio_on_mob, radio),300)

/obj/item/abductor/mind_device
	name = "mental interface device"
	desc = "A dual-mode tool for directly communicating with sentient brains. It can be used to send a direct message to a target, \
			or to send a command to a test subject with a charged gland."
	icon_state = "mind_device_message"
	item_state = "silencer"
	var/mode = MIND_DEVICE_MESSAGE

/obj/item/abductor/mind_device/attack_self(mob/user)
	if(!ScientistCheck(user))
		return

	if(mode == MIND_DEVICE_MESSAGE)
		mode = MIND_DEVICE_CONTROL
		icon_state = "mind_device_control"
	else
		mode = MIND_DEVICE_MESSAGE
		icon_state = "mind_device_message"
	to_chat(user, SPAN_NOTICE("You switch the device to [mode==MIND_DEVICE_MESSAGE? "TRANSMISSION": "COMMAND"] MODE"))

/obj/item/abductor/mind_device/proc/mind_control(atom/target, mob/living/user)
	if(iscarbon(target))
		var/mob/living/carbon/human/C = target
		var/obj/item/organ/internal/heart/gland/G = locate() in C.internal_organs
		if(!istype(G))
			to_chat(user, SPAN_WARNING("Your target does not have an experimental gland!"))
			return
		if(!G.mind_control_uses)
			to_chat(user, SPAN_WARNING("Your target's gland is spent!"))
			return
		if(G.active_mind_control)
			to_chat(user, SPAN_WARNING("Your target is already under a mind-controlling influence!"))
			return

		var/command = input(user, "Enter the command for your target to follow.\
											Uses Left: [G.mind_control_uses], Duration: [G.mind_control_duration]", "Enter command")

		if(!command)
			return

		if(QDELETED(user) || !user.is_item_in_hands(src) || loc != user)
			return

		if(QDELETED(G))
			return
		if(istype(C.head, /obj/item/clothing/head/tinfoil))
			to_chat(user, SPAN_WARNING("Your target seems to have some sort of tinfoil protection on, blocking the message from being sent!"))
			return
		G.mind_control(command, user)
		to_chat(user, SPAN_NOTICE("You send the command to your target."))

/obj/item/abductor/mind_device/proc/mind_message(atom/target, mob/living/user)
	if(isliving(target))
		var/mob/living/L = target
		if(L.stat == DEAD)
			to_chat(user, SPAN_WARNING("Your target is dead!"))
			return
		var/message = input(user, "Message to send to your target's brain", "Enter message")
		if(!message)
			return
		if(QDELETED(L) || L.stat == DEAD)
			return

		to_chat(L, SPAN_NOTICE("You hear a voice in your head saying: </span><span class='abductor'>[message]"))
		to_chat(user, SPAN_NOTICE("You send the message to your target."))

/obj/item/abductor/mind_device/afterattack(atom/target, mob/living/user, flag, params)
	. = ..()
	if(!ScientistCheck(user))
		return

	switch(mode)
		if(MIND_DEVICE_CONTROL)
			mind_control(target, user)
		if(MIND_DEVICE_MESSAGE)
			mind_message(target, user)

/obj/item/paper/guides/antag/abductor
	name = "Dissection Guide"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "paper_words"
	readonly = TRUE
	info = {"<b>Dissection for Dummies</b><br>

<br>
1.Acquire fresh specimen.<br>
2.Put the specimen on operating table.<br>
3.Apply scalpel to specimen's torso.<br>
4.Clamp bleeders on specimen's torso with a hemostat.<br>
5.Retract skin of specimen's torso with a retractor.<br>
6.Apply saw to specimen's torso.<br>
7.Apply scalpel again to specimen's torso.<br>
8.Search through the specimen's torso with hemostat to remove heart.<br>
9.Insert replacement gland (Retrieve one from gland storage).<br>
10.Apply FixOVein to repair veins<br>
10.Apply bonegel to start repair bones<br>
10.Apply bone setter to set bones into the right plas<br>
10.Apply bonegel to repair bones<br>
10.Apply cautery to hide all evidences<br>
10.Consider dressing the specimen back to not disturb the habitat. <br>
11.Put the specimen in the experiment machinery.<br>
12.Choose one of the machine options. The target will be analyzed and teleported to the selected drop-off point.<br>
13.You will receive one supply credit, and the subject will be counted towards your quota.<br>
<br>
Congratulations! You are now trained for invasive xenobiology research!"}

/obj/item/gun/energy/abductor/alien
	name = "alien pistol"
	desc = "A complicated gun that fires bursts of high-intensity radiation."
	icon_state = "alienpistol"
	slot_flags = SLOT_BELT //too unusually shaped to fit in a holster
	w_class = ITEM_SIZE_NORMAL
	projectile_type = /obj/item/projectile/energy/declone
	fire_delay = 10
	origin_tech = null
	max_shots = 5 //to compensate a bit for self-recharging
	one_hand_penalty = 1 //a little bulky
	self_recharge = 1
	recharge_time = 20


/obj/item/gun/energy/abductor/special_check(mob/user)
	if(!isabductor(user))
		return FALSE
	return ..()

#define BATON_STUN 0
#define BATON_SLEEP 1
#define BATON_CUFF 2
#define BATON_PROBE 3
#define BATON_MODES 4

/obj/item/melee/baton/abductor
	name = "advanced baton"
	desc = "A quad-mode baton used for incapacitation and restraining of specimens."

	icon = 'icons/obj/abductor.dmi'
	item_icons = list(
					slot_l_hand_str = 'icons/inv_slots/items/abductor_lefthand.dmi',
					slot_r_hand_str = 'icons/inv_slots/items/abductor_righthand.dmi',
				)
	icon_state = "wonderprodStun"
	item_state = "wonderprod"

	hitcost = 0 //YEP
	agonyforce = 90
	var/obj/item/handcuffs/handcuffs = new /obj/item/handcuffs/energy()
	var/mode = BATON_STUN
	var/sleep_time = 60
	bcell = /obj/item/cell/device/standard
	var/time_to_cuff = 3 SECONDS

/obj/item/melee/baton/abductor/proc/toggle(mob/living/user=usr)
	if(!AbductorCheck(user))
		return
	mode = (mode+1)%BATON_MODES
	var/txt
	switch(mode)
		if(BATON_STUN)
			txt = "stunning"
		if(BATON_SLEEP)
			txt = "sleep inducement"
		if(BATON_CUFF)
			txt = "restraining"
		if(BATON_PROBE)
			txt = "probing"

	to_chat(usr, SPAN_NOTICE("You switch the baton to [txt] mode."))
	update_icon()

/obj/item/melee/baton/abductor/attack_self(mob/living/user)
	toggle(user)
	add_fingerprint(user)

/obj/item/melee/baton/abductor/update_icon()
	. = ..()
	switch(mode)
		if(BATON_STUN)
			icon_state = "wonderprodStun"
			item_state = "wonderprodStun"
		if(BATON_SLEEP)
			icon_state = "wonderprodSleep"
			item_state = "wonderprodSleep"
		if(BATON_CUFF)
			icon_state = "wonderprodCuff"
			item_state = "wonderprodCuff"
		if(BATON_PROBE)
			icon_state = "wonderprodProbe"
			item_state = "wonderprodProbe"

/obj/item/melee/baton/abductor/attack(mob/target, mob/living/user, modifiers)
	if(!AbductorCheck(user))
		return
	return ..()

/obj/item/melee/baton/abductor/apply_hit_effect(mob/living/target, mob/living/user, hit_zone)
	switch (mode)
		if(BATON_STUN)
			var/stun = stunforce
			var/agony = agonyforce
			if(user.a_intent != I_HELP)
				//whacking someone causes a much poorer electrical contact than deliberately prodding them.
				stun *= 0.5
				agony *= 0.5
			target.visible_message(SPAN_DANGER("[user] stuns [target] with [src]!"),
			SPAN_DANGER("[user] stuns you with [src]!"))
			if(ishuman(target))
				var/mob/living/carbon/human/H = target
				H.handle_tasing(agony, stun, hit_zone, src)
			else
				target.stun_effect_act(stun, agony, hit_zone, src)
		if(BATON_SLEEP)
			SleepAttack(target,user)
		if(BATON_CUFF)
			CuffAttack(target,user)
		if(BATON_PROBE)
			ProbeAttack(target,user)

/obj/item/melee/baton/abductor/proc/SleepAttack(mob/living/carbon/human/L,mob/living/user)
	playsound(src, 'sound/weapons/Egloves.ogg', 50, 1, -1)
	if(L.incapacitated())
		if(istype(L.head, /obj/item/clothing/head/tinfoil))
			to_chat(user, SPAN_WARNING("The specimen's tinfoil protection is interfering with the sleep inducement!"))
			L.visible_message(SPAN_DANGER("[user] tried to induced sleep in [L] with [src], but tinfoil protection blocking it!"), \
								SPAN_DANGER("You feel a strange wave of heavy drowsiness wash over you, but your tinfoil protection deflects most of it!"))
			L.drowsyness += 5
			return
		L.visible_message(SPAN_DANGER("[user] induces sleep in [L] with [src]!"), \
							SPAN_DANGER("You suddenly feel very drowsy!"))
		L.sleeping = sleep_time
		log_attack(user, L, "put to sleep")
	else
		if(istype(L.head, /obj/item/clothing/head/tinfoil))
			to_chat(user, SPAN_WARNING("The specimen's tinfoil protection is completely blocking our sleep inducement methods!"))
			L.visible_message(SPAN_DANGER("[user] tried to induce sleep in [L] with [src], but tinfoil protection completely protected \him!"), \
								SPAN_DANGER("Any sense of drowsiness is quickly diminished as your tinfoil protection deflects the effects!"))
			return
		L.drowsyness+=2
		to_chat(user, SPAN_WARNING("Sleep inducement works fully only on stunned specimens! "))
		L.visible_message(SPAN_DANGER("[user] tried to induce sleep in [L] with [src]!"), \
							SPAN_DANGER("You suddenly feel drowsy!"))

/obj/item/melee/baton/abductor/proc/CuffAttack(mob/living/L,mob/living/user)
	if(!iscarbon(L))
		return
	var/mob/living/carbon/C = L
	if(istype(C))
		if(!C.handcuffed)
			handcuffs.place_handcuffs(C, user)
			return
		else
			to_chat(user, SPAN_WARNING("\The [C] is already handcuffed!"))

/obj/item/melee/baton/abductor/proc/ProbeAttack(mob/living/L,mob/living/user)
	L.visible_message(SPAN_DANGER("[user] probes [L] with [src]!"), SPAN_DANGER("[user] probes you!"))

	var/species = SPAN_WARNING("Unknown species")
	var/helptext = SPAN_WARNING("Species unsuitable for experiments.")

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		species = SPAN_NOTICE("[H.dna.species]")
		if(H.mind?.changeling)
			species = SPAN_WARNING("Changeling lifeform")
		var/obj/item/organ/internal/heart/gland/temp = locate() in H.internal_organs
		if(temp)
			helptext = SPAN_WARNING("Experimental gland detected!")
		else
			if (locate(/obj/item/organ/internal/heart) in H.internal_organs)
				helptext = SPAN_NOTICE("Subject suitable for experiments.")
			else
				helptext = SPAN_WARNING("Subject unsuitable for experiments.")

	to_chat(user, "[SPAN_NOTICE("Probing result:")][species]")
	to_chat(user, "[helptext]")

/obj/item/melee/baton/abductor/_examine_text(mob/user)
	. = ..()
	if(AbductorCheck(user))
		switch(mode)
			if(BATON_STUN)
				. += SPAN_WARNING("The baton is in stun mode.")
			if(BATON_SLEEP)
				. += SPAN_WARNING("The baton is in sleep inducement mode.")
			if(BATON_CUFF)
				. += SPAN_WARNING("The baton is in restraining mode.")
			if(BATON_PROBE)
				. += SPAN_WARNING("The baton is in probing mode.")

/obj/item/handcuffs/energy
	name = "hard-light energy field"
	desc = "A hard-light field restraining the hands."
	icon_state = "handcuffAlien" // Needs sprite
	breakouttime = 45 SECONDS

/obj/item/handcuffs/energy/can_place(mob/target, mob/user)
	return 1

/obj/item/handcuffs/energy/on_restraint_removal(mob/user)
	user.visible_message(SPAN_DANGER("[user]'s [name] breaks in a discharge of energy!"), \
							SPAN_DANGER("[user]'s [name] breaks in a discharge of energy!"))
	var/datum/effect/effect/system/spark_spread/S = new
	var/turf/T = get_turf(user.loc)
	S.set_up(4,0,user.loc)
	S.attach(T)
	S.start()
	return

/obj/item/device/radio/headset/abductor/attackby(obj/item/W, mob/user, params)
	if(isScrewdriver(W))
		return // Stops humans from disassembling abductor headsets.
	return ..()

/obj/item/abductor_machine_beacon
	name = "machine beacon"
	desc = "A beacon designed to instantly tele-construct abductor machinery."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "beacon"
	w_class = ITEM_SIZE_TINY
	var/obj/machinery/spawned_machine

/obj/item/abductor_machine_beacon/attack_self(mob/user)
	..()
	user.visible_message(SPAN_NOTICE("[user] push button on [src] and activates it."), SPAN_NOTICE("You push button on [src] and activate it."))
	playsound(src, 'sound/machines/terminal_alert.ogg', 50)
	addtimer(CALLBACK(src, .proc/try_spawn_machine), 30)

/obj/item/abductor_machine_beacon/proc/try_spawn_machine()
	var/viable = FALSE
	if(isfloor(get_turf(loc)))
		var/turf/T = get_turf(loc)
		viable = TRUE
		for(var/obj/thing in T.contents)
			if(thing.density || istype(thing, /obj/structure) || istype(thing, /obj/machinery))
				viable = FALSE
	if(viable)
		playsound(src, 'sound/effects/phasein.ogg', 50, TRUE)
		var/new_machine = new spawned_machine(get_turf(loc))
		visible_message(SPAN_NOTICE("[new_machine] warps on top of the beacon!"))
		qdel(src)
	else
		playsound(src, 'sound/machines/buzz-two.ogg', 50)

/obj/item/abductor_machine_beacon/chem_dispenser
	name = "beacon - Reagent Synthesizer"
	spawned_machine = /obj/machinery/chemical_dispenser/abductor

/obj/item/scalpel/alien
	name = "alien scalpel"
	desc = "It's a gleaming sharp knife made out of silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/hemostat/alien
	name = "alien hemostat"
	desc = "You've never seen this before."
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/retractor/alien
	name = "alien retractor"
	desc = "You're not sure if you want the veil pulled back."
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/circular_saw/alien
	name = "alien saw"
	desc = "Do the aliens also lose this, and need to find an alien hatchet?"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "saw"
	surgery_speed = 0.25

/obj/item/surgicaldrill/alien
	name = "alien drill"
	desc = "Maybe alien surgeons have finally found a use for the drill."
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/cautery/alien
	name = "alien cautery"
	desc = "Why would aliens have a tool to stop bleeding? \
		Unless..."
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/FixOVein/alien
	name = "FoxOVein"
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/bonegel/alien
	name = "bonebiomass"
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/bonesetter/alien
	name = "bone setter"
	icon = 'icons/obj/abductor.dmi'
	surgery_speed = 0.25

/obj/item/clothing/head/helmet/abductor
	name = "agent headgear"
	desc = "Abduct with style - spiky style."
	icon_state = "alienhelmet"
	item_state = "alienhelmet"
	species_restricted = list(SPECIES_ABDUCTOR)
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|BLOCKHAIR

// Operating Table / Beds / Lockers
/obj/structure/bed/abductor
	name = "resting contraption"
	desc = "This looks similar to contraptions from Earth. Could aliens be stealing our technology?"
	icon_state = "alienbed"
	base_icon =  "alienbed"
	material_alteration = MATERIAL_ALTERATION_NONE

/obj/machinery/optable/abductor
	name = "alien operating table"
	desc = "Used for alien medical procedures. The surface is covered in tiny spines."
	icon = 'icons/obj/furniture.dmi'
	icon_state = "alienbed"
	can_buckle = 1
	/// Amount to inject per second
	var/inject_am = 0.5

	var/static/list/injected_reagents = list(/datum/reagent/inaprovaline, /datum/reagent/dexalinp, /datum/reagent/painkiller/tramadol)

/obj/machinery/optable/abductor/take_victim(mob/living/carbon/C, mob/living/carbon/user)
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
		if(O in component_parts)
			continue
		O.dropInto(loc)
	src.add_fingerprint(user)
	if(ishuman(C))
		START_PROCESSING(SSobj, src)
		var/mob/living/carbon/human/H = C
		src.victim = H
		to_chat(C, SPAN_DANGER("You feel a series of tiny pricks!"))

/obj/machinery/optable/abductor/check_victim()
	if(locate(/mob/living/carbon/human, src.loc))
		play_beep()
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(M.lying)
			src.victim = M
			return 1
	src.victim = null
	return 0

/obj/machinery/optable/abductor/Process()
	. = PROCESS_KILL
	if(locate(/mob/living/carbon/human, src.loc))
		var/mob/living/carbon/human/M = locate(/mob/living/carbon/human, src.loc)
		if(M.lying)
			. = TRUE
			src.victim = M
			M.adjustBrainLoss(-25)
			for(var/chemical in injected_reagents)
				if(M.reagents.get_reagent_amount(chemical) < inject_am )
					M.reagents.add_reagent(chemical, inject_am )
			return 1
	src.victim = null
	return 0

/obj/machinery/optable/abductor/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/closet/abductor
	name = "alien locker"
	desc = "Contains secrets of the universe."
	icon_state = "abductor"
	icon_closed = "abductor"
	icon_opened = "abductoropen"
	dremovable = FALSE
	setup = 0

/obj/structure/table/abductor
	name = "alien table"
	desc = "Advanced flat surface technology at work!"
	icon = 'icons/obj/alien_table.dmi'
	icon_state = "alien_table-0"
	material = MATERIAL_SILVER

/obj/structure/table/abductor/Initialize()
	. = ..()
	icon = 'icons/obj/alien_table.dmi'
	icon_state = "alien_table-0"
	updateOverlays()
	for (var/dir in GLOB.cardinal)
		var/obj/structure/table/abductor/L
		if(locate(/obj/structure/table/abductor, get_step(src, dir)))
			L = locate(/obj/structure/table/abductor, get_step(src, dir))
			L.updateOverlays()

/obj/structure/table/abductor/proc/updateOverlays()
	spawn(1)
		overlays = list()

		var/dir_sum = 0

		var/turf/T
		for (var/direction in GLOB.cardinal)
			T = get_step(src, direction)
			if(locate(/obj/structure/table/abductor, T))
				dir_sum += direction

		icon_state = "alien_table-[dir_sum]"
		return

//INDESTRUTIBLE TABLE YEAAAAH
/obj/structure/table/abductor/attackby(obj/item/W, mob/user, click_params)
	if (!W) return

	// Handle harm intent grabbing/tabling.
	if(istype(W, /obj/item/grab) && get_dist(src,user)<2)
		var/obj/item/grab/G = W
		if (istype(G.affecting, /mob/living/carbon/human))
			var/obj/occupied = turf_is_crowded()
			if(occupied)
				to_chat(user, "<span class='danger'>There's \a [occupied] in the way.</span>")
				return

			if(G.force_danger())
				G.assailant.next_move = world.time + 13 //also should prevent user from triggering this repeatedly
				visible_message("<span class='warning'>[G.assailant] starts putting [G.affecting] on \the [src].</span>")
				if(!do_after(G.assailant, 13))
					return 0
				if(!G) //check that we still have a grab
					return 0
				G.affecting.forceMove(src.loc)
				G.affecting.Weaken(rand(1,4))
				G.affecting.Stun(1)
				visible_message("<span class='warning'>[G.assailant] puts [G.affecting] on \the [src].</span>")
				G.affecting.break_all_grabs(G.assailant)
				qdel(W)
			else
				to_chat(user, "<span class='danger'>You need a better grip to do that!</span>")
			return

	// Handle dismantling or placing things on the table from here on.
	if(isrobot(user))
		return

	if(W.loc != user) // This should stop mounted modules ending up outside the module.
		return

	// Placing stuff on tables
	if(user.unEquip(W, target = loc))
		auto_align(W, click_params)
		return 1
	return


/obj/item/clothing/under/abductor
	desc = "The most advanced form of jumpsuit known to reality, looks uncomfortable."
	name = "alien jumpsuit"
	icon_state = "abductor"
	item_state = "black"
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 10, rad = 0)

//TOOL BELT
/obj/item/storage/belt/abductor
	name = "agent belt"
	desc = "A belt used by abductor agents."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "belt"
	item_state = "security"

/obj/item/storage/belt/abductor/full/New()
	..()
	new /obj/item/screwdriver/abductor(src)
	new /obj/item/wrench/abductor(src)
	new /obj/item/weldingtool/abductor(src)
	new /obj/item/crowbar/abductor(src)
	new /obj/item/wirecutters/abductor(src)
	new /obj/item/device/multitool/abductor(src)
	new /obj/item/stack/cable_coil(src)

//TOOLS
/obj/item/screwdriver/abductor
	name = "alien screwdriver"
	desc = "An ultrasonic screwdriver."
	icon = 'icons/obj/abductor.dmi'
	randicon = FALSE
	icon_state = "screwdriver_a"
	item_state = "screwdriver"

/obj/item/wrench/abductor
	name = "alien wrench"
	desc = "A polarized wrench. It causes anything placed between the jaws to turn."
	icon = 'icons/obj/abductor.dmi'
	randicon = FALSE
	icon_state = "wrench"

/obj/item/weldingtool/abductor
	name = "alien welding tool"
	desc = "An alien welding tool. Whatever fuel it uses, it never runs out."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "welder"
	tank = /obj/item/welder_tank/huge

/obj/item/crowbar/abductor
	name = "alien crowbar"
	desc = "A hard-light crowbar. It appears to pry by itself, without any effort required."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "crowbar"

/obj/item/wirecutters/abductor
	name = "alien wirecutters"
	desc = "Extremely sharp wirecutters, made out of a silvery-green metal."
	icon = 'icons/obj/abductor.dmi'
	randicon = FALSE
	icon_state = "cutters"

/obj/item/device/multitool/abductor
	name = "alien multitool"
	desc = "An omni-technological interface."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "multitool"
