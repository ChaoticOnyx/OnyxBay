
// These exist for the sole purpose of being placed inside organs as a dirty hack.
/obj/item/reagent_containers/food/organ
	name = "organ"
	desc = "It's good for you."
	icon = 'icons/mob/human_races/organs/human.dmi'
	icon_state = "appendix"
	filling_color = "#e00d34"
	center_of_mass = "x=16;y=16"
	bitesize = 3

/obj/item/reagent_containers/food/organ/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/nutriment/protein, rand(3, 5))
	reagents.add_reagent(/datum/reagent/toxin, rand(1, 3))

/obj/item/reagent_containers/food/organ/brain
	name = "brain"
	desc = "Kuru is real."
	icon_state = "brain2"
	startswith = list(/datum/reagent/alkysine = 4)
