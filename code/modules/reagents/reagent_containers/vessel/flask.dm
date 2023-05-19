
/obj/item/reagent_containers/vessel/flask
	name = "\improper Captain's flask"
	desc = "A metal flask belonging to the captain."
	icon_state = "flask"
	force = 6.0
	mod_weight = 0.65
	mod_reach = 0.25
	mod_handy = 0.5
	volume = 60
	center_of_mass = "x=17;y=7"
	lid_type = /datum/vessel_lid/flask

/obj/item/reagent_containers/vessel/flask/shiny
	name = "shiny flask"
	desc = "A shiny metal flask. It appears to have a Greek symbol inscribed on it."
	icon_state = "shinyflask"

/obj/item/reagent_containers/vessel/flask/lithium
	name = "lithium flask"
	desc = "A flask with a Lithium Atom symbol on it."
	icon_state = "lithiumflask"

/obj/item/reagent_containers/vessel/flask/detflask
	name = "\improper Detective's flask"
	desc = "A metal flask with a leather band and golden badge belonging to the detective."
	icon_state = "detflask"
	volume = 60
	center_of_mass = "x=17;y=8"

/obj/item/reagent_containers/vessel/flask/barflask
	name = "flask"
	desc = "For those who can't be bothered to hang out at the bar to drink."
	icon_state = "barflask"
	volume = 60
	center_of_mass = "x=17;y=7"

/obj/item/reagent_containers/vessel/flask/vacuumflask
	name = "vacuum flask"
	desc = "Keeping your drinks at the perfect temperature since 1892."
	icon_state = "vacuumflask"
	volume = 60
	center_of_mass = "x=15;y=4"
	lid_type = /datum/vessel_lid/cap
	override_lid_state = LID_CLOSED
