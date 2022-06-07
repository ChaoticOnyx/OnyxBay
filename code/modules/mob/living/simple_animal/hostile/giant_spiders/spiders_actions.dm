
/datum/action/innate/spider
	button_icon = 'icons/mob/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"

/datum/action/innate/spider/lay_web
	name = "Spin Web"
	//desc = "Spin a web to slow down potential prey."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
		return
	var/mob/living/simple_animal/hostile/giant_spider/spider = owner

	if(!isturf(spider.loc))
		return
	var/turf/spider_turf = get_turf(spider)

	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	if(web)
		if(!spider.web_sealer || istype(web, /obj/structure/spider/stickyweb/sealed))
			to_chat(spider, SPAN_WARNING("There's already a web here!"))
			return

	if(!spider.is_busy)
		spider.is_busy = TRUE
		if(web)
			spider.visible_message(SPAN_NOTICE("[spider] begins to pack more webbing onto the web."),SPAN_NOTICE("You begin to seal the web."))
		else
			spider.visible_message(SPAN_NOTICE("[spider] begins to secrete a sticky substance."),SPAN_NOTICE("You begin to lay a web."))
		spider.stop_automated_movement = TRUE
		if(do_after(spider, 40 * spider.web_speed, target = spider_turf))
			if(spider.is_busy && spider.loc == spider_turf)
				if(web)
					qdel(web)
					new /obj/structure/spider/stickyweb/sealed(spider_turf)
				new /obj/structure/spider/stickyweb(spider_turf)
		spider.is_busy = FALSE
		spider.stop_automated_movement = FALSE
	else
		to_chat(spider, SPAN_WARNING("You're already doing something else!"))

/datum/action/innate/spider/wrap
	name = "Wrap"
	panel = "Spider"

/datum/action/innate/spider/wrap/Click()
	if(!istype(usr, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return TRUE
	var/mob/living/simple_animal/hostile/giant_spider/midwife/user = usr
	activate(user)
	return TRUE

/datum/action/innate/spider/wrap/proc/activate(mob/living/user)
	var/message
	if(active)
		message = SPAN_NOTICE("You no longer prepare to wrap something in a cocoon.")
	else
		message = SPAN_NOTICE("You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B>")
		return TRUE

//TODO click handler
/datum/action/innate/spider/wrap/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return
	if(owner.incapacitated() || !istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return

	var/mob/living/simple_animal/hostile/giant_spider/midwife/user = owner

	if(user.Adjacent(target) && (ismob(target) || isobj(target)))
		var/atom/movable/target_atom = target
		if(target_atom.anchored)
			return
		user.cocoon_target = target_atom
		INVOKE_ASYNC(user, /mob/living/simple_animal/hostile/giant_spider/midwife/.proc/cocoon)
		return TRUE


/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	//desc = "Lay a cluster of eggs, which will soon grow into a normal spider."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "lay_eggs"
	var/enriched = FALSE

/datum/action/innate/spider/lay_eggs/IsAvailable()
	. = ..()
	if(!.)
		return
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return FALSE
	var/mob/living/simple_animal/hostile/giant_spider/midwife/S = owner
	if(enriched && !S.fed)
		return FALSE
	return TRUE

/datum/action/innate/spider/lay_eggs/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/spider = owner

	var/obj/structure/spider/eggcluster/eggs = locate() in get_turf(spider)
	if(eggs)
		to_chat(spider, SPAN_WARNING("There is already a cluster of eggs here!"))
	else if(enriched && !spider.fed)
		to_chat(spider, SPAN_WARNING("You are too hungry to do this!"))
	else if(!spider.is_busy)
		spider.is_busy = TRUE
		spider.visible_message(SPAN_NOTICE("[spider] begins to lay a cluster of eggs."), SPAN_NOTICE("You begin to lay a cluster of eggs."))
		spider.stop_automated_movement = TRUE
		if(do_after(spider, spider.egg_lay_time, target = get_turf(spider)))
			if(spider.is_busy)
				eggs = locate() in get_turf(spider)
				if(!eggs || !isturf(spider.loc))
					var/egg_choice = enriched ? /obj/effect/mob_spawn/ghost_role/spider/enriched : /obj/effect/mob_spawn/ghost_role/spider
					var/obj/effect/mob_spawn/ghost_role/spider/new_eggs = new egg_choice(get_turf(spider))
					new_eggs.directive = spider.directive
					new_eggs.faction = spider.faction
					if(enriched)
						spider.fed--
					owner.update_action_buttons()
		spider.is_busy = FALSE
		spider.stop_automated_movement = FALSE

/datum/action/innate/spider/lay_eggs/enriched
	name = "Lay Enriched Eggs"
	//desc = "Lay a cluster of eggs, which will soon grow into a greater spider.  Requires you drain a human per cluster of these eggs."
	button_icon_state = "lay_enriched_eggs"
	enriched = TRUE

/datum/action/innate/spider/set_directive
	name = "Set Directive"
	//desc = "Set a directive for your children to follow."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "directive"

/datum/action/innate/spider/set_directive/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider))
			return FALSE
		return TRUE

/datum/action/innate/spider/set_directive/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
		return
	var/mob/living/simple_animal/hostile/giant_spider/midwife/spider = owner
	spider.directive = input(spider, "Enter the new directive", "Create directive", "[spider.directive]") as text
	if(isnull(spider.directive))
		return
	message_admins("[owner] set its directive to: '[spider.directive]'.")
	log_game("[key_name(owner)] set its directive to: '[spider.directive]'.")

/datum/action/innate/spider/comm
	name = "Command"
	//desc = "Send a command to all living spiders."
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/giant_spider/midwife))
			return FALSE
		return TRUE

/datum/action/innate/spider/comm/Trigger(trigger_flags)
	var/input = input(owner, "Input a command for your legions to follow.", "Command") as text
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(owner, input)
	return TRUE

/**
 * Sends a message to all spiders from the target.
 *
 * Allows the user to send a message to all spiders that exist.  Ghosts will also see the message.
 * Arguments:
 * * user - The spider sending the message
 * * message - The message to be sent
 */
/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	var/my_message
	my_message = span_spider("<b>Command from [user]:</b> [message]")
	for(var/mob/living/simple_animal/hostile/giant_spider/spider in GLOB.spidermobs)
		to_chat(spider, my_message)
	for(var/ghost in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(ghost, user)
		to_chat(ghost, "[link] [my_message]")
	usr.log_talk(message, LOG_SAY, tag="spider command")

/// For /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define SIGNAL_STARTED_CHARGE "mob_ability_charge_started"
/// For /datum/action/cooldown/mob_cooldown/charge/proc/do_charge(): ()
#define SIGNAL_FINISHED_CHARGE "mob_ability_charge_finished"

/**
 * Charge
 */
/datum/action/cooldown/charge
	name = "Charge"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "sniper_zoom"
	//desc = "Allows you to charge at a chosen position."
	cooldown_time = 1.5 SECONDS
	/// Delay before the charge actually occurs
	var/charge_delay = 0.3 SECONDS
	/// The amount of turfs we move past the target
	var/charge_past = 2
	/// The maximum distance we can charge
	var/charge_distance = 50
	/// The sleep time before moving in deciseconds while charging
	var/charge_speed = 0.5
	/// The damage the charger does when bumping into something
	var/charge_damage = 30
	/// If we destroy objects while charging
	var/destroy_objects = TRUE
	/// List of charging mobs
	var/list/charging = list()

/datum/action/cooldown/charge/New(Target, delay, past, distance, speed, damage, destroy)
	. = ..()
	if(!isnull(delay))
		charge_delay = delay
	if(!isnull(past))
		charge_past = past
	if(!isnull(distance))
		charge_distance = distance
	if(!isnull(speed))
		charge_speed = speed
	if(!isnull(damage))
		charge_damage = damage
	if(!isnull(destroy))
		destroy_objects = destroy

/datum/action/cooldown/charge/Activate(atom/target_atom)
	// start pre-cooldown so that the ability can't come up while the charge is happening
	StartCooldown(10 SECONDS)
	charge_sequence(owner, target_atom, charge_delay, charge_past)
	StartCooldown()

/datum/action/cooldown/charge/proc/charge_sequence(atom/movable/charger, atom/target_atom, delay, past)
	do_charge(owner, target_atom, charge_delay, charge_past)

/datum/action/cooldown/charge/proc/do_charge(atom/movable/charger, atom/target_atom, delay, past)
	if(!target_atom || target_atom == owner)
		return
	var/chargeturf = get_turf(target_atom)
	if(!chargeturf)
		return
	var/dir = get_dir(charger, target_atom)
	var/turf/target = get_ranged_target_turf(chargeturf, dir, past)
	if(!target)
		return

	if(charger in charging)
		// Stop any existing charging, this'll clean things up properly
		charging -= charger

	charging += charger
	SEND_SIGNAL(owner, SIGNAL_STARTED_CHARGE)
	register_signal(charger, SIGNAL_MOVABLE_BUMP, .proc/on_bump)
	register_signal(charger, SIGNAL_MOVED, .proc/on_moved)
	DestroySurroundings(charger)
	charger.set_dir(dir)
	do_charge_indicator(charger, target)

	sleep(delay);

	if(QDELETED(charger))
		return;

	if(ismob(charger))
		var/mob/sleep_check_death_mob = charger;
		if(sleep_check_death_mob.stat == DEAD)
			return;


	var/time_to_hit = min(get_dist(charger, target), charge_distance) * charge_speed

	spawn(time_to_hit)
		charge_end()

	return TRUE

/datum/action/cooldown/charge/proc/charge_end()
	SIGNAL_HANDLER
	var/atom/movable/charger = owner
	unregister_signal(charger, list(SIGNAL_MOVABLE_BUMP, SIGNAL_MOVED))
	SEND_SIGNAL(owner, SIGNAL_FINISHED_CHARGE)
	charging -= charger

/datum/action/cooldown/charge/proc/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/dragon_swoop/bubblegum(target_turf)
	var/obj/effect/temp_visual/decoy/D = new /obj/effect/temp_visual/decoy(charger.loc, charger)
	animate(D, alpha = 0, color = "#FF0000", transform = matrix()*2, time = 3)

/datum/action/cooldown/charge/proc/on_moved(atom/source)
	playsound(source, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)

/datum/action/cooldown/charge/proc/DestroySurroundings(atom/movable/charger)
	if(!destroy_objects)
		return
	if(!isanimal(charger))
		return
	for(var/dir in GLOB.cardinal)
		var/turf/next_turf = get_step(charger, dir)
		if(!next_turf)
			continue
		if(next_turf.Adjacent(charger) && (iswall(next_turf)))
			if(!isanimal(charger))
				SSexplosions.medturf += next_turf
				continue
			next_turf.attack_generic(charger)
			continue
		for(var/obj/object in next_turf.contents)
			if(!object.Adjacent(charger))
				continue
			if(!istype(/obj/machinery, object) && !istype(/obj/structure, object))
				continue
			if(!object.density)
				continue
			if(!isanimal(charger))
				SSexplosions.med_mov_atom += target
				break
			object.attack_generic(charger)
			break

/datum/action/cooldown/charge/proc/on_bump(atom/movable/source, atom/target)
	if(owner == target)
		return
	if(isturf(target))
		SSexplosions.medturf += target
	if(isobj(target) && target.density)
		SSexplosions.med_mov_atom += target

	INVOKE_ASYNC(src, .proc/DestroySurroundings, source)
	hit_target(source, target, charge_damage)

/datum/action/cooldown/charge/proc/hit_target(atom/movable/source, atom/target, damage_dealt)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.visible_message("<span class='danger'>[source] slams into [living_target]!</span>", "<span class='userdanger'>[source] tramples you into the ground!</span>")
	source.forceMove(get_turf(living_target))
	living_target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(living_target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(living_target, 4, 3)
	shake_camera(source, 2, 3)

/**
 * Basic Charge
 */

/datum/action/cooldown/charge/basic_charge
	name = "Basic Charge"
	cooldown_time = 6 SECONDS
	charge_delay = 1.5 SECONDS
	charge_distance = 4
	var/shake_duration = 1 SECONDS
	var/shake_pixel_shift = 15

/datum/action/cooldown/charge/basic_charge/do_charge_indicator(atom/charger, atom/charge_target)
	charger.shake_animation(shake_pixel_shift, shake_duration)

/datum/action/cooldown/charge/basic_charge/hit_target(atom/movable/source, atom/target, damage_dealt)
	var/mob/living/living_source
	if(isliving(source))
		living_source = source

	if(!isliving(target))
		if(!target.density || target.CanPass(source, get_dir(target, source)))
			return
		source.visible_message(SPAN_DANGER("[source] smashes into [target]!"))
		if(!living_source)
			return
		living_source.Stun(6)
		return

	var/mob/living/living_target = target
	if(ishuman(living_target))
		var/mob/living/carbon/human/human_target = living_target
		if(human_target.check_shields(source, 0, "the [source.name]") && living_source)
			living_source.Stun(6)
			return

	living_target.visible_message(SPAN_DANGER("[source] charges on [living_target]!"), SPAN_DANGER("[source] charges into you!"))
	living_target.Stun(6)
