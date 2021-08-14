//also it's weapon contoroller.
/obj/item/formfactor
	name = "Formfactor"
	desc = "This is formfactor of some weapon."

	var/obj/item/weapon/gun/holder

/obj/item/formfactor/New()
	. = ..()
	holder = loc
	return holder

/obj/item/formfactor/update_icon()
	if(holder)
		icon_state = holder.icon_state
	..()

/obj/item/formfactor/proc/consume_next_projectile(mob/user)
	return holder.consume_next_projectile(user)

/obj/item/formfactor/proc/Fire(atom/target, mob/living/user, clickparams, pointblank=0, reflex=0)
	if(!user || !target) return
	if(target.z != user.z) return

	holder.add_fingerprint(user)
	add_fingerprint(user)

	if(!holder.special_check(user))
		return

	if(world.time < holder.next_fire_time)
		if(world.time % 3) //to prevent spam
			to_chat(user, SPAN("warning", "[holder] is not ready to fire again!"))
		return

	var/shoot_time = (holder.burst - 1) * holder.burst_delay
	user.setClickCooldown(shoot_time) //no clicking on things while shooting
	user.setMoveCooldown(shoot_time) //no moving while shooting either
	holder.next_fire_time = world.time + shoot_time

	var/held_twohanded = (user.can_wield_item(holder) && holder.is_held_twohanded(user))

	//actually attempt to shoot
	var/turf/targloc = get_turf(target) //cache this in case target gets deleted during shooting, e.g. if it was a securitron that got destroyed.
	for(var/i in 1 to holder.burst)
		var/obj/projectile = consume_next_projectile(user)
		if(!projectile)
			holder.handle_click_empty(user)
			break

		holder.process_accuracy(projectile, user, target, i, held_twohanded)

		if(pointblank)
			holder.process_point_blank(projectile, user, target)

		if(holder.process_projectile(projectile, user, target, user.zone_sel?.selecting, clickparams))
			var/burstfire = 0
			if(holder.burst > 1) // It ain't a burst? Then just act normally
				if(i > 1)
					burstfire = -1  // We've already seen the BURST message, so shut up
				else
					burstfire = 1 // We've yet to see the BURST message
			holder.handle_post_fire(user, target, pointblank, reflex, burstfire)
			holder.update_icon()

		if(i < holder.burst)
			sleep(holder.burst_delay)

		if(!(target && target.loc))
			target = targloc
			pointblank = 0

	//update timing
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	user.setMoveCooldown(holder.move_delay)
	holder.next_fire_time = world.time + holder.fire_delay

/obj/item/formfactor/flamerthrower
	var/obj/item/weapon/gun/flamer/F

/obj/item/formfactor/flamerthrower/New()
	. = ..()
	F = .

/obj/item/formfactor/flamerthrower/Fire(atom/target, mob/living/user, params, pointblank=0, reflex=0)
	var/turf/curloc = get_turf(user) //In case the target or we are expired.
	var/turf/targloc = get_turf(target)
	if(!targloc || !curloc)
		return //Something has gone wrong...

	if(!F.is_held_twohanded(user))
		to_chat(user, SPAN_WARNING("You cant fire on target with just one hand"))
		return

	if(F.is_flamer_can_fire(user))
		if(world.time > F.last_use + F.fire_delay)
			F.last_fired = world.time
			F.last_use = world.time
			F.unleash_flame(target, user)
			targloc.hotspot_expose(700,125)
			log_attack("[user] start spreadding fire with \ref[F].")
			return
		else
			to_chat(user, SPAN_WARNING("[F] is not ready to fire again!"))
			playsound(F.loc, 'sound/signals/warning3.ogg', 50, 0)
			return
