// eliza's attempt at a new vending machine
/obj/machinery/vending/games
	name = "Good Clean Fun"
	desc = "Vends things that the CO and SEA are probably not going to appreciate you fiddling with instead of your job..."

	icon = 'icons/obj/machines/vending/games.dmi'
	icon_state = "games"
	light_color = "#57FFE4"

	vend_delay = 15
	product_slogans = "Escape to a fantasy world!;Fuel your gambling addiction!;Ruin your friendships!"
	product_ads = "Elves and dwarves!;Totally not satanic!;Fun times forever!"

	vending_sound = SFX_VENDING_GENERIC

	component_types = list(
		/obj/item/vending_cartridge/games
		)

	legal = list(
		/obj/item/toy/blink = 5,
		/obj/item/toy/spinningtoy = 2,
		/obj/item/deck/cards = 5,
		/obj/item/deck/tarot = 5,
		/obj/item/pack/cardemon = 6,
		/obj/item/pack/spaceball = 6,
		/obj/item/storage/pill_bottle/dice_nerd = 5,
		/obj/item/storage/pill_bottle/dice = 5,
		/obj/item/storage/box/checkers = 2,
		/obj/item/storage/box/checkers/chess/red = 2,
		/obj/item/storage/box/checkers/chess = 2,
		/obj/item/plant_pot = 5,
		/obj/item/pottable_plant_gacha = 10
		)

	illegal = list(
		/obj/item/reagent_containers/spray/waterflower = 2,
		/obj/item/storage/box/snappops = 3,
		/obj/item/gun/energy/laser/practice = 1
		)

	premium = list(
		/obj/item/gun/projectile/revolver/capgun = 1,
		/obj/item/ammo_magazine/caps = 4,
		/obj/item/toy/pig = 1
		)

	prices = list(
		/obj/item/toy/blink = 3,
		/obj/item/toy/spinningtoy = 10,
		/obj/item/deck/tarot = 3,
		/obj/item/deck/cards = 3,
		/obj/item/pack/cardemon = 5,
		/obj/item/pack/spaceball = 5,
		/obj/item/storage/pill_bottle/dice_nerd = 6,
		/obj/item/storage/pill_bottle/dice = 6,
		/obj/item/storage/box/checkers = 10,
		/obj/item/storage/box/checkers/chess/red = 10,
		/obj/item/storage/box/checkers/chess = 10,
		/obj/item/plant_pot = 10,
		/obj/item/pottable_plant_gacha = 10
		)

/obj/item/vending_cartridge/games
	icon_state = "refill_games"
	build_path = /obj/machinery/vending/games
