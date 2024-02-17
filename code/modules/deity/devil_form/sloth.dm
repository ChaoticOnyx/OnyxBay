#define SIN_SLOTH_BEGINNER 0
#define SIN_SLOTH_BLASPHEMER 3
#define SIN_SLOTH_SACRILEGE 6
#define SIN_SLOTH_ULTIMATE 10
#define DEFAULT_TELEPORT_TIME 8 SECONDS

/datum/deity_power/structure/devil_teleport
	build_distance = 0
	health_max = 200
	power_path = /obj/structure/deity/devil_teleport

/datum/spell/hand/build_teleport
	name = "Build teleport"
	desc = "BUILD TELEPORT!"
	feedback = "BT"
	school = "inferno"
	spell_flags = 0
	invocation_type = SPI_NONE
	spell_delay = 2 SECONDS
	icon_state = "wiz_marsh"
	override_base = "const"
	charge_max = 2 MINUTES

/datum/spell/hand/build_teleport/cast_hand(atom/A, mob/user)
	var/datum/deity_power/structure/devil_teleport/dt = locate(/datum/deity_power/structure/devil_teleport) in connected_god.form?.buildables
	ASSERT(dt)
	dt.manifest(A, connected_god)

/obj/structure/deity/devil_teleport
	name = "Teleport"
	desc = "TELEPORT."
	icon_state = "jew"
	var/destination

/obj/structure/deity/devil_teleport/Initialize(mapload)
	. = ..()
	var/area/A = get_area(src)
	destination = A.name

/obj/structure/deity/devil_teleport/Destroy()
	return ..()

/obj/structure/deity/devil_teleport/attack_hand(mob/user)
	if(user.mind?.godcultist?.linked_deity == linked_deity || user.mind?.deity == linked_deity)
		teleport(user)

/obj/structure/deity/devil_teleport/proc/teleport(mob/user)
	var/list/possible_destinations = list()
	for(var/obj/structure/deity/devil_teleport/tp in linked_deity.buildings)
		if(tp == src)
			continue

		possible_destinations.Add(tp.destination)

	var/destination = tgui_input_list(user, "Choose a destination", "Teleport", sort_list(possible_destinations))

	for(var/obj/structure/deity/devil_teleport/tp in linked_deity.buildings)
		if(tp.destination != destination)
			continue

		var/obj/effect/devilsteleport/portal_effect = new /obj/effect/devilsteleport(get_turf(user))
		spawn(0)
			animate(portal_effect, alpha = 255, time = DEFAULT_TELEPORT_TIME / 1.2, flags = ANIMATION_PARALLEL)
			animate(user, alpha = 0, time = DEFAULT_TELEPORT_TIME, flags = ANIMATION_PARALLEL)
		if(!do_after(user, DEFAULT_TELEPORT_TIME, src, FALSE))
			animate(user, alpha = 255, time = 2)
			qdel(portal_effect)
			return

		qdel(portal_effect)
		user.forceMove(get_turf(tp))
		user.alpha = 255

/obj/effect/devilsteleport
	icon_state = "portal"
	icon = 'icons/obj/cult.dmi'
	anchored = TRUE
	mouse_opacity = 0
	alpha = 100
