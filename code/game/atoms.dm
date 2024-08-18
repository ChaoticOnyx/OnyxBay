/atom
	var/level = 2
	var/atom_flags
	var/effect_flags
	var/list/blood_DNA
	var/is_bloodied
	var/was_bloodied
	var/blood_color
	var/last_bumped = 0
	var/pass_flags = 0
	var/throwpass = 0
	var/hitby_sound = null
	var/hitby_loudness_multiplier = 1.0
	var/germ_level = GERM_LEVEL_AMBIENT // The higher the germ level, the more germ on the atom.
	var/simulated = 1 //filter for actions - used by lighting overlays
	var/fluorescent // Shows up under a UV light.

	///Value used to increment ex_act() if reactionary_explosions is on
	var/explosion_block = 0

	///Proximity monitor associated with this atom
	var/datum/proximity_monitor/proximity_monitor

	///Chemistry.
	var/datum/reagents/reagents = null

	//var/chem_is_open_container = 0
	// replaced by OPENCONTAINER flags and atom/proc/is_open_container()
	///Chemistry.

	var/list/climbers

	var/tf_scale_x  // The atom's base transform scale for width.
	var/tf_scale_y  // The atom's base transform scale for height.
	var/tf_rotation // The atom's base transform scale for rotation.
	var/tf_offset_x // The atom's base transform scale for horizontal offset.
	var/tf_offset_y // The atom's base transform scale for vertical offset.

	/// Last name used to calculate a color for the chatmessage overlays. Used for caching.
	var/chat_color_name
	/// Last color calculated for the the chatmessage overlays. Used for caching.
	var/chat_color
	var/chat_color_darkened

	/// Icon state's name that can be used during icon generation as a base without impacting appearance of atom in mapping tools.
	var/base_icon_state

	/// This atom's cache of non-protected overlays, used for normal icon additions. Do not manipulate directly- See SSoverlays.
	var/list/atom_overlay_cache

	/// This atom's cache of overlays that can only be removed explicitly, like C4. Do not manipulate directly- See SSoverlays.
	var/list/atom_protected_overlay_cache

	/// This defines whether this atom will be added to SSpoi, set TRUE if you want it to be shown in follow panel
	var/is_poi = FALSE

/atom/New(loc, ...)
	CAN_BE_REDEFINED(TRUE)
	//atom creation method that preloads variables at creation
	if(GLOB.use_preloader && (src.type == GLOB._preloader.target_path))//in case the instanciated atom is creating other atoms in New()
		GLOB._preloader.load(src)

	var/do_initialize = SSatoms.init_state
	if(do_initialize != INITIALIZATION_INSSATOMS)
		args[1] = do_initialize == INITIALIZATION_INNEW_MAPLOAD
		if(SSatoms.InitAtom(src, args))
			//we were deleted
			return

	var/list/created = SSatoms.created_atoms
	if(created)
		created += src

	if(atom_flags & ATOM_FLAG_CLIMBABLE)
		verbs += /atom/proc/climb_on

//Called after New if the map is being loaded. mapload = TRUE
//Called from base of New if the map is not being loaded. mapload = FALSE
//This base must be called or derivatives must set initialized to TRUE
//must not sleep
//Other parameters are passed from New (excluding loc), this does not happen if mapload is TRUE
//Must return an Initialize hint. Defined in __DEFINES/subsystems.dm

/atom/proc/Initialize(mapload, ...)
	CAN_BE_REDEFINED(TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(atom_flags & ATOM_FLAG_INITIALIZED)
		util_crash_with("Warning: [src]([type]) initialized multiple times!")
	atom_flags |= ATOM_FLAG_INITIALIZED

	if(loc)
		SEND_SIGNAL(loc, SIGNAL_ATOM_INITIALIZED_ON, src) /// Sends a signal that the new atom `src`, has been created at `loc`

	if(light_max_bright && light_outer_range)
		update_light()

	if(opacity)
		updateVisibility(src)
		var/turf/T = loc
		if(istype(T))
			T.RecalculateOpacity()

	if(is_poi)
		SSpoints_of_interest.make_point_of_interest(src)

	return INITIALIZE_HINT_NORMAL

//called if Initialize returns INITIALIZE_HINT_LATELOAD
/atom/proc/LateInitialize()
	set waitfor = FALSE

/atom/proc/drop_location()
	var/atom/L = loc
	if(!L)
		return null
	return L.allow_drop() ? L : get_turf(L)

/atom/Entered(atom/movable/enterer, atom/old_loc)
	..()

	SEND_SIGNAL(src, SIGNAL_ENTERED, src, enterer, old_loc)

/atom/Exited(atom/movable/exitee, atom/new_loc)
	. = ..()

	SEND_SIGNAL(src, SIGNAL_EXITED, src, exitee, new_loc)

/atom/Destroy()
	QDEL_NULL(reagents)
	QDEL_NULL(proximity_monitor)
	ClearOverlays()
	underlays.Cut()
	return ..()

/atom/proc/reveal_blood()
	return

/atom/proc/assume_air(datum/gas_mixture/giver)
	return null

/atom/proc/remove_air(amount)
	return null

/atom/proc/return_air()
	if(loc)
		return loc.return_air()
	else
		return null

//return flags that should be added to the viewer's sight var.
//Otherwise return a negative number to indicate that the view should be cancelled.
/atom/proc/check_eye(user as mob)
	if (istype(user, /mob/living/silicon/ai)) // WHYYYY
		return 0
	return -1

/atom/proc/on_reagent_change()
	return

/atom/proc/Bumped(AM as mob|obj)
	return

// Convenience proc to see if a container is open for chemistry handling
// returns true if open
// false if closed
/atom/proc/is_open_container()
	return atom_flags & ATOM_FLAG_OPEN_CONTAINER

/*//Convenience proc to see whether a container can be accessed in a certain way.

	proc/can_subract_container()
		return flags & EXTRACT_CONTAINER

	proc/can_add_container()
		return flags & INSERT_CONTAINER
*/

/atom/proc/allow_drop()
	return FALSE

/atom/proc/CheckExit()
	return TRUE

// If you want to use this, the atom must have the PROXMOVE flag, and the moving
// atom must also have the PROXMOVE flag currently to help with lag. ~ ComicIronic
/atom/proc/HasProximity(atom/movable/AM)
	return

/atom/proc/emp_act(severity)
	return

/atom/proc/set_density(new_density)
	if(density != new_density)
		density = !!new_density

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	P.on_hit(src, 0, def_zone)
	. = 0

/atom/proc/in_contents_of(container)//can take class or object instance as argument
	if(ispath(container))
		if(istype(src.loc, container))
			return 1
	else if(src in container)
		return 1
	return

/*
 *	atom/proc/search_contents_for(path,list/filter_path=null)
 * Recursevly searches all atom contens (including contents contents and so on).
 *
 * ARGS: path - search atom contents for atoms of this type
 *	   list/filter_path - if set, contents of atoms not of types in this list are excluded from search.
 *
 * RETURNS: list of found atoms
 */

/atom/proc/search_contents_for(path,list/filter_path=null)
	var/list/found = list()
	for(var/atom/A in src)
		if(istype(A, path))
			found += A
		if(filter_path)
			var/pass = 0
			for(var/type in filter_path)
				pass |= istype(A, type)
			if(!pass)
				continue
		if(A.contents.len)
			found += A.search_contents_for(path,filter_path)
	return found




/*
Beam code by Gunbuddy

Beam() proc will only allow one beam to come from a source at a time.  Attempting to call it more than
once at a time per source will cause graphical errors.
Also, the icon used for the beam will have to be vertical and 32x32.
The math involved assumes that the icon is vertical to begin with so unless you want to adjust the math,
its easier to just keep the beam vertical.
*/
/atom/proc/Beam(atom/BeamTarget,icon_state="b_beam",icon='icons/effects/beam.dmi',time=50, maxdistance=10)
	//BeamTarget represents the target for the beam, basically just means the other end.
	//Time is the duration to draw the beam
	//Icon is obviously which icon to use for the beam, default is beam.dmi
	//Icon_state is what icon state is used. Default is b_beam which is a blue beam.
	//Maxdistance is the longest range the beam will persist before it gives up.
	var/EndTime=world.time+time
	while(BeamTarget&&world.time<EndTime&&get_dist(src,BeamTarget)<maxdistance&&z==BeamTarget.z)
	//If the BeamTarget gets deleted, the time expires, or the BeamTarget gets out
	//of range or to another z-level, then the beam will stop.  Otherwise it will
	//continue to draw.

		set_dir(get_dir(src,BeamTarget))	//Causes the source of the beam to rotate to continuosly face the BeamTarget.

		for(var/obj/effect/overlay/beam/O in orange(10,src))	//This section erases the previously drawn beam because I found it was easier to
			if(O.BeamSource==src)				//just draw another instance of the beam instead of trying to manipulate all the
				qdel(O)							//pieces to a new orientation.
		var/Angle=round(Get_Angle(src,BeamTarget))
		var/icon/I=new(icon,icon_state)
		I.Turn(Angle)
		var/DX=(32*BeamTarget.x+BeamTarget.pixel_x)-(32*x+pixel_x)
		var/DY=(32*BeamTarget.y+BeamTarget.pixel_y)-(32*y+pixel_y)
		var/N=0
		var/length=round(sqrt((DX)**2+(DY)**2))
		for(N,N<length,N+=32)
			var/obj/effect/overlay/beam/X=new(loc)
			X.BeamSource=src
			if(N+32>length)
				var/icon/II=new(icon,icon_state)
				II.DrawBox(null,1,(length-N),32,32)
				II.Turn(Angle)
				X.icon=II
			else X.icon=I
			var/Pixel_x=round(sin(Angle)+32*sin(Angle)*(N+16)/32)
			var/Pixel_y=round(cos(Angle)+32*cos(Angle)*(N+16)/32)
			if(DX==0) Pixel_x=0
			if(DY==0) Pixel_y=0
			if(Pixel_x>32)
				for(var/a=0, a<=Pixel_x,a+=32)
					X.x++
					Pixel_x-=32
			if(Pixel_x<-32)
				for(var/a=0, a>=Pixel_x,a-=32)
					X.x--
					Pixel_x+=32
			if(Pixel_y>32)
				for(var/a=0, a<=Pixel_y,a+=32)
					X.y++
					Pixel_y-=32
			if(Pixel_y<-32)
				for(var/a=0, a>=Pixel_y,a-=32)
					X.y--
					Pixel_y+=32
			X.pixel_x=Pixel_x
			X.pixel_y=Pixel_y
		sleep(3)	//Changing this to a lower value will cause the beam to follow more smoothly with movement, but it will also be more laggy.
					//I've found that 3 ticks provided a nice balance for my use.
	for(var/obj/effect/overlay/beam/O in orange(10,src)) if(O.BeamSource==src) qdel(O)

/atom/proc/examine(mob/user, infix = "")
	// This reformat names to get a/an properly working on item descriptions when they are bloody
	var/f_name = "\a [SPAN("info", "<em>[src][infix]</em>")]."
	if(is_bloodied && !istype(src, /obj/effect/decal))

		f_name = (gender == PLURAL) ? "some " : "a "

		if(blood_color != SYNTH_BLOOD_COLOUR)
			f_name += "<span class='danger'>blood-stained</span> [SPAN("info", "<em>[name][infix]</em>")]!"
		else
			f_name += "oil-stained [name][infix]."

	. = list("\icon[src] That's [f_name][infix]")
	. += desc

	return

/atom/proc/baked_examine(...)
	SHOULD_NOT_OVERRIDE(TRUE)

	var/content = "<div class='Examine'>"

	var/list/strings_list = examine(arglist(args))
	content += strings_list.Join("\n")
	content += "</div>"

	return content

// called by mobs when e.g. having the atom as their machine, pulledby, loc (AKA mob being inside the atom) or buckled var set.
// see code/modules/mob/mob_movement.dm for more.
/atom/proc/relaymove()
	return

//called to set the atom's dir and used to add behaviour to dir-changes
/atom/proc/set_dir(new_dir)
	var/old_dir = dir

	if(new_dir == old_dir)
		return FALSE

	dir = new_dir
	SEND_SIGNAL(src, SIGNAL_DIR_SET, src, old_dir, dir)

	return TRUE

/atom/proc/set_icon_state(new_icon_state)
	icon_state = new_icon_state
	update_icon()

/atom/proc/update_icon()
	if(QDELETED(src))
		return
	on_update_icon(arglist(args))
	return

/atom/proc/on_update_icon()
	return

/atom/proc/blob_act(damage)
	CAN_BE_REDEFINED(TRUE)
	return

/atom/proc/ex_act()
	CAN_BE_REDEFINED(TRUE)
	return

/atom/proc/emag_act(remaining_charges, mob/user, emag_source)
	CAN_BE_REDEFINED(TRUE)
	return NO_EMAG_ACT

/atom/proc/fire_act()
	CAN_BE_REDEFINED(TRUE)
	return

/atom/proc/melt()
	CAN_BE_REDEFINED(TRUE)
	return

/atom/proc/hitby(atom/movable/AM, speed = 0, nomsg = FALSE)
	if(density)
		AM.throwing = 0
		play_hitby_sound(AM)
		if(!nomsg)
			visible_message(SPAN("warning", "[src] was hit by \the [AM]."))
	return

/atom/proc/play_hitby_sound(atom/movable/AM)
	if(!hitby_sound)
		return
	var/sound_loudness = rand(65, 85)

	if(istype(AM, /obj/item/projectile))
		sound_loudness = 100
	if(isobj(AM))
		var/obj/O = AM
		sound_loudness = min(100, O.w_class * (O.throwforce ? 10 : 5) * hitby_loudness_multiplier)

	playsound(src, hitby_sound, sound_loudness, 1)


// returns TRUE if made bloody, returns FALSE otherwise
// accepts either a human or a hex color
/atom/proc/add_blood(source)
	if(atom_flags & ATOM_FLAG_NO_BLOOD)
		return FALSE

	if(!islist(blood_DNA)) // if our list of DNA doesn't exist yet (or isn't a list) initialise it.
		blood_DNA = list()

	is_bloodied = TRUE
	was_bloodied = TRUE

	if(ishuman(source))
		var/mob/living/carbon/human/M = source
		if(!istype(M.dna, /datum/dna))
			M.dna = new /datum/dna(null)
			M.dna.real_name = M.real_name
		M.check_dna()
		blood_color = M.species.get_blood_colour(M)
	else if(istext(source))
		blood_color = source
	else
		blood_color = COLOR_BLOOD_HUMAN
	return TRUE

/atom/proc/add_vomit_floor(mob/living/carbon/M, toxvomit = 0, datum/reagents/inject_reagents)
	if(istype(src, /turf/simulated))
		var/obj/effect/decal/cleanable/vomit/this = new /obj/effect/decal/cleanable/vomit(src)
		if(istype(inject_reagents) && inject_reagents.total_volume)
			inject_reagents.trans_to_obj(this, min(15, inject_reagents.total_volume))
			//this.reagents.add_reagent(/datum/reagent/acid/stomach, 5) //Gonna rework the vomiting system one day. ~Toby
		// Make toxins vomit look different
		if(toxvomit)
			this.icon_state = "vomittox_[pick(1,4)]"

/atom/proc/clean_blood()
	if(!simulated)
		return FALSE
	is_bloodied = FALSE
	fluorescent = 0
	germ_level = 0
	if(islist(blood_DNA))
		blood_DNA.Cut()
	blood_color = null
	return TRUE

/atom/proc/get_global_map_pos()
	if(!islist(GLOB.global_map) || isemptylist(GLOB.global_map)) return
	var/cur_x = null
	var/cur_y = null
	var/list/y_arr = null
	for(cur_x=1,cur_x<=GLOB.global_map.len,cur_x++)
		y_arr = GLOB.global_map[cur_x]
		cur_y = y_arr.Find(src.z)
		if(cur_y)
			break
//	log_debug("X = [cur_x]; Y = [cur_y]")

	if(cur_x && cur_y)
		return list("x"=cur_x,"y"=cur_y)
	else
		return 0

/atom/proc/isinspace()
	return istype(get_turf(src), /turf/space)

// Show a message to all mobs and objects in sight of this atom
// Use for objects performing visible actions
// message is output to anyone who can see, e.g. "The [src] does something!"
// blind_message (optional) is what blind people will hear e.g. "You hear something!"
/atom/proc/visible_message(message, blind_message, range = world.view, checkghosts = null)
	var/list/seeing_mobs = list()
	var/list/seeing_objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), range, seeing_mobs, seeing_objs, checkghosts)

	for(var/o in seeing_objs)
		var/obj/O = o
		O.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)

	for(var/m in seeing_mobs)
		var/mob/M = m
		if(M.see_invisible >= invisibility)
			M.show_message(message, VISIBLE_MESSAGE, blind_message, AUDIBLE_MESSAGE)
		else if(blind_message)
			M.show_message(blind_message, AUDIBLE_MESSAGE)

// Show a message to all mobs and objects in earshot of this atom
// Use for objects performing audible actions
// message is the message output to anyone who can hear.
// deaf_message (optional) is what deaf people will see.
// hearing_distance (optional) is the range, how many tiles away the message can be heard.
// spash_override replaces the runechatted message if provided. i.e. you can make the atom go "*beep*" instead of "The Machine states, "Bee ..."
/atom/proc/audible_message(message, deaf_message, hearing_distance = world.view, checkghosts = null, splash_override = null)
	var/list/hearing_mobs = list()
	var/list/hearing_objs = list()
	get_mobs_and_objs_in_view_fast(get_turf(src), hearing_distance, hearing_mobs, hearing_objs, checkghosts)

	for(var/o in hearing_objs)
		var/obj/O = o
		O.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)

	for(var/m in hearing_mobs)
		var/mob/M = m
		M.show_message(message, AUDIBLE_MESSAGE, deaf_message, VISIBLE_MESSAGE)
		if(M.get_preference_value("CHAT_RUNECHAT") == GLOB.PREF_YES)
			M.create_chat_message(src, splash_override ? splash_override : message)

/atom/movable/proc/dropInto(atom/destination)
	while(istype(destination))
		var/atom/drop_destination = destination.onDropInto(src)
		if(!istype(drop_destination) || drop_destination == destination)
			return forceMove(destination)
		destination = drop_destination
	return forceMove(null)

/atom/proc/onDropInto(atom/movable/AM)
	return // If onDropInto returns null, then dropInto will forceMove AM into us.

/atom/movable/onDropInto(atom/movable/AM)
	return loc // If onDropInto returns something, then dropInto will attempt to drop AM there.

/atom/proc/InsertedContents()
	return contents

//all things climbable

/atom/attack_hand(mob/user)
	..()
	if(LAZYLEN(climbers) && !LAZYISIN(climbers, user))
		user.visible_message("<span class='warning'>[user.name] shakes \the [src].</span>", \
					"<span class='notice'>You shake \the [src].</span>")
		object_shaken()

/atom/proc/climb_on()

	set name = "Climb"
	set desc = "Climbs onto an object."
	set category = "Object"
	set src in oview(1)

	do_climb(usr)

/atom/proc/can_climb(mob/living/user, post_climb_check=0)
	if (!(atom_flags & ATOM_FLAG_CLIMBABLE) || !can_touch(user) || (!post_climb_check && LAZYISIN(climbers, user)))
		return FALSE

	if(!user.Adjacent(src))
		show_splash_text(user, "can't climb!", SPAN_DANGER("You can't climb there, the way is blocked."))
		return FALSE

	var/obj/occupied = turf_is_crowded()
	if(occupied)
		show_splash_text(user, "no free space!", SPAN_DANGER("There's \a [occupied] in the way.."))
		return FALSE

	return TRUE

/atom/proc/can_touch(mob/user)
	if (!user)
		return 0
	if(!Adjacent(user))
		return 0
	if (user.restrained() || user.buckled)
		to_chat(user, "<span class='notice'>You need your hands and legs free for this.</span>")
		return 0
	if (user.incapacitated())
		return 0
	if (issilicon(user))
		to_chat(user, "<span class='notice'>You need hands for this.</span>")
		return 0
	return 1

/atom/proc/turf_is_crowded()
	var/turf/T = get_turf(src)
	if(!T || !istype(T))
		return 0
	for(var/atom/A in T.contents)
		if(A.atom_flags & ATOM_FLAG_CLIMBABLE)
			continue
		if(A.density && !(A.atom_flags & ATOM_FLAG_CHECKS_BORDER)) //ON_BORDER structures are handled by the Adjacent() check.
			return A
	return 0

/atom/proc/do_climb(mob/living/user)
	if(!can_climb(user))
		return

	user.visible_message(SPAN_WARNING("\The [user] starts climbing onto \the [src]!"))
	LAZYDISTINCTADD(climbers, user)

	if(!do_after(user,(issmall(user) ? 30 : 50), src))
		LAZYREMOVE(climbers, user)
		return

	if(!can_climb(user, post_climb_check=1))
		LAZYREMOVE(climbers, user)
		return

	user.forceMove(get_turf(src))

	if(get_turf(user) == get_turf(src))
		user.visible_message(SPAN_WARNING("\The [user] climbs onto \the [src]!"))

	LAZYREMOVE(climbers, user)

/atom/proc/object_shaken()
	for(var/mob/living/M in climbers)
		M.Weaken(1)
		show_splash_text(M, "you are shaken off!", SPAN_DANGER("You topple as you are shaken off \the [src]!"))
		LAZYREMOVE(climbers, M)

	for(var/mob/living/M in get_turf(src))
		if(M.lying) //No spamming this on people.
			return

		M.Weaken(3)
		show_splash_text(M, "you topple!", SPAN_DANGER("You topple as \the [src] moves under you!"))

		if(prob(25))
			var/damage = rand(15, 30)
			var/mob/living/carbon/human/H = M
			if(!istype(H))
				to_chat(H, SPAN_DANGER("You land heavily!"))
				M.adjustBruteLoss(damage)
				return

			var/obj/item/organ/external/affecting
			var/list/limbs = BP_ALL_LIMBS //sanity check, can otherwise be shortened to affecting = pick(BP_ALL_LIMBS)
			if(limbs.len)
				affecting = H.get_organ(pick(limbs))

			if(affecting)
				to_chat(M, "<span class='danger'>You land heavily on your [affecting.name]!</span>")
				affecting.take_external_damage(damage, 0)
				if(affecting.parent)
					affecting.parent.add_autopsy_data("Misadventure", damage)
			else
				to_chat(H, "<span class='danger'>You land heavily!</span>")
				H.adjustBruteLoss(damage)

			H.UpdateDamageIcon()
			H.updatehealth()

/atom/MouseDrop_T(atom/movable/target, mob/user)
	var/mob/living/H = user
	if(istype(H) && can_climb(H) && target == user)
		do_climb(target)
	else
		return ..()

// Called after we wrench/unwrench this object
/obj/proc/wrenched_change()
	return

// Pushes A away from the atom's location, unless they are anchored or buckled. Gives up if impossible.
/atom/proc/shove_out(atom/movable/A)
	set waitfor = 0

	if(A.anchored)
		return FALSE

	if(isliving(A))
		var/mob/living/L = A
		if(L.buckled)
			return FALSE

	var/turf/T = loc
	if(!istype(T))
		return FALSE

	var/list/valid_turfs = list()
	for(var/dir_to_test in GLOB.cardinal)
		var/turf/new_turf = get_step(T, dir_to_test)
		if(!new_turf.contains_dense_objects(FALSE))
			valid_turfs |= new_turf

	while(valid_turfs.len)
		T = pick(valid_turfs)
		valid_turfs -= T // Try to move us to the turf. If all turfs fail for some reason we will stay on this tile.
		if(A.forceMove(T))
			return TRUE

	return FALSE

// Pushes all living mobs and items away from the atom's location. Unless they are buckled or anchored. Gives up if impossible.
/atom/proc/shove_everything(shove_mobs = TRUE, shove_objects = TRUE, shove_items = TRUE, min_w_class = ITEM_SIZE_TINY, max_w_class = ITEM_SIZE_HUGE)
	set waitfor = 0

	var/turf/T = loc
	if(!istype(T))
		return FALSE

	var/list/valid_turfs = list()
	var/list/valid_dirs = GLOB.cardinal.Copy()

	for(var/obj/machinery/door/window/slim_door in T.contents)
		if(slim_door.density)
			valid_dirs -= slim_door.dir

	for(var/dir_to_test in valid_dirs)
		var/turf/new_turf = get_step(T, dir_to_test)
		if(!new_turf.contains_dense_objects(FALSE))
			valid_turfs.Add("[dir_to_test]")
			valid_turfs["[dir_to_test]"] = new_turf

	if(!length(valid_turfs))
		return FALSE

	for(var/atom/movable/A in T)
		if(A == src)
			continue

		if(A.anchored)
			continue

		if(isobserver(A))
			continue

		if(!A.simulated)
			continue

		if(istype(A, /obj/item))
			if(!shove_items)
				continue
			var/obj/item/I = A
			if(I.w_class < min_w_class || I.w_class > max_w_class)
				continue
		else if(isliving(A))
			if(!shove_mobs)
				continue
			var/mob/living/L = A
			if(L.buckled)
				continue
			if("[L.dir]" in valid_turfs)
				if(L.forceMove(valid_turfs["[L.dir]"])) // We prefer shoving mobs according to their facing direction.
					continue
		else if(isobj(A) && !shove_objects)
			continue

		for(var/i in shuffle(valid_turfs))
			if(A.forceMove(valid_turfs[i]))
				break

	return TRUE

/atom/proc/post_attach_label()
	return

/atom/proc/post_remove_label()
	return

/atom/proc/SetName(new_name)
	var/old_name = name

	if(old_name != new_name)
		name = new_name

/atom/proc/set_opacity(new_opacity)
	if(new_opacity != opacity)
		var/old_opacity = opacity
		opacity = new_opacity

		SEND_SIGNAL(src, SIGNAL_OPACITY_SET, src, old_opacity, new_opacity)

		return TRUE
	else
		return FALSE

/atom/proc/set_invisibility(new_invisibility = 0)
	var/old_invisibility = invisibility
	if(old_invisibility != new_invisibility)
		invisibility = new_invisibility

		SEND_SIGNAL(src, SIGNAL_INVISIBILITY_SET, src, old_invisibility, new_invisibility)

/atom/proc/recursive_dir_set(atom/a, old_dir, new_dir)
	if(loc != a)
		set_dir(new_dir)

// Clear the atom's tf_* variables and the current transform state.
/atom/proc/ClearTransform()
	tf_scale_x = null
	tf_scale_y = null
	tf_rotation = null
	tf_offset_x = null
	tf_offset_y = null
	transform = null

// Sets the atom's tf_* variables and the current transform state, also applying others if supplied.
/atom/proc/SetTransform(
	scale,
	scale_x = tf_scale_x,
	scale_y = tf_scale_y,
	rotation = tf_rotation,
	offset_x = tf_offset_x,
	offset_y = tf_offset_y,
	list/others
)
	if(!isnull(scale))
		tf_scale_x = scale
		tf_scale_y = scale
	else
		tf_scale_x = scale_x
		tf_scale_y = scale_y
	tf_rotation = rotation
	tf_offset_x = offset_x
	tf_offset_y = offset_y
	transform = matrix().Update(
		scale_x = tf_scale_x,
		scale_y = tf_scale_y,
		rotation = tf_rotation,
		offset_x = tf_offset_x,
		offset_y = tf_offset_y,
		others = others
	)


/// Respond to an RCD acting on our item
/atom/proc/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	return FALSE

///Return the values you get when an RCD eats you?
/atom/proc/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	return FALSE
