#define GLASS_AIRLOCK_HIT_SOUND pick('sound/effects/materials/glass/knock1.ogg', 'sound/effects/materials/glass/knock2.ogg', 'sound/effects/materials/glass/knock3.ogg')

//regular airlock presets

//////////////////////////////////////////
/obj/machinery/door/airlock/command
	name = "Airlock"
	icon = 'icons/obj/doors/doorcom.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_com

//////////////////////////////////////////
/obj/machinery/door/airlock/security
	name = "Airlock"
	icon = 'icons/obj/doors/doorsec.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_sec

//////////////////////////////////////////
/obj/machinery/door/airlock/engineering
	name = "Airlock"
	icon = 'icons/obj/doors/dooreng.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_eng

//////////////////////////////////////////
/obj/machinery/door/airlock/medical
	name = "Airlock"
	icon = 'icons/obj/doors/doormed.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_med

//////////////////////////////////////////
/obj/machinery/door/airlock/virology
	name = "Airlock"
	icon = 'icons/obj/doors/doorviro.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_viro

//////////////////////////////////////////
/obj/machinery/door/airlock/maintenance
	name = "Maintenance Access"
	icon = 'icons/obj/doors/doormaint.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_mai

//////////////////////////////////////////
/obj/machinery/door/airlock/external
	name = "External Airlock"
	icon = 'icons/obj/doors/doorext.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_ext
	open_sound_powered = list('sound/machines/airlock/open_exterior1.ogg', 'sound/machines/airlock/open_exterior2.ogg', 'sound/machines/airlock/open_exterior3.ogg', 'sound/machines/airlock/open_exterior4.ogg')
	open_sound_unpowered = list('sound/machines/airlock/open_exterior1.ogg', 'sound/machines/airlock/open_exterior2.ogg', 'sound/machines/airlock/open_exterior3.ogg', 'sound/machines/airlock/open_exterior4.ogg')

/obj/machinery/door/airlock/external/bolted
	icon_state = "door_locked"
	locked = 1

/obj/machinery/door/airlock/external/bolted/cycling
	frequency = 1379

/obj/machinery/door/airlock/external/bolted_open
	icon_state = "door_open"
	density = 0
	locked = 1
	opacity = 0

/obj/machinery/door/airlock/external/snow
	icon = 'icons/obj/doors/doorextsnow.dmi'

//////////////////////////////////////////
/obj/machinery/door/airlock/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/doorglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	glass = 1
	open_sound_powered = 'sound/machines/airlock/glass_open1.ogg'
	close_sound_powered = 'sound/machines/airlock/glass_close1.ogg'

/obj/machinery/door/airlock/glass/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass/museum
	name = "Museum Airlock"

//////////////////////////////////////////
/obj/machinery/door/airlock/centcom
	name = "Airlock"
	icon = 'icons/obj/doors/doorele.dmi'
	opacity = 0

	explosion_block = 2
/obj/machinery/door/airlock/centcom/Process()
	return PROCESS_KILL

//////////////////////////////////////////
/obj/machinery/door/airlock/vault
	name = "Vault"
	icon = 'icons/obj/doors/vault.dmi'
	explosion_resistance = 20
	opacity = 1
	secured_wires = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity //Until somebody makes better sprites.

	explosion_block = 2
/obj/machinery/door/airlock/vault/bolted
	icon_state = "door_locked"
	locked = 1

//////////////////////////////////////////
/obj/machinery/door/airlock/freezer
	name = "Freezer Airlock"
	icon = 'icons/obj/doors/doorfreezer.dmi'
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_fre

//////////////////////////////////////////
/obj/machinery/door/airlock/hatch
	name = "Airtight Hatch"
	icon = 'icons/obj/doors/doorhatchele.dmi'
	explosion_resistance = 20
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_hatch

//////////////////////////////////////////
/obj/machinery/door/airlock/maintenance_hatch
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorhatchmaint2.dmi'
	explosion_resistance = 20
	opacity = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_mhatch

/obj/machinery/door/airlock/maintenance_hatch/bolted
	locked = 1
	icon_state = "door_locked"

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_command
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorcomglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_com
	glass = 1

/obj/machinery/door/airlock/glass_command/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_external
	name = "External Airlock"
	icon = 'icons/obj/doors/doorextglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_ext
	glass = 1

/obj/machinery/door/airlock/glass_external/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

/obj/machinery/door/airlock/glass_external/bolted
	icon_state = "door_locked"
	locked = 1

/obj/machinery/door/airlock/glass_external/bolted/cycling
	frequency = 1379

/obj/machinery/door/airlock/glass_external/bolted_open
	icon_state = "door_open"
	density = 0
	locked = 1
	opacity = 0

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_engineering
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorengglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_eng
	glass = 1

/obj/machinery/door/airlock/glass_engineering/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_security
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorsecglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_sec
	glass = 1

/obj/machinery/door/airlock/glass_security/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_medical
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doormedglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_med
	glass = 1

/obj/machinery/door/airlock/glass_medical/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_virology
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorviroglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_viro
	glass = 1

/obj/machinery/door/airlock/glass_virology/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/mining
	name = "Mining Airlock"
	icon = 'icons/obj/doors/doormining.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_min

//////////////////////////////////////////
/obj/machinery/door/airlock/atmos
	name = "Atmospherics Airlock"
	icon = 'icons/obj/doors/dooratmo.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo

//////////////////////////////////////////
/obj/machinery/door/airlock/research
	name = "Airlock"
	icon = 'icons/obj/doors/doorresearch.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_research

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_research
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorresearchglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_research
	glass = 1
	heat_proof = 1

/obj/machinery/door/airlock/glass_research/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_mining
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/doorminingglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_min
	glass = 1

/obj/machinery/door/airlock/glass_mining/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_atmos
	name = "Maintenance Hatch"
	icon = 'icons/obj/doors/dooratmoglass.dmi'
	hitsound = null
	maxhealth = 300
	explosion_resistance = 5
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_atmo
	glass = 1

/obj/machinery/door/airlock/glass_atmos/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/gold
	name = "Gold Airlock"
	icon = 'icons/obj/doors/doorgold.dmi'
	mineral = MATERIAL_GOLD

//////////////////////////////////////////
/obj/machinery/door/airlock/silver
	name = "Silver Airlock"
	icon = 'icons/obj/doors/doorsilver.dmi'
	mineral = MATERIAL_SILVER

//////////////////////////////////////////
/obj/machinery/door/airlock/diamond
	name = "Diamond Airlock"
	icon = 'icons/obj/doors/doordiamond.dmi'
	mineral = MATERIAL_DIAMOND

	explosion_block = 2
//////////////////////////////////////////
/obj/machinery/door/airlock/uranium
	name = "Uranium Airlock"
	desc = "And they said I was crazy."
	icon = 'icons/obj/doors/dooruranium.dmi'
	mineral = MATERIAL_URANIUM

/obj/machinery/door/airlock/uranium/Initialize()
	. = ..()

	create_reagents()
	reagents.add_reagent(/datum/reagent/uranium, 2 * REAGENTS_PER_MATERIAL_SHEET, null, FALSE)

//////////////////////////////////////////
/obj/machinery/door/airlock/plasma
	name = "Plasma Airlock"
	desc = "No way this can end badly."
	icon = 'icons/obj/doors/doorplasma.dmi'
	mineral = MATERIAL_PLASMA

/obj/machinery/door/airlock/plasma/attackby(obj/C, mob/user)
	if(C)
		ignite(C.get_temperature_as_from_ignitor())
	..()

/obj/machinery/door/airlock/plasma/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/ignite(exposed_temperature)
	if(exposed_temperature > 300)
		PlasmaBurn(exposed_temperature)

/obj/machinery/door/airlock/plasma/proc/PlasmaBurn(temperature)
	for(var/turf/simulated/floor/target_tile in range(2,loc))
		target_tile.assume_gas("plasma", 35, 400+T0C)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/turf/simulated/wall/W in range(3,src))
		W.burn((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)
	new /obj/structure/door_assembly( src.loc )
	qdel(src)

//////////////////////////////////////////
/obj/machinery/door/airlock/sandstone
	name = "Sandstone Airlock"
	icon = 'icons/obj/doors/doorsand.dmi'
	mineral = MATERIAL_SANDSTONE

//////////////////////////////////////////
/obj/machinery/door/airlock/science
	name = "Airlock"
	icon = 'icons/obj/doors/doorsci.dmi'
	assembly_type = /obj/structure/door_assembly/door_assembly_science

//////////////////////////////////////////
/obj/machinery/door/airlock/glass_science
	name = "Glass Airlocks"
	icon = 'icons/obj/doors/doorsciglass.dmi'
	opacity = 0
	assembly_type = /obj/structure/door_assembly/door_assembly_science
	glass = 1

/obj/machinery/door/airlock/glass_science/Initialize()
	. = ..()
	hitsound = GLASS_AIRLOCK_HIT_SOUND

//////////////////////////////////////////
/obj/machinery/door/airlock/highsecurity
	name = "Secure Airlock"
	explosion_block = 2
	icon = 'icons/obj/doors/hightechsecurity.dmi'
	explosion_resistance = 20
	secured_wires = 1
	assembly_type = /obj/structure/door_assembly/door_assembly_highsecurity

/obj/machinery/door/airlock/highsecurity/bolted
	icon_state = "door_locked"
	locked = 1
