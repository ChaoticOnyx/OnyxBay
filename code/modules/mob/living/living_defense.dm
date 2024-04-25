
/*
	run_armor_check() args
	def_zone - What part is getting hit, if null will check entire body
	attack_flag - The type of armour to be checked
	armour_pen - reduces the effectiveness of armour
	absorb_text - shown if the armor check is 100% successful
	soften_text - shown if the armor check is more than 0% successful and less than 100%

	Returns
	a blocked amount between 0 - 100, representing the success of the armor check.
*/
/mob/living/proc/run_armor_check(def_zone = null, attack_flag = "melee", armor_pen = 0, absorb_text = null, soften_text = null)
	var/armor = get_flat_armor(def_zone, attack_flag)

	if(armor_pen >= armor)
		return 0 //effective_armor is going to be 0, fullblock is going to be 0, blocked is going to 0, let's save ourselves the trouble

	var/effective_armor = (armor - armor_pen) / 100
	var/fullblock = (effective_armor * effective_armor) * ARMOR_BLOCK_CHANCE_MULT

	if(fullblock >= 1 || prob(fullblock * 100))
		show_message(SPAN("warning", absorb_text ? absorb_text : "Your armor absorbs the blow!"))
		return 100

	//this makes it so that X armour blocks X% damage, when including the chance of hard block.
	//I double checked and this formula will also ensure that a higher effective_armor
	//will always result in higher (non-fullblock) damage absorption too, which is also a nice property
	//In particular, blocked will increase from 0 to 50 as effective_armor increases from 0 to 0.999 (if it is 1 then we never get here because ofc)
	//and the average damage absorption = (blocked/100)*(1-fullblock) + 1.0*(fullblock) = effective_armor
	var/blocked = (effective_armor - fullblock) / (1 - fullblock) * 100

	if(blocked > 20)
		//Should we show this every single time?
		show_message(SPAN("warning", soften_text ? soften_text : "Your armor softens the blow!"))

	return round(blocked, 1)

//Adds two armor values together.
//If armor_a and armor_b are between 0-100 the result will always also be between 0-100.
/proc/add_armor(armor_a, armor_b)
	if(armor_a >= 100 || armor_b >= 100)
		return 100 //adding to infinite protection doesn't make it any bigger

	var/protection_a = 1/(blocked_mult(armor_a)) - 1
	var/protection_b = 1/(blocked_mult(armor_b)) - 1
	return 100 - 1/(protection_a + protection_b + 1)*100

// Returns "flattened" armor value of a bodypart (or the whole body if def_zone = null)
// Basically just combines all the layers, and thus is used everywhere except direct combat
/mob/living/proc/get_flat_armor(def_zone, type)
	return 0

// Returns a list of armor values, from the outer layer (suit accessories) to the inner (undies)
// Unlike in get_flat_armor(), def_zone MUST be specified, since it would make no sense otherwise
/mob/living/proc/get_layered_armor(def_zone, type)
	return null

/mob/living/bullet_act(obj/item/projectile/P, def_zone)

	//Being hit while using a deadman switch
	var/obj/item/device/assembly/signaler/signaler = get_active_hand()
	if(istype(signaler) && signaler.deadman)
		log_and_message_admins("has triggered a signaler deadman's switch")
		src.visible_message("<span class='warning'>[src] triggers their deadman's switch!</span>")
		signaler.signal()

	//Armor
	var/damage = P.damage
	var/flags = P.damage_flags()
	var/absorb = run_armor_check(def_zone, P.check_armour, P.armor_penetration)

	// Turning bullets blunt and dissipating lasers
	// Having any positive absorb means the armor's actually workedm one way or another, no need to check for value
	if(absorb)
		if(flags & DAM_LASER)
			//the armour causes the heat energy to spread out, which reduces the damage (and the blood loss)
			//this is mostly so that armour doesn't cause people to lose MORE fluid from lasers than they would otherwise
			damage *= FLUIDLOSS_CONC_BURN/FLUIDLOSS_WIDE_BURN
		flags &= ~(DAM_SHARP|DAM_EDGE)

	// Species-specific bullet_act aka The Platinum Snowflake; seriously what the fuck
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(!C.species?.bullet_act(P, C))
			return

	// Applying damage
	if(!P.nodamage)
		apply_damage(damage, P.damage_type, def_zone, absorb, flags, P)

	// Applying projectile-specific stuff
	P.on_hit(src, absorb, def_zone)

	return absorb

/mob/living/blob_act(damage)
	apply_damage(damage, BRUTE, BP_CHEST, 0, 0)

/mob/living/proc/aura_check(type)
	if(!auras)
		return TRUE
	. = TRUE
	var/list/newargs = args - args[1]
	for(var/a in auras)
		var/obj/aura/aura = a
		var/result = 0
		switch(type)
			if(AURA_TYPE_WEAPON)
				result = aura.attackby(arglist(newargs))
			if(AURA_TYPE_BULLET)
				result = aura.bullet_act(arglist(newargs))
			if(AURA_TYPE_THROWN)
				result = aura.hitby(arglist(newargs))
			if(AURA_TYPE_LIFE)
				result = aura.life_tick()
		if(result & AURA_FALSE)
			. = FALSE
		if(result & AURA_CANCEL)
			break


//Handles the effects of "stun" weapons
/mob/living/proc/stun_effect_act(stun_amount, agony_amount, def_zone, used_weapon = null)
	flash_pain()

	if (stun_amount)
		Stun(stun_amount)
		Weaken(stun_amount)
		apply_effect(STUTTER, stun_amount)
		apply_effect(EYE_BLUR, stun_amount)

	if (agony_amount)
		apply_damage(agony_amount, PAIN, def_zone, 0, used_weapon)
		apply_effect(STUTTER, agony_amount/10)
		apply_effect(EYE_BLUR, agony_amount/10)

/mob/living/proc/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0)
	  return 0 //only carbon liveforms have this proc

/mob/living/emp_act(severity)
	var/list/L = src.get_contents()
	for(var/obj/O in L)
		O.emp_act(severity)
	..()

/mob/living/proc/resolve_item_attack(obj/item/I, mob/living/user, target_zone)
	return target_zone

//Called when the mob is hit with an item in combat. Returns the blocked result
/mob/living/proc/hit_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone, atype = 0)
	visible_message("<span class='danger'>[src] has been [I.attack_verb.len? pick(I.attack_verb) : "attacked"] with [I.name] by [user]!</span>")

	var/blocked = run_armor_check(hit_zone, "melee")
	standard_weapon_hit_effects(I, user, effective_force, blocked, hit_zone)

	if(I.damtype == BRUTE && prob(33)) // Added blood for whacking non-humans too
		var/turf/simulated/location = get_turf(src)
		if(istype(location)) location.add_blood_floor(src)

	return blocked

/mob/living/proc/parry_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone)
	return hit_with_weapon(I, user, effective_force, hit_zone)

/mob/living/proc/touch_with_weapon(obj/item/I, mob/living/user, effective_force, hit_zone)
	visible_message("<span class='notice'>[user] touches [src] with [I.name].</span>")

//returns 0 if the effects failed to apply for some reason, 1 otherwise.
/mob/living/proc/standard_weapon_hit_effects(obj/item/I, mob/living/user, effective_force, blocked, hit_zone)
	if(!effective_force || blocked >= 100)
		return 0

	// Hulk modifier
	if(MUTATION_HULK in user.mutations)
		effective_force *= 2

	// STRONG modifier
	if(MUTATION_STRONG in user.mutations)
		effective_force *= 2 // Strong hulks are crazy ngl

	//Apply weapon damage
	var/damage_flags = I.damage_flags()
	if(prob(blocked)) //armour provides a chance to turn sharp/edge weapon attacks into blunt ones
		damage_flags &= ~(DAM_SHARP|DAM_EDGE)

	apply_damage(effective_force, I.damtype, hit_zone, blocked, damage_flags, used_weapon=I)

	return 1

// this proc handles being hit by a thrown atom
/mob/living/hitby(atom/movable/AM, speed = THROWFORCE_SPEED_DIVISOR)// Standardization and logging -Sieve
	if(!aura_check(AURA_TYPE_THROWN, AM, speed))
		return

	if(isobj(AM))
		var/obj/O = AM
		var/dtype = O.damtype
		var/throw_damage = O.throwforce / (speed * THROWFORCE_SPEED_DIVISOR)

		var/miss_chance = 15
		if(O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			miss_chance = max(15 * (distance - 2), 0)

		if(prob(miss_chance))
			visible_message(SPAN("notice", "\The [O] misses [src] narrowly!"))
			return

		visible_message(SPAN("warning", "\The [src] has been hit by \the [O]."))
		play_hitby_sound(AM)

		var/armor = run_armor_check(null, "melee")
		if(armor < 100)
			var/damage_flags = O.damage_flags()
			if(prob(armor))
				damage_flags &= ~(DAM_SHARP|DAM_EDGE)
			apply_damage(throw_damage, dtype, null, armor, damage_flags, O)

		O.throwing = 0		//it hit, so stop moving

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				admin_attack_log(M, src, "Threw \an [O] at the victim.", "Had \an [O] thrown at them.", "threw \an [O] at")

		// Begin BS12 momentum-transfer code.
		var/mass = 1.5
		if(istype(O, /obj/item))
			var/obj/item/I = O
			mass = I.w_class / THROWNOBJ_KNOCKBACK_DIVISOR
		var/momentum = speed * mass

		if(O.throw_source && momentum >= THROWNOBJ_KNOCKBACK_SPEED)
			var/dir = get_dir(O.throw_source, src)

			if(buckled)
				return

			visible_message(SPAN("warning", "\The [src] staggers under the impact!"), SPAN("warning", "You stagger under the impact!"))
			throw_at(get_edge_target_turf(src, dir), 1, (1 / momentum))

			if(!O || !src)
				return

			if(O.sharp) //Projectile is suitable for pinning.
				//Handles embedding for non-humans and simple_animals.
				embed(O)

				var/turf/T = near_wall(dir, 2)

				if(T)
					forceMove(T)
					visible_message(SPAN("warning", "[src] is pinned to the wall by [O]!"), SPAN("warning", "You are pinned to the wall by [O]!"))
					anchored = 1
					pinned += O

/mob/living/play_hitby_sound(atom/movable/AM)
	var/sound_to_play
	if(istype(AM, /obj/item))
		var/obj/item/I = AM
		sound_to_play = I.hitsound
	else if(isliving(AM))
		sound_to_play = SFX_FIGHTING_PUNCH
	if(!sound_to_play)
		return

	var/sound_loudness = rand(65, 85)

	if(isobj(AM))
		var/obj/O = AM
		sound_loudness = min(100, O.w_class * (O.throwforce ? 15 : 5))

	playsound(src, sound_to_play, sound_loudness, 1)

/mob/living/proc/embed(obj/O, def_zone=null, datum/wound/supplied_wound)
	O.forceMove(src)
	src.embedded += O
	grant_verb(src, /mob/proc/yank_out_object)

//This is called when the mob is thrown into a dense turf
/mob/living/proc/turf_collision(turf/T, speed)
	visible_message("<span class='danger'>[src] slams into \the [T]!</span>")
	playsound(loc, 'sound/effects/bangtaper.ogg', 50, 1, -1)
	src.take_organ_damage(speed*2.5)

/mob/living/proc/near_wall(direction,distance=1)
	var/turf/T = get_step(get_turf(src),direction)
	var/turf/last_turf = src.loc
	var/i = 1

	while(i>0 && i<=distance)
		if(!T || T.density) //Turf is a wall or map edge.
			return last_turf
		i++
		last_turf = T
		T = get_step(T,direction)

	return 0

// End BS12 momentum-transfer code.

/mob/living/attack_generic(mob/user, damage, attack_message)

	if(!damage || !istype(user))
		return

	adjustBruteLoss(damage)
	admin_attack_log(user, src, "Attacked", "Was attacked", "attacked")

	src.visible_message("<span class='danger'>[user] has [attack_message] [src]!</span>")
	user.do_attack_animation(src)
	spawn(1) updatehealth()
	return 1

/mob/living/proc/IgniteMob()
	if(fire_stacks > 0 && !on_fire)
		on_fire = 1
		set_light(0.6, 0.1, 4, l_color = COLOR_ORANGE)
		update_fire()

/mob/living/proc/ExtinguishMob()
	if(on_fire)
		on_fire = 0
		fire_stacks = 0
		set_light(0)
		update_fire()

/mob/living/proc/update_fire()
	return

/mob/living/proc/adjust_fire_stacks(add_fire_stacks) //Adjusting the amount of fire_stacks we have on person
	fire_stacks = Clamp(fire_stacks + add_fire_stacks, FIRE_MIN_STACKS, FIRE_MAX_STACKS)

/mob/living/proc/handle_fire()
	if(fire_stacks < 0)
		fire_stacks = min(0, ++fire_stacks) //If we've doused ourselves in water to avoid fire, dry off slowly

	if(!on_fire)
		return 1
	else if(fire_stacks <= 0)
		ExtinguishMob() //Fire's been put out.
		return 1

	fire_stacks = max(0, fire_stacks - 0.1) //I guess the fire runs out of fuel eventually

	var/datum/gas_mixture/G = loc.return_air() // Check if we're standing in an oxygenless environment
	if(G.get_by_flag(XGM_GAS_OXIDIZER) < 1)
		ExtinguishMob() //If there's no oxygen in the tile we're on, put out the fire
		return 1

	var/turf/location = get_turf(src)
	location.hotspot_expose(fire_burn_temperature(), 50, 1)

/mob/living/fire_act(datum/gas_mixture/air, temperature, volume)
	//once our fire_burn_temperature has reached the temperature of the fire that's giving fire_stacks, stop adding them.
	//allow fire_stacks to go up to 4 for fires cooler than 700 K, since are being immersed in flame after all.
	if(fire_stacks <= 4 || fire_burn_temperature() < temperature)
		adjust_fire_stacks(4)
	IgniteMob()

/mob/living/proc/get_cold_protection()
	return 0

/mob/living/proc/get_heat_protection()
	return 0

//Finds the effective temperature that the mob is burning at.
/mob/living/proc/fire_burn_temperature()
	if (fire_stacks <= 0)
		return 0

	//Scale quadratically so that single digit numbers of fire stacks don't burn ridiculously hot.
	//lower limit of 700 K, same as matches and roughly the temperature of a cool flame.
	return max(2.25*round(FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE*(fire_stacks/FIRE_MAX_FIRESUIT_STACKS)**2), 700)

/mob/living/proc/reagent_permeability()
	return 1

/mob/living/proc/handle_actions()
	//Pretty bad, i'd use picked/dropped instead but the parent calls in these are nonexistent
	for(var/datum/action/A in actions)
		if(A.CheckRemoval(src))
			A.Remove(src)
	for(var/obj/item/I in src)
		if(I.action_button_name)
			if(!I.action)
				if(I.action_button_is_hands_free)
					I.action = new /datum/action/item_action/hands_free
				else
					I.action = new /datum/action/item_action
				I.action.name = I.action_button_name
				I.action.target = I
			I.action.Grant(src)
	return

/mob/living/update_action_buttons()
	if(!hud_used) return
	if(!client) return

	client.screen -= hud_used.hide_actions_toggle
	for(var/datum/action/A in actions)
		if(A.button)
			client.screen -= A.button

	if(!hud_used.hud_shown)
		return

	if(hud_used.action_buttons_hidden)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.update_icon()

		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,1)

		client.screen += hud_used.hide_actions_toggle
		return

	var/button_number = 0
	for(var/datum/action/A in actions)
		if(QDELETED(A))
			continue

		button_number++
		if(A.button == null)
			var/atom/movable/screen/movable/action_button/N = new(hud_used)
			N.owner = A
			A.button = N
			A.build_button_icon(N)

		var/atom/movable/screen/movable/action_button/B = A.button

		B.update_icon()

		B.SetName(A.update_button_name(A.button))

		client.screen += B

		if(!B.moved)
			B.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			//hud_used.SetButtonCoords(B,button_number)

	if(button_number > 0)
		if(!hud_used.hide_actions_toggle)
			hud_used.hide_actions_toggle = new(hud_used)
			hud_used.hide_actions_toggle.InitialiseIcon(src)
		if(!hud_used.hide_actions_toggle.moved)
			hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
			//hud_used.SetButtonCoords(hud_used.hide_actions_toggle,button_number+1)
		client.screen += hud_used.hide_actions_toggle

/mob/living/proc/get_evasion()
	var/result = evasion // First we get the 'base' evasion.  Generally this is zero.
	for(var/datum/modifier/M in modifiers)
		if(!isnull(M.evasion))
			result += M.evasion
	return result

/mob/living/proc/calc_rad_resist(radiation_type)
	ASSERT(IS_VALID_RADIATION_TYPE(radiation_type))

	// TODO: Add code
