
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

	var/datum/spell/CP = new /datum/spell/targeted/equip_item/cream_puff
	user.add_spell(CP)

	var/datum/spell/HS = new /datum/spell/toggled/hamstring_magic
	user.add_spell(HS)

	var/datum/spell/HM = new /datum/spell/targeted/equip_item/cream_puff
	user.add_spell(HM)

	var/datum/spell/DM = new /datum/spell/hand/deltoid_magic
	user.add_spell(DM)

	var/datum/spell/BM = new /datum/spell/hand/biceps_magic
	user.add_spell(BM)

	var/datum/spell/GM = new /datum/spell/gastrocnemius_magic
	user.add_spell(GM)

	if(spellbook)
		user.drop(spellbook)
		qdel(spellbook)
		var/obj/item/reagent_containers/food/cream_puff/CR = new /obj/item/reagent_containers/food/cream_puff(get_turf(user))
		user.pick_or_drop(CR)
	return
