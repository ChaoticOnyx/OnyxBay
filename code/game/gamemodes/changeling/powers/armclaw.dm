
// Grows a claw - armorpen higher than blade's, but lower damage
/datum/changeling_power/item/claw
	name = "Claw"
	desc = "We reform our hand into a deadly claw."
	icon_state = "ling_claw"
	required_chems = 30
	power_item_type = /obj/item/melee/changeling/claw

/datum/changeling_power/item/claw/activate()
	if(check_incapacitated())
		return

	if(!create_item(power_item_type))
		return

	my_mob.visible_message(SPAN("danger", "[my_mob]\'s arm twists horribly as sharpened bones grow through flesh!"), \
						   SPAN("changeling", "We transform our hand into [changeling.recursive_enhancement ? "an extra sharp" : "a"] claw."), \
						   SPAN("italics", "You hear organic matter ripping and tearing!"))

/datum/changeling_power/item/claw/update_recursive_enhancement()
	if(..())
		power_item_type = /obj/item/melee/changeling/claw/greater
	else
		power_item_type = /obj/item/melee/changeling/claw

