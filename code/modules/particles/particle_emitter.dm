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
