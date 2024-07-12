#define BUILDSTAGE_INITIAL       0
#define BUILDSTAGE_IARMOR_ATTACH 1
#define BUILDSTAGE_IARMOR_WELD   2
#define BUILDSTAGE_PROX          3
#define BUILDSTAGE_SIGNALLER     4
#define BUILDSTAGE_HATCH        5
#define BUILDSTAGE_EARMOR_ATTACH 6
#define BUILDSTAGE_EARMOR_WELD   7

/obj/machinery/turret_frame
	name = "turret frame"
	icon = 'icons/obj/turrets.dmi'
	icon_state = "turret_frame"
	density = TRUE
	/// Type of the turret
	var/target_type = /obj/machinery/turret/network
	/// Current stage of the building process
	var/buildstage = BUILDSTAGE_INITIAL
	/// Signaler that will be used in completed turret
	var/obj/item/device/assembly/signaler/signaler = null

/obj/machinery/turret_frame/Initialize(mapload, _signaler, _buildstage)
	. = ..()
	if(issignaler(_signaler))
		signaler = _signaler
		signaler.forceMove(src)

	if(_buildstage)
		buildstage = _buildstage

	register_context()

/obj/machinery/turret_frame/add_context(list/context, obj/item/held_item, mob/user)
	. = NONE

	if(isnull(held_item))
		switch(buildstage)
			if(BUILDSTAGE_HATCH)
				if(!signaler)
					context[SCREENTIP_CONTEXT_LMB] = "Remove signaler"
					return CONTEXTUAL_SCREENTIP_SET

			if(BUILDSTAGE_SIGNALLER)
				context[SCREENTIP_CONTEXT_LMB] = "Remove sensor"
				return CONTEXTUAL_SCREENTIP_SET

	switch(buildstage)
		if(BUILDSTAGE_INITIAL)
			if(isWrench(held_item) && !anchored)
				context[SCREENTIP_CONTEXT_LMB] = "Secure bolts"
				return CONTEXTUAL_SCREENTIP_SET

			else if(isCrowbar(held_item) && !anchored)
				context[SCREENTIP_CONTEXT_LMB] = "Disassemble"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_IARMOR_ATTACH)
			if(istype(held_item, /obj/item/stack/material) && held_item.get_material_name() == MATERIAL_STEEL)
				context[SCREENTIP_CONTEXT_LMB] = "Install internal armor"
				return CONTEXTUAL_SCREENTIP_SET

			else if(isWrench(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Unfasten bolts"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_IARMOR_WELD)
			if(isWrench(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Secure internal armor"
				return CONTEXTUAL_SCREENTIP_SET

			else if(isWelder(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Remove internal armor"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_PROX)
			if(isprox(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Attach sensor"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_SIGNALLER)
			if(issignaler(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Attach signaler"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_HATCH)
			if(isScrewdriver(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Close hatch"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_EARMOR_ATTACH)
			if(istype(held_item, /obj/item/stack/material) &&held_item.get_material_name() == MATERIAL_STEEL)
				context[SCREENTIP_CONTEXT_LMB] = "Install external armor"
				return CONTEXTUAL_SCREENTIP_SET

			else if(isScrewdriver(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Open hatch"
				return CONTEXTUAL_SCREENTIP_SET

		if(BUILDSTAGE_EARMOR_WELD)
			if(isWelder(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Weld external armor"
				return CONTEXTUAL_SCREENTIP_SET

			else if(isCrowbar(held_item))
				context[SCREENTIP_CONTEXT_LMB] = "Remove external armor"
				return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/turret_frame/attackby(obj/item/I, mob/user)
	switch(buildstage)
		if(BUILDSTAGE_INITIAL)
			if(isWrench(I) && !anchored)
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				show_splash_text(user, "Bolts secured")
				anchored = TRUE
				buildstage = BUILDSTAGE_IARMOR_ATTACH
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
					buildstage = BUILDSTAGE_IARMOR_WELD
					icon_state = "turret_frame2"
				else
					show_splash_text(user, "Not enough metal!")
				return

			else if(isWrench(I))
				playsound(loc, 'sound/items/Ratchet.ogg', 75, 1)
				show_splash_text(user, "Bolts unfastened")
				anchored = FALSE
				buildstage = BUILDSTAGE_INITIAL
				return

		if(BUILDSTAGE_IARMOR_WELD)
			if(isWrench(I))
				playsound(loc, 'sound/items/Ratchet.ogg', 100, 1)
				show_splash_text(user, "Internal armor secured")
				buildstage = BUILDSTAGE_PROX
				return

			else if(isWelder(I))
				var/obj/item/weldingtool/WT = I
				if(!WT.use_tool(src, user, delay = 4 SECONDS, amount = 5))
					return

				if(QDELETED(src) || !user)
					return

				buildstage = BUILDSTAGE_IARMOR_ATTACH
				show_splash_text(user, "Internal armor removed!")
				new /obj/item/stack/material/steel(get_turf(src), 2)
				return

		if(BUILDSTAGE_PROX)
			if(isprox(I))
				if(!user.drop(I, src))
					return

				show_splash_text(user, "Prox sensor attached")
				qdel(I)
				buildstage = BUILDSTAGE_SIGNALLER
				return

		if(BUILDSTAGE_SIGNALLER)
			if(issignaler(I))
				if(!user.drop(I, src))
					return

				show_splash_text(user, "Signaler attached")
				signaler = I
				buildstage = BUILDSTAGE_HATCH
				return

		if(BUILDSTAGE_HATCH)
			if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				buildstage = BUILDSTAGE_EARMOR_ATTACH
				show_splash_text(user, "Internal access hatch closed")
				return

		if(BUILDSTAGE_EARMOR_ATTACH)
			if(istype(I, /obj/item/stack/material) && I.get_material_name() == MATERIAL_STEEL)
				var/obj/item/stack/M = I
				if(M.use(2))
					show_splash_text(user, "External armor attached")
					buildstage = BUILDSTAGE_EARMOR_WELD
				else
					show_splash_text(user, "Not enough metal!")
				return

			else if(isScrewdriver(I))
				playsound(loc, 'sound/items/Screwdriver.ogg', 100, 1)
				buildstage = BUILDSTAGE_HATCH
				show_splash_text(user, "Internal access hatch opened!")
				return

		if(BUILDSTAGE_EARMOR_WELD)
			if(isWelder(I))
				var/obj/item/weldingtool/WT = I
				if(!WT.use_tool(src, user, delay = 3 SECONDS, amount = 5))
					return FALSE

				if(QDELETED(src) || !user)
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
				buildstage = BUILDSTAGE_EARMOR_ATTACH
				return

/obj/machinery/turret_frame/attack_hand(mob/user)
	switch(buildstage)
		if(BUILDSTAGE_HATCH)
			if(!signaler)
				buildstage = BUILDSTAGE_PROX
				return

			if(user.pick_or_drop(signaler))
				signaler = null
				show_splash_text(user, "Signaler detached!")
				buildstage = BUILDSTAGE_PROX

		if(BUILDSTAGE_SIGNALLER)
			show_splash_text(user, "Proximity sensor detached!")
			new /obj/item/device/assembly/prox_sensor(loc)
			buildstage = BUILDSTAGE_PROX

#undef BUILDSTAGE_INITIAL
#undef BUILDSTAGE_IARMOR_ATTACH
#undef BUILDSTAGE_IARMOR_WELD
#undef BUILDSTAGE_PROX
#undef BUILDSTAGE_SIGNALLER
#undef BUILDSTAGE_HATCH
#undef BUILDSTAGE_EARMOR_ATTACH
#undef BUILDSTAGE_EARMOR_WELD
