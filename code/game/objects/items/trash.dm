//Items labled as 'trash' for the trash bag.
//TODO: Make this an item var or something...

//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/trash.dmi'
	w_class = ITEM_SIZE_SMALL
	desc = "This is rubbish."
	mod_reach = 0.25
	mod_weight = 0.25
	mod_handy = 0.25

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state = "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state = "candy"

/obj/item/trash/proteinbar
	name = "protein bar"
	desc = "Haven't seen these for a while..."
	icon_state = "proteinbar"

/obj/item/trash/tweakers
	name = "Tweakers bar"
	icon_state = "tweakers"

/obj/item/trash/sweetroid
	name = "Sweetroid bar"
	icon_state = "sweetroid"

/obj/item/trash/sugarmatter
	name = "SugarMatter bar"
	icon_state = "sugarmatter"

/obj/item/trash/jellaws
	name = "Jellaw's Jellybaton"
	icon_state = "jellaws"

/obj/item/trash/nutribar
	name = "nutrition bar"
	icon_state = "nutribar"

/obj/item/trash/cheesie
	name = "\improper Cheesie Honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "syndi cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/waffles
	name = "waffles"
	icon_state = "waffles"

/obj/item/trash/plate
	name = "plate"
	icon_state = "plate"
	w_class = ITEM_SIZE_TINY

/obj/item/trash/plate_in_bag
	name = "plate"
	icon_state = "plate_in_bag"
	w_class = ITEM_SIZE_TINY

/obj/item/trash/snack_bowl
	name = "snack bowl"
	icon_state	= "snack_bowl"

/obj/item/trash/snack_bowl_in_bag
	name = "snack bowl"
	icon_state	= "snack_bowl_in_bag"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"

/obj/item/trash/tray_in_bag
	name = "tray"
	icon_state = "tray_in_bag"

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/liquidfood
	name = "\improper \"LiquidFood\" MRE"
	icon_state = "liquidfood"

/obj/item/trash/tastybread
	name = "bread tube"
	icon_state = "tastybread"

/obj/item/trash/hematogen
	name = "Hema2Gen"
	icon_state = "hema2gen"

/obj/item/trash/pan
	name = "holey pan"
	icon_state = "pan"

/obj/item/trash/skrellsnacks
	name = "\improper SkrellSnax"
	icon_state = "skrellsnacks"

/obj/item/trash/cans
	var/base_state = ""

/obj/item/trash/cans/Initialize()
	. = ..()
	base_state = icon_state
	if(prob(42))
		icon_state = "[base_state]2"
	item_state = base_state

/obj/item/trash/cans/cola
	name = "\improper Space Cola"
	icon_state = "cola"

/obj/item/trash/cans/colavanilla
	name = "\improper Vanilla Space Cola"
	icon_state = "colavanilla"

/obj/item/trash/cans/colacherry
	name = "\improper Cherry Space Cola"
	icon_state = "colacherry"

/obj/item/trash/cans/dopecola
	name = "\improper Dope Cola"
	icon_state = "dopecola"

/obj/item/trash/cans/space_mountain_wind
	name = "\improper Space Mountain Wind"
	icon_state = "space_mountain_wind"

/obj/item/trash/cans/thirteenloko
	name = "\improper Thirteen Loko"
	icon_state = "thirteen_loko"

/obj/item/trash/cans/dr_gibb
	name = "\improper Dr. Gibb"
	icon_state = "dr_gibb"

/obj/item/trash/cans/starkist
	name = "\improper Star-kist"
	icon_state = "starkist"

/obj/item/trash/cans/space_up
	name = "\improper Space-Up"
	icon_state = "space-up"

/obj/item/trash/cans/lemon_lime
	name = "\improper Lemon-Lime"
	icon_state = "lemon-lime"

/obj/item/trash/cans/iced_tea
	name = "\improper Vrisk Serket Iced Tea"
	icon_state = "ice_tea_can"

/obj/item/trash/cans/grape_juice
	name = "\improper Grapel Juice"
	icon_state = "purple_can"

/obj/item/trash/cans/tonic
	name = "\improper T-Borg's Tonic Water"
	icon_state = "tonic"

/obj/item/trash/cans/sodawater
	name = "soda water"
	icon_state = "sodawater"

/obj/item/trash/cans/machpellabeer
	name = "\improper Machpella Dark Beer"
	icon_state = "machpellabeer"

/obj/item/trash/cans/applecider
	name = "\improper MeadBy Apple Cider"
	icon_state = "applecider"

/obj/item/trash/cans/red_mule
	name = "\improper Red MULE"
	icon_state = "red_mule"

/obj/item/trash/attack(mob/M as mob, mob/living/user as mob)
	return
