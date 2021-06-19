/obj/item/weapon/nullrod
	name = "null sceptre"
	desc = "A sceptre of pure black obsidian capped at both ends with silver ferrules. Some religious groups claim it disrupts and dampens the powers of paranormal phenomenae."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_BELT
	force = 11.5
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 1.2
	mod_reach = 0.75
	mod_handy = 1.0

/obj/item/weapon/nullrod/attack(mob/M, mob/living/user)
	admin_attack_log(user, M, "Attacked using \a [src]", "Was attacked with \a [src]", "used \a [src] to attack")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	user.do_attack_animation(M)
	if(M.mind && LAZYLEN(M.mind.learned_spells))
		M.silence_spells(300)
		to_chat(M, SPAN_DANGER("You've been silenced!"))
		return

	if(!user.IsAdvancedToolUser())
		to_chat(user, SPAN_WARNING("You don't have the dexterity to do this!"))
		return

	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_DANGER("The rod slips out of your hand and hits your head."))
		user.take_organ_damage(10)
		user.Paralyse(20)
		return

	if(GLOB.cult && iscultist(M))
		M.visible_message(SPAN_NOTICE("\The [user] waves \the [src] over \the [M]'s head."))
		GLOB.cult.remove_antagonist(usr.mind, 1)
		return

	..()

/obj/item/weapon/nullrod/afterattack(atom/A, mob/user, proximity)
	if(!proximity)
		return

	if(istype(A, /turf/simulated/wall/cult))
		var/turf/simulated/wall/cult/W = A
		user.visible_message(SPAN_NOTICE("\The [user] touches \the [A] with \the [src], and the enchantment affecting it fizzles away."),SPAN_NOTICE("You touch \the [A] with \the [src], and the enchantment affecting it fizzles away."))
		W.decultify()

	if(istype(A, /turf/simulated/floor/misc/cult))
		var/turf/simulated/floor/misc/cult/F = A
		user.visible_message(SPAN_NOTICE("\The [user] touches \the [A] with \the [src], and the enchantment affecting it fizzles away."),SPAN_NOTICE("You touch \the [A] with \the [src], and the enchantment affecting it fizzles away."))
		F.decultify()
