
/datum/spell/hand/biceps_magic
	name = "Biceps Magic"
	desc = "Use biceps to strangle someone unconscious quickly."

	feedback = "BM"
	range = 1
	spell_flags = 0

	invocation = "BICEPS BRACHII!"
	invocation_type = SPI_SHOUT
	spell_delay = 5 SECONDS
	charge_max = 5 SECONDS
	hand_name_override = "sheer muscular power"

	icon_state = "wiz_biceps"
	compatible_targets = list(/mob/living/carbon/human)

/datum/spell/hand/biceps_magic/cast_hand(mob/living/carbon/human/H, mob/living/carbon/human/user)
	user.drop(user.get_active_hand())
	user.remove_nutrition(50)

	var/saved_zone_sel = user.zone_sel.selecting
	user.zone_sel.selecting = BP_HEAD
	user.make_grab(user, H, GRAB_QUICKCHOKE)
	user.zone_sel.selecting = saved_zone_sel

	H.damage_poise(25)

	to_chat(H, SPAN("warning", "It looks like you're in trouble."))
	return TRUE
