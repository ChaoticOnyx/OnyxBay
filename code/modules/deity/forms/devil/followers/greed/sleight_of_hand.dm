/datum/action/cooldown/spell/sleight_of_hand
	name = "Sleight of Hand"
	desc = "Steal a random item from the victim's backpack."
	button_icon_state = "devil_sleight"
	cooldown_time = 1 MINUTE
	click_to_activate = TRUE
	cast_range = 1

/datum/action/cooldown/spell/sleight_of_hand/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on) && (locate(/obj/item/storage/backpack) in cast_on.contents)

/datum/action/cooldown/spell/sleight_of_hand/cast(mob/living/carbon/human/cast_on)
	var/obj/storage_item = locate(/obj/item/storage/backpack) in cast_on.contents

	var/item = safepick(storage_item.contents)
	if(isnull(item))
		return FALSE

	to_chat(cast_on, SPAN_WARNING("Your [storage_item] feels lighter..."))
	to_chat(owner, SPAN_NOTICE("With a blink, you pull [item] out of [cast_on]'s [storage_item]."))
	owner.pick_or_drop(item)
