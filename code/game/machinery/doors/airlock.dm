#define BOLTS_FINE 0
#define BOLTS_EXPOSED 1
#define BOLTS_CUT 2
/obj/machinery/door/airlock
	name = "airlock"
	icon = 'icons/obj/doors/doorint.dmi'
	icon_state = "door_closed"
	power_channel = ENVIRON

	explosion_resistance = 10
	var/aiControlDisabled = 0 //If 1, AI control is disabled until the AI hacks back in and disables the lock. If 2, the AI has bypassed the lock. If -1, the control is enabled but the AI had bypassed it earlier, so if it is disabled again the AI would have no trouble getting back in.
	var/hackProof = 0 // if 1, this door can't be hacked by the AI
	var/electrified_until = 0			//World time when the door is no longer electrified. -1 if it is permanently electrified until someone fixes it.
	var/main_power_lost_until = 0	 	//World time when main power is restored.
	var/backup_power_lost_until = -1	//World time when backup power is restored.
	var/next_beep_at = 0				//World time when we may next beep due to doors being blocked by mobs
	var/spawnPowerRestoreRunning = 0
	var/welded = null
	var/locked = 0
	var/lock_cut_state = BOLTS_FINE
	var/lights = 1 // bolt lights show by default
	var/aiDisabledIdScanner = 0
	var/aiHacking = 0
	var/obj/machinery/door/airlock/closeOther = null
	var/closeOtherId = null
	var/lockdownbyai = 0
	autoclose = 1
	var/assembly_type = /obj/structure/door_assembly
	var/mineral = null
	var/justzap = 0
	var/safe = 1
	normalspeed = 1
	var/obj/item/weapon/airlock_electronics/electronics = null
	var/hasShocked = 0 //Prevents multiple shocks from happening
	var/secured_wires = 0
	var/datum/wires/airlock/wires = null

	var/open_sound_powered = list('sound/machines/airlock/open1.ogg', 'sound/machines/airlock/open2.ogg', 'sound/machines/airlock/open3.ogg')
	var/open_sound_unpowered = 'sound/machines/airlock/open_force1.ogg'
	var/open_failure_access_denied = 'sound/machines/airlock/error3.ogg'

	var/close_sound_powered = 'sound/machines/airlock/close1.ogg'
	var/close_sound_unpowered = 'sound/machines/airlock/close_force1.ogg'
	var/close_failure_blocked = 'sound/machines/airlock/error1.ogg'

	var/bolts_rising = 'sound/machines/bolts_up.ogg'
	var/bolts_dropping = 'sound/machines/bolts_down.ogg'

	var/door_crush_damage = DOOR_CRUSH_DAMAGE

	var/_wifi_id
	var/datum/wifi/receiver/button/door/wifi_receiver
	var/obj/item/weapon/airlock_brace/brace = null

/obj/machinery/door/airlock/attack_generic(mob/user, damage)
	if(stat & (BROKEN|NOPOWER))
		if(damage >= 10)
			if(density)
				visible_message("<span class='danger'>\The [user] forces \the [src] open!</span>")
				open(1)
			else
				visible_message("<span class='danger'>\The [user] forces \the [src] closed!</span>")
				close(1)
		else
			visible_message("<span class='notice'>\The [user] strains fruitlessly to force \the [src] [density ? "open" : "closed"].</span>")
		return
	..()

/obj/machinery/door/airlock/get_material()
	return get_material_by_name(mineral ? mineral : MATERIAL_STEEL)

/obj/machinery/door/airlock/Process()
	if(main_power_lost_until > 0 && world.time >= main_power_lost_until)
		regainMainPower()

	if(backup_power_lost_until > 0 && world.time >= backup_power_lost_until)
		regainBackupPower()

	else if(electrified_until > 0 && world.time >= electrified_until)
		electrify(0)

	if(arePowerSystemsOn())
		execute_current_command()
/*
About the new airlock wires panel:
*	An airlock wire dialog can be accessed by the normal way or by using wirecutters or a multitool on the door while the wire-panel is open. This would show the following wires, which you can either wirecut/mend or send a multitool pulse through. There are 9 wires.
*		one wire from the ID scanner. Sending a pulse through this flashes the red light on the door (if the door has power). If you cut this wire, the door will stop recognizing valid IDs. (If the door has 0000 access, it still opens and closes, though)
*		two wires for power. Sending a pulse through either one causes a breaker to trip, disabling the door for 10 seconds if backup power is connected, or 1 minute if not (or until backup power comes back on, whichever is shorter). Cutting either one disables the main door power, but unless backup power is also cut, the backup power re-powers the door in 10 seconds. While unpowered, the door may be open, but bolts-raising will not work. Cutting these wires may electrocute the user.
*		one wire for door bolts. Sending a pulse through this drops door bolts (whether the door is powered or not) or raises them (if it is). Cutting this wire also drops the door bolts, and mending it does not raise them. If the wire is cut, trying to raise the door bolts will not work.
*		two wires for backup power. Sending a pulse through either one causes a breaker to trip, but this does not disable it unless main power is down too (in which case it is disabled for 1 minute or however long it takes main power to come back, whichever is shorter). Cutting either one disables the backup door power (allowing it to be crowbarred open, but disabling bolts-raising), but may electocute the user.
*		one wire for opening the door. Sending a pulse through this while the door has power makes it open the door if no access is required.
*		one wire for AI control. Sending a pulse through this blocks AI control for a second or so (which is enough to see the AI control light on the panel dialog go off and back on again). Cutting this prevents the AI from controlling the door unless it has hacked the door through the power connection (which takes about a minute). If both main and backup power are cut, as well as this wire, then the AI cannot operate or hack the door at all.
*		one wire for electrifying the door. Sending a pulse through this electrifies the door for 30 seconds. Cutting this wire electrifies the door, so that the next person to touch the door without insulated gloves gets electrocuted. (Currently it is also STAYING electrified until someone mends the wire)
*		one wire for controling door safetys.  When active, door does not close on someone.  When cut, door will ruin someone's shit.  When pulsed, door will immedately ruin someone's shit.
*		one wire for controlling door speed.  When active, dor closes at normal rate.  When cut, door does not close manually.  When pulsed, door attempts to close every tick.
*/

/obj/machinery/door/airlock/bumpopen(mob/living/user) //Airlocks now zap you when you 'bump' them open when they're electrified. --NeoFite
	if(!issilicon(usr))
		if(isElectrified())
			if(!justzap)
				if(shock(user, 100))
					justzap = 1
					spawn(10)
						justzap = 0
					return
			else /*if(src.justzap)*/
				return
		else if(prob(3) && operating == 0)
			var/mob/living/carbon/C = user
			if(istype(C) && C.hallucination_power > 25)
				to_chat(user, "<span class='danger'>You feel a powerful shock course through your body!</span>")
				user.adjustHalLoss(10)
				user.Stun(3)
				return
	..(user)

/obj/machinery/door/airlock/bumpopen(mob/living/simple_animal/user)
	..(user)

/obj/machinery/door/airlock/proc/isElectrified()
	if(electrified_until != 0)
		return 1
	return 0

/obj/machinery/door/airlock/proc/isWireCut(wireIndex)
	// You can find the wires in the datum folder.
	return wires.IsIndexCut(wireIndex)

/obj/machinery/door/airlock/proc/canAIControl()
	return ((aiControlDisabled != 1) && (!isAllPowerLoss()))

/obj/machinery/door/airlock/proc/canAIHack()
	return ((aiControlDisabled == 1) && (!hackProof) && (!isAllPowerLoss()))

/obj/machinery/door/airlock/proc/arePowerSystemsOn()
	if(stat & (NOPOWER|BROKEN))
		return 0
	return (main_power_lost_until == 0 || backup_power_lost_until == 0)

/obj/machinery/door/airlock/requiresID()
	return !(src.isWireCut(AIRLOCK_WIRE_IDSCAN) || aiDisabledIdScanner)

/obj/machinery/door/airlock/proc/isAllPowerLoss()
	if(stat & (NOPOWER|BROKEN))
		return 1
	if(mainPowerCablesCut() && backupPowerCablesCut())
		return 1
	return 0

/obj/machinery/door/airlock/proc/mainPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_MAIN_POWER1) || src.isWireCut(AIRLOCK_WIRE_MAIN_POWER2)

/obj/machinery/door/airlock/proc/backupPowerCablesCut()
	return src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER1) || src.isWireCut(AIRLOCK_WIRE_BACKUP_POWER2)

/obj/machinery/door/airlock/proc/loseMainPower()
	main_power_lost_until = mainPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// If backup power is permanently disabled then activate in 10 seconds if possible, otherwise it's already enabled or a timer is already running
	if(backup_power_lost_until == -1 && !backupPowerCablesCut())
		backup_power_lost_until = world.time + SecondsToTicks(10)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

	update_icon()

/obj/machinery/door/airlock/proc/loseBackupPower()
	backup_power_lost_until = backupPowerCablesCut() ? -1 : world.time + SecondsToTicks(60)

	// Disable electricity if required
	if(electrified_until && isAllPowerLoss())
		electrify(0)

	update_icon()

/obj/machinery/door/airlock/proc/regainMainPower()
	if(!mainPowerCablesCut())
		main_power_lost_until = 0
		// If backup power is currently active then disable, otherwise let it count down and disable itself later
		if(!backup_power_lost_until)
			backup_power_lost_until = -1

	update_icon()

/obj/machinery/door/airlock/proc/regainBackupPower()
	if(!backupPowerCablesCut())
		// Restore backup power only if main power is offline, otherwise permanently disable
		backup_power_lost_until = main_power_lost_until == 0 ? -1 : 0

	update_icon()

/obj/machinery/door/airlock/proc/electrify(duration, feedback = 0)
	var/message = ""
	if(isWireCut(AIRLOCK_WIRE_ELECTRIFY) && arePowerSystemsOn())
		message = "The electrification wire is cut - Door permanently electrified."
		electrified_until = -1
		. = 1
	else if(duration && !arePowerSystemsOn())
		message = "The door is unpowered - Cannot electrify the door."
		electrified_until = 0
	else if(!duration && electrified_until != 0)
		message = "The door is now un-electrified."
		electrified_until = 0
	else if(duration)	//electrify door for the given duration seconds
		if(usr)
			shockedby += text("\[[time_stamp()]\] - [key_name(usr)]")
			admin_attacker_log(usr, "electrified \the [name] [duration == -1 ? "permanently" : "for [duration] second\s"]")
		else
			shockedby += text("\[[time_stamp()]\] - EMP)")
		message = "The door is now electrified [duration == -1 ? "permanently" : "for [duration] second\s"]."
		electrified_until = duration == -1 ? -1 : world.time + SecondsToTicks(duration)
		. = 1

	if(feedback && message)
		to_chat(usr, message)
	if(.)
		playsound(src, get_sfx("spark"), 30, 0, -6)

/obj/machinery/door/airlock/proc/set_idscan(activate, feedback = 0)
	var/message = ""
	if(isWireCut(AIRLOCK_WIRE_IDSCAN))
		message = "The IdScan wire is cut - IdScan feature permanently disabled."
	else if(activate && aiDisabledIdScanner)
		aiDisabledIdScanner = 0
		message = "IdScan feature has been enabled."
	else if(!activate && !aiDisabledIdScanner)
		aiDisabledIdScanner = 1
		message = "IdScan feature has been disabled."

	if(feedback && message)
		to_chat(usr, message)

/obj/machinery/door/airlock/proc/set_safeties(activate, feedback = 0)
	var/message = ""
	// Safeties!  We don't need no stinking safeties!
	if(isWireCut(AIRLOCK_WIRE_SAFETY))
		message = text("The safety wire is cut - Cannot enable safeties.")
	else if(!activate && safe)
		safe = FALSE
	else if(activate && !safe)
		safe = TRUE

	if(feedback && message)
		to_chat(usr, message)

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise
// The preceding comment was borrowed from the grille's shock script
/obj/machinery/door/airlock/shock(mob/user, prb)
	if(!arePowerSystemsOn())
		return 0
	if(hasShocked)
		return 0	//Already shocked someone recently?
	. = ..()
	if(.)
		hasShocked = 1
		sleep(10)
		hasShocked = 0

/obj/machinery/door/airlock/update_icon(keep_light = 0)
	if(!keep_light)
		set_light(0)
	overlays?.Cut()
	if(density)
		if(locked && lights && arePowerSystemsOn())
			icon_state = "door_locked"
			set_light(0.35, 0.9, 1.5, 3, COLOR_RED_LIGHT)
		else
			icon_state = "door_closed"
		if(p_open || welded)
			overlays = list()
			if(p_open)
				overlays += image(icon, "panel_open")
			if(!(stat & NOPOWER))
				if(stat & BROKEN)
					overlays += image(icon, "sparks_broken")
				else if(health < maxhealth * 0.75)
					overlays += image(icon, "sparks_damaged")
			if(welded)
				overlays += image(icon, "welded")
		else if(health < maxhealth * 0.75 && !(stat & NOPOWER))
			overlays += image(icon, "sparks_damaged")
	else
		icon_state = "door_open"
		if(arePowerSystemsOn() && !p_open) // Doors with opened panels have no green lights on their icons
			set_light(0.30, 0.9, 1.5, 3, COLOR_LIME)
		if((stat & BROKEN) && !(stat & NOPOWER))
			overlays += image(icon, "sparks_open")

	if(brace)
		brace.update_icon()
		overlays += image(brace.icon, brace.icon_state)
	SSdemo.mark_dirty(src)

/obj/machinery/door/airlock/do_animate(animation)
	switch(animation)
		if("opening")
			overlays?.Cut()
			if(!p_open)
				set_light(0.30, 0.9, 1.5, 3, COLOR_LIME)
			flick("[p_open ? "o_door_opening" : "door_opening"]", src)
			update_icon(1)
		if("closing")
			overlays?.Cut()
			flick("[p_open ? "o_door_closing" : "door_closing"]", src)
			update_icon()
		if("spark")
			if(density)
				flick("door_spark", src)
		if("deny")
			if(density && arePowerSystemsOn())
				flick("door_deny", src)
				if(secured_wires)
					playsound(loc, open_failure_access_denied, 50, 0)
	return

/obj/machinery/door/airlock/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/door/airlock/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.default_state)
	var/data[0]

	data["main_power_loss"]   = round(main_power_lost_until   > 0 ? max(main_power_lost_until - world.time,   0) / 10 : main_power_lost_until,   1)
	data["backup_power_loss"] = round(backup_power_lost_until > 0 ? max(backup_power_lost_until - world.time, 0) / 10 : backup_power_lost_until, 1)
	data["electrified"]       = round(electrified_until       > 0 ? max(electrified_until - world.time,       0) / 10 : electrified_until,       1)
	data["open"] = !density

	var/commands[0]
	commands[++commands.len] = list("name" = "IdScan",      "command"= "idscan",   "active" = !aiDisabledIdScanner, "enabled" = "Enabled", "disabled" = "Disable",    "danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Bolts",       "command"= "bolts",    "active" = !locked,              "enabled" = "Raised ", "disabled" = "Dropped",    "danger" = 0, "act" = 0)
	commands[++commands.len] = list("name" = "Bolt Lights", "command"= "lights",   "active" = lights,               "enabled" = "Enabled", "disabled" = "Disable",    "danger" = 0, "act" = 1)
	commands[++commands.len] = list("name" = "Safeties",    "command"= "safeties", "active" = safe,                 "enabled" = "Nominal", "disabled" = "Overridden", "danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Timing",      "command"= "timing",   "active" = normalspeed,          "enabled" = "Nominal", "disabled" = "Overridden", "danger" = 1, "act" = 0)
	commands[++commands.len] = list("name" = "Door State",  "command"= "open",     "active" = density,              "enabled" = "Closed",  "disabled" = "Opened",     "danger" = 0, "act" = 0)

	data["commands"] = commands

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "door_control.tmpl", "Door Controls", 450, 350, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/door/airlock/proc/hack(mob/user)
	if(!aiHacking)
		aiHacking = TRUE
		spawn(20)
			//TODO: Make this take a minute
			to_chat(user, "Airlock AI control has been blocked. Beginning fault-detection.")
			sleep(50)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = FALSE
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = FALSE
				return
			to_chat(user, "Fault confirmed: airlock control wire disabled or cut.")
			sleep(20)
			to_chat(user, "Attempting to hack into airlock. This may take some time.")
			sleep(200)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = FALSE
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = FALSE
				return
			to_chat(user, "Upload access confirmed. Loading control program into airlock software.")
			sleep(170)
			if(canAIControl())
				to_chat(user, "Alert cancelled. Airlock control has been restored without our assistance.")
				aiHacking = FALSE
				return
			else if(!canAIHack(user))
				to_chat(user, "We've lost our connection! Unable to hack airlock.")
				aiHacking = FALSE
				return
			to_chat(user, "Transfer complete. Forcing airlock to execute program.")
			sleep(50)
			//disable blocked control
			aiControlDisabled = 2
			to_chat(user, "Receiving control information from airlock.")
			sleep(10)
			//bring up airlock dialog
			aiHacking = FALSE
			if(user)
				attack_ai(user)

/obj/machinery/door/airlock/CanPass(atom/movable/mover, turf/target)
	if(isElectrified())
		if(istype(mover, /obj/item))
			var/obj/item/i = mover
			if(i.matter && (MATERIAL_STEEL in i.matter) && i.matter[MATERIAL_STEEL] > 0)
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
	return ..()

/obj/machinery/door/airlock/attack_hand(mob/user)
	if(!istype(usr, /mob/living/silicon))
		if(isElectrified() && shock(user, 100))
			return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			if(density && (!arePowerSystemsOn() || (stat & BROKEN)))
				user.setClickCooldown(DEFAULT_WEAPON_COOLDOWN)
				to_chat(user, "You start forcing \the [src] open...")
				if(do_after(user, 30, src))
					if(welded)
						to_chat(user, SPAN("danger", "The airlock has been welded shut!"))
					else if(locked)
						to_chat(user, SPAN("danger", "The door bolts are down!"))
					else if(density)
						visible_message(SPAN("danger","\The [user] forces \the [src] open!"))
						open(TRUE)
						shake_animation(2, 2)
				return
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			visible_message(SPAN("danger", "[user] slashes at \the [name]."), 1)
			take_damage(10)
			user.do_attack_animation(src)
			user.setClickCooldown(5)
			shake_animation(2, 2)
			return

	if(p_open)
		user.set_machine(src)
		wires.Interact(user)
	else
		..(user)
	return

/obj/machinery/door/airlock/CanUseTopic(mob/user)
	if(operating < 0) //emagged
		to_chat(user, "<span class='warning'>Unable to interface: Internal error.</span>")
		return STATUS_CLOSE
	if(issilicon(user) && !src.canAIControl())
		if(canAIHack(user))
			hack(user)
		else
			if(isAllPowerLoss()) //don't really like how this gets checked a second time, but not sure how else to do it.
				to_chat(user, "<span class='warning'>Unable to interface: Connection timed out.</span>")
			else
				to_chat(user, "<span class='warning'>Unable to interface: Connection refused.</span>")
		return STATUS_CLOSE

	return ..()

/obj/machinery/door/airlock/Topic(href, href_list)
	if(..())
		return 1

	var/activate = text2num(href_list["activate"])
	switch(href_list["command"])
		if("idscan")
			set_idscan(activate, 1)

		if("main_power")
			if(!main_power_lost_until)
				src.loseMainPower()

		if("backup_power")
			if(!backup_power_lost_until)
				src.loseBackupPower()

		if("bolts")
			if(src.isWireCut(AIRLOCK_WIRE_DOOR_BOLTS))
				to_chat(usr, "The door bolt control wire is cut - Door bolts permanently dropped.")
			else if(activate && src.lock())
				to_chat(usr, "The door bolts have been dropped.")
			else if(!activate && src.unlock())
				to_chat(usr, "The door bolts have been raised.")

		if("electrify_temporary")
			electrify(30 * activate, 1)

		if("electrify_permanently")
			electrify(-1 * activate, 1)

		if("open")
			if(src.welded)
				to_chat(usr, text("The airlock has been welded shut!"))
			else if(src.locked)
				to_chat(usr, text("The door bolts are down!"))
			else if(activate && density)
				open()
			else if(!activate && !density)
				close()

		if("safeties")
			set_safeties(!activate, 1)

		if("timing")
			// Door speed control
			if(isWireCut(AIRLOCK_WIRE_SPEED))
				to_chat(usr, text("The timing wire is cut - Cannot alter timing."))
			else if(activate && normalspeed)
				normalspeed = 0
			else if(!activate && !normalspeed)
				normalspeed = 1

		if("lights")
			// Bolt lights
			if(isWireCut(AIRLOCK_WIRE_LIGHT))
				to_chat(usr, "The bolt lights wire is cut - The door bolt lights are permanently disabled.")
			else if(!activate && lights)
				lights = 0
				to_chat(usr, "The door bolt lights have been disabled.")
			else if(activate && !lights)
				lights = 1
				to_chat(usr, "The door bolt lights have been enabled.")

	update_icon()
	return 1

//returns 1 on success, 0 on failure
/obj/machinery/door/airlock/proc/cut_bolts(item, mob/user)
	var/cut_delay = (15 SECONDS)
	var/cut_verb
	var/cut_sound

	if(isWelder(item))
		var/obj/item/weapon/weldingtool/WT = item
		if(!WT.isOn())
			return 0
		if(!WT.remove_fuel(0,user))
			to_chat(user, "<span class='notice'>You need more welding fuel to complete this task.</span>")
			return 0
		cut_verb = "cutting"
		cut_sound = 'sound/items/Welder.ogg'

	else if(istype(item,/obj/item/weapon/gun/energy/plasmacutter)) //They could probably just shoot them out, but who cares!
		cut_verb = "cutting"
		cut_sound = 'sound/items/Welder.ogg'
		cut_delay *= 0.66

	else if(istype(item,/obj/item/weapon/melee/energy/blade) || istype(item,/obj/item/weapon/melee/energy/sword))
		cut_verb = "slicing"
		cut_sound = "spark"
		cut_delay *= 0.66

	else if(istype(item,/obj/item/weapon/circular_saw))
		cut_verb = "sawing"
		cut_sound = 'sound/effects/fighting/circsawhit.ogg'
		cut_delay *= 1.5

	else if(istype(item, /obj/item/weapon/material/twohanded/fireaxe))
		//special case - zero delay, different message
		if(lock_cut_state == BOLTS_EXPOSED)
			return 0 //can't actually cut the bolts, go back to regular smashing
		var/obj/item/weapon/material/twohanded/fireaxe/F = item
		if(!F.wielded)
			return 0
		user.visible_message(
			"<span class='danger'>\The [user] smashes the bolt cover open!</span>",
			"<span class='warning'>You smash the bolt cover open!</span>"
			)
		playsound(src, 'sound/effects/fighting/smash.ogg', 100, 1)
		lock_cut_state = BOLTS_EXPOSED
		return 0

	else
		// I guess you can't cut bolts with that item. Never mind then.
		return 0

	if(src.lock_cut_state == BOLTS_FINE)
		user.visible_message(
			"<span class='notice'>\The [user] begins [cut_verb] through the bolt cover on [src].</span>",
			"<span class='notice'>You begin [cut_verb] through the bolt cover.</span>"
			)

		playsound(src, cut_sound, 100, 1)
		if(do_after(user, cut_delay, src))
			user.visible_message(
				"<span class='notice'>\The [user] removes the bolt cover from [src]</span>",
				"<span class='notice'>You remove the cover and expose the door bolts.</span>"
				)
			src.lock_cut_state = BOLTS_EXPOSED
		return 1

	if(lock_cut_state == BOLTS_EXPOSED)
		user.visible_message(
			"<span class='notice'>\The [user] begins [cut_verb] through [src]'s bolts.</span>",
			"<span class='notice'>You begin [cut_verb] through the door bolts.</span>"
			)
		playsound(src, cut_sound, 100, 1)
		if(do_after(user, cut_delay, src))
			user.visible_message(
				"<span class='notice'>\The [user] severs the door bolts, unlocking [src].</span>",
				"<span class='notice'>You sever the door bolts, unlocking the door.</span>"
				)
			lock_cut_state = BOLTS_CUT
			unlock(1) //force it
		return 1

/obj/machinery/door/airlock/attackby(obj/item/C, mob/user)
	// Brace is considered installed on the airlock, so interacting with it is protected from electrification.
	if(brace && (istype(C.GetIdCard(), /obj/item/weapon/card/id/) || istype(C, /obj/item/weapon/crowbar/brace_jack)))
		return brace.attackby(C, user)

	if(!brace && istype(C, /obj/item/weapon/airlock_brace))
		var/obj/item/weapon/airlock_brace/A = C
		if(!density)
			to_chat(user, "You must close \the [src] before installing \the [A]!")
			return

		if((!A.req_access.len && !A.req_one_access) && (alert("\the [A]'s 'Access Not Set' light is flashing. Install it anyway?", "Access not set", "Yes", "No") == "No"))
			return

		if(do_after(user, 50, src) && density)
			to_chat(user, "You successfully install \the [A]. \The [src] has been locked.")
			brace = A
			brace.airlock = src
			user.drop_from_inventory(brace)
			brace.forceMove(src)
			update_icon()
		return

	if(!istype(usr, /mob/living/silicon))
		if(isElectrified())
			if(shock(user, 75))
				return

	if(istype(C, /obj/item/taperoll))
		return

	if(!repairing && (stat & BROKEN) && locked) //bolted and broken
		if(!cut_bolts(C,user))
			..()
		return

	if(!repairing && isWelder(C) && !(operating > 0) && density)
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			if(!welded)
				welded = TRUE
			else
				src.welded = null
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			update_icon()
			return
		else
			return

	else if(isScrewdriver(C))
		if(p_open)
			if(stat & BROKEN)
				to_chat(usr, "<span class='warning'>The panel is broken and cannot be closed.</span>")
			else
				p_open = FALSE
		else
			p_open = TRUE
		update_icon()

	else if(isWirecutter(C))
		return attack_hand(user)

	else if(isMultitool(C))
		return attack_hand(user)

	else if(istype(C, /obj/item/device/assembly/signaler))
		return attack_hand(user)

	else if(istype(C, /obj/item/weapon/pai_cable))	// -- TLE
		var/obj/item/weapon/pai_cable/cable = C
		cable.plugin(src, user)

	else if(!repairing && isCrowbar(C))
		if(p_open && (operating < 0 || (!operating && welded && !arePowerSystemsOn() && density && !locked)) && !brace)
			playsound(loc, 'sound/items/Crowbar.ogg', 100, 1)
			user.visible_message("[user] removes the electronics from the airlock assembly.", "You start to remove electronics from the airlock assembly.")
			if(do_after(user, 40, src))
				to_chat(user, SPAN("notice", "You remove the airlock electronics!"))
				deconstruct(user)
				return

		else if(arePowerSystemsOn())
			to_chat(user, SPAN("notice", "The airlock's motors resist your efforts to force it."))
		else if(locked)
			to_chat(user, SPAN("notice", ">The airlock's bolts prevent it from being forced."))
		else if(brace)
			to_chat(user, SPAN("notice", "The airlock's brace holds it firmly in place."))
		else
			spawn(0)
				density ? open(1) : close(1)

			//if door is unbroken, but at half health or less, hit with fire axe using harm intent
	else if (istype(C, /obj/item/weapon/material/twohanded/fireaxe) && !(stat & BROKEN) && (src.health <= src.maxhealth / 2) && user.a_intent == I_HURT)
		var/obj/item/weapon/material/twohanded/fireaxe/F = C
		if(F.wielded)
			playsound(src, 'sound/effects/fighting/smash.ogg', 100, 1)
			user.visible_message("<span class='danger'>[user] smashes \the [C] into the airlock's control panel! It explodes in a shower of sparks!</span>", "<span class='danger'>You smash \the [C] into the airlock's control panel! It explodes in a shower of sparks!</span>")
			health = 0
			set_broken(TRUE)
		else
			return ..()

	else if(istype(C, /obj/item/weapon/material/twohanded/fireaxe) && !arePowerSystemsOn())
		if(locked)
			to_chat(user, SPAN("notice", "The airlock's bolts prevent it from being forced."))
		else if(!welded && !operating)
			var/obj/item/weapon/material/twohanded/fireaxe/F = C
			if(!F.wielded)
				to_chat(user, SPAN("notice", "You need to be wielding \the [C] to do that."))
				return
			spawn()
				density ? open(1) : close(1)

	else
		..()

/obj/machinery/door/airlock/deconstruct(mob/user, moved = FALSE)
	var/obj/structure/door_assembly/da = new assembly_type(src.loc)
	if(istype(da, /obj/structure/door_assembly/multi_tile))
		da.set_dir(src.dir)
	if(mineral)
		da.glass = mineral
	//else if(glass)
	else if(glass && !da.glass)
		da.glass = 1

	if(moved)
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
	else
		da.anchored = 1
	da.state = 1
	da.created_name = src.name
	da.update_state()

	if(operating == -1 || (stat & BROKEN))
		new /obj/item/weapon/circuitboard/broken(src.loc)
		operating = 0
	else
		if(!electronics)
			create_electronics()

		electronics.dropInto(loc)
		electronics = null

	qdel(src)

	return da

/obj/machinery/door/airlock/set_broken(new_state)
	. = ..()
	if(. && new_state)
		p_open = 1
		if (secured_wires)
			lock()
		visible_message("\The [src]'s control panel bursts open, sparks spewing out!")
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()

/obj/machinery/door/airlock/can_open(forced = 0)
	if(brace)
		return 0
	if(!forced && (!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR)))
		return 0
	if(locked || welded)
		return 0
	return ..()

/obj/machinery/door/airlock/can_close(forced = 0)
	if(locked || welded)
		return 0
	if(!forced && (!arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_OPEN_DOOR)))
		return	0
	return ..()

/obj/machinery/door/airlock/open(forced = 0)
	if(!can_open(forced))
		return 0
	use_power_oneoff(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people

	//if the door is unpowered then it doesn't make sense to hear the woosh of a pneumatic actuator
	if(arePowerSystemsOn())
		if(islist(open_sound_powered))
			playsound(loc, pick(open_sound_powered), 70, 1)
		else
			playsound(loc, open_sound_powered, 70, 1)
	else
		if(islist(open_sound_unpowered))
			playsound(loc, pick(open_sound_unpowered), 70, 1)
		else
			playsound(loc, open_sound_unpowered, 70, 1)

	if(closeOther != null && istype(closeOther, /obj/machinery/door/airlock/) && !closeOther.density)
		closeOther.close()
	return ..()

/obj/machinery/door/airlock/close(forced = 0)
	if(!can_close(forced))
		addtimer(CALLBACK(src, .proc/close), next_close_time(), TIMER_UNIQUE|TIMER_OVERRIDE)
		return 0

	if(safe)
		for(var/turf/T in locs)
			for(var/atom/movable/AM in T)
				if(AM.blocks_airlock())
					if(world.time > next_beep_at)
						playsound(src.loc, close_failure_blocked, 30, 0, -3)
						next_beep_at = world.time + SecondsToTicks(10)
					addtimer(CALLBACK(src, .proc/close), next_close_time(), TIMER_UNIQUE|TIMER_OVERRIDE)
					return

	for(var/turf/T in locs)
		for(var/atom/movable/AM in T)
			if(AM.airlock_crush(door_crush_damage))
				take_damage(door_crush_damage)
				use_power_oneoff(door_crush_damage * 100)		// Uses bunch extra power for crushing the target.

	use_power_oneoff(360)	//360 W seems much more appropriate for an actuator moving an industrial door capable of crushing people
	if(arePowerSystemsOn())
		playsound(src.loc, close_sound_powered, 100, 1)
	else
		playsound(src.loc, close_sound_unpowered, 100, 1)

	..()

/obj/machinery/door/airlock/proc/lock(forced = 0)
	if(locked)
		return 0

	if(operating && !forced)
		return 0

	if(lock_cut_state == BOLTS_CUT)
		return 0 //what bolts?

	locked = TRUE
	playsound(src, bolts_dropping, 30, 0, -6)
	audible_message("You hear a click from the bottom of the door.", hearing_distance = 1)
	update_icon()
	return 1

/obj/machinery/door/airlock/proc/unlock(forced = 0)
	if(!locked)
		return 0

	if(!forced && (operating || !arePowerSystemsOn() || isWireCut(AIRLOCK_WIRE_DOOR_BOLTS)))
		return 0

	locked = FALSE
	playsound(src, bolts_rising, 30, 0, -6)
	audible_message("You hear a click from the bottom of the door.", hearing_distance = 1)
	update_icon()
	return 1

/obj/machinery/door/airlock/allowed(mob/M)
	if(locked)
		return 0
	return ..(M)

/obj/machinery/door/airlock/New(newloc, obj/structure/door_assembly/assembly = null)
	..()

	//if assembly is given, create the new door from the assembly
	if (assembly && istype(assembly))
		assembly_type = assembly.type

		electronics = assembly.electronics
		electronics.forceMove(src)

		//update the door's access to match the electronics'
		secured_wires = electronics.secure
		if(electronics.one_access)
			req_access.Cut()
			req_one_access = src.electronics.conf_access
		else
			req_one_access.Cut()
			req_access = src.electronics.conf_access

		//get the name from the assembly
		if(assembly.created_name)
			SetName(assembly.created_name)
		else
			SetName("[istext(assembly.glass) ? "[assembly.glass] airlock" : assembly.base_name]")

		//get the dir from the assembly
		set_dir(assembly.dir)

	//wires
	var/turf/T = get_turf(newloc)
	if(T && (T.z in GLOB.using_map.admin_levels))
		secured_wires = 1
	if(secured_wires)
		wires = new /datum/wires/airlock/secure(src)
	else
		wires = new /datum/wires/airlock(src)

/obj/machinery/door/airlock/Initialize()
	if(closeOtherId != null)
		for(var/obj/machinery/door/airlock/A in world)
			if(A.closeOtherId == closeOtherId && A != src)
				closeOther = A
				break

	var/turf/T = loc
	var/obj/item/weapon/airlock_brace/A = locate(/obj/item/weapon/airlock_brace) in T
	if(!brace && A)
		brace = A
		brace.airlock = src
		brace.forceMove(src)
		update_icon()

	return ..()

/obj/machinery/door/airlock/Destroy()
	qdel(wires)
	wires = null
	qdel(wifi_receiver)
	wifi_receiver = null
	if(brace)
		qdel(brace)
	return ..()

// Most doors will never be deconstructed over the course of a round,
// so as an optimization defer the creation of electronics until
// the airlock is deconstructed
/obj/machinery/door/airlock/proc/create_electronics()
	//create new electronics
	if(secured_wires)
		electronics = new /obj/item/weapon/airlock_electronics/secure( src.loc )
	else
		electronics = new /obj/item/weapon/airlock_electronics( src.loc )

	//update the electronics to match the door's access
	if(!req_access)
		check_access()
	if(req_access.len)
		electronics.conf_access = req_access
	else if(req_one_access.len)
		electronics.conf_access = req_one_access
		electronics.one_access = 1

/obj/machinery/door/airlock/emp_act(severity)
	if(prob(20 / severity))
		spawn(0)
			open()
	if(prob(40 / severity))
		var/duration = SecondsToTicks(30 / severity)
		if(electrified_until > -1 && (duration + world.time) > electrified_until)
			electrify(duration)
	..()

/obj/machinery/door/airlock/power_change() //putting this is obj/machinery/door itself makes non-airlock doors turn invisible for some reason
	. = ..()
	if(stat & NOPOWER)
		// If we lost power, disable electrification
		electrified_until = 0

/obj/machinery/door/airlock/proc/prison_open()
	if(arePowerSystemsOn())
		unlock()
		open()
		lock()
	return

// Braces can act as an extra layer of armor - they will take damage first.
/obj/machinery/door/airlock/take_damage(amount)
	if(brace)
		brace.take_damage(amount)
	else
		..(amount)

/obj/machinery/door/airlock/examine(mob/user)
	. = ..()
	if(lock_cut_state == BOLTS_EXPOSED)
		. += "\nThe bolt cover has been cut open."
	if(lock_cut_state == BOLTS_CUT)
		. += "\nThe door bolts have been cut."
	if(brace)
		. += "\n\The [brace] is installed on \the [src], preventing it from opening."
		. += "\n[brace.examine_health()]"

/obj/machinery/door/airlock/autoname
	name = "hatch"
	icon = 'icons/obj/doors/doorhatchmaint2.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/autoname/New()
	var/area/A = get_area(src)
	name = A.name
	..()
