
/datum/spell/hand/deltoid_magic
	name = "Deltoid Magic"
	desc = "Prepare your deltoid muscle to land a devastating punch."

	feedback = "DM"
	range = 1
	spell_flags = 0

	invocation = "DELTOID! TRICEPS! BRACHIORADIALIS!"
	invocation_type = SPI_SHOUT
	spell_delay = 5 SECONDS
	charge_max = 5 SECONDS
	hand_name_override = "inhuman might"

	icon_state = "wiz_deltoid"
	compatible_targets = list(/mob/living/carbon/human)

/datum/spell/hand/deltoid_magic/cast_hand(mob/living/carbon/human/H, mob/living/carbon/user)
	user.drop(user.get_active_hand())
	user.remove_nutrition(50)

	var/obj/item/organ/external/affecting = H.get_organ(ran_zone(user.zone_sel.selecting))
	if(!affecting || affecting.is_stump())
		to_chat(user, SPAN("danger", "They are missing that limb!"))
		return FALSE

	user.do_attack_animation(H)
	playsound(H.loc, 'sound/effects/bang.ogg', rand(80, 100), 1, -1)

	var/throw_dir = user.dir
	if(user == H)
		throw_dir = turn(get_dir(H, user), 180)
		user.visible_message(SPAN("danger", "[user] has punched the floor, sending themselves flying!"))
	else
		user.visible_message(SPAN("danger", "[user] has punched \the [H] so hard, they're sent flying!"))
		H.apply_damage(rand(20, 40), BRUTE, affecting)
		H.Weaken(8)
		H.Stun(4)
		H.damage_poise(30)

	H.throw_at(get_edge_target_turf(H, throw_dir), 5, 1)


	return TRUE
