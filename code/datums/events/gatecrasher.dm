/datum/event/gatecrasher
	id = "gatecrasher"
	name = "Gatecrasher"
	description = "An uninvited guest get teleported aboard the station"

	mtth = 6 HOURS
	difficulty = 60

/datum/event/gatecrasher/on_fire()
	set waitfor = FALSE

	if(length(GLOB.intact_station_closets))
		var/obj/structure/closet/C = pick(GLOB.intact_station_closets)
		new /obj/gatecrasher_spawn(C.loc, C)
		C.intact_closet = FALSE
		GLOB.intact_station_closets.Remove(C)
		return

	var/list/affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	var/list/pick_turfs = list()

	for(var/z in affecting_z)
		for(var/turf/simulated/floor/T in block(locate(1, 1, z), locate(world.maxx, world.maxy, z)))
			if(turf_contains_dense_objects(T))
				continue
			pick_turfs.Add(weakref(T))

	for(var/t in pick_turfs)
		var/turf/T = safepick(pick_turfs)?.resolve()
		if(istype(T))
			new /obj/gatecrasher_spawn(T)
			break

////////////

/obj/gatecrasher_spawn
	name = "SEENOEVIL"
	desc = "HEARNOEVIL"
	icon_state = "SPEAKNOEVIL"
	mouse_opacity = 0
	density = FALSE
	alpha = 0

	var/list/possible_containers = list(
		/obj/structure/closet/secure_closet/freezer/fridge,
		/obj/structure/closet/secure_closet/freezer/money,
		/obj/structure/closet/secure_closet/miner,
		/obj/structure/closet/secure_closet/iaa,
		/obj/structure/closet/coffin = 2,
		/obj/structure/closet/body_bag = 3,
		/obj/structure/closet/body_bag/cryobag = 5,
		/obj/structure/closet/body_bag/cryobag/syndi,
		/obj/structure/closet/acloset = 2,
		/obj/structure/closet/firecloset,
		/obj/structure/closet/syndicate,
		/obj/structure/closet = 5
	)

	var/species = list(                 // List of species to pick from. Uses util_pick_weight()
		SPECIES_HUMAN = 50,
		SPECIES_SWINE = 10,
		SPECIES_TAJARA = 10,
		SPECIES_UNATHI = 10,
		SPECIES_SKRELL = 10,
		SPECIES_DIONA = 5,
		SPECIES_GRAVWORLDER = 5,
		SPECIES_SPACER = 5,
		SPECIES_VATGROWN = 5,
		SPECIES_GOLEM = 3,
		SPECIES_VOX = 3,
		"Shadow" = 1,
		SPECIES_PROMETHEAN = 1,
		SPECIES_STARGAZER = 1,
		SPECIES_SLIMEPERSON = 1,
		SPECIES_XENO_QUEEN = 1,
		SPECIES_XENO_HUNTER_FERAL = 1
	)

	var/outfits_to_spawn = list( // List of outfits to pick from. Uses util_pick_weight()
		/decl/hierarchy/outfit = 10,
		/decl/hierarchy/outfit/job/assistant = 20,
		/decl/hierarchy/outfit/job/service/janitor = 2,
		/decl/hierarchy/outfit/job/internal_affairs_agent = 2,
		/decl/hierarchy/outfit/job/chaplain = 2,
		/decl/hierarchy/outfit/job/merchant = 10,
		/decl/hierarchy/outfit/job/clown = 6,
		/decl/hierarchy/outfit/job/mime = 6,
		/decl/hierarchy/outfit/job/cargo/cargo_tech = 4,
		/decl/hierarchy/outfit/job/cargo/mining = 10,
		/decl/hierarchy/outfit/job/cargo/mining/void = 6,
		/decl/hierarchy/outfit/job/medical/virologist = 2,
		/decl/hierarchy/outfit/job/science/scientist = 6,
		/decl/hierarchy/outfit/job/silicon = 2,
		/decl/hierarchy/outfit/nanotrasen/representative = 4,
		/decl/hierarchy/outfit/nanotrasen/officer = 2,
		/decl/hierarchy/outfit/pirate = 14,
		/decl/hierarchy/outfit/pirate/space = 6,
		/decl/hierarchy/outfit/wizard/blue = 2,
		/decl/hierarchy/outfit/spec_op_officer = 2,
		/decl/hierarchy/outfit/death_command = 2,
		/decl/hierarchy/outfit/syndicate = 2,
		/decl/hierarchy/outfit/syndicate/armored/commando = 2,
		/decl/hierarchy/outfit/tunnel_clown = 2,
		/decl/hierarchy/outfit/masked_killer = 2,
		/decl/hierarchy/outfit/reaper = 2,
		/decl/hierarchy/outfit/standard_space_gear = 10,
		/decl/hierarchy/outfit/soviet_soldier = 2
	)

	var/items_to_spawn = list(
		/obj/item/reagent_containers/syringe/drugs,
		/obj/item/storage/pill_bottle/happy,
		/obj/item/storage/pill_bottle/zoom,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/box/donut,
		/obj/item/storage/box/anti_photons,
		/obj/item/storage/box/fragshells,
		/obj/item/storage/box/secret_project_disks/science,
		/obj/item/storage/box/supermatters,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/imp_imprinting,
		/obj/item/storage/bouquet/shotgun,
		/obj/item/storage/bible/booze,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/storage/belt/soulstone/full,
		/obj/item/storage/firstaid/combat,
		/obj/item/storage/firstaid/surgery/syndie,
		/obj/item/storage/secure/briefcase/nukedisk,
		/obj/item/storage/secure/briefcase/money,
		/obj/item/tank/jetpack/carbondioxide,
		/obj/item/tank/jetpack/oxygen,
		/obj/item/tank/plasma/onetankbomb,
		/obj/item/teleportation_scroll,
		/obj/item/vampiric,
		/obj/item/stock_parts/manipulator/femto,
		/obj/item/stock_parts/scanning_module/triphasic,
		/obj/item/stock_parts/micro_laser/quadultra,
		/obj/item/stock_parts/matter_bin/bluespace,
		/obj/item/stock_parts/capacitor/rectangular,
		/obj/item/staff,
		/obj/item/staff/plague_bell,
		/obj/item/stack/telecrystal/bluespace_crystal,
		/obj/item/stack/telecrystal,
		/obj/item/stack/material/animalhide/cat,
		/obj/item/stack/material/animalhide/corgi,
		/obj/item/stack/material/animalhide/goat,
		/obj/item/stack/material/animalhide/human,
		/obj/item/stack/material/animalhide/lizard,
		/obj/item/stack/material/animalhide/monkey,
		/obj/item/stack/material/animalhide/xeno,
		/obj/item/stack/material/deuterium/fifty,
		/obj/item/stack/material/diamond/ten,
		/obj/item/stack/material/gold/ten,
		/obj/item/stack/material/plasma/fifty,
		/obj/item/stack/material/leather,
		/obj/item/stack/material/xenochitin,
		/obj/item/stack/material/xenochitin,
		/obj/item/soap,
		/obj/item/soap/deluxe,
		/obj/item/soap/gold,
		/obj/item/soap/syndie,
		/obj/item/soap/nanotrasen,
		/obj/item/skull,
		/obj/item/shield/adamantineshield,
		/obj/item/shield/energy,
		/obj/item/shield/riot,
		/obj/item/shield/buckler,
		/obj/item/scrying,
		/obj/item/resonator/upgraded,
		/obj/item/reagent_containers/spray/hair_grower,
		/obj/item/reagent_containers/spray/hair_remover,
		/obj/item/reagent_containers/hypospray/vial,
		/obj/item/reagent_containers/vessel/bottle/chemical/adminordrazine,
		/obj/item/reagent_containers/vessel/bottle/chemical/small/chloralhydrate,
		/obj/item/reagent_containers/vessel/bottle/chemical/small/cyanide,
		/obj/item/reagent_containers/vessel/bottle/chemical/big/compost,
		/obj/item/reagent_containers/vessel/bottle/chemical/nanites,
		/obj/item/reagent_containers/vessel/bottle/pwine,
		/obj/item/reagent_containers/vessel/bottle/holywater,
		/obj/item/reagent_containers/vessel/can/machpellabeer,
		/obj/item/plastique,
		/obj/item/pinpointer/nukeop,
		/obj/item/pickaxe/sledgehammer,
		/obj/item/pickaxe/diamond,
		/obj/item/orion_ship,
		/obj/item/oreportal,
		/obj/item/music_tape/custom,
		/obj/item/melee/energy/axe,
		/obj/item/material/twohanded/chainsaw,
		/obj/item/material/twohanded/fireaxe,
		/obj/item/material/sword/katana,
		/obj/item/material/scythe,
		/obj/item/material/brass_knuckle,
		/obj/item/material/knife/butch/kitchen/syndie,
		/obj/item/lazarus_injector,
		/obj/item/magic_rock,
		/obj/item/instrument/violin,
		/obj/item/instrument/accordion,
		/obj/item/instrument/saxophone,
		/obj/item/gun/energy/meteorgun,
		/obj/item/gun/energy/mindflayer,
		/obj/item/gun/energy/plasmastun,
		/obj/item/gun/energy/retro,
		/obj/item/gun/energy/gun/nuclear,
		/obj/item/gun/energy/accelerator,
		/obj/item/gun/energy/sniperrifle,
		/obj/item/gun/energy/staff/animate,
		/obj/item/gun/energy/staff/focus,
		/obj/item/gun/energy/toxgun,
		/obj/item/gun/flamer/full,
		/obj/item/gun/launcher/grenade/loaded,
		/obj/item/gun/launcher/alien/slugsling,
		/obj/item/gun/launcher/alien/spikethrower,
		/obj/item/gun/launcher/money/hacked,
		/obj/item/gun/launcher/net,
		/obj/item/gun/launcher/rocket,
		/obj/item/gun/portalgun,
		/obj/item/gun/whip_of_torment,
		/obj/item/gun/projectile/pirate,
		/obj/item/gun/projectile/shotgun/doublebarrel/flare,
		/obj/item/gun/projectile/revolver/webley,
		/obj/item/gun/projectile/revolver/deckard,
		/obj/item/gun/projectile/pistol/gyropistol,
		/obj/item/gun/projectile/magic/bloodchill,
		/obj/item/gun/projectile/dartgun/vox/medical,
		/obj/item/gun/projectile/dartgun/vox/raider,
		/obj/item/grenade/spawnergrenade/manhacks,
		/obj/item/golem_shell,
		/obj/item/foldchair,
		/obj/item/diseasedisk/premade = 5,
		/obj/item/device/soulstone = 5,
		/obj/item/device/personal_shield,
		/obj/item/device/multitool/hacktool,
		/obj/item/defibrillator/compact/combat/loaded,
		/obj/item/contraband/poster,
		/obj/item/corncob,
		/obj/item/bikehorn/vuvuzela,
		/obj/item/bikehorn,
		/obj/item/blueprints,
		/obj/item/asteroid/beholder_eye,
		/obj/item/clothing/head/tinfoil,
		/obj/item/clothing/ring/seal/mason,
		/obj/item/clothing/ring/magic,
		/obj/item/clothing/glasses/hud/psychoscope,
		/obj/item/capturedevice/hacked
	)

/obj/gatecrasher_spawn/Initialize(mapload, obj/structure/closet/existing_closet = null)
	. = ..(mapload)

	// Choosing/spawning a closet
	var/obj/structure/closet/C
	if(existing_closet)
		C = existing_closet
	else
		var/closet_type = util_pick_weight(possible_containers)
		C = new closet_type(loc)

	// Spawning the gatecrasher
	var/mob/living/carbon/human/gatecrasher/H = new /mob/living/carbon/human/gatecrasher(loc)

	// Magically randomizing the gatecrasher
	randomize_appearance(H)
	equip_outfit(H)
	H.update_dna()
	H.update_icon()
	H.forceMove(C) // Not spawning the dude right in the closet to make sure all the things get updated correctly

	// Spawning 2 to 6 funny items
	var/list/_items_to_spawn = list()
	var/num_items_to_spawn = rand(2, 6)
	for(var/i = 0, i < num_items_to_spawn, i++)
		_items_to_spawn.Add(pick(items_to_spawn))
	create_objects_in_loc(C, _items_to_spawn)

	// Snowflake birbs
	if(H.species.name == SPECIES_VOX)
		new /obj/item/storage/box/vox(C)

	// Finalizing the glorious act of shitspawning
	H.controllable = TRUE
	GLOB.available_mobs_for_possess["\ref[H]"] += H
	notify_ghosts("A gatecrasher has appeared at the station!", source = H, action = NOTIFY_POSSES, posses_mob = TRUE)
	log_debug("A possessable gatecrasher [H] has been spawned at: x = [x], y = [y], z = [z].")

	return INITIALIZE_HINT_QDEL

/obj/gatecrasher_spawn/proc/randomize_appearance(mob/living/carbon/human/M)
	M.set_species(util_pick_weight(species))

	M.randomize_gender()
	M.randomize_skin_tone()
	M.s_tone = random_skin_tone(M.species)

	M.randomize_hair_color()
	M.change_facial_hair_color(M.r_hair, M.g_hair, M.b_hair)
	M.randomize_hair_style()
	M.randomize_facial_hair_style()

	if(!(M.species.species_appearance_flags & HAS_EYE_COLOR))
		M.change_eye_color(arglist(GetHexColors(M.species.default_eye_color)))
	else
		M.randomize_eye_color()

	var/new_body_build = pick(M.species.get_body_build_datum_list(M.gender))
	if(new_body_build)
		M.change_body_build(new_body_build)

	if(prob(70)) // 44% to be normal, 14% for each of four other heights
		M.body_height = pick(body_heights)
		M.update_transform()

	M.SetName(M.species.get_random_name(M.gender))
	M.real_name = M.name

#define OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR 0x0002
#define OUTFIT_ADJUSTMENT_SKIP_ID_PDA        0x0004
#define OUTFIT_ADJUSTMENT_PLAIN_HEADSET      0x0008

/obj/gatecrasher_spawn/proc/equip_outfit(mob/living/carbon/human/M)
	var/adjustments = 0
	adjustments = prob(30) ? (adjustments|OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR) : adjustments
	adjustments = prob(70) ? (adjustments|OUTFIT_ADJUSTMENT_SKIP_ID_PDA)        : adjustments
	adjustments = prob(50) ? (adjustments|OUTFIT_ADJUSTMENT_PLAIN_HEADSET)      : adjustments

	var/decl/hierarchy/outfit/O = outfit_by_type(util_pick_weight(outfits_to_spawn))
	O.equip(M, equip_adjustments = adjustments)

#undef OUTFIT_ADJUSTMENT_SKIP_SURVIVAL_GEAR
#undef OUTFIT_ADJUSTMENT_SKIP_ID_PDA
#undef OUTFIT_ADJUSTMENT_PLAIN_HEADSET
