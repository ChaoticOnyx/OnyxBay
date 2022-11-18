#define HACK_STAGE_PRE 0
#define HACK_STAGE_FINISH 3

#define STAGE_DURATION 1 MINUTE
#define CABLES_REQUIRED 10

/obj/item/device/money_drill
	name = "Money Drill"
	desc = "A rather fragile structure made of a drill connected by wires."

	icon_state = "money_drill"
	item_state = "money_drill"
	w_class = ITEM_SIZE_NORMAL
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	throwforce = 5
	throw_range = 2
	force = 10.0

	var/hack_interrupted = FALSE
	var/hack_progress = 0
	var/obj/machinery/atm/hack_target = null
	var/hack_stage = HACK_STAGE_PRE
	var/broken = FALSE

/obj/item/device/money_drill/_examine_text(mob/user)
	var/msg = ..() + "<br>"

	if(broken)
		var/obj/item/stack/cable_coil/C = locate() in contents

		if(!C || C?.get_amount() < CABLES_REQUIRED)
			msg += SPAN("info", "Wires") + " are " + SPAN("bad", "torn.<br>")
		
		var/obj/item/pickaxe/drill/D = locate() in contents

		if(!D)
			msg += SPAN("info", "Drill") + " are " + SPAN("bad", "broken<br>")
	
	return msg

/obj/item/device/money_drill/emp_act(severity)
	broke()

/obj/item/device/money_drill/hitby(atom/movable/AM, speed, nomsg)
	. = ..()
	
	if(!broken && prob(50))
		broke()

/obj/item/device/money_drill/attack(mob/living/M, mob/living/user, target_zone)
	. = ..()
	
	if(. && !broken && prob(75))
		broke()

/obj/item/device/money_drill/proc/broke()
	broken = TRUE
	new /obj/effect/sparks(get_turf(src))
	visible_message(SPAN("warning", "\The [hack_target] sparks!"), SPAN("warning", "You hear something is sparks!"))

/obj/item/device/money_drill/attackby(obj/item/W, mob/user)
	if(!broken)
		return ..()

	// Repair.
	// Insert cables.
	if(istype(W, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/N = W
		var/obj/item/stack/cable_coil/O = locate() in contents

		if(O?.get_amount() >= CABLES_REQUIRED)
			to_chat(user, "\The [src] does not need more cables")
			return
		
		user.visible_message("[user] puts \the [N] in \the [src]", "You put \the [N] in \the [src]")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)

		if(!O)
			O = new(src)
		
		var/transfer_amount = min(CABLES_REQUIRED - O.get_amount(), N.get_amount())

		N.use(transfer_amount)
		O.amount += transfer_amount
	// Insert drill.
	else if(istype(W, /obj/item/pickaxe/drill))
		var/obj/item/pickaxe/drill/D = W
		var/obj/item/pickaxe/drill/O = locate() in contents

		if(O)
			to_chat(user, "\The [src] does not need a new drill")
			return

		user.visible_message("[user] puts \the [D] in \the [src]", "You put \the [D] in \the [src]")
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)

		user.drop_item(D)
		D.forceMove(src)
	
	_repair_if_can()
	
/obj/item/device/money_drill/proc/_repair_if_can()
	var/obj/item/stack/cable_coil/C = locate() in contents

	if(!C || C.get_amount() < 10)
		return

	var/obj/item/pickaxe/drill/D = locate() in contents

	if(!D)
		return

	broken = FALSE
	qdel(C)
	qdel(D)

/obj/item/device/money_drill/attack_hand(mob/user)
	if(!anchored)
		return ..()

	// Fixing the drill.
	if(hack_interrupted)
		user.visible_message("[user] starts to fix \the [src]", "You start to fix \the [src]")

		if(!do_after(user, 10 SECONDS, src, TRUE))
			user.visible_message("[user] stopped fixing of \the [src]", "You stop fixing \the [src]")
			return
		
		user.visible_message("[user] has fixed \the [src]", "You have fixed \the [src]")
		hack_interrupted = FALSE
		return

	// Uninstalling the drill.
	user.visible_message("[user] starts to uninstall \the [src]", "You start to uninstall \the [src]")

	if(!do_after(user, 10 SECONDS, src, TRUE))
		user.visible_message("[user] stopped uninstalling \the [src]", "You stop uninstalling \the [src]")
		return
	
	user.visible_message("[user] has uninstalled \the [src]", "You have uninstalled \the [src]")
	_stop_hack()
	user.put_in_any_hand_if_possible(src, FALSE, FALSE, TRUE)

/obj/item/device/money_drill/resolve_attackby(atom/target, mob/user, click_params)
	// 1 - Check if it is ATM.
	var/obj/machinery/atm/A = target
	if(!istype(A))
		return ..()

	// 2 - Check if the ATM and the drill it is not broken.
	if(broken)
		to_chat(user, SPAN("warning", "\The [src] is broken!"))
		return

	if(A.stat & BROKEN)
		to_chat(user, SPAN("warning", "\The [target] is broken and can't be hacked"))
		return

	// 3 - Start hacking.
	if(_start_hack(A, user))
		// 4 - Profit (a bit later).
		START_PROCESSING(SSmachines, src)

/obj/item/device/money_drill/proc/_start_hack(obj/machinery/atm/target, mob/user)
	user.visible_message("[user] start installing \the [src] on \the [target]", "You start to install \the [src] on \the [target]")

	if(!do_after(user, 5 SECONDS, hack_target, TRUE, can_move = FALSE))
		user.visible_message("[user] stopped installing \the [src] on \the [target]", "You stop to install \the [src] on \the [target]")
		return FALSE

	user.visible_message("[user] have installed \the [src]", "You have installed \the [src]")

	// Setup some variables.
	hack_progress = 0
	hack_target = target
	hack_stage = HACK_STAGE_PRE
	hack_interrupted = FALSE

	// Move and anchor the drill.
	user.drop_item(src)
	forceMove(get_turf(hack_target))
	pixel_x = hack_target.pixel_x
	pixel_y = hack_target.pixel_y
	anchored = TRUE
	layer = hack_target.layer + 0.01

	return TRUE

/obj/item/device/money_drill/proc/_stop_hack()
	// Reset state, position and un-anchor the drill.
	pixel_x = 0
	pixel_y = 0
	anchored = FALSE
	layer = initial(layer)
	hack_stage = HACK_STAGE_PRE
	hack_target = null
	hack_progress = 0
	hack_interrupted = FALSE

/obj/item/device/money_drill/proc/_finish_hack()
	hack_target.set_broken(TRUE)
	new /obj/effect/sparks(get_turf(hack_target))
	visible_message(SPAN("warning", "\The [hack_target] sparks!"), SPAN("warning", "You hear something is sparks!"))

	// Spawn money and throw it around.
	var/money_stacks = rand(4, 10)
	var/turf/T = get_step(hack_target, hack_target.dir)

	for(var/spawned = 0; spawned < money_stacks; spawned += 1)
		var/atom/movable/money = spawn_money(pick(list(1000, 2000, 3000)), T)
		money.throw_at_random(FALSE, 5, 1)

	_stop_hack()


/obj/item/device/money_drill/Process(decseconds)
	var/beep_msg = "\The [src] beeps"

	// Check if we trying to hack nullspace.
	if(QDELETED(hack_target))
		return PROCESS_KILL

	if(broken)
		_stop_hack()
		return PROCESS_KILL

	// Check if we finished.
	if(hack_stage >= HACK_STAGE_FINISH)
		visible_message(beep_msg, beep_msg)
		playsound(src, 'sound/signals/warning7.ogg', 40, FALSE)
		_finish_hack()
		return PROCESS_KILL

	if(hack_interrupted)
		THROTTLE(beep_cd, 3 SECONDS)

		if(beep_cd)
			visible_message(beep_msg, beep_msg)
			playsound(src, 'sound/signals/error29.ogg', 40, FALSE)
		
		return

	hack_progress += decseconds / 10 / STAGE_DURATION * 100

	// Progress in hacking.
	if(hack_progress >= 100)
		hack_progress = 0
		visible_message(beep_msg, beep_msg)
		playsound(src, 'sound/signals/warning8.ogg', 40, FALSE)
		hack_stage += 1

		if(prob(15))
			visible_message(SPAN("warning", "\The [src] stops drilling!"))
			hack_interrupted = TRUE
		
		return

	THROTTLE(sound_cd, 8 SECONDS)
	if(sound_cd)
		playsound(src, 'sound/items/drill.ogg', 60, TRUE, world.view * 2)

#undef HACK_STAGE_PRE
#undef HACK_STAGE_FINISH
#undef STAGE_DURATION
#undef CABLES_REQUIRED
