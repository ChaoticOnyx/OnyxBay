
/datum/wizard_class/musclemancer
	name = "Athlete"
	feedback_tag = "MM"
	description = "Your proficiency in the art of spellcasting is comparable to that of a cream puff's. But you've spent years hitting the gym."
	icon_state = "muscle_tome"
	points = 0
	can_make_contracts = FALSE

	spells = list() // Yes
	artifacts = list() // For real

/datum/wizard_class/musclemancer/on_class_chosen(mob/user, obj/item/spellbook)
	to_chat(user, SPAN("notice", "Suddenly, you realize you've never ever gotten your own spell book. What you've been holding is just a cream puff."))

	user.add_mutation(MUTATION_STRONG)
	user.update_mutations()

	var/datum/spell/new_spell = new /datum/spell/targeted/equip_item/cream_puff
	user.add_spell(new_spell)

	if(spellbook)
		user.drop(spellbook)
		qdel(spellbook)
		var/obj/item/reagent_containers/food/cream_puff/CR = new /obj/item/reagent_containers/food/cream_puff(get_turf(user))
		user.pick_or_drop(CR)
	return
