/datum/wizard
	/// An instance of /datum/wizard_class.
	/// Not intedend to change instance's values.
	var/datum/wizard_class/class = null
	/// Points that a wizard spends to buy artifacts or spells.
	var/points = 0
	var/can_reset_class = TRUE
	var/mob/living/lich = null //Variable used for necromancers to store reference to their lich
	var/list/thralls = list()

/datum/wizard/proc/reset()
	class = null
	points = 0
	can_reset_class = FALSE

/datum/wizard/proc/set_class(datum/wizard_class/path)
	class = GLOB.wizard_classes["[path]"]
	points = class.points
	feedback_add_details("wizard_class_selected", class.feedback_tag)

/datum/wizard/proc/spend(cost)
	points -= cost

/datum/wizard/proc/can_spend(cost)
	if(points - cost < 0)
		return FALSE

	return TRUE

/datum/wizard/proc/escape_to_lich(datum/mind/necromancer)
	if(!isliving(lich))
		to_chat(necromancer, SPAN_DANGER("Your lich is dead, all hope is lost..."))
		return

	if(MUTATION_SKELETON in lich.mutations)
		lich.mutations.Remove(MUTATION_SKELETON)
	to_chat(lich, SPAN_DANGER("You fell something bizarre, as if your mind is being sucked from your head!"))
	to_chat(lich, SPAN_DANGER("You scream in dismay, realizing that your master is going to take over your body!"))
	lich.spellremove()
	lich.ghostize()
	necromancer.transfer_to(lich)
	to_chat(necromancer, SPAN_DANGER("Your old body is gone, yet your counsciousness continues to live on in your lich!"))

/datum/wizard/Destroy()
	lich = null
	thralls.Cut()
	return ..()
