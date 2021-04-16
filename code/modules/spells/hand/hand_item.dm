/*much like grab this item is used primarily for the utility it provides.
Basically: I can use it to target things where I click. I can then pass these targets to a spell and target things not using a list.
*/

/obj/item/magic_hand
	name = "Magic Hand"
	icon = 'icons/mob/screen1.dmi'
	atom_flags = 0
	item_flags = 0
	obj_flags = 0
	simulated = 0
	icon_state = "spell"
	var/next_spell_time = 0
	var/spell/hand/hand_spell

/obj/item/magic_hand/New(spell/hand/S)
	hand_spell = S
	name = "[name] ([S.name])"
	icon_state = S.hand_state

/obj/item/magic_hand/get_storage_cost()
	return ITEM_SIZE_NO_CONTAINER

/obj/item/magic_hand/attack(mob/living/M, mob/living/user)
	if(hand_spell && hand_spell.valid_target(M, user))
		if(hand_spell.spell_cast_delay)
			if(do_after(user, hand_spell.spell_cast_delay, M))
				fire_spell(M, user)
				return 0
			else
				return 1
		else
			fire_spell(M, user)
			return 0
	return 1

/obj/item/magic_hand/proc/fire_spell(atom/A, mob/living/user)
	if(!hand_spell) //no spell? Die.
		user.drop_from_inventory(src)

	if(!hand_spell.valid_target(A,user))
		return
	if(world.time < next_spell_time)
		to_chat(user, "<span class='warning'>The spell isn't ready yet!</span>")
		return

	if(hand_spell.show_message)
		user.visible_message("\The [user][hand_spell.show_message]")
	if(hand_spell.cast_hand(A,user))
		next_spell_time = world.time + hand_spell.spell_delay
		if(hand_spell.move_delay)
			user.addMoveCooldown(hand_spell.move_delay)
		if(hand_spell.click_delay)
			user.setClickCooldown(hand_spell.click_delay)
	else
		user.drop_from_inventory(src)

/obj/item/magic_hand/afterattack(atom/A, mob/user, proximity)
	if(hand_spell)
		fire_spell(A,user)

/obj/item/magic_hand/throw_at() //no throwing pls
	usr.drop_from_inventory(src)

/obj/item/magic_hand/dropped() //gets deleted on drop
	..()
	loc = null
	qdel(src)

/obj/item/magic_hand/Destroy() //better save than sorry.
	hand_spell = null
	..()

/obj/item/magic_hand/control_hand
	icon_state = "domination_spell"
	list/instructions
	var/spell/hand/mind_control/mind_spell

/obj/item/magic_hand/control_hand/attack_self(mob/user)
	. = ..()
	mind_spell.interact(user)

/obj/item/magic_hand/control_hand/New(spell/hand/S)
	hand_spell = S
	mind_spell = S
	name = "[name] ([S.name])"
	icon_state = S.hand_state
