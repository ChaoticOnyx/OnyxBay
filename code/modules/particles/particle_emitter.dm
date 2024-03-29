/* /atom/movable/ can hold only one instance of particles.
Therefore, we can use particle emitter to bypass this limitation and
create complex effects by combining different emitters */

/atom/movable/particle_emitter
	name = ""
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | TILE_BOUND

/atom/movable/particle_emitter/Initialize(mapload, time, _color)
	. = ..()

	if(time > 0)
		QDEL_IN(src, time)

	color = _color

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
