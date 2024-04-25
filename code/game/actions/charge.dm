/// For /datum/action/cooldown/charge/proc/do_charge(): ()
#define SIGNAL_STARTED_CHARGE "mob_ability_charge_started"
/// For /datum/action/cooldown/charge/proc/do_charge(): ()
#define SIGNAL_FINISHED_CHARGE "mob_ability_charge_finished"

/**
 * Charge
 */
/datum/action/cooldown/charge
	name = "Charge"
	action_type = AB_INNATE
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "charge"
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
	var/charge_damage = 50
	/// If we destroy objects while charging
	var/destroy_objects = TRUE
	/// List of charging mobs
	var/list/charging = list()
	click_to_activate = TRUE

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

/datum/action/cooldown/charge/Trigger(trigger_flags, atom/target)
	. = ..()
	if(!IsAvailable())
		return FALSE

	if(active)
		to_chat(usr, SPAN_NOTICE("You no longer prepare to charge."))
		button.update_icon()
		active = FALSE
		return FALSE
	else
		to_chat(usr, SPAN_NOTICE("You prepare to charge. <B>Left-click your target to charge!</B>"))
		var/image/img = image(button_icon,button,"bg_active")
		img.pixel_x = 0
		img.pixel_y = 0
		button.AddOverlays(img)
		active = TRUE
		return TRUE

/datum/action/cooldown/charge/ActivateOnClick(atom/target_atom)
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
	register_signal(charger, SIGNAL_MOVABLE_BUMP, nameof(.proc/on_bump))
	register_signal(charger, SIGNAL_MOVED, nameof(.proc/on_moved))
	DestroySurroundings(charger)
	charger.set_dir(dir)
	do_charge_indicator(charger, target)

	sleep(delay);

	if(QDELETED(charger))
		return;

	if(ismob(charger))
		var/mob/sleep_check_death_mob = charger;
		if(sleep_check_death_mob.is_ic_dead())
			return;

	walk(charger,dir,1,charge_speed)
	var/time_to_hit = min(get_dist(charger, target), charge_distance)

	spawn(time_to_hit)
		charge_end()

	return TRUE

/datum/action/cooldown/charge/proc/charge_end()
	SIGNAL_HANDLER
	var/atom/movable/charger = owner
	unregister_signal(charger, list(SIGNAL_MOVABLE_BUMP, SIGNAL_MOVED))
	SEND_SIGNAL(owner, SIGNAL_FINISHED_CHARGE)
	walk(charger,0)
	charging -= charger

//TODO Cool animation
/datum/action/cooldown/charge/proc/do_charge_indicator(atom/charger, atom/charge_target)
	var/turf/target_turf = get_turf(charge_target)
	if(!target_turf)
		return

/datum/action/cooldown/charge/proc/on_moved(atom/source)
	playsound(source, 'sound/effects/meteorimpact.ogg', 200, TRUE, 2, TRUE)
	INVOKE_ASYNC(src, nameof(.proc/DestroySurroundings), source)

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
			var/turf/simulated/wall/W = next_turf
			W.attack_generic(charger, 40, wallbreaker=1)
			continue
		for(var/obj/object in next_turf.contents)
			if(!object.Adjacent(charger))
				continue
			if(!istype(object, /obj/machinery) && !istype(object, /obj/structure))
				continue
			if(!object.density)
				continue
			if(!isanimal(charger))
				SSexplosions.med_mov_atom += target
				break
			object.attack_generic(charger)
			break

/datum/action/cooldown/charge/proc/on_bump(atom/target)
	if(owner == target)
		return
	if(isturf(target))
		SSexplosions.medturf += target
	if(isobj(target) && target.density)
		SSexplosions.med_mov_atom += target

	INVOKE_ASYNC(src, nameof(.proc/DestroySurroundings), usr)
	hit_target(target, charge_damage)

/datum/action/cooldown/charge/proc/hit_target(atom/target, damage_dealt)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	living_target.visible_message("<span class='danger'>[usr] slams into [living_target]!</span>", "<span class='userdanger'>[usr] tramples you into the ground!</span>")
	usr.forceMove(get_turf(living_target))
	living_target.apply_damage(damage_dealt, BRUTE)
	playsound(get_turf(living_target), 'sound/effects/meteorimpact.ogg', 100, TRUE)
	shake_camera(living_target, 4, 3)
	shake_camera(usr, 2, 3)

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

/datum/action/cooldown/charge/basic_charge/hit_target(atom/movable/target, damage_dealt)
	var/mob/living/living_source
	if(isliving(usr))
		living_source = usr

	if(!isliving(target))
		if(!target.density || target.CanPass(usr, get_dir(target, usr)))
			return
		usr.visible_message(SPAN_DANGER("[usr] smashes into [target]!"))
		if(!living_source)
			return
		living_source.Stun(6)
		return

	var/mob/living/living_target = target
	if(ishuman(living_target))
		var/mob/living/carbon/human/human_target = living_target
		var/zone = ran_zone(BP_CHEST, 75)
		if(human_target.check_shields(damage_dealt, usr, usr, zone, "the [usr.name]") && living_source)
			living_source.Stun(6)
			return

	living_target.visible_message(SPAN_DANGER("[usr] charges on [living_target]!"), SPAN_DANGER("[usr] charges into you!"))
	shake_camera(living_target, 4, 3)
	living_target.Stun(8)
	living_target.Weaken(5)
	living_target.apply_damage(damage_dealt, BRUTE)
