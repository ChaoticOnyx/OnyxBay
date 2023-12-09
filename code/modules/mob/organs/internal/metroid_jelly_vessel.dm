/obj/item/organ/internal/promethean/metroid_jelly_vessel
	name = "metroid jelly vessel"
	parent_organ = BP_CHEST
	icon_state = "xgibdown1"
	organ_tag = BP_METROID
	var/stored_jelly = 600
	var/max_jelly= 600

/obj/item/organ/internal/promethean/metroid_jelly_vessel/think()
	. = ..()

	var/new_jelly_reagents = owner.reagents.get_reagent_amount(/datum/reagent/metroidjelly)
	owner.reagents.remove_reagent(/datum/reagent/metroidjelly, new_jelly_reagents)
	var/new_jelly_touching = owner.touching.get_reagent_amount(/datum/reagent/metroidjelly)
	owner.touching.remove_reagent(/datum/reagent/metroidjelly, new_jelly_touching)
	add_jelly(new_jelly_touching+new_jelly_reagents)

/obj/item/organ/internal/promethean/metroid_jelly_vessel/proc/add_jelly(new_jelly)
	stored_jelly = clamp((stored_jelly+new_jelly), 0, max_jelly)

/obj/item/organ/internal/promethean/metroid_jelly_vessel/proc/remove_jelly(new_jelly)
	stored_jelly = clamp((stored_jelly-new_jelly), 0, max_jelly)
