/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	//Mining resources (for the large drills).
	var/has_resources
	var/list/resources

	var/thermite = 0
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to
	var/dirt = 0

/turf/simulated/post_change()
	..()
	var/turf/T = GetAbove(src)
	if(istype(T,/turf/space) || (density && istype(T, /turf/simulated/open)))
		var/new_turf_type = density ? (istype(T.loc, /area/space) ? /turf/simulated/floor/plating/airless : /turf/simulated/floor/plating) : /turf/simulated/open
		T.ChangeTurf(new_turf_type)

// This is not great.
/turf/simulated/proc/wet_floor(wet_val = 1, overwrite = FALSE)
	if(wet_val < wet && !overwrite)
		return

	if(!wet)
		wet = wet_val
		wet_overlay = image('icons/effects/water.dmi',src,"wet_floor")
		AddOverlays(wet_overlay)

	try_add_think_ctx("unwet_context", CALLBACK(src, nameof(.proc/unwet_floor)), world.time + 20 SECONDS)

/turf/simulated/proc/unwet_floor(check_very_wet = TRUE)
	if(check_very_wet && wet >= 2)
		wet--
		set_next_think_ctx("unwet_context", world.time + 20 SECONDS)
		return

	wet = 0
	if(wet_overlay)
		CutOverlays(wet_overlay)
		wet_overlay = null

	remove_think_ctx("unwet_context")

/turf/simulated/clean_blood()
	for(var/obj/effect/decal/cleanable/blood/B in contents)
		B.clean_blood()
	return ..()

/turf/simulated/New()
	..()
	if(istype(loc, /area/chapel))
		holy = TRUE
	levelupdate()

/turf/simulated/proc/AddTracks(typepath,bloodDNA,comingdir,goingdir,bloodcolor=COLOR_BLOOD_HUMAN)
	var/obj/effect/decal/cleanable/blood/tracks/tracks = locate(typepath) in src
	if(!tracks)
		tracks = new typepath(src)
	tracks.AddTracks(bloodDNA,comingdir,goingdir,bloodcolor)

/turf/simulated/proc/update_dirt()
	dirt = min(dirt+1, 101)
	var/obj/effect/decal/cleanable/dirt/dirtoverlay = locate(/obj/effect/decal/cleanable/dirt, src)
	if (dirt > 50)
		if (!dirtoverlay)
			dirtoverlay = new /obj/effect/decal/cleanable/dirt(src)
		dirtoverlay.alpha = min((dirt - 50) * 5, 255)

/turf/simulated/remove_cleanables()
	dirt = 0
	. = ..()

/turf/simulated/Entered(atom/A, atom/OL)
	if(isliving(A))
		var/mob/living/M = A

		var/need_update_dirt = TRUE

		if(M.buckled && !istype(M.buckled, /obj/structure/bed/chair/wheelchair)) // No bloody trails for rollerbedded dudes pls
			return ..()

		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			// Tracking blood
			var/list/bloodDNA = null
			var/bloodcolor = ""

			if(H.shoes)
				var/obj/item/clothing/accessory/shoe_covers/SC = H.shoes
				if(istype(SC))
					SC.handle_movement(src, (H.m_intent == M_RUN ? 1 : 0), TRUE)
					need_update_dirt = FALSE
				else
					var/obj/item/clothing/shoes/S = H.shoes
					if(istype(S))
						S.handle_movement(src, (H.m_intent == M_RUN ? 1 : 0))
						if(S.get_accessory_cover())
							need_update_dirt = FALSE
						if(S.track_blood)
							if(S.blood_DNA)
								bloodDNA = S.blood_DNA
							bloodcolor = S.blood_color
							S.track_blood--

			else if(H.track_blood)
				if(H.feet_blood_DNA)
					bloodDNA = H.feet_blood_DNA
				bloodcolor = H.feet_blood_color
				H.track_blood--

			if(bloodDNA)
				AddTracks(H.species.get_move_trail(H), bloodDNA, H.dir, 0, bloodcolor) // Coming
				var/turf/simulated/from = get_step(H, reverse_direction(H.dir))
				if(istype(from) && from)
					from.AddTracks(H.species.get_move_trail(H), bloodDNA, 0, H.dir, bloodcolor) // Going

				bloodDNA = null

		// Dirt overlays.
		if(need_update_dirt)
			update_dirt()

		if(M.lying)
			return ..()

		if(wet)
			if(M.buckled)
				return // TODO: Lube-drifting wheelchairs aka dejavu

			if(M.m_intent == M_WALK && prob(min(100, 100 / (wet / 10))))
				return

			var/slip_dist = 1
			var/slip_stun = 3
			var/floor_type = "wet"

			if(wet >= 2) // Lube
				floor_type = "slippery"
				slip_dist = 4
				slip_stun = 6

			if(M.slip("the [floor_type] floor", slip_stun))
				for(var/i = 1 to slip_dist)
					step(M, M.dir)
					sleep(1)

	..()

//returns 1 if made bloody, returns 0 otherwise
/turf/simulated/add_blood(source)
	if(!ishuman(source))
		return FALSE // Meh, fuck it, if you'll ever need the add_blood("#abcdef") behavior - just go ahead code it yourself. ~ToTh
	. = ..()
	if(!.)
		return

	var/mob/living/carbon/human/M = source
	for(var/obj/effect/decal/cleanable/blood/B in contents)
		if(!B.blood_DNA)
			B.blood_DNA = list()
		if(!B.blood_DNA[M.dna.unique_enzymes])
			B.blood_DNA[M.dna.unique_enzymes] = M.dna.b_type
			B.virus2 = virus_copylist(M.virus2)
		return
	blood_splatter(src, M.get_blood(M.vessel), 1)

// Only adds blood on the floor -- Skie
/turf/simulated/proc/add_blood_floor(mob/living/carbon/M as mob)
	if( istype(M, /mob/living/carbon/alien ))
		var/obj/effect/decal/cleanable/blood/xeno/this = new /obj/effect/decal/cleanable/blood/xeno(src)
		this.blood_DNA["UNKNOWN BLOOD"] = "X*"
	else if( istype(M, /mob/living/silicon/robot ))
		new /obj/effect/decal/cleanable/blood/oil(src)

/turf/simulated/proc/can_build_cable(mob/user)
	return 0

/turf/simulated/attackby(obj/item/thing, mob/user)
	if(isCoil(thing) && can_build_cable(user))
		var/obj/item/stack/cable_coil/coil = thing
		coil.turf_place(src, user)
		return
	return ..()
