/obj/structure/barricade
	name = "protocade"
	desc = "This thing is technical. The fuck you seeing it in game? Report to devs!1"

	anchored = TRUE
	density = TRUE

	/// Amount of points taken by an object.
	var/damage = 0
	/// Maximum amount of object's damage points till it breaks apart.
	var/maxdamage = 100


/obj/structure/barricade/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H))
			attack_generic(H, rand(7.5, 12.5), "shreds")
			user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

			attack_animation(user)
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			return

		attack_generic(H, rand(7.5, 12.5), "smashes")
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

		attack_animation(user)
		playsound(loc, 'sound/effects/grillehit.ogg', 80, 1)
		return

	return ..()


/obj/structure/barricade/attackby(obj/item/W, mob/user)
	if(W.force && user.a_intent == I_HURT)
		attack_generic(user, W.force, "")
		user.setClickCooldown(W.update_attack_cooldown())

		attack_animation(user)
		obj_attack_sound(W)
		return

	return ..()


/obj/structure/barricade/attack_generic(mob/user, damage, attack_verb, wallbreaker)
	visible_message(SPAN("danger", "[user] [attack_verb] \the [src]!"))
	take_damage(damage)


/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			take_damage(maxdamage * 0.7)
		if(EXPLODE_LIGHT)
			take_damage(maxdamage * 0.4)


/obj/structure/barricade/proc/take_damage(amount)
	damage = clamp(damage + amount, 0, maxdamage)

	if(damage == maxdamage)
		Break()
		qdel(src)


/obj/structure/barricade/proc/Break()
	pass()


/obj/structure/barricade/security/CanPass(atom/movable/mover, turf/target)
	// Extra check that allows bullets to pass through.
	if(mover?.pass_flags & PASS_FLAG_TABLE)
		return TRUE

	return FALSE
