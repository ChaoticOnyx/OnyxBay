#define BUILDSTAGE_INITIAL      0
#define BUILDSTAGE_CIRCUITBOARD 1
#define BUILDSTAGE_SIGNALER     2
#define BUILDSTAGE_HATCH        3
#define BUILDSTAGE_ARMOR_ATTACH 4
#define BUILDSTAGE_ARMOR_WELD   5

/obj/structure/turret_control_frame
	name = "Turret control panel frame"
	anchored = TRUE
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_assembly"

	/// Current stage of the building process
	var/buildstage = BUILDSTAGE_INITIAL
	/// Signaler that will be used in completed panel
	var/obj/item/device/assembly/signaler/signaler = null
	/// Type of the panel
	var/target_type = /obj/machinery/turret_control_panel

/obj/structure/turret_control_frame/Initialize(mapload, _signaler, _buildstage)
	. = ..()
	if(issignaler(_signaler))
		signaler = _signaler
		signaler.forceMove(src)

	if(_buildstage)
		buildstage = _buildstage

/obj/structure/turret_control_frame/attackby(obj/item/I, mob/user)
	switch(buildstage)
		if(BUILDSTAGE_INITIAL)
			if(isWrench(I) && !anchored)
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				show_splash_text(user, "Bolts secured")
				anchored = TRUE
				buildstage = BUILDSTAGE_CIRCUITBOARD
				return

			else if(isCrowbar(I) && !anchored)
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				new /obj/item/stack/material/steel(get_turf(src), 5)
				qdel_self()
				return

		if(BUILDSTAGE_CIRCUITBOARD)
			if(istype(I, /obj/item/circuitboard/turret_control_panel) && user.drop(I, src))
				show_splash_text(user, "Circuitboard installed")
				buildstage = BUILDSTAGE_SIGNALER

		if(BUILDSTAGE_SIGNALER)
			if(issignaler(I) && user.drop(I))
				show_splash_text(user, "Signaler installed")
				signaler = I
				buildstage = BUILDSTAGE_HATCH
				return

		if(BUILDSTAGE_HATCH)
			if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				buildstage = BUILDSTAGE_ARMOR_ATTACH
				show_splash_text(user, "Internal access hatch closed")
				return

		if(BUILDSTAGE_ARMOR_ATTACH)
			if(istype(I, /obj/item/stack/material) && I.get_material_name() == MATERIAL_STEEL)
				var/obj/item/stack/M = I
				if(M.use(2))
					show_splash_text(user, "External armor attached")
					buildstage = BUILDSTAGE_ARMOR_WELD
				else
					show_splash_text(user, "Not enough metal!")
				return

			else if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				buildstage = BUILDSTAGE_HATCH
				show_splash_text(user, "Internal access hatch opened!")
				return

		if(BUILDSTAGE_ARMOR_WELD)
			if(isWelder(I))
				var/obj/item/weldingtool/WT = I
				if(!WT.isOn())
					return

				if(WT.get_fuel() < 5)
					show_splash_text(user, "Not enough fuel!")

				playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				if(do_after(user, 30, src))
					if(QDELETED(src) || !WT.remove_fuel(5, user))
						return

					show_splash_text(user, "External armor welded")

					//The final step: create a full turret control panel
					var/obj/machinery/turret_control_panel/tcp = new target_type(get_turf(src), signaler)
					tcp.enabled = FALSE

					qdel_self()

			else if(isCrowbar(I))
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				show_splash_text(user, "External armor detached!")
				new /obj/item/stack/material/steel(loc, 2)
				buildstage = BUILDSTAGE_ARMOR_ATTACH
				return

/obj/structure/turret_control_frame/attack_hand(mob/user)
	switch(buildstage)
		if(BUILDSTAGE_HATCH)
			if(!signaler)
				return

			if(user.pick_or_drop(signaler))
				signaler = null
				show_splash_text(user, "Signaler removed!")
				buildstage = BUILDSTAGE_SIGNALER

		if(BUILDSTAGE_SIGNALER)
			show_splash_text(user, "Circuitboard removed!")
			new /obj/item/circuitboard/turret_control_panel(get_turf(src))
			buildstage = BUILDSTAGE_CIRCUITBOARD

/obj/item/circuitboard/turret_control_panel
	name = "circuitboard (sentry turret)"
	board_type = "machine"
	origin_tech = list(TECH_DATA = 4, TECH_ENGINEERING = 4)

#undef BUILDSTAGE_INITIAL
#undef BUILDSTAGE_CIRCUITBOARD
#undef BUILDSTAGE_SIGNALER
#undef BUILDSTAGE_HATCH
#undef BUILDSTAGE_ARMOR_ATTACH
#undef BUILDSTAGE_ARMOR_WELD
