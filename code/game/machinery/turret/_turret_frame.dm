#define BUILDSTAGE_INITIAL       0
#define BUILDSTAGE_IARMOR_ATTACH 1
#define BUILDSTAGE_IARMOR_WELD   2
#define BUILDSTAGE_PROX          3
#define BUILDSTAGE_SIGNALLER     4
#define BUILIDSTAGE_HATCH        5
#define BUILDSTAGE_EARMOR_ATTACH 6
#define BUILDSTAGE_EARMOR_WELD   7

/obj/machinery/turret_frame
	name = "turret frame"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_frame"
	density = TRUE
	/// Type of the turret
	var/target_type = /obj/machinery/turret
	/// Current stage of the building process
	var/build_step = BUILDSTAGE_INITIAL
	/// Signaler that will be used in completed turret
	var/obj/item/device/assembly/signaler/signaler = null

/obj/machinery/turret_frame/attackby(obj/item/I, mob/user)
	switch(build_step)
		if(BUILDSTAGE_INITIAL)
			if(isWrench(I) && !anchored)
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				show_splash_text(user, "Bolts secured")
				anchored = TRUE
				build_step = BUILDSTAGE_IARMOR_ATTACH
				return

			else if(isCrowbar(I) && !anchored)
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				new /obj/item/stack/material/steel(get_turf(src), 5)
				qdel_self()
				return

		if(BUILDSTAGE_IARMOR_ATTACH)
			if(istype(I, /obj/item/stack/material) && I.get_material_name() == MATERIAL_STEEL)
				var/obj/item/stack/M = I
				if(M.use(2))
					show_splash_text(user, "Internal armor installed")
					build_step = BUILDSTAGE_IARMOR_WELD
					icon_state = "turret_frame2"
				else
					show_splash_text(user, "Not enough metal!")
				return

			else if(isWrench(I))
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				show_splash_text(user, "Bolts unfastened")
				anchored = FALSE
				build_step = BUILDSTAGE_INITIAL
				return

		if(BUILDSTAGE_IARMOR_WELD)
			if(isWrench(I))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				show_splash_text(user, "Internal armor secured")
				build_step = BUILDSTAGE_PROX
				return

			else if(isWelder(I))
				var/obj/item/weldingtool/WT = I
				if(!WT.isOn())
					return
				if(WT.get_fuel() < 5)
					show_splash_text(user, "Not enough fuel!")
					return

				playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				if(do_after(user, 20, src))
					if(!QDELETED(src) || !WT.remove_fuel(5, user))
						return

					build_step = BUILDSTAGE_IARMOR_ATTACH
					show_splash_text(user, "Internal armor removed!")
					new /obj/item/stack/material/steel(get_turf(src), 2)
					return

		if(BUILDSTAGE_PROX)
			if(isprox(I))
				if(!user.drop(I))
					return

				show_splash_text(user, "Prox sensor attached")
				qdel(I)
				build_step = BUILDSTAGE_SIGNALLER
				return

		if(BUILDSTAGE_SIGNALLER)
			if(issignaler(I))
				if(!user.drop(I))
					return

				show_splash_text(user, "Signaler attached")
				signaler = I
				build_step = BUILIDSTAGE_HATCH
				return

		if(BUILIDSTAGE_HATCH)
			if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = BUILDSTAGE_EARMOR_ATTACH
				show_splash_text(user, "Internal access hatch closed")
				return

		if(BUILDSTAGE_EARMOR_ATTACH)
			if(istype(I, /obj/item/stack/material) && I.get_material_name() == MATERIAL_STEEL)
				var/obj/item/stack/M = I
				if(M.use(2))
					show_splash_text(user, "External armor attached")
					build_step = BUILDSTAGE_EARMOR_WELD
				else
					show_splash_text(user, "Not enough metal!")
				return

			else if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				build_step = BUILIDSTAGE_HATCH
				show_splash_text(user, "Internal access hatch opened!")
				return

		if(BUILDSTAGE_EARMOR_WELD)
			if(isWelder(I))
				var/obj/item/weldingtool/WT = I
				if(!WT.isOn())
					return

				if(WT.get_fuel() < 5)
					to_chat(user, "<span class='notice'>You need more fuel to complete this task.</span>")

				playsound(loc, pick('sound/items/Welder.ogg', 'sound/items/Welder2.ogg'), 50, 1)
				if(do_after(user, 30, src))
					if(!QDELETED(src) || !WT.remove_fuel(5, user))
						return

					show_splash_text(user, "External armor welded")

					//The final step: create a full turret
					var/obj/machinery/turret/T = new target_type(get_turf(src), signaler)
					T.enabled = FALSE

					qdel_self()

			else if(isCrowbar(I))
				playsound(loc, 'sound/items/Crowbar.ogg', 75, 1)
				show_splash_text(user, "External armor detached!")
				new /obj/item/stack/material/steel(loc, 2)
				build_step = BUILDSTAGE_EARMOR_ATTACH
				return

/obj/machinery/turret_frame/attack_hand(mob/user)
	switch(build_step)
		if(BUILIDSTAGE_HATCH)
			if(!signaler)
				return

			if(user.pick_or_drop(signaler))
				signaler = null
				show_splash_text(user, "Signaler detached!")
				build_step = BUILDSTAGE_PROX

		if(BUILDSTAGE_SIGNALLER)
			show_splash_text(user, "Proximity sensor detached!")
			new /obj/item/device/assembly/prox_sensor(loc)
			build_step = BUILDSTAGE_PROX

#undef BUILDSTAGE_INITIAL
#undef BUILDSTAGE_IARMOR_ATTACH
#undef BUILDSTAGE_IARMOR_WELD
#undef BUILDSTAGE_PROX
#undef BUILDSTAGE_SIGNALLER
#undef BUILIDSTAGE_HATCH
#undef BUILDSTAGE_EARMOR_ATTACH
#undef BUILDSTAGE_EARMOR_WELD
