
// Grows an arm blade - damage higher than claw's, but lower armorpen
/datum/changeling_power/item/armblade
	name = "Arm Blade"
	desc = "We reform our hand into a deadly arm blade."
	icon_state = "ling_armblade"
	required_chems = 40
	power_item_type = /obj/item/melee/changeling/arm_blade

/datum/changeling_power/item/armblade/activate()
	if(check_incapacitated())
		return

	my_mob.visible_message("<b>[my_mob]</b>'s arm twitches.", \
		SPAN("changeling", "The flesh of our hand is transforming."))

	spawn(4 SECONDS)
		if(!create_item(power_item_type))
			return

		my_mob.visible_message(SPAN("danger", "The flesh is torn around the [my_mob]\'s arm!"), \
							   SPAN("changeling", "We transform our hand into [changeling.recursive_enhancement ? "an extra sharp" : "a"] blade."), \
							   SPAN("italics", "You hear organic matter ripping and tearing!"))

/datum/changeling_power/item/armblade/update_recursive_enhancement()
	if(..())
		power_item_type = /obj/item/melee/changeling/arm_blade/greater
	else
		power_item_type = /obj/item/melee/changeling/arm_blade
