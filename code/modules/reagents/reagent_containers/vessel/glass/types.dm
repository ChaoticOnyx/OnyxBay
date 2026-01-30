
// Shot - 5u
/obj/item/reagent_containers/vessel/glass/shot
	name = "shot glass"
	icon_state = "shot_preview"
	base_name = "shot"
	base_icon = "shot"
	filling_states = "5"
	force = 3.0
	matter = list(MATERIAL_GLASS = 15)
	w_class = ITEM_SIZE_TINY

	volume = 5
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5"

	rim_pos = "y=17;x_left=13;x_right=21"

/obj/item/reagent_containers/vessel/glass/shot/get_storage_cost()
	return ..() * 1.5

// Ryumka - 5u
/obj/item/reagent_containers/vessel/glass/vodkaglass
	name = "rumka"
	icon_state = "vodka_preview"
	base_name = "rumka"
	base_icon = "vodka"
	filling_states = "33;66;100"
	force = 3.0
	matter = list(MATERIAL_GLASS = 15)
	w_class = ITEM_SIZE_TINY

	volume = 5
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5"

	rim_pos = "y=21;x_left=14;x_right=21"

/obj/item/reagent_containers/vessel/glass/vodkaglass/get_storage_cost()
	return ..() * 1.5

// Double Shot - 10u
/obj/item/reagent_containers/vessel/glass/dshot
	name = "double shot"
	icon_state = "dshot_preview"
	base_name = "double shot"
	base_icon = "dshot"
	filling_states = "33;66;100"
	force = 3.0
	w_class = ITEM_SIZE_TINY

	volume = 10
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10"

	rim_pos = "y=21;x_left=14;x_right=20"

/obj/item/reagent_containers/vessel/glass/dshot/get_storage_cost()
	return ..() * 1.5

// Cocktail glass - 20u
/obj/item/reagent_containers/vessel/glass/cocktail
	name = "cocktail glass"
	icon_state = "cocktail_preview"
	base_name = "glass"
	base_icon = "cocktail"
	filling_states = "33;66;100"

	volume = 0.2 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;20"

	rim_pos = "y=22;x_left=13;x_right=21"

// Wine glass - 25u
/obj/item/reagent_containers/vessel/glass/wine
	name = "wine glass"
	icon_state = "wine_preview"
	base_name = "glass"
	base_icon = "wine"
	filling_states = "20;40;60;80;100"

	volume = 0.25 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;25"

	rim_pos = "y=25;x_left=12;x_right=21"

// Cognac glass - 25u
/obj/item/reagent_containers/vessel/glass/cognac
	name = "cognac glass"
	icon_state = "cognac_preview"
	base_name = "glass"
	base_icon = "cognac"
	filling_states = "20;40;60;80;100"

	volume = 0.25 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;25"

	rim_pos = "y=22;x_left=13;x_right=20"

// Half-pint glass - 25u
/obj/item/reagent_containers/vessel/glass/square
	name = "half-pint glass"
	icon_state = "square_preview"
	item_state = "glass_clear"
	base_name = "glass"
	base_icon = "square"
	desc = "Your standard drinking glass."
	filling_states = "20;40;60;80;100"

	volume = 0.25 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;25"

	rim_pos = "y=23;x_left=13;x_right=20"

// Rocks glass - 30u
/obj/item/reagent_containers/vessel/glass/rocks
	name = "rocks glass"
	icon_state = "rocks_preview"
	base_name = "glass"
	base_icon = "rocks"
	filling_states = "25;50;75;100"

	volume = 0.3 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;20;30"

	rim_pos = "y=21;x_left=10;x_right=23"

// Shake glass - 35u
/obj/item/reagent_containers/vessel/glass/shake
	name = "tall cocktail glass"
	icon_state = "shake_preview"
	base_name = "glass"
	base_icon = "shake"
	filling_states = "25;50;75;100"

	volume = 0.35 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;20;35"

	rim_pos = "y=25;x_left=13;x_right=21"

// Hurricane glass - 35u
/obj/item/reagent_containers/vessel/glass/hurricane
	name = "hurricane glass"
	icon_state = "hurricane_preview"
	base_name = "glass"
	base_icon = "hurricane"
	filling_states = "20;40;60;80;100"

	volume = 0.35 LITERS
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = "5;10;20;35"

	rim_pos = "y=25;x_left=13;x_right=20"

// Pint glass - 50u
/obj/item/reagent_containers/vessel/glass/pint
	name = "pint glass"
	icon_state = "pint_preview"
	base_name = "pint"
	base_icon = "pint"
	filling_states = "16;33;50;66;83;100"
	force = 6.0
	mod_weight = 0.55
	mod_reach = 0.25
	mod_handy = 0.65
	smash_weaken = 2

	volume = 0.5 LITERS
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;20;25;50"

	rim_pos = "y=25;x_left=12;x_right=21"

/obj/item/reagent_containers/vessel/glass/pint/get_storage_cost()
	return ..() * 1.5

// Beer mug - 60u
/obj/item/reagent_containers/vessel/glass/mug
	name = "glass mug"
	icon_state = "mug_preview"
	base_name = "mug"
	base_icon = "mug"
	filling_states = "25;50;75;100"
	force = 7.0
	mod_weight = 0.6
	mod_reach = 0.25
	mod_handy = 0.65
	smash_weaken = 3

	volume = 0.6 LITERS
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = "5;10;20;25;50;60"

	rim_pos = "y=22;x_left=12;x_right=20"

/obj/item/reagent_containers/vessel/glass/mug/get_storage_cost()
	return ..() * 1.5

// Dwarf mug - 100u
/obj/item/reagent_containers/vessel/glass/bigmug
	name = "large mug"
	icon_state = "bigmug"
	base_name = "big mug"
	base_icon = "bigmug"
	filling_states = "50;100"
	force = 7.5
	mod_weight = 0.6
	mod_reach = 0.25
	mod_handy = 0.65

	volume = 100
	amount_per_transfer_from_this = 20
	possible_transfer_amounts = "5;10;20;25;50;60;100"

	rim_pos = "y=22;x_left=12;x_right=20"
	brittle = FALSE

/obj/item/reagent_containers/vessel/glass/bigmug/get_storage_cost()
	return ..() * 1.5

// Carafe - 180u
/obj/item/reagent_containers/vessel/glass/carafe
	name = "carafe"
	icon_state = "carafe_preview"
	base_name = "carafe"
	base_icon = "carafe"
	filling_states = "10;20;30;40;50;60;70;80;90;100"
	force = 8.5
	mod_weight = 0.75
	mod_reach = 0.5
	mod_handy = 0.75
	smash_weaken = 5
	matter = list(MATERIAL_GLASS = 250)
	w_class = ITEM_SIZE_NORMAL

	volume = 180
	amount_per_transfer_from_this = 25
	possible_transfer_amounts = "5;10;20;25;50;60;100;120;180"

	rim_pos = "y=26;x_left=12;x_right=21"
	center_of_mass = "x=16;y=7"
