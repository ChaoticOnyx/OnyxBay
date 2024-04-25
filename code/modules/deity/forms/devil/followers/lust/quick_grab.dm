/datum/action/cooldown/spell/quickgrab
	name = "Quick Grab"
	desc = "Lusty hands tee hee!!!"
	button_icon_state = "devil_grab"
	cooldown_time = 30 SECONDS
	cast_range = 2
	click_to_activate = TRUE

/datum/action/cooldown/spell/quickgrab/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/quickgrab/cast(mob/living/carbon/human/cast_on)
	var/mob/living/carbon/human/human_owner = owner
	if(!istype(human_owner))
		return

	human_owner.drop(human_owner.get_active_hand())

	var/saved_zone_sel = human_owner.zone_sel.selecting
	human_owner.zone_sel.selecting = BP_HEAD
	human_owner.make_grab(human_owner, cast_on, GRAB_QUICKCHOKE)
	human_owner.zone_sel.selecting = saved_zone_sel

	cast_on.damage_poise(25)

	to_chat(cast_on, SPAN("warning", "You are firmly grabbed by \the [human_owner]!"))
