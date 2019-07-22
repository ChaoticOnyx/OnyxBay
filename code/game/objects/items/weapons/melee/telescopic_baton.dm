/** Telescopic Baton */
/obj/item/weapon/melee/telebaton
	name = "telescopic baton"
	desc = "A compact yet rebalanced personal defense weapon. Can be concealed when folded."
	icon = 'icons/obj/weapons.dmi'
	icon_state = "telebaton_0"
	item_state = "telebaton_0"
	slot_flags = SLOT_BELT
	w_class = ITEM_SIZE_SMALL
	force = 5.0
	mod_weight = 1.0
	mod_reach = 0.5
	mod_handy = 1.0
	var/on = FALSE

/obj/item/weapon/melee/telebaton/attack_self(mob/user as mob)
	on = !on
	if(on)
		user.visible_message("<span class='warning'>With a flick of their wrist, [user] extends their telescopic baton.</span>",
		"<span class='warning'>You extend the baton.</span>",
		"You hear an ominous click.")
		w_class = ITEM_SIZE_NORMAL
		force = 15 //quite robust
		mod_weight = 1.0
		mod_reach = 1.0
		mod_handy = 1.25
		attack_verb = list("smacked", "struck", "slapped")
	else
		user.visible_message("<span class='notice'>\The [user] collapses their telescopic baton.</span>",
		"<span class='notice'>You collapse the baton.</span>",
		"You hear a click.")
		w_class = ITEM_SIZE_SMALL
		force = 3 //not so robust now
		mod_weight = 0.5
		mod_reach = 0.5
		mod_handy = 1.0
		attack_verb = list("hit", "punched")

	playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
	add_fingerprint(user)
	update_icon()
	update_held_icon()

/obj/item/weapon/melee/telebaton/update_icon()
	if(on)
		icon_state = "telebaton_1"
		item_state = "telebaton_1"
	else
		icon_state = "telebaton_0"
		item_state = "telebaton_0"
	if(length(blood_DNA))
		generate_blood_overlay(TRUE) // Force recheck.
		overlays.Cut()
		overlays += blood_overlay

/obj/item/weapon/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
	if(on)
		if ((MUTATION_CLUMSY in user.mutations) && prob(50))
			to_chat(user, "<span class='warning'>You club yourself over the head.</span>")
			user.Weaken(3 * force)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				H.apply_damage(2*force, BRUTE, BP_HEAD)
			else
				user.take_organ_damage(2*force)
			return
		if(..())
			return
	else
		return ..()
