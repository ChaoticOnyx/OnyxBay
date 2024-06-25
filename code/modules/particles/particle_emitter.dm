/**
 * /atom/movable/ can hold only one instance of particles.
 * Therefore, we can use particle emitter to bypass this limitation and
 * create complex effects by combining different emitters
*/
/atom/movable/particle_emitter
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND

/atom/movable/particle_emitter/Initialize(mapload, time, color)
	. = ..()

	if(time > 0)
		QDEL_IN(src, time)

	src.color = color


/atom/movable/particle_emitter/attachable
	/// typepath of the last location we're in, if it's different when moved then we need to update vis contents
	var/last_attached_location_type
	/// the main item we're attached to at the moment, particle holders hold particles for something
	var/weakref/weak_attached
	/// besides the item we're also sometimes attached to other stuff! (items held emitting particles on a mob)
	var/weakref/weak_additional

/atom/movable/particle_emitter/attachable/Initialize(mapload, time, color)
	. = ..()

	if(!loc)
		util_crash_with("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL

	if(ismovable(loc))
		register_signal(loc, SIGNAL_MOVED, nameof(.proc/on_move))

	register_signal(loc, SIGNAL_QDELETING, nameof(.proc/on_qdel))
	weak_attached = weakref(loc)
	update_visual_contents(loc)

/atom/movable/particle_emitter/attachable/Destroy(force)
	var/atom/movable/attached = weak_attached.resolve()
	var/atom/movable/additional_attached
	if(weak_additional)
		additional_attached = weak_additional.resolve()
	if(attached)
		attached.vis_contents -= src
		unregister_signal(loc, list(SIGNAL_MOVED, SIGNAL_QDELETING))
	if(additional_attached)
		additional_attached.vis_contents -= src
	QDEL_NULL(particles)
	return ..()

///signal called when parent is moved
/atom/movable/particle_emitter/attachable/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(attached.loc.type != last_attached_location_type)
		update_visual_contents(attached)

///signal called when parent is deleted
/atom/movable/particle_emitter/attachable/proc/on_qdel(atom/movable/attached, force)
	//SIGNAL_HANDLER FUCK YOU, 'proc/send_asset()'
	qdel_self()

/**
 * logic proc for particle holders, aka where they move.
 * subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
 * this base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles
 */
/atom/movable/particle_emitter/attachable/proc/update_visual_contents(atom/movable/attached_to)
	if(weak_additional)
		var/atom/movable/resolved_location = weak_additional.resolve()
		if(resolved_location)
			resolved_location.vis_contents -= src

	if(isitem(attached_to) && ismob(attached_to.loc))
		var/mob/particle_mob = attached_to.loc
		last_attached_location_type = attached_to.loc
		weak_additional = weakref(particle_mob)
		particle_mob.vis_contents += src

	attached_to.vis_contents |= src

/atom/movable/particle_emitter/proc/enable(on)
	if(on)
		particles.spawning = initial(particles.spawning)
	else
		particles.spawning = 0

/atom/movable/particle_emitter/heat
	particles = new /particles/heat()
	render_target = HEAT_EFFECT_TARGET
	plane = TEMPERATURE_EFFECT_PLANE

/atom/movable/particle_emitter/heat/Initialize()
	. = ..()
	filters += filter(type = "blur", size = 1)

/atom/movable/particle_emitter/heat/high
	particles = new /particles/heat/high()

/atom/movable/particle_emitter/steam
	plane = DUST_PLANE
	particles = new /particles/mist()
	layer = ABOVE_PROJECTILE_LAYER
	render_target = STEAM_EFFECT_TARGET
	alpha = 127
	invisibility = INVISIBILITY_LIGHTING

/atom/movable/particle_emitter/steam/Initialize(mapload, time, color)
	. = ..()
	filters += filter(type = "blur", size = 2)
	filters += filter(type = "wave", x = 0, y = 0, size = rand() * 2.5 + 0.5)

/atom/movable/particle_emitter/fire_smoke
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	plane = DEFAULT_PLANE
	layer = FIRE_LAYER
	particles = new /particles/fire_smoke()

/atom/movable/particle_emitter/fire_smoke/light
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	plane = DEFAULT_PLANE
	layer = FIRE_LAYER
	particles = new /particles/smoke/burning/small()

/atom/movable/particle_emitter/smoke_steam
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	plane = DEFAULT_PLANE
	layer = FIRE_LAYER
	particles = new /particles/smoke/steam()

/atom/movable/particle_emitter/fog
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND
	plane = DEFAULT_PLANE
	layer = FIRE_LAYER
	particles = new /particles/fog()

/atom/movable/particle_emitter/fog/breath
	particles = new /particles/fog/breath()

/atom/movable/particle_emitter/attachable/overheat_smoke
	plane = DEFAULT_PLANE
	layer = FIRE_LAYER
	particles = new /particles/overheat_smoke()

/atom/movable/particle_emitter/debris_visuals
	particles = new /particles/debris()

/atom/movable/particle_emitter/smoke_visuals
	particles = new /particles/impact_smoke()

/atom/movable/particle_emitter/firing_smoke
	particles = new /particles/firing_smoke()

/atom/movable/particle_emitter/firing_smoke/Initialize(mapload, time, color)
	. = ..()
	add_think_ctx("remove_count", CALLBACK(src, nameof(.proc/remove_count)), world.time + 5)
	add_think_ctx("remove_drift", CALLBACK(src, nameof(.proc/remove_drift)), world.time + 3)

/atom/movable/particle_emitter/firing_smoke/proc/remove_count()
	particles.count = 0
	QDEL_IN(src, 0.1 SECONDS)

/atom/movable/particle_emitter/firing_smoke/proc/remove_drift()
	particles.drift = 0

/atom/movable/particle_emitter/clouds
	particles = new /particles/clouds()
	layer = FIRE_LAYER
	render_target = CLOUD_EFFECT_TARGET
