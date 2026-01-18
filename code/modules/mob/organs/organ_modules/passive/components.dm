/obj/item/organ_module/actuators
	name = "Organ actuator"
	icon_state = "ams"
	desc = "A mechanic actuator that fits most prostheses."
	allowed_organs = BP_ALL_LIMBS
	module_type = OM_TYPE_ACTUATOR
	loadout_cost = 0

/obj/item/organ_module/processor
	name = "CPU"
	icon_state = "cpu"
	desc = "Standard processor for prosthetic devices."
	allowed_organs = BP_ALL_LIMBS
	module_type = OM_TYPE_PROCESSOR
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	cpu_power = 2
	cpu_load = 0
	loadout_cost = 0

/obj/item/organ_module/processor/advanced
	name = "Biotech Sigma CPU"
	icon_state = "cpu_adv"
	desc = "Advanced CPU capable of supporting a large number of prosthetic modules."
	cpu_power = 4
	loadout_cost = 8

/obj/item/organ_module/processor/super
	name = "Raven Microcyber MK.3"
	icon_state = "cpu_super"
	desc = "Produced by Raven Biotech corporation, this CPU is considered to be one of the most advanced processors for prosthetics."
	cpu_power = 5
	loadout_cost = 16
