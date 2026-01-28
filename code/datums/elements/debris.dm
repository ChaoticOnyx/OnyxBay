/datum/element/debris
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Icon state of debris when impacted by a projectile
	var/debris = null
	///Velocity of debris particles
	var/debris_velocity = -15
	///Amount of debris particles
	var/debris_amount = 8
	///Scale of particle debris
	var/debris_scale = 0.7

/datum/element/debris/attach(datum/target, debris_icon_state, debris_velocity = -15, debris_amount = 8, debris_scale = 0.7)
	. = ..()
	src.debris = debris_icon_state
	src.debris_velocity = debris_velocity
	src.debris_amount = debris_amount
	src.debris_scale = debris_scale
	register_signal(target, SIGNAL_BULLET_ACT, nameof(.proc/register_for_impact))

/datum/element/debris/detach(datum/source)
	. = ..()
	unregister_signal(source, SIGNAL_BULLET_ACT)

/datum/element/debris/proc/register_for_impact(datum/source, obj/item/projectile/proj)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, nameof(.proc/on_impact), source, proj)

/datum/element/debris/proc/on_impact(datum/source, obj/item/projectile/P)
	var/angle = !isnull(P.Angle) ? P.Angle : round(Get_Angle(P.starting, source), 1)
	var/x_component = sin(angle) * debris_velocity
	var/y_component = cos(angle) * debris_velocity
	var/x_component_smoke = sin(angle) * -15
	var/y_component_smoke = cos(angle) * -15
	var/position_offset = rand(-6,6)
	var/atom/movable/particle_emitter/smoke_visuals/smoke_visuals = new(source)
	smoke_visuals.particles.position = list(position_offset, position_offset)
	smoke_visuals.particles.velocity = list(x_component_smoke, y_component_smoke)

	if(debris && P.check_armour != ENERGY && P.check_armour != LASER)
		var/atom/movable/particle_emitter/debris_visuals/debris_visuals = new(source)
		debris_visuals.particles.position = generator("circle", position_offset, position_offset)
		debris_visuals.particles.velocity = list(x_component, y_component)
		debris_visuals.layer = ABOVE_HUMAN_LAYER + 0.02
		debris_visuals.particles.icon_state = debris
		debris_visuals.particles.count = debris_amount
		debris_visuals.particles.spawning = debris_amount
		debris_visuals.particles.scale = debris_scale
		QDEL_IN(debris_visuals, 0.7 SECONDS)
	smoke_visuals.layer = ABOVE_HUMAN_LAYER + 0.01
	QDEL_IN(smoke_visuals, 0.7 SECONDS)
