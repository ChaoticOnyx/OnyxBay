
//Emag-lite
/mob/proc/changeling_electric_lockpick()
	set category = "Changeling"
	set name = "Electric Lockpick (5 + 10/use)"
	set desc = "Bruteforces open most electrical locking systems, at 10 chemicals per use."

	if(is_regenerating())
		return

	var/datum/changeling/changeling = changeling_power(5)
	if(!changeling)
		return FALSE

	var/obj/held_item = get_active_hand()

	if(held_item == null)
		if(changeling_generic_weapon(/obj/item/weapon/finger_lockpick,FALSE,5))  //Chemical cost is handled in the equip proc.
			return TRUE
		return FALSE
