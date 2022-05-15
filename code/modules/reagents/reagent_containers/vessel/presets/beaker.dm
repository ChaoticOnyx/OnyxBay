///
/// Presets for /obj/item/reagent_containers/vessel/beaker
///

/obj/item/reagent_containers/vessel/beaker/cryoxadone
	name = "cryoxadone beaker"
	desc = "Just put it into the nearest cryocell. Please."
	base_name = "beaker"
	base_desc = "A beaker."
	start_label = "cryoxadone"
	startswith = list(/datum/reagent/cryoxadone = 30)
	override_lid_state = LID_CLOSED

/obj/item/reagent_containers/vessel/beaker/sulphuric
	name = "sulphuric acid beaker"
	desc = "Suphuric acid is used for printing various circuits. Or melting down people's faces."
	base_name = "beaker"
	base_desc = "A beaker."
	start_label = "sulphuric acid"
	startswith = list(/datum/reagent/acid = 60)
	override_lid_state = LID_CLOSED
