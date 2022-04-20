
// Emag-lite
/datum/changeling_power/item/lockpick
	name = "Bioelectric Lockpick"
	desc = "Bruteforces open most electrical locking systems, consuming 20 chemicals per use."
	icon_state = "ling_lockpick"
	required_chems = 10
	power_item_type = /obj/item/finger_lockpick
	var/last_time_used = 0
	var/fingerpick_cost = 20
	var/fingerpick_cooldown = 10 SECONDS

/datum/changeling_power/item/lockpick/activate()
	if(check_incapacitated())
		return
	create_item(power_item_type, FALSE)
