/obj/random
	name = "random object"
	desc = "This item type is used to spawn random objects at round-start."
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "landmark_unique_gray"
	alpha = 128
	var/spawn_nothing_percentage = 0 // this variable determines the likelyhood that this random object will not spawn anything

	var/spawn_method = /obj/random/proc/spawn_item

// creates a new object and deletes itself
/obj/random/Initialize()
	..()
	call(src, spawn_method)()
	return INITIALIZE_HINT_QDEL

// creates the random item
/obj/random/proc/spawn_item()
	if(prob(spawn_nothing_percentage))
		return

	if(isnull(loc))
		return

	var/build_path = pickweight(spawn_choices())

	var/atom/A = new build_path(src.loc)
	if(pixel_x || pixel_y)
		A.pixel_x = pixel_x
		A.pixel_y = pixel_y

// Returns an associative list in format path:weight
/obj/random/proc/spawn_choices()
	return list()

/obj/random/single
	name = "randomly spawned object"
	desc = "This item type is used to randomly spawn a given object at round-start."
	icon_state = "landmark_unique_gray"
	var/spawn_object = null

/obj/random/single/spawn_choices()
	return list(ispath(spawn_object) ? spawn_object : text2path(spawn_object))

/obj/random/tool
	name = "random tool"
	desc = "This is a random tool."
	icon_state = "landmark_tool"

/obj/random/tool/spawn_choices()
	return list(/obj/item/screwdriver,
				/obj/item/wirecutters,
				/obj/item/weldingtool,
				/obj/item/weldingtool/largetank,
				/obj/item/crowbar,
				/obj/item/wrench,
				/obj/item/device/flashlight)

/obj/random/technology_scanner
	name = "random scanner"
	desc = "This is a random technology scanner."
	icon_state = "landmark_scanner"

/obj/random/technology_scanner/spawn_choices()
	return list(/obj/item/device/t_scanner = 10,
				/obj/item/device/radio = 5,
				/obj/item/device/analyzer = 10,
				/obj/item/device/geiger = 5,
				/obj/item/device/analyzer/plant_analyzer = 1,
				/obj/item/device/mass_spectrometer = 1,
				/obj/item/device/reagent_scanner = 1,
				/obj/item/device/robotanalyzer = 1)

/obj/random/powercell
	name = "random powercell"
	desc = "This is a random powercell."
	icon_state = "landmark_cell"

/obj/random/powercell/spawn_choices()
	return list(/obj/item/cell/crap = 2,
				/obj/item/cell/apc = 7,
				/obj/item/cell = 15,
				/obj/item/cell/high = 7,
				/obj/item/cell/super = 3,
				/obj/item/cell/hyper = 1,
				/obj/item/cell/device/standard = 10,
				/obj/item/cell/device/high = 5)

/obj/random/bomb_supply
	name = "bomb supply"
	desc = "This is a random bomb supply."
	icon_state = "landmark_bomb"

/obj/random/bomb_supply/spawn_choices()
	return list(/obj/item/device/assembly/igniter,
				/obj/item/device/assembly/prox_sensor,
				/obj/item/device/assembly/signaler,
				/obj/item/device/assembly/timer,
				/obj/item/device/multitool)

/obj/random/toolbox
	name = "random toolbox"
	desc = "This is a random toolbox."
	icon_state = "landmark_box"
	spawn_nothing_percentage = 40

/obj/random/toolbox/spawn_choices()
	return list(/obj/item/storage/toolbox/mechanical = 40,
				/obj/item/storage/toolbox/electrical = 30,
				/obj/item/storage/toolbox/emergency = 30,
				/obj/item/storage/toolbox/syndicate = 1)

/obj/random/tech_supply
	name = "random tech supply"
	desc = "This is a random piece of technology supplies."
	icon_state = "landmark_tech"
	spawn_nothing_percentage = 50

/obj/random/tech_supply/spawn_choices()
	return list(/obj/random/powercell = 3,
				/obj/random/technology_scanner = 2,
				/obj/item/packageWrap = 1,
				/obj/item/hand_labeler = 1,
				/obj/random/bomb_supply = 2,
				/obj/item/extinguisher = 1,
				/obj/item/clothing/gloves/insulated/cheap = 1,
				/obj/item/stack/cable_coil/random = 2,
				/obj/random/toolbox = 2,
				/obj/item/storage/belt/utility = 2,
				/obj/item/storage/belt/utility/atmostech = 1,
				/obj/random/tool = 5,
				/obj/item/tape_roll = 2)

/obj/random/medical
	name = "random medical equipment"
	desc = "This is a random medical item."
	icon_state = "landmark_supply"
	spawn_nothing_percentage = 25

/obj/random/medical/spawn_choices()
	return list(/obj/random/medical/lite = 21,
				/obj/item/bodybag = 2,
				/obj/item/reagent_containers/vessel/bottle/chemical/inaprovaline = 2,
				/obj/item/reagent_containers/vessel/bottle/chemical/antitoxin = 2,
				/obj/item/storage/pill_bottle = 2,
				/obj/item/storage/pill_bottle/tramadol = 1,
				/obj/item/storage/pill_bottle/citalopram = 2,
				/obj/item/storage/pill_bottle/dexalin_plus = 1,
				/obj/item/storage/pill_bottle/dermaline = 1,
				/obj/item/storage/pill_bottle/bicaridine = 1,
				/obj/item/reagent_containers/syringe/antitoxin/packaged = 2,
				/obj/item/reagent_containers/syringe/antiviral/packaged = 1,
				/obj/item/reagent_containers/syringe/inaprovaline/packaged = 2,
				/obj/item/storage/box/freezer = 1,
				/obj/item/stack/nanopaste = 1)

/obj/random/medical/lite
	name = "random medicine"
	desc = "This is a random simple medical item."
	icon_state = "landmark_supply"
	spawn_nothing_percentage = 25

/obj/random/medical/lite/spawn_choices()
	return list(/obj/item/stack/medical/bruise_pack = 4,
				/obj/item/stack/medical/ointment = 4,
				/obj/item/storage/pill_bottle/antidexafen = 2,
				/obj/item/storage/pill_bottle/paracetamol = 2,
				/obj/item/stack/medical/advanced/bruise_pack = 2,
				/obj/item/stack/medical/advanced/ointment = 2,
				/obj/item/stack/medical/splint = 1,
				/obj/item/bodybag/cryobag = 1,
				/obj/item/storage/pill_bottle/kelotane = 2,
				/obj/item/storage/pill_bottle/dylovene = 2)

/obj/random/firstaid
	name = "random first aid kit"
	desc = "This is a random first aid kit."
	icon_state = "landmark_supply"
	spawn_nothing_percentage = 50

/obj/random/firstaid/spawn_choices()
	return list(/obj/item/storage/firstaid/regular = 10,
				/obj/item/storage/firstaid/toxin = 6,
				/obj/item/storage/firstaid/o2 = 6,
				/obj/item/storage/firstaid/adv = 3,
				/obj/item/storage/firstaid/combat = 1,
				/obj/item/storage/firstaid = 6,
				/obj/item/storage/firstaid/fire = 6)

/obj/random/contraband
	name = "random illegal item"
	desc = "Hot Stuff."
	icon_state = "landmark_unique_red"
	spawn_nothing_percentage = 66

/obj/random/contraband/spawn_choices()
	return list(/obj/item/haircomb = 4,
				/obj/item/storage/pill_bottle/tramadol = 3,
				/obj/item/storage/pill_bottle/happy = 2,
				/obj/item/storage/pill_bottle/zoom = 2,
				/obj/item/reagent_containers/vessel/beaker/vial/random/toxin = 1,
				/obj/item/reagent_containers/vessel/beaker/sulphuric = 1,
				/obj/item/contraband/poster = 5,
				/obj/item/material/butterfly = 2,
				/obj/item/material/butterflyblade = 3,
				/obj/item/material/butterflyhandle = 3,
				/obj/item/material/wirerod = 3,
				/obj/item/melee/baton/cattleprod = 1,
				/obj/item/material/butterfly/switchblade = 1,
				/obj/item/material/hatchet/tacknife = 1,
				/obj/item/material/kitchen/utensil/knife/boot = 2,
				/obj/item/storage/secure/briefcase/money = 1,
				/obj/item/storage/box/syndie_kit/cigarette = 1,
				/obj/item/stack/telecrystal = 1,
				/obj/item/clothing/under/syndicate = 2,
				/obj/item/reagent_containers/syringe = 3,
				/obj/item/reagent_containers/syringe/steroid/packaged = 2,
				/obj/item/reagent_containers/syringe/drugs = 1)

/obj/random/drinkbottle
	name = "random drink"
	desc = "This is a random drink."
	icon_state = "landmark_drink"
	spawn_nothing_percentage = 25

/obj/random/drinkbottle/spawn_choices()
	return list(/obj/item/reagent_containers/vessel/bottle/whiskey,
				/obj/item/reagent_containers/vessel/bottle/gin,
				/obj/item/reagent_containers/vessel/bottle/specialwhiskey,
				/obj/item/reagent_containers/vessel/bottle/vodka,
				/obj/item/reagent_containers/vessel/bottle/tequilla,
				/obj/item/reagent_containers/vessel/bottle/absinthe,
				/obj/item/reagent_containers/vessel/bottle/wine,
				/obj/item/reagent_containers/vessel/bottle/cognac,
				/obj/item/reagent_containers/vessel/bottle/rum,
				/obj/item/reagent_containers/vessel/bottle/patron)


/obj/random/energy
	name = "random energy weapon"
	desc = "This is a random energy weapon."
	icon_state = "landmark_laser"

/obj/random/energy/spawn_choices()
	return list(/obj/item/gun/energy/laser = 4,
				/obj/item/gun/energy/gun = 3,
				/obj/item/gun/energy/retro = 2,
				/obj/item/gun/energy/lasercannon = 2,
				/obj/item/gun/energy/xray = 3,
				/obj/item/gun/energy/sniperrifle = 1,
				/obj/item/gun/energy/gun/nuclear = 1,
				/obj/item/gun/energy/ionrifle = 2,
				/obj/item/gun/energy/toxgun = 3,
				/obj/item/gun/energy/taser = 4,
				/obj/item/gun/energy/crossbow/largecrossbow = 2,
				/obj/item/gun/energy/stunrevolver = 4)

/obj/random/projectile
	name = "random projectile weapon"
	desc = "This is a random projectile weapon."
	icon_state = "landmark_projectile"

/obj/random/projectile/spawn_choices()
	return list(/obj/item/gun/projectile/shotgun/pump = 3,
				/obj/item/gun/projectile/automatic/c20r = 2,
				/obj/item/gun/projectile/automatic/as75 = 2,
				/obj/item/gun/projectile/automatic/z8 = 2,
				/obj/item/gun/projectile/pistol/colt = 4,
				/obj/item/gun/projectile/pistol/vp78 = 4,
				/obj/item/gun/projectile/pistol/secgun/wood = 3,
				/obj/item/gun/projectile/pistol/holdout = 4,
				/obj/item/gun/projectile/pirate = 5,
				/obj/item/gun/projectile/revolver = 2,
				/obj/item/gun/projectile/automatic/wt550 = 3,
				/obj/item/gun/projectile/revolver/detective = 4,
				/obj/item/gun/projectile/revolver/mateba = 2,
				/obj/item/gun/projectile/shotgun/doublebarrel = 4,
				/obj/item/gun/projectile/shotgun/doublebarrel/sawn = 3,
				/obj/item/gun/projectile/heavysniper = 1,
				/obj/item/gun/projectile/shotgun/pump/combat = 2)

/obj/random/handgun
	name = "random handgun"
	desc = "This is a random sidearm."
	icon_state = "landmark_projectile"

/obj/random/handgun/spawn_choices()
	return list(/obj/item/gun/projectile/pistol/vp78 = 3,
				/obj/item/gun/energy/gun = 2,
				/obj/item/gun/projectile/pistol/colt = 2,
				/obj/item/gun/projectile/pistol/holdout = 2,
				/obj/item/gun/energy/retro = 1,
				/obj/item/gun/projectile/pistol/secgun/wood = 1)

/obj/random/ammo
	name = "random ammunition"
	desc = "This is random ammunition."
	icon_state = "landmark_ammo"

/obj/random/ammo/spawn_choices()
	return list(/obj/item/storage/box/shotgun/beanbags = 6,
				/obj/item/storage/box/shotgun/slugs = 2,
				/obj/item/storage/box/shotgun/shells = 4,
				/obj/item/storage/box/shotgun/stunshells = 1,
				/obj/item/ammo_magazine/c45m = 2,
				/obj/item/ammo_magazine/c45m/rubber = 4,
				/obj/item/ammo_magazine/c45m/flash = 4,
				/obj/item/ammo_magazine/mc9mmt = 2,
				/obj/item/ammo_magazine/mc9mmt/rubber = 6)

/obj/random/action_figure
	name = "random action figure"
	desc = "This is a random action figure."
	icon_state = "landmark_figure"

/obj/random/action_figure/spawn_choices()
	return list(/obj/item/toy/figure/cmo,
				/obj/item/toy/figure/assistant,
				/obj/item/toy/figure/atmos,
				/obj/item/toy/figure/bartender,
				/obj/item/toy/figure/borg,
				/obj/item/toy/figure/gardener,
				/obj/item/toy/figure/captain,
				/obj/item/toy/figure/cargotech,
				/obj/item/toy/figure/ce,
				/obj/item/toy/figure/chaplain,
				/obj/item/toy/figure/chef,
				/obj/item/toy/figure/chemist,
				/obj/item/toy/figure/clown,
				/obj/item/toy/figure/corgi,
				/obj/item/toy/figure/detective,
				/obj/item/toy/figure/dsquad,
				/obj/item/toy/figure/engineer,
				/obj/item/toy/figure/geneticist,
				/obj/item/toy/figure/hop,
				/obj/item/toy/figure/hos,
				/obj/item/toy/figure/qm,
				/obj/item/toy/figure/janitor,
				/obj/item/toy/figure/agent,
				/obj/item/toy/figure/librarian,
				/obj/item/toy/figure/md,
				/obj/item/toy/figure/mime,
				/obj/item/toy/figure/miner,
				/obj/item/toy/figure/ninja,
				/obj/item/toy/figure/wizard,
				/obj/item/toy/figure/rd,
				/obj/item/toy/figure/roboticist,
				/obj/item/toy/figure/scientist,
				/obj/item/toy/figure/syndie,
				/obj/item/toy/figure/secofficer,
				/obj/item/toy/figure/warden,
				/obj/item/toy/figure/psychologist,
				/obj/item/toy/figure/paramedic,
				/obj/item/toy/figure/ert,
				/obj/item/toy/figure/moose)

/obj/random/plushie
	name = "random plushie"
	desc = "This is a random plushie."
	icon_state = "landmark_toy"
	spawn_nothing_percentage = 35

/obj/random/plushie/spawn_choices()
	return list(
		/obj/item/toy/plushie/nymph,
		/obj/item/toy/plushie/mouse,
		/obj/item/toy/plushie/kitten,
		/obj/item/toy/plushie/lizard,
		/obj/item/toy/plushie/farwa,
		/obj/item/toy/plushie/spider,
		/obj/item/toy/plushie/snail
	)

/obj/random/plushie/large
	name = "random large plushie"
	desc = "This is a random large plushie."
	icon_state = "landmark_plushie_l"
	spawn_nothing_percentage = 35

/obj/random/plushie/large/spawn_choices()
	return list(/obj/structure/plushie/ian,
				/obj/structure/plushie/drone,
				/obj/structure/plushie/carp,
				/obj/structure/plushie/beepsky)

// Mostly remains and cleanable decals. Stuff a janitor could clean up.
/obj/random/trash
	name = "random trash"
	desc = "This is some random trash."
	icon_state = "landmark_garbage"
	spawn_nothing_percentage = 35

/obj/random/trash/spawn_choices()
	return list(/obj/item/remains/lizard = 3,
				/obj/effect/decal/cleanable/blood/gibs/robot = 3,
				/obj/effect/decal/cleanable/blood/oil = 5,
				/obj/effect/decal/cleanable/blood/oil/streak = 5,
				/obj/effect/decal/cleanable/spiderling_remains = 5,
				/obj/item/remains/mouse = 3,
				/obj/effect/decal/cleanable/vomit = 4,
				/obj/effect/decal/cleanable/blood/splatter = 2,
				/obj/effect/decal/cleanable/ash = 5,
				/obj/effect/decal/cleanable/generic = 5,
				/obj/effect/decal/cleanable/flour = 2,
				/obj/effect/decal/cleanable/dirt = 5,
				/obj/item/remains/robot = 3,
				/obj/item/remains/xeno = 1)

// A couple of random closets to spice up maint.
/obj/random/closet
	name = "random closet"
	desc = "This is a random closet."
	icon_state = "landmark_storage"
	spawn_nothing_percentage = 25

/obj/random/closet/spawn_choices()
	return list(/obj/structure/closet = 15,
				/obj/structure/closet/firecloset = 4,
				/obj/structure/closet/firecloset/full = 2,
				/obj/structure/closet/acloset = 1,
				/obj/structure/closet/syndicate = 1,
				/obj/structure/closet/emcloset = 3,
				/obj/structure/closet/jcloset = 1,
				/obj/structure/closet/athletic_mixed = 2,
				/obj/structure/closet/toolcloset = 2,
				/obj/structure/closet/l3closet/general = 1,
				/obj/structure/closet/cabinet = 4,
				/obj/structure/closet/coffin = 3,
				/obj/structure/closet/crate = 10,
				/obj/structure/closet/crate/freezer = 4,
				/obj/structure/closet/crate/freezer/rations = 2,
				/obj/structure/closet/crate/internals = 4,
				/obj/structure/closet/crate/trashcart = 2,
				/obj/structure/closet/crate/medical = 4,
				/obj/structure/closet/crate/hydroponics = 4,
				/obj/structure/closet/crate/plastic = 5,
				/obj/structure/closet/crate/paper_refill = 3,
				/obj/structure/closet/boxinggloves = 2,
				/obj/structure/largecrate = 5,
				/obj/structure/largecrate/animal/goat = 1,
				/obj/structure/closet/wardrobe/grey = 5,
				/obj/structure/closet/wardrobe/xenos = 2,
				/obj/structure/closet/wardrobe/mixed = 3,
				/obj/structure/closet/wardrobe/white = 3,
				/obj/structure/closet/wardrobe/orange = 3,
				/obj/structure/closet/crate/secure/loot = 1,
				/obj/structure/closet/secure_closet/freezer/kitchen = 3)

/obj/random/coin
	name = "random coin"
	desc = "This is a random coin."
	icon_state = "landmark_unique_orange"
	spawn_nothing_percentage = 50

/obj/random/coin/spawn_choices()
	return list(/obj/item/material/coin/iron = 10,
				/obj/item/material/coin/silver = 10,
				/obj/item/material/coin/gold = 5,
				/obj/item/material/coin/platinum = 3,
				/obj/item/material/coin/uranium = 1,
				/obj/item/material/coin/plasma = 1,
				/obj/item/material/coin/diamond = 1)

/obj/random/toy
	name = "random toy"
	desc = "This is a random toy."
	icon_state = "landmark_toy"
	spawn_nothing_percentage = 15

/obj/random/toy/spawn_choices()
	return list(/obj/item/toy/bosunwhistle,
				/obj/item/toy/therapy_red,
				/obj/item/toy/therapy_purple,
				/obj/item/toy/therapy_blue,
				/obj/item/toy/therapy_yellow,
				/obj/item/toy/therapy_orange,
				/obj/item/toy/therapy_green,
				/obj/item/toy/cultsword,
				/obj/item/toy/katana,
				/obj/item/toy/snappop,
				/obj/item/toy/sword,
				/obj/item/toy/water_balloon,
				/obj/item/toy/crossbow,
				/obj/item/toy/blink,
				/obj/item/reagent_containers/spray/waterflower,
				/obj/item/toy/prize/ripley,
				/obj/item/toy/prize/fireripley,
				/obj/item/toy/prize/deathripley,
				/obj/item/toy/prize/gygax,
				/obj/item/toy/prize/durand,
				/obj/item/toy/prize/honk,
				/obj/item/toy/prize/marauder,
				/obj/item/toy/prize/seraph,
				/obj/item/toy/prize/mauler,
				/obj/item/toy/prize/odysseus,
				/obj/item/toy/prize/phazon,
				/obj/item/deck/cards)

/obj/random/tank
	name = "random tank"
	desc = "This is a tank."
	icon_state = "landmark_tank"

/obj/random/tank/spawn_choices()
	return list(/obj/item/tank/oxygen = 5,
				/obj/item/tank/oxygen/yellow = 4,
				/obj/item/tank/oxygen/red = 4,
				/obj/item/tank/air = 3,
				/obj/item/tank/emergency/oxygen = 4,
				/obj/item/tank/emergency/oxygen/engi = 3,
				/obj/item/tank/emergency/oxygen/double = 2,
				/obj/item/tank/emergency/nitrogen = 2,
				/obj/item/tank/emergency/nitrogen/double = 1,
				/obj/item/tank/nitrogen = 1,
				/obj/item/device/suit_cooling_unit = 1)

// random materials for building stuff.
/obj/random/material
	name = "random material"
	desc = "This is a random material."
	icon_state = "landmark_unique_purple"
	spawn_nothing_percentage = 25

/obj/random/material/spawn_choices()
	return list(/obj/item/stack/material/steel/ten = 30,
				/obj/item/stack/material/glass/ten = 30,
				/obj/item/stack/material/glass/reinforced/ten = 20,
				/obj/item/stack/material/plastic/ten = 30,
				/obj/item/stack/material/wood/ten = 30,
				/obj/item/stack/material/cardboard/ten = 30,
				/obj/item/stack/rods/ten = 30,
				/obj/item/stack/material/plasteel/ten = 5,
				/obj/item/stack/material/steel/fifty = 15,
				/obj/item/stack/material/glass/fifty = 15,
				/obj/item/stack/material/glass/reinforced/fifty = 10,
				/obj/item/stack/material/plastic/fifty = 15,
				/obj/item/stack/material/wood/fifty = 15,
				/obj/item/stack/material/cardboard/fifty = 15,
				/obj/item/stack/rods/fifty = 20,
				/obj/item/stack/material/plasteel/fifty = 3)

/obj/random/soap
	name = "random сleaning supplies"
	desc = "This is a random bar of soap. Soap! SOAP?! SOAP!!!"
	icon_state = "landmark_soap"

/obj/random/soap/spawn_choices()
	return list(/obj/item/soap = 4,
				/obj/item/soap/nanotrasen = 3,
				/obj/item/soap/deluxe = 3,
				/obj/item/soap/syndie = 1,
				/obj/item/soap/gold = 1,
				/obj/item/reagent_containers/rag = 2,
				/obj/item/reagent_containers/spray/cleaner = 2,
				/obj/item/grenade/chem_grenade/cleaner = 1)

// Large objects to block things off in maintenance.
/obj/random/obstruction
	name = "random obstruction"
	desc = "This is a random obstruction."
	icon_state = "landmark_barrier"
	spawn_nothing_percentage = 25

/obj/random/obstruction/spawn_choices()
	return list(/obj/structure/barricade,
				/obj/structure/girder,
				/obj/structure/window_frame/grille,
				/obj/structure/window_frame/broken,
				/obj/structure/foamedmetal,
				/obj/item/caution,
				/obj/item/caution/cone,
				/obj/structure/inflatable/wall,
				/obj/structure/inflatable/door)

/obj/random/pottedplant
	name = "random potted plant"
	desc = "This is a random potted plant."
	icon = 'icons/obj/plants.dmi'
	icon_state = "random_plant_spawner"

/obj/random/pottedplant/spawn_choices()
	return list(/obj/structure/flora/pottedplant = 3,
				/obj/structure/flora/pottedplant/large = 3,
				/obj/structure/flora/pottedplant/fern = 3,
				/obj/structure/flora/pottedplant/overgrown = 3,
				/obj/structure/flora/pottedplant/bamboo = 3,
				/obj/structure/flora/pottedplant/largebush = 3,
				/obj/structure/flora/pottedplant/thinbush = 3,
				/obj/structure/flora/pottedplant/mysterious = 3,
				/obj/structure/flora/pottedplant/smalltree = 3,
				/obj/structure/flora/pottedplant/unusual = 3,
				/obj/structure/flora/pottedplant/orientaltree = 3,
				/obj/structure/flora/pottedplant/tall = 3,
				/obj/structure/flora/pottedplant/sticky = 3,
				/obj/structure/flora/pottedplant/smelly = 3,
				/obj/structure/flora/pottedplant/aquatic = 3,
				/obj/structure/flora/pottedplant/flower = 3,
				/obj/structure/flora/pottedplant/crystal = 3,
				/obj/structure/flora/pottedplant/subterranean = 3,
				/obj/structure/flora/pottedplant/minitree = 3,
				/obj/structure/flora/pottedplant/stoutbush = 3,
				/obj/structure/flora/pottedplant/tropical = 3,
				/obj/structure/flora/pottedplant/flowerbushblue = 3,
				/obj/structure/flora/pottedplant/flowerbushred = 3,
				/obj/structure/flora/pottedplant/largeleaves = 3,
				/obj/structure/flora/pottedplant/overgrownbush = 3,
				/obj/structure/flora/pottedplant/tropicaltree = 3,
				/obj/structure/flora/pottedplant/tropicalflowers = 3,
				/obj/structure/flora/pottedplant/faketree = 3,
				/obj/structure/flora/pottedplant/autumn = 3,
				/obj/structure/flora/pottedplant/pink = 3,
				/obj/structure/flora/pottedplant/ugly = 2,
				/obj/structure/flora/pottedplant/dead = 2,
				/obj/structure/flora/pottedplant/eye = 1)

/obj/random/assembly
	name = "random assembly"
	desc = "This is a random circuit assembly."
	icon_state = "landmark_circuit"

/obj/random/assembly/spawn_choices()
	return list(/obj/item/device/electronic_assembly,
				/obj/item/device/electronic_assembly/medium,
				/obj/item/device/electronic_assembly/large,
				/obj/item/device/electronic_assembly/drone)

/obj/random/advdevice
	name = "random advanced device"
	icon_state = "landmark_tech"
	spawn_nothing_percentage = 30

/obj/random/advdevice/spawn_choices()
	return list(/obj/item/device/flashlight = 5,
				/obj/item/device/flashlight/lantern = 2,
				/obj/item/device/flashlight/flare = 4,
				/obj/item/device/flashlight/pen = 2,
				/obj/item/device/uv_light = 1,
				/obj/item/device/toner = 3,
				/obj/item/device/camera_film = 3,
				/obj/item/device/analyzer = 2,
				/obj/item/device/healthanalyzer = 2,
				/obj/item/device/paicard = 2,
				/obj/item/device/destTagger = 2,
				/obj/item/device/mmi = 1,
				/obj/item/beartrap = 2,
				/obj/item/handcuffs = 1,
				/obj/item/camera_assembly = 5,
				/obj/item/device/camera = 2,
				/obj/item/device/pda = 2,
				/obj/item/card/emag_broken = 1,
				/obj/item/device/radio/headset = 2,
				/obj/item/device/flashlight/glowstick/random = 5)

/obj/random/smokes
	name = "random smokeable"
	desc = "This is a random smokeable item."
	icon_state = "landmark_smoke"
	spawn_nothing_percentage = 35

/obj/random/smokes/spawn_choices()
	return list(/obj/item/storage/fancy/cigarettes = 5,
				/obj/item/storage/fancy/cigarettes/dromedaryco = 4,
				/obj/item/storage/fancy/cigarettes/killthroat = 1,
				/obj/item/storage/fancy/cigarettes/luckystars = 3,
				/obj/item/storage/fancy/cigarettes/jerichos = 3,
				/obj/item/storage/fancy/cigarettes/menthols = 2,
				/obj/item/storage/fancy/cigarettes/carcinomas = 3,
				/obj/item/storage/fancy/cigarettes/professionals = 2,
				/obj/item/storage/fancy/cigar = 1,
				/obj/item/clothing/mask/smokable/cigarette = 2,
				/obj/item/clothing/mask/smokable/cigarette/menthol = 2,
				/obj/item/clothing/mask/smokable/cigarette/cigar = 1,
				/obj/item/clothing/mask/smokable/cigarette/cigar/cohiba = 1,
				/obj/item/clothing/mask/smokable/cigarette/cigar/havana = 1,
				/obj/item/clothing/mask/smokable/cigarette/spliff = 1)

/obj/random/snack
	name = "random snack"
	desc = "This is a random snack item."
	icon_state = "landmark_food"
	spawn_nothing_percentage = 50

/obj/random/snack/spawn_choices()
	return list(/obj/item/reagent_containers/food/liquidfood,
				/obj/item/reagent_containers/food/packaged/tweakers,
				/obj/item/reagent_containers/food/packaged/sweetroid,
				/obj/item/reagent_containers/food/packaged/sugarmatter,
				/obj/item/reagent_containers/food/packaged/jellaws,
				/obj/item/reagent_containers/vessel/dry_ramen,
				/obj/item/reagent_containers/food/packaged/chips,
				/obj/item/reagent_containers/food/packaged/sosjerky,
				/obj/item/reagent_containers/food/packaged/no_raisin,
				/obj/item/reagent_containers/food/spacetwinkie,
				/obj/item/reagent_containers/food/packaged/cheesiehonkers,
				/obj/item/reagent_containers/food/packaged/tastybread,
				/obj/item/reagent_containers/food/packaged/nutribar,
				/obj/item/reagent_containers/food/packaged/syndicake,
				/obj/item/reagent_containers/food/donut,
				/obj/item/reagent_containers/food/donut/cherryjelly,
				/obj/item/reagent_containers/food/donut/jelly,
				/obj/item/pizzabox/meat,
				/obj/item/pizzabox/vegetable,
				/obj/item/pizzabox/margherita,
				/obj/item/pizzabox/mushroom,
				/obj/item/reagent_containers/food/plumphelmetbiscuit,
				/obj/item/reagent_containers/food/packaged/skrellsnacks,
				/obj/item/reagent_containers/food/tortilla,
				/obj/item/reagent_containers/food/popcorn,
				/obj/item/reagent_containers/food/cookie)


/obj/random/storage
	name = "random storage item"
	desc = "This is a storage item."
	icon_state = "landmark_storage"
	spawn_nothing_percentage = 35

/obj/random/storage/spawn_choices()
	return list(/obj/item/storage/secure/briefcase = 2,
				/obj/item/storage/briefcase = 4,
				/obj/item/storage/briefcase/inflatable = 3,
				/obj/item/storage/backpack = 5,
				/obj/item/storage/backpack/satchel = 5,
				/obj/item/storage/backpack/satchel/leather = 2,
				/obj/item/storage/backpack/satchel/flat = 1,
				/obj/item/storage/backpack/dufflebag = 2,
				/obj/item/storage/backpack/messenger = 4,
				/obj/item/storage/box = 5,
				/obj/item/storage/box/donkpockets = 3,
				/obj/item/storage/box/sinpockets = 1,
				/obj/item/storage/box/donut = 2,
				/obj/item/storage/box/cups = 3,
				/obj/item/storage/box/mousetraps = 5,
				/obj/item/storage/box/engineer = 3,
				/obj/item/storage/box/security = 3,
				/obj/item/storage/box/vox = 1,
				/obj/item/storage/box/beakers = 3,
				/obj/item/storage/box/syringes = 3,
				/obj/item/storage/box/gloves = 3,
				/obj/item/storage/box/masks = 3,
				/obj/item/storage/box/large = 2,
				/obj/item/storage/box/glowsticks = 3,
				/obj/item/storage/wallet = 1,
				/obj/item/storage/ore = 2,
				/obj/item/storage/belt/utility = 3,
				/obj/item/storage/belt/utility/full = 1,
				/obj/item/storage/belt/medical/emt = 2,
				/obj/item/storage/belt/medical = 2,
				/obj/item/storage/belt/security = 1)

/obj/random/clothing
	name = "random clothes"
	desc = "This is a random piece of clothing."
	icon_state = "landmark_outfit"
	spawn_nothing_percentage = 35

/obj/random/clothing/spawn_choices()
	return list(/obj/item/clothing/under/syndicate/tacticool = 2,
				/obj/item/clothing/under/syndicate/combat = 1,
				/obj/item/clothing/under/hazard = 2,
				/obj/item/clothing/under/sterile = 2,
				/obj/item/clothing/under/casual_pants/camo = 2,
				/obj/item/clothing/under/casual_pants/track = 2,
				/obj/item/clothing/under/casual_pants/classicjeans = 2,
				/obj/item/clothing/under/rank/medical/paramedic = 2,
				/obj/item/clothing/under/overalls = 2,
				/obj/item/clothing/ears/earmuffs = 2,
				/obj/item/clothing/under/dress/maid = 1,
				/obj/item/clothing/under/dress/bar_f = 1,
				/obj/item/clothing/under/dress/dress_fire = 1,
				/obj/item/clothing/under/dress/dress_purple = 1,
				/obj/item/clothing/under/color/grey = 2,
				/obj/item/clothing/under/color/black = 2,
				/obj/item/clothing/under/color/blue = 2,
				/obj/item/clothing/under/color/brown = 2,
				/obj/item/clothing/under/color/green = 2,
				/obj/item/clothing/under/color/rainbow = 1,
				/obj/item/clothing/under/color/yellow = 2,
				/obj/item/clothing/under/color/white = 2,
				/obj/item/clothing/under/color/red = 2,
				/obj/item/clothing/under/rank/miner = 2,
				/obj/item/clothing/under/rank/vice = 1,
				/obj/item/clothing/under/waiter = 2,
				/obj/item/clothing/under/soviet = 1)

/obj/random/clothing/masks
	name = "random mask"
	desc = "This is a random face mask."
	icon_state = "landmark_mask"

/obj/random/clothing/masks/spawn_choices()
	return list(/obj/item/clothing/mask/gas = 4,
				/obj/item/clothing/mask/gas/old = 5,
				/obj/item/clothing/mask/gas/swat = 1,
				/obj/item/clothing/mask/gas/syndicate = 1,
				/obj/item/clothing/mask/breath = 6,
				/obj/item/clothing/mask/breath/medical = 4,
				/obj/item/clothing/mask/balaclava = 3,
				/obj/item/clothing/mask/balaclava/tactical = 2,
				/obj/item/clothing/mask/surgical = 4)

/obj/random/clothing/shoes
	name = "random footwear"
	desc = "This is a random pair of shoes."
	icon_state = "landmark_shoes"
	spawn_nothing_percentage = 15


/obj/random/clothing/shoes/spawn_choices()
	return list(/obj/item/clothing/shoes/workboots = 4,
				/obj/item/clothing/shoes/jackboots = 4,
				/obj/item/clothing/shoes/swat = 1,
				/obj/item/clothing/shoes/combat = 1,
				/obj/item/clothing/shoes/galoshes = 2,
				/obj/item/clothing/shoes/magboots = 1,
				/obj/item/clothing/shoes/laceup = 4,
				/obj/item/clothing/shoes/black = 8,
				/obj/item/clothing/shoes/dress = 4,
				/obj/item/clothing/shoes/sandal = 4,
				/obj/item/clothing/shoes/brown = 6,
				/obj/item/clothing/shoes/red = 6,
				/obj/item/clothing/shoes/blue = 6,
				/obj/item/clothing/shoes/leather = 5)

/obj/random/clothing/gloves
	name = "random gloves"
	desc = "This is a random pair of gloves."
	icon_state = "landmark_gloves"
	spawn_nothing_percentage = 15

/obj/random/clothing/gloves/spawn_choices()
	return list(/obj/item/clothing/gloves/insulated = 1,
				/obj/item/clothing/gloves/thick = 6,
				/obj/item/clothing/gloves/thick/botany = 3,
				/obj/item/clothing/gloves/latex = 4,
				/obj/item/clothing/gloves/latex/nitrile = 2,
				/obj/item/clothing/gloves/white = 5,
				/obj/item/clothing/gloves/rainbow = 1,
				/obj/item/clothing/gloves/duty = 5,
				/obj/item/clothing/gloves/guards = 1,
				/obj/item/clothing/gloves/tactical = 1,
				/obj/item/clothing/gloves/insulated/cheap = 5,
				/obj/item/clothing/gloves/vox = 1,
				/obj/item/clothing/gloves/boxing = 1)

/obj/random/clothing/glasses
	name = "random eyewear"
	desc = "This is a random pair of glasses."
	icon_state = "landmark_glasses"
	spawn_nothing_percentage = 25

/obj/random/clothing/glasses/spawn_choices()
	return list(/obj/item/clothing/glasses/sunglasses = 10,
				/obj/item/clothing/glasses/sunglasses/big = 4,
				/obj/item/clothing/glasses/sunglasses/prescription = 3,
				/obj/item/clothing/glasses/sunglasses/redglasses = 2,
				/obj/item/clothing/glasses/eyepatch = 7,
				/obj/item/clothing/glasses/monocle = 2,
				/obj/item/clothing/glasses/regular = 20,
				/obj/item/clothing/glasses/regular/hipster = 7,
				/obj/item/clothing/glasses/regular/scanners = 1,
				/obj/item/clothing/glasses/threedglasses = 2,
				/obj/item/clothing/glasses/hud/standard/meson = 8,
				/obj/item/clothing/glasses/hud/standard/science = 6,
				/obj/item/clothing/glasses/welding = 8,
				/obj/item/clothing/glasses/hud/one_eyed/oneye/medical = 4,
				/obj/item/clothing/glasses/tacgoggles = 1)

/obj/random/clothing/hat
	name = "random headgear"
	desc = "This is a random hat of some kind."
	icon_state = "landmark_hat"

/obj/random/clothing/hat/spawn_choices()
	return list(/obj/item/clothing/head/helmet = 1,
				/obj/item/clothing/head/helmet/space/emergency = 2,
				/obj/item/clothing/head/bio_hood/general = 1,
				/obj/item/clothing/head/hardhat = 3,
				/obj/item/clothing/head/hardhat/orange = 3,
				/obj/item/clothing/head/hardhat/red = 3,
				/obj/item/clothing/head/hardhat/dblue = 2,
				/obj/item/clothing/head/ushanka = 2,
				/obj/item/clothing/head/welding = 2,
				/obj/item/clothing/head/cardborg = 1,
				/obj/item/clothing/head/cowboy_hat = 1,
				/obj/item/clothing/head/nursehat = 1,
				/obj/item/clothing/head/syndicatefake = 1,
				/obj/item/clothing/head/wizard/fake = 1,
				/obj/item/clothing/head/bowler = 1,
				/obj/item/clothing/head/fez = 1,
				/obj/item/clothing/head/beaverhat = 1,
				/obj/item/clothing/head/that = 1,
				/obj/item/clothing/head/flatcap = 1,
				/obj/item/clothing/head/soft/grey = 2,
				/obj/item/clothing/head/soft/black = 2,
				/obj/item/clothing/head/soft/blue = 2,
				/obj/item/clothing/head/soft/orange = 2,
				/obj/item/clothing/head/soft/rainbow = 1)

/obj/random/clothing/suit
	name = "random suit"
	desc = "This is a random piece of outerwear."
	spawn_nothing_percentage = 25

/obj/random/clothing/suit/spawn_choices()
	return list(/obj/item/clothing/suit/storage/hazardvest = 4,
				/obj/item/clothing/suit/storage/toggle/labcoat = 4,
				/obj/item/clothing/suit/space/emergency = 1,
				/obj/item/clothing/suit/armor/vest = 2,
				/obj/item/clothing/suit/storage/toggle/bomber = 3,
				/obj/item/clothing/suit/chef/classic = 3,
				/obj/item/clothing/suit/surgicalapron = 2,
				/obj/item/clothing/suit/apron/overalls = 3,
				/obj/item/clothing/suit/bio_suit/general = 1,
				/obj/item/clothing/suit/storage/toggle/hoodie/black = 3,
				/obj/item/clothing/suit/storage/toggle/brown_jacket = 3,
				/obj/item/clothing/suit/apron = 4,
				/obj/item/clothing/suit/cardborg = 2,
				/obj/item/clothing/suit/ianshirt = 1,
				/obj/item/clothing/suit/pirate = 1,
				/obj/item/clothing/suit/wizrobe/fake = 1,
				/obj/item/clothing/suit/syndicatefake = 1,
				/obj/item/clothing/suit/poncho/colored = 1,
				/obj/item/clothing/suit/poncho/colored/red = 1,
				/obj/item/clothing/suit/storage/toggle/labcoat = 4,
				/obj/item/clothing/suit/storage/toggle/varsity = 1,
				/obj/item/clothing/suit/storage/toggle/varsity/blue = 1,
				/obj/item/clothing/suit/storage/toggle/varsity/brown = 1,
				/obj/item/clothing/suit/storage/toggle/varsity/red = 1)

/obj/random/clothing/accessory
	name = "random accessory"
	desc = "This is a random utility accessory."
	icon_state = "landmark_accessory"
	spawn_nothing_percentage = 45

/obj/random/clothing/accessory/spawn_choices()
	return list(/obj/item/clothing/accessory/storage/webbing = 3,
				/obj/item/clothing/accessory/storage/webbing_large = 3,
				/obj/item/clothing/accessory/storage/black_vest = 2,
				/obj/item/clothing/accessory/storage/brown_vest = 2,
				/obj/item/clothing/accessory/storage/white_vest = 2,
				/obj/item/clothing/accessory/storage/bandolier = 1,
				/obj/item/clothing/accessory/holster/thigh = 1,
				/obj/item/clothing/accessory/holster/hip = 1,
				/obj/item/clothing/accessory/holster/waist = 1,
				/obj/item/clothing/accessory/holster/armpit = 1,
				/obj/item/clothing/accessory/kneepads = 3,
				/obj/item/clothing/accessory/stethoscope = 2)

/obj/random/cash
	name = "random currency"
	desc = "LOADSAMONEY!"
	icon_state = "landmark_unique_orange"
	spawn_nothing_percentage = 50

/obj/random/cash/spawn_choices()
	return list(/obj/item/spacecash/bundle/c1 = 9,
				/obj/item/spacecash/bundle/c10 = 8,
				/obj/item/spacecash/bundle/c20 = 5,
				/obj/item/spacecash/bundle/c50 = 2,
				/obj/item/spacecash/bundle/c100 = 1)

// Clutter and loot for maintenance and away missions
/obj/random/maintenance
	name = "random maintenance item"
	desc = "This is a random maintenance item."
	spawn_nothing_percentage = 40

/obj/random/maintenance/spawn_choices()
	return list(/obj/random/junk = 4,
				/obj/random/trash = 4,
				/obj/random/maintenance/clean = 5)

/*
Maintenance loot lists without the trash, for use inside things.
Individual items to add to the maintenance list should go here, if you add
something, make sure it's not in one of the other lists.
*/
/obj/random/maintenance/clean
	name = "random clean maintenance item"
	desc = "This is a random clean maintenance item."
	icon_state = "landmark_unique_blue"
	spawn_nothing_percentage = 15

/obj/random/maintenance/clean/spawn_choices()
	return list(/obj/random/tech_supply = 100,
				/obj/random/medical = 40,
				/obj/random/medical/lite = 80,
				/obj/random/firstaid = 20,
				/obj/random/powercell = 50,
				/obj/random/technology_scanner = 80,
				/obj/random/bomb_supply = 80,
				/obj/random/contraband = 1,
				/obj/random/action_figure = 2,
				/obj/random/plushie = 2,
				/obj/random/material = 15,
				/obj/random/coin = 5,
				/obj/random/toy = 20,
				/obj/random/tank = 20,
				/obj/random/soap = 5,
				/obj/random/drinkbottle = 5,
				/obj/random/loot = 1,
				/obj/random/advdevice = 50,
				/obj/random/smokes = 30,
				/obj/random/snack = 60,
				/obj/random/storage = 30,
				/obj/random/clothing = 30,
				/obj/random/clothing/masks = 10,
				/obj/random/clothing/glasses = 20,
				/obj/random/clothing/hat = 10,
				/obj/random/clothing/shoes = 20,
				/obj/random/clothing/gloves = 10,
				/obj/random/clothing/suit = 20,
				/obj/random/clothing/accessory = 20,

				/obj/random/cash = 10)

// Better loot for away missions and salvage.
/obj/random/loot
	name = "random loot"
	desc = "This is some random loot."
	icon_state = "landmark_unique_purple"

/obj/random/loot/spawn_choices()
	return list(/obj/random/energy = 10,
				/obj/random/projectile = 10,
				/obj/random/voidhelmet = 10,
				/obj/random/voidsuit = 10,
				/obj/random/powersuit = 10,
				/obj/item/clothing/mask/muzzle = 7,
				/obj/item/clothing/mask/gas/vox = 8,
				/obj/item/clothing/mask/gas/syndicate = 10,
				/obj/item/clothing/glasses/hud/scanners/night = 3,
				/obj/item/clothing/glasses/hud/standard/thermal = 1,
				/obj/item/clothing/glasses/welding/superior = 7,
				/obj/item/clothing/head/collectable/petehat = 4,
				/obj/item/clothing/suit/straight_jacket = 6,
				/obj/item/clothing/head/helmet/syndi = 3,
				/obj/item/stack/material/diamond/ten = 7,
				/obj/item/clothing/under/contortionist = 1,
				/obj/item/stack/material/glass/rplass/ten = 7,
				/obj/item/stack/material/marble/ten = 8,
				/obj/item/stack/material/plasma/ten = 7,
				/obj/item/stack/material/gold/ten = 7,
				/obj/item/stack/material/silver/ten = 7,
				/obj/item/stack/material/osmium/ten = 7,
				/obj/item/stack/material/platinum/ten = 8,
				/obj/item/stack/material/tritium/ten = 7,
				/obj/item/stack/material/mhydrogen/ten = 6,
				/obj/item/stack/material/plasteel/ten = 9,
				/obj/item/storage/box/monkeycubes = 5,
				/obj/item/storage/box/monkeycubes/neaeracubes = 4,
				/obj/item/storage/box/monkeycubes/stokcubes = 4,
				/obj/item/storage/box/monkeycubes/farwacubes = 4,
				/obj/item/storage/firstaid/surgery = 4,
				/obj/item/cell/infinite = 1,
				/obj/item/archaeological_find = 2,
				/obj/machinery/artifact = 1,
				/obj/item/device/multitool/hacktool = 2,
				/obj/item/surgicaldrill = 7,
				/obj/item/FixOVein = 7,
				/obj/item/retractor = 7,
				/obj/item/hemostat = 7,
				/obj/item/cautery = 7,
				/obj/item/bonesetter = 7,
				/obj/item/bonegel = 7,
				/obj/item/circular_saw = 7,
				/obj/item/scalpel = 7,
				/obj/item/melee/baton/loaded = 9,
				/obj/item/device/radio/headset/syndicate = 6)

/obj/random/voidhelmet
	name = "random voidsuit helmet"
	desc = "This is a random voidsuit helmet."
	icon_state = "landmark_helmet"

/obj/random/voidhelmet/spawn_choices()
	return list(/obj/item/clothing/head/helmet/space/void,
				/obj/item/clothing/head/helmet/space/void/engineering,
				/obj/item/clothing/head/helmet/space/void/engineering/alt,
				/obj/item/clothing/head/helmet/space/void/engineering/salvage,
				/obj/item/clothing/head/helmet/space/void/mining,
				/obj/item/clothing/head/helmet/space/void/mining/alt,
				/obj/item/clothing/head/helmet/space/void/security,
				/obj/item/clothing/head/helmet/space/void/security/alt,
				/obj/item/clothing/head/helmet/space/void/atmos,
				/obj/item/clothing/head/helmet/space/void/atmos/alt,
				/obj/item/clothing/head/helmet/space/void/syndi,
				/obj/item/clothing/head/helmet/space/void/medical,
				/obj/item/clothing/head/helmet/space/void/medical/alt)

/obj/random/voidsuit
	name = "random voidsuit"
	desc = "This is a random voidsuit."
	icon_state = "landmark_void"

/obj/random/voidsuit/spawn_choices()
	return list(/obj/item/clothing/suit/space/void,
				/obj/item/clothing/suit/space/void/engineering,
				/obj/item/clothing/suit/space/void/engineering/alt,
				/obj/item/clothing/suit/space/void/engineering/salvage,
				/obj/item/clothing/suit/space/void/mining,
				/obj/item/clothing/suit/space/void/mining/alt,
				/obj/item/clothing/suit/space/void/security,
				/obj/item/clothing/suit/space/void/security/alt,
				/obj/item/clothing/suit/space/void/atmos,
				/obj/item/clothing/suit/space/void/atmos/alt,
				/obj/item/clothing/suit/space/void/syndi,
				/obj/item/clothing/suit/space/void/medical,
				/obj/item/clothing/suit/space/void/medical/alt)

/obj/random/powersuit
	name = "random powersuit"
	desc = "This is a random powersuit control module."
	icon_state = "landmark_rig"

/obj/random/powersuit/spawn_choices()
	return list(/obj/item/rig/industrial,
				/obj/item/rig/eva,
				/obj/item/rig/light/hacker,
				/obj/item/rig/light/stealth,
				/obj/item/rig/light,
				/obj/item/rig/unathi,
				/obj/item/rig/unathi/fancy)

/obj/random/hostile
	name = "random hostile mob"
	desc = "This is a random hostile mob."
	icon_state = "landmark_carp"
	spawn_nothing_percentage = 80

/obj/random/hostile/spawn_choices()
	return list(/mob/living/simple_animal/hostile/viscerator,
				/mob/living/simple_animal/hostile/carp,
				/mob/living/simple_animal/hostile/carp/pike,
				/mob/living/simple_animal/hostile/vagrant/swarm)

// Holiday stuff.
/obj/random/jackolantern
	name = "random jack o'lantern"
	desc = "This is a random jack o'lantern."
	icon_state = "landmark_lantern"

/obj/random/jackolantern/spawn_choices()
	return list(/obj/item/jackolantern/best,
				/obj/item/jackolantern/girl,
				/obj/item/jackolantern/scream,
				/obj/item/jackolantern/old)

/obj/random/sock
	name = "random Christmas sock"
	desc = "This is a random Christams sock. HOU-HOU-HOU!"
	icon_state = "landmark_sock"

/obj/random/sock/spawn_choices()
	return list(/obj/structure/sign/christmas/sock = 5,
				/obj/structure/sign/christmas/sock2 = 3,
				/obj/structure/sign/christmas/socknt = 5,
				/obj/structure/sign/christmas/sockfrog = 4,
				/obj/structure/sign/christmas/sockninja = 1,
				/obj/structure/sign/christmas/sockwizard = 1,
				/obj/structure/sign/christmas/socksindy = 2)

/obj/random/music_tape
	name = "random music tape"
	desc = "This is a random music tape."
	icon_state = "landmark_tape"

/obj/random/music_tape/spawn_choices()
	return list(/obj/item/music_tape_box/jazz = 10,
				/obj/item/music_tape_box/classic = 30,
				/obj/item/music_tape_box/frontier = 5,
				/obj/item/music_tape_box/exodus = 5,
				/obj/item/music_tape_box/valhalla = 3)

// Selects one spawn point out of a group of points with the same ID and asks it to generate its items
var/list/multi_point_spawns

/obj/random_multi
	name = "random object spawn point"
	desc = "This item type is used to spawn random objects at round-start. Only one spawn point for a given group id is selected."
	icon = 'icons/misc/landmarks.dmi'
	icon_state = "landmark_unique_blue"
	alpha = 128
	invisibility = INVISIBILITY_MAXIMUM
	var/id     // Group id.
	var/weight // Probability weight for this spawn point.

/obj/random_multi/Initialize()
	. = ..()
	weight = max(1, round(weight))

	if(!multi_point_spawns)
		multi_point_spawns = list()
	var/list/spawnpoints = multi_point_spawns[id]
	if(!spawnpoints)
		spawnpoints = list()
		multi_point_spawns[id] = spawnpoints
	spawnpoints[src] = weight

/obj/random_multi/Destroy()
	var/list/spawnpoints = multi_point_spawns[id]
	spawnpoints -= src
	if(!spawnpoints.len)
		multi_point_spawns -= id
	. = ..()

/obj/random_multi/proc/generate_items()
	return

/obj/random_multi/single_item
	var/item_path  // Item type to spawn.

/obj/random_multi/single_item/generate_items()
	new item_path(loc)

/hook/roundstart/proc/generate_multi_spawn_items()
	for(var/id in multi_point_spawns)
		var/list/spawn_points = multi_point_spawns[id]
		var/obj/random_multi/rm = pickweight(spawn_points)
		rm.generate_items()
		for(var/entry in spawn_points)
			qdel(entry)
	return 1

/obj/random_multi/single_item/captains_spare_id
	name = "multi point - Captain's spare"
	icon_state = "landmark_card"
	id = "Captain's spare id"
	item_path = /obj/item/card/id/captains_spare

/obj/random_multi/single_item/bookrev
	name = "multi point - Veridical Chronicles of NanoTrasen"
	icon_state = "landmark_bookrev"
	id = "Veridical Chronicles of NanoTrasen"
	item_path = /obj/item/book/rev

// Broken items, or stuff that could be picked up.
/obj/random/junk
	name = "random junk"
	desc = "This is some random junk."
	icon_state = "landmark_garbage"
	spawn_nothing_percentage = 35

/obj/random/junk/spawn_choices()
	return list(get_random_junk_type())

var/list/random_junk_
var/list/random_useful_
/proc/get_random_useful_type()
	if(!random_useful_)
		random_useful_ = list()
		random_useful_ += /obj/item/pen/crayon/random
		random_useful_ += /obj/item/pen
		random_useful_ += /obj/item/pen/blue
		random_useful_ += /obj/item/pen/red
		random_useful_ += /obj/item/pen/multi
		random_useful_ += /obj/item/storage/box/matches
		random_useful_ += /obj/item/stack/material/cardboard
		random_useful_ += /obj/item/storage/fancy/cigarettes
		random_useful_ += /obj/item/deck/cards
	return pick(random_useful_)

/proc/get_random_junk_type()
	if(prob(20)) // Misc. clutter.
		return /obj/effect/decal/cleanable/generic

	// 80% chance that we reach here.
	if(prob(95)) // Misc. junk.
		if(!random_junk_)
			random_junk_ = subtypesof(/obj/item/trash)
			random_junk_ += typesof(/obj/item/cigbutt)
			random_junk_ += /obj/effect/decal/cleanable/spiderling_remains
			random_junk_ += /obj/item/remains/mouse
			random_junk_ += /obj/item/remains/robot
			random_junk_ += /obj/item/paper/crumpled
			random_junk_ += /obj/item/inflatable/torn
			random_junk_ += /obj/effect/decal/cleanable/molten_item
			random_junk_ += /obj/item/material/shard
			random_junk_ += /obj/item/hand/missing_card

			random_junk_ -= /obj/item/trash/dish/plate
			random_junk_ -= /obj/item/trash/dish/bowl
			random_junk_ -= /obj/item/trash/syndi_cakes
			random_junk_ -= /obj/item/trash/dish/tray
		return pick(random_junk_)

	// Misc. actually useful stuff or perhaps even food.
	// 4% chance that we reach here.
	if(prob(75))
		return get_random_useful_type()

	// 1% chance that we reach here.
	var/lunches = lunchables_lunches()
	return lunches[pick(lunches)]
