
/obj/item/reagent_containers/vessel/beaker
	name = "beaker"
	desc = "A beaker."
	icon = 'icons/obj/reagent_containers/chemical.dmi'
	icon_state = "beaker"
	item_state = "beaker"
	center_of_mass = "x=17;y=10"
	force = 5.0
	mod_weight = 0.5
	mod_reach = 0.25
	mod_handy = 0.45
	matter = list(MATERIAL_GLASS = 2500)
	brittle = TRUE
	precise_measurement = TRUE
	filling_states = "5;10;25;50;75;80;100"
	label_icon = TRUE
	overlay_icon = TRUE
	lid_type = /datum/vessel_lid/lid
	drop_sound = SFX_DROP_HELMET
	pickup_sound = SFX_PICKUP_HELMET

	rad_resist_type = /datum/rad_resist/beaker_large

/datum/rad_resist/beaker_large
	alpha_particle_resist = 11.8 MEGA ELECTRONVOLT
	beta_particle_resist = 0.8 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/reagent_containers/vessel/beaker/large
	name = "large beaker"
	desc = "A large beaker."
	icon_state = "beakerlarge"
	center_of_mass = "x=17;y=10"
	force = 6.5
	mod_weight = 0.65
	mod_reach = 0.3
	mod_handy = 0.45
	matter = list(MATERIAL_GLASS = 5000)
	volume = 120
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60;120"
	override_lid_state = LID_OPEN

/obj/item/reagent_containers/vessel/beaker/large/get_storage_cost()
	return ..() * 1.5

/obj/item/reagent_containers/vessel/beaker/plass
	name = "plass beaker"
	desc = "A beaker made of plass, it doesn't allow radiation to pass through."
	icon_state = "plass_beaker"
	matter = list(MATERIAL_PLASS = 2500)
	brittle = FALSE // Plass be strong
	rad_resist_type = /datum/rad_resist/beaker_plass

/datum/rad_resist/beaker_plass
	alpha_particle_resist = 48 MEGA ELECTRONVOLT
	beta_particle_resist = 22.2 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT

/obj/item/reagent_containers/vessel/beaker/noreact
	name = "cryostasis beaker"
	desc = "A cryostasis beaker that allows for chemical storage without reactions."
	icon_state = "beakernoreact"
	center_of_mass = "x=17;y=10"
	matter = list(MATERIAL_GLASS = 2500)
	brittle = FALSE
	volume = 60
	amount_per_transfer_from_this = 10
	atom_flags = ATOM_FLAG_NO_REACT
	override_lid_state = LID_OPEN


/obj/item/reagent_containers/vessel/beaker/bluespace
	name = "bluespace beaker"
	desc = "A bluespace beaker, powered by experimental bluespace technology."
	icon_state = "beakerbluespace"
	center_of_mass = "x=17;y=10"
	force = 6.5
	mod_weight = 0.65
	mod_reach = 0.3
	mod_handy = 0.45
	matter = list(MATERIAL_STEEL = 1000, MATERIAL_GLASS = 5000)
	brittle = FALSE
	volume = 300
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;25;30;60;120;150;200;250;300"
	override_lid_state = LID_OPEN

/obj/item/reagent_containers/vessel/beaker/vial
	name = "vial"
	desc = "A small glass vial."
	icon_state = "vial"
	center_of_mass = "x=16;y=10"
	force = 2.5
	mod_weight = 0.35
	mod_reach = 0.2
	mod_handy = 0.4
	matter = list(MATERIAL_GLASS = 1250)
	volume = 30
	w_class = ITEM_SIZE_TINY //half the volume of a bottle, half the size
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;15;30"
	override_lid_state = LID_OPEN
	lid_type = /datum/vessel_lid/cork
