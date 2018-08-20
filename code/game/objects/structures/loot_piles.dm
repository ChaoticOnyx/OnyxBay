/*
Basically, each player key gets one chance per loot pile to get them phat lewt.
When they click the pile, after a delay, they 'roll' if they get anything, using chance_nothing.  If they're unlucky, they get nothing.
Otherwise, they roll up to two times, first a roll for rare things, using chance_rare.  If they succeed, they get something quite good.
If that roll fails, they do one final roll, using chance_uncommon.  If they succeed, they get something fairly useful.
If that fails again, they walk away with some common junk.

The same player cannot roll again, however other players can.  This has two benefits.  The first benefit is that someone raiding all of
maintenance will not deprive other people from a shot at loot, and that for the surface variants, it quietly encourages bringing along
buddies, to get more chances at getting cool things instead of someone going solo to hoard all the stuff.

Loot piles can be depleted, if loot_depleted is turned on.  Note that players who searched the pile already won't deplete the loot furthers when searching again.
*/

/obj/structure/loot_pile
	name = "base loot pile"
	desc = "If you can read me, this is bugged"
	description_info = "This can be searched by clicking on it and waiting a few seconds.  You might find valuable treasures or worthless junk. \
	These can only searched each once per player."
	icon = 'icons/obj/loot_piles.dmi'
	icon_state = "randompile"
	density = FALSE
	anchored = TRUE

	var/list/icon_states_to_use = list() // List of icon states the pile can choose from on initialization. If empty or null, it will stay the initial icon_state.

	var/list/searched_by = list()	// Keys that have searched this loot pile, with values of searched time.
	var/allow_multiple_looting = FALSE	// If true, the same person can loot multiple times.  Mostly for debugging.
	var/busy = FALSE				// Used so you can't spamclick to loot.

	var/chance_nothing = 0			// Unlucky people might need to loot multiple spots to find things.

	var/chance_uncommon = 10		// Probability of pulling from the uncommon_loot list.
	var/chance_rare = 1				// Ditto, but for rare_loot list.
	var/loot_depletion = FALSE		// If true, loot piles can be 'depleted' after a certain number of searches by different players, where no more loot can be obtained.
	var/loot_left = 0				// When this reaches zero, and loot_depleted is true, you can't obtain anymore loot.
	var/delete_on_depletion = FALSE	// If true, and if the loot gets depleted as above, the pile is deleted.

	var/list/common_loot = list()	// Common is generally less-than-useful junk and filler, at least for maint loot piles.
	var/list/uncommon_loot = list()	// Uncommon is actually maybe some useful items, usually the reason someone bothers looking inside.
	var/list/rare_loot = list()		// Rare is really powerful, or at least unique items.

/obj/structure/loot_pile/attack_hand(mob/user)
	//Human mob
	if(isliving(user))
		var/mob/living/L = user

		if(busy)
			to_chat(L, "<span class='warning'>\The [src] is already being searched.</span>")
			return

		L.visible_message("[user] searches through \the [src].","<span class='notice'>You search through \the [src].</span>")

		//Do the searching
		busy = TRUE
		if(do_after(user,rand(4 SECONDS,6 SECONDS),src))
			// The loot's all gone.
			if(loot_depletion && loot_left <= 0)
				to_chat(L, "<span class='warning'>\The [src] has been picked clean.</span>")
				busy = FALSE
				return

			//You already searched this one
			if( (user.ckey in searched_by) && !allow_multiple_looting)
				to_chat(L, "<span class='warning'>You can't find anything else vaguely useful in \the [src].  Another set of eyes might, however.</span>")
				busy = FALSE
				return

			// You got unlucky.
			if(chance_nothing && prob(chance_nothing))
				to_chat(L, "<span class='warning'>Nothing in this pile really catches your eye...</span>")
				searched_by |= user.ckey
				busy = FALSE
				return

			// You found something!
			var/obj/item/loot = null
			var/span = "notice" // Blue

			if(prob(chance_rare) && rare_loot.len) // You won THE GRAND PRIZE!
				loot = produce_rare_item()
				span = "cult" // Purple and bold.

			else if(prob(chance_uncommon) && uncommon_loot.len) // Otherwise you might still get something good.
				loot = produce_uncommon_item()
				span = "alium" // Green

			else // Welp.
				loot = produce_common_item()

			if(loot)
				searched_by |= user.ckey
				loot.forceMove(get_turf(src))
				to_chat(L, "<span class='[span]'>You found \a [loot]!</span>")
				if(loot_depletion)
					loot_left--
					if(loot_left <= 0)
						to_chat(L, "<span class='warning'>You seem to have gotten the last of the spoils inside \the [src].</span>")
						if(delete_on_depletion)
							qdel(src)

		busy = FALSE
	else
		return ..()

/obj/structure/loot_pile/proc/produce_common_item()
	var/path = pick(common_loot)
	return new path(src)

/obj/structure/loot_pile/proc/produce_uncommon_item()
	var/path = pick(uncommon_loot)
	return new path(src)

/obj/structure/loot_pile/proc/produce_rare_item()
	var/path = pick(rare_loot)
	return new path(src)

/obj/structure/loot_pile/Initialize()
	if(icon_states_to_use && icon_states_to_use.len)
		icon_state = pick(icon_states_to_use)
	. = ..()

// Has large amounts of possible items, most of which may or may not be useful.
/obj/structure/loot_pile/maint/junk
	name = "pile of junk"
	desc = "Lots of junk lying around.  They say one man's trash is another man's treasure."
	icon_states_to_use = list("junk_pile1", "junk_pile2", "junk_pile3", "junk_pile4", "junk_pile5")

	common_loot = list(
		/obj/item/device/flashlight/flare,
		/obj/item/device/flashlight/glowstick,
		/obj/item/device/flashlight/glowstick/blue,
		/obj/item/device/flashlight/glowstick/orange,
		/obj/item/device/flashlight/glowstick/red,
		/obj/item/device/flashlight/glowstick/yellow,
		/obj/item/device/flashlight/pen,
		/obj/item/weapon/cell,
		/obj/item/weapon/cell/device,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/breath,
		/obj/item/weapon/reagent_containers/glass/rag,
		/obj/item/weapon/reagent_containers/food/snacks/liquidfood,
		/obj/item/weapon/storage/secure/briefcase,
		/obj/item/weapon/storage/briefcase,
		/obj/item/weapon/storage/backpack,
		/obj/item/weapon/storage/backpack/satchel,
		/obj/item/weapon/storage/backpack/dufflebag,
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/wallet,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/shoes/black,
		/obj/item/clothing/shoes/leather,
		/obj/item/clothing/gloves/white,
		/obj/item/clothing/gloves/rainbow,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/glasses/meson,
		/obj/item/clothing/glasses/meson/prescription,
		/obj/item/clothing/glasses/welding,
		/obj/item/clothing/head/bio_hood/general,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat/red,
		/obj/item/clothing/head/ushanka,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/space/emergency,
		/obj/item/clothing/suit/storage/toggle/bomber,
		/obj/item/clothing/suit/bio_suit/general,
		/obj/item/clothing/suit/storage/toggle/hoodie/black,
		/obj/item/clothing/suit/storage/toggle/brown_jacket,
		/obj/item/clothing/under/color/grey,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/weapon/camera_assembly,
		/obj/item/weapon/caution,
		/obj/item/weapon/caution/cone,
		/obj/item/weapon/card/emag_broken,
		/obj/item/device/camera,
		/obj/item/device/pda,
		/obj/item/device/radio/headset,
		/obj/item/device/paicard
	)

	uncommon_loot = list(
		/obj/item/clothing/shoes/syndigaloshes,
		/obj/item/clothing/under/tactical,
		/obj/item/weapon/beartrap,
		/obj/item/weapon/material/butterfly/switchblade
	)

	rare_loot = list(
	)

// Contains mostly useless garbage.
/obj/structure/loot_pile/maint/trash
	name = "pile of trash"
	desc = "Lots of garbage in one place.  Might be able to find something if you're in the mood for dumpster diving."
	icon_states_to_use = list("trash_pile1", "trash_pile2")

	common_loot = list(
		/obj/item/trash/candle,
		/obj/item/trash/candy,
		/obj/item/trash/candy/proteinbar,
		/obj/item/trash/cheesie,
		/obj/item/trash/chips,
		/obj/item/trash/liquidfood,
		/obj/item/trash/pistachios,
		/obj/item/trash/plate,
		/obj/item/trash/popcorn,
		/obj/item/trash/raisins,
		/obj/item/trash/semki,
		/obj/item/trash/snack_bowl,
		/obj/item/trash/sosjerky,
		/obj/item/trash/syndi_cakes,
		/obj/item/trash/tastybread,
		/obj/item/trash/tray,
		/obj/item/trash/waffles,
		/obj/item/weapon/reagent_containers/food/snacks/mysterysoup,
		/obj/item/stack/rods{amount = 5},
		/obj/item/stack/material/steel{amount = 5},
		/obj/item/stack/material/cardboard{amount = 5},
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/material/wirerod,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/newspaper,
		/obj/item/weapon/paper/crumpled,
		/obj/item/weapon/paper/crumpled/bloody
	)

	uncommon_loot = list(
		/obj/item/weapon/reagent_containers/syringe/steroid,
		/obj/item/weapon/storage/pill_bottle/zoom,
		/obj/item/weapon/storage/pill_bottle/happy,
		/obj/item/weapon/storage/pill_bottle/tramadol
	)

// Contains loads of different types of boxes, which may have items inside!
/obj/structure/loot_pile/maint/boxfort
	name = "pile of boxes"
	desc = "A large pile of boxes sits here."
	density = TRUE
	icon_states_to_use = list("boxfort")

	common_loot = list(
		/obj/item/weapon/storage/box,
		/obj/item/weapon/storage/box/beakers,
		/obj/item/weapon/storage/box/botanydisk,
		/obj/item/weapon/storage/box/cups,
		/obj/item/weapon/storage/box/donkpockets,
		/obj/item/weapon/storage/box/donut,
		/obj/item/weapon/storage/box/donut/empty,
		/obj/item/weapon/storage/box/evidence,
		/obj/item/weapon/storage/box/lights/mixed,
		/obj/item/weapon/storage/box/lights/tubes,
		/obj/item/weapon/storage/box/lights/bulbs,
		/obj/item/weapon/storage/box/masks,
		/obj/item/weapon/storage/box/ids,
		/obj/item/weapon/storage/box/mousetraps,
		/obj/item/weapon/storage/box/syringes,
		/obj/item/weapon/storage/box/survival,
		/obj/item/weapon/storage/box/gloves,
		/obj/item/weapon/storage/box/PDAs
	)

	uncommon_loot = list(
		/obj/item/weapon/storage/box/sinpockets,
		/obj/item/weapon/storage/box/practiceshells,
		/obj/item/weapon/storage/box/blanks,
		/obj/item/weapon/storage/box/smokes,
		/obj/item/weapon/storage/box/handcuffs,
		/obj/item/weapon/storage/box/seccarts
	)

	rare_loot = list(
		/obj/item/weapon/storage/box/flashbangs,
		/obj/item/weapon/storage/box/flashshells,
		/obj/item/weapon/storage/box/stunshells,
		/obj/item/weapon/storage/box/teargas
	)

// One of the more useful maint piles, contains electrical components.
/obj/structure/loot_pile/maint/technical
	name = "broken machine"
	desc = "A destroyed machine with unknown purpose, and doesn't look like it can be fixed.  It might still have some functional components?"
	density = TRUE
	icon_states_to_use = list("technical_pile1", "technical_pile2", "technical_pile3")

	common_loot = list(
		/obj/item/weapon/stock_parts/console_screen,
		/obj/item/weapon/stock_parts/capacitor,
		/obj/item/weapon/stock_parts/capacitor/adv,
		/obj/item/weapon/stock_parts/capacitor/super,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/manipulator/nano,
		/obj/item/weapon/stock_parts/manipulator/pico,
		/obj/item/weapon/stock_parts/matter_bin,
		/obj/item/weapon/stock_parts/matter_bin/adv,
		/obj/item/weapon/stock_parts/matter_bin/super,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/scanning_module/adv,
		/obj/item/weapon/stock_parts/scanning_module/phasic,
		/obj/item/weapon/stock_parts/subspace/amplifier,
		/obj/item/weapon/stock_parts/subspace/analyzer,
		/obj/item/weapon/stock_parts/subspace/ansible,
		/obj/item/weapon/stock_parts/subspace/crystal,
		/obj/item/weapon/stock_parts/subspace/transmitter,
		/obj/item/weapon/stock_parts/subspace/treatment,
		/obj/item/frame,
		/obj/item/borg/upgrade/restart,
		/obj/item/weapon/cell,
		/obj/item/weapon/cell/high,
		/obj/item/weapon/cell/device,
		/obj/item/weapon/circuitboard/broken,
		/obj/item/weapon/circuitboard/arcade,
		/obj/item/weapon/circuitboard/autolathe,
		/obj/item/weapon/circuitboard/atmos_alert,
		/obj/item/weapon/circuitboard/message_monitor,
		/obj/item/weapon/circuitboard/rcon_console,
		/obj/item/weapon/smes_coil,
		/obj/item/weapon/cartridge/engineering,
		/obj/item/device/analyzer,
		/obj/item/device/healthanalyzer,
		/obj/item/device/robotanalyzer,
		/obj/item/device/lightreplacer,
		/obj/item/device/radio,
		/obj/item/device/hailer,
		/obj/item/device/gps,
		/obj/item/device/geiger,
		/obj/item/device/mass_spectrometer,
		/obj/item/weapon/wrench,
		/obj/item/weapon/screwdriver,
		/obj/item/weapon/wirecutters,
		/obj/item/device/multitool,
		/obj/item/mecha_parts/mecha_equipment/generator,
		/obj/item/mecha_parts/mecha_equipment/tool/cable_layer,
		/obj/item/mecha_parts/mecha_equipment/tool/drill,
		/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/tool/passenger,
		/obj/item/mecha_parts/mecha_equipment/tool/sleeper,
		/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
		/obj/item/robot_parts/robot_component/binary_communication_device,
		/obj/item/robot_parts/robot_component/armour,
		/obj/item/robot_parts/robot_component/actuator,
		/obj/item/robot_parts/robot_component/camera,
		/obj/item/robot_parts/robot_component/diagnosis_unit,
		/obj/item/robot_parts/robot_component/radio
	)

	uncommon_loot = list(
		/obj/item/weapon/cell/super,
		/obj/item/weapon/circuitboard/crew,
		/obj/item/weapon/aiModule/reset,
		/obj/item/weapon/smes_coil/super_capacity,
		/obj/item/weapon/smes_coil/super_io,
		/obj/item/weapon/cartridge/captain,
		/obj/item/device/tvcamera,
		/obj/item/borg/upgrade/jetpack,
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/tasercooler,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser,
		/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,
		/obj/item/rig_module/device/drill,
		/obj/item/rig_module/device/healthscanner,
		/obj/item/rig_module/device/orescanner,
		/obj/item/rig_module/device/anomaly_scanner,
		/obj/item/rig_module/datajack,
		/obj/item/rig_module/vision/medhud,
		/obj/item/rig_module/vision/meson,
		/obj/item/rig_module/vision/sechud,
	)

	rare_loot = list(
		/obj/item/weapon/cell/hyper,
		/obj/item/weapon/aiModule/freeform,
		/obj/item/weapon/aiModule/asimov,
		/obj/item/weapon/aiModule/paladin,
		/obj/item/weapon/aiModule/safeguard,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	)


// Surface base type
/obj/structure/loot_pile/surface
	// Surface loot piles are considerably harder and more dangerous to reach, so you're more likely to get rare things.
	chance_uncommon = 20
	chance_rare = 5
	loot_depletion = TRUE
	loot_left = 5 // This is to prevent people from asking the whole station to go down to some alien ruin to get massive amounts of phat lewt.


// Subtype for mecha and mecha accessories. These might not always be on the surface.
/obj/structure/loot_pile/mecha
	name = "pod wreckage"
	desc = "The ruins of some unfortunate pod. Perhaps something is salvageable."
	icon = 'icons/mecha/mecha.dmi'
	icon_state = "engineering_pod-broken"
	density = TRUE

	chance_uncommon = 20
	chance_rare = 10

	loot_depletion = TRUE
	loot_left = 9

	common_loot = list(
		/obj/random/tool,
		/obj/random/tool,
		/obj/random/tool,
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 40}
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser,
		/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/tool/drill,
		/obj/item/mecha_parts/mecha_equipment/generator
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		/obj/item/mecha_parts/mecha_equipment/generator/nuclear,
		)

//Stuff you may find attached to a ripley.
/obj/structure/loot_pile/mecha/ripley
	name = "ripley wreckage"
	desc = "The ruins of some unfortunate ripley. Perhaps something is salvageable."
	icon_states_to_use = list("ripley-broken", "firefighter-broken", "ripley-broken-old")

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 25},
		/obj/item/stack/material/glass{amount = 10},
		/obj/item/stack/material/plasteel{amount = 5},
		/obj/item/mecha_parts/chassis/ripley,
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg,
		/obj/item/device/kit/paint/ripley,
		/obj/item/device/kit/paint/ripley/flames_red,
		/obj/item/device/kit/paint/ripley/flames_blue
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tool/hydraulic_clamp,
		/obj/item/mecha_parts/mecha_equipment/tool/drill/diamonddrill,
		/obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/gravcatapult,
		/obj/item/mecha_parts/mecha_equipment/tool/rcd,
		)

//Death-Ripley, same common, but more combat-exosuit-based
/obj/structure/loot_pile/mecha/deathripley
	name = "strange ripley wreckage"
	icon_state = "deathripley-broken"

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 40},
		/obj/item/stack/material/glass{amount = 20},
		/obj/item/stack/material/plasteel{amount = 10},
		/obj/item/mecha_parts/chassis/ripley,
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg,
		/obj/item/device/kit/paint/ripley/death
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tool/safety_clamp,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/riggedlaser,
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tool/rcd,
		/obj/item/mecha_parts/mecha_equipment/wormhole_generator,
		)

/obj/structure/loot_pile/mecha/odysseus
	name = "odysseus wreckage"
	desc = "The ruins of some unfortunate odysseus. Perhaps something is salvageable."
	icon_state = "odysseus-broken"

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 25},
		/obj/item/stack/material/glass{amount = 10},
		/obj/item/stack/material/plasteel{amount = 5},
		/obj/item/mecha_parts/chassis/odysseus,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tool/sleeper,
		/obj/item/mecha_parts/mecha_equipment/tool/syringe_gun,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flare,
		/obj/item/mecha_parts/mecha_equipment/tool/extinguisher,
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/gravcatapult,
		)

/obj/structure/loot_pile/mecha/gygax
	name = "gygax wreckage"
	desc = "The ruins of some unfortunate gygax. Perhaps something is salvageable."
	icon_state = "gygax-broken"

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 25},
		/obj/item/stack/material/glass{amount = 10},
		/obj/item/stack/material/plasteel{amount = 5},
		/obj/item/mecha_parts/chassis/gygax,
		/obj/item/mecha_parts/part/gygax_head,
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_armour
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser,
		/obj/item/device/kit/paint/gygax,
		/obj/item/device/kit/paint/gygax/darkgygax,
		/obj/item/device/kit/paint/gygax/recitence
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg,
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
		)

/obj/structure/loot_pile/mecha/durand
	name = "durand wreckage"
	desc = "The ruins of some unfortunate durand. Perhaps something is salvageable."
	icon_state = "durand-broken"

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 25},
		/obj/item/stack/material/glass{amount = 10},
		/obj/item/stack/material/plasteel{amount = 5},
		/obj/item/mecha_parts/chassis/durand,
		/obj/item/mecha_parts/part/durand_head,
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_armour
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser,
		/obj/item/device/kit/paint/durand,
		/obj/item/device/kit/paint/durand/seraph,
		/obj/item/device/kit/paint/durand/phazon
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay,
		/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot,
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
		)

/obj/structure/loot_pile/mecha/phazon
	name = "phazon wreckage"
	desc = "The ruins of some unfortunate phazon. Perhaps something is salvageable."
	icon_state = "phazon-broken"

	common_loot = list(
		/obj/item/stack/material/plasteel{amount = 20},
		/obj/item/mecha_parts/chassis/phazon,
		/obj/item/mecha_parts/part/phazon_head,
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg
		)

	uncommon_loot = list(
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy,
		)

	rare_loot = list(
		/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay,
		/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion,
		/obj/item/mecha_parts/mecha_equipment/repair_droid,
		/obj/item/mecha_parts/mecha_equipment/teleporter
		)

/obj/structure/loot_pile/surface/drone
	name = "drone wreckage"
	desc = "The ruins of some unfortunate drone. Perhaps something is salvageable."
	icon = 'icons/mob/animal.dmi'
	icon_state = "drone_dead"

// Since the actual drone loot is a bit stupid in how it is handled, this is a sparse and empty list with items I don't exactly want in it. But until we can get the proper items in . . .

	common_loot = list(
		/obj/random/tool,
		/obj/item/stack/cable_coil/random,
		/obj/random/tank,
		/obj/item/stack/material/steel{amount = 25},
		/obj/item/stack/material/glass{amount = 10},
		/obj/item/stack/material/plasteel{amount = 5},
		/obj/item/weapon/cell,
		/obj/item/weapon/material/shard
		)

	uncommon_loot = list(
		/obj/item/weapon/cell/high,
		/obj/item/robot_parts/robot_component/actuator,
		/obj/item/robot_parts/robot_component/armour,
		/obj/item/robot_parts/robot_component/binary_communication_device,
		/obj/item/robot_parts/robot_component/camera,
		/obj/item/robot_parts/robot_component/diagnosis_unit,
		/obj/item/robot_parts/robot_component/radio
		)

	rare_loot = list(
		/obj/item/weapon/cell/super,
		/obj/item/borg/upgrade/restart,
		/obj/item/borg/upgrade/jetpack,
		/obj/item/borg/upgrade/tasercooler,
		/obj/item/borg/upgrade/syndicate,
		/obj/item/borg/upgrade/vtec
		)