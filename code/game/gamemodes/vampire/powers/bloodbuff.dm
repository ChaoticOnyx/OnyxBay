/datum/vampire_power/toggled/blood_buff
	name = "Blood Buff"
	desc = "Increases your strength imbued with the Power of the Veil."

	blood_cost = 5
	blood_drain = 3

	text_activate = "You became much more stronger."
	text_deactivate = "You are no longer that strong."
	text_noblood = "You are no longer that strong because you run out of blood."

/datum/vampire_power/toggled/blood_buff/activate()
	if(!..())
		return
	my_mob.add_mutation(MUTATION_STRONG)
	my_mob.update_mutations()
	my_mob.visible_message(SPAN("danger", "A dark aura manifests itself around [my_mob], their eyes turning red and their composure changing to be more beast-like."))
	for(var/datum/power/vampire/P in vampirepowers)
		if(P.name == "Grapple")
			vampire.add_power(P)
			break

/datum/vampire_power/toggled/blood_buff/deactivate(no_message = TRUE)
	if(!..())
		return
	my_mob.remove_mutation(MUTATION_STRONG)
	my_mob.update_mutations()
	my_mob.visible_message(SPAN("danger", "[my_mob]'s eyes no longer glow with violent rage, their form reverting to resemble that of a normal person's."))
	for(var/datum/power/vampire/P in vampirepowers)
		if(P.name == "Grapple")
			vampire.remove_power(P)
			break
	my_mob.regenerate_icons()
