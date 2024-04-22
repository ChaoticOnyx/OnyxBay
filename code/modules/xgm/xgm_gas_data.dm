/var/datum/xgm_gas_data/gas_data

/datum/xgm_gas_data
	//Simple list of all the gas IDs.
	var/list/gases = list()
	//The friendly, human-readable name for the gas.
	var/list/name = list()
	//Specific heat of the gas.  Used for calculating heat capacity.
	var/list/specific_heat = list()
	//Molar mass of the gas.  Used for calculating specific entropy.
	var/list/molar_mass = list()
	//Tile overlays.  /atom/movable/gas_overlay, created from references to 'icons/effects/tile_effects.dmi'
	var/list/tile_overlay = list()
	//Overlay limits.  There must be at least this many moles for the overlay to appear.
	var/list/overlay_limit = list()
	//Flags.
	var/list/flags = list()
	//Products created when burned. For fuel only for now (not oxidizers)
	var/list/burn_product = list()
	/// Cache of temperature overlays
	var/list/temp_overlay_cache = list()

/decl/xgm_gas
	var/id = ""
	var/name = "Unnamed Gas"
	var/specific_heat = 20	// J/(mol*K)
	var/molar_mass = 0.032	// kg/mol

	var/tile_overlay = null
	var/overlay_limit = null

	var/flags = 0
	var/burn_product = "carbon_dioxide"

/hook/startup/proc/generateGasData()
	gas_data = new
	for(var/p in (typesof(/decl/xgm_gas) - /decl/xgm_gas))
		var/decl/xgm_gas/gas = new p //avoid initial() because of potential New() actions

		if(gas.id in gas_data.gases)
			error("Duplicate gas id `[gas.id]` in `[p]`")

		gas_data.gases += gas.id
		gas_data.name[gas.id] = gas.name
		gas_data.specific_heat[gas.id] = gas.specific_heat
		gas_data.molar_mass[gas.id] = gas.molar_mass
		if(gas.overlay_limit)
			gas_data.overlay_limit[gas.id] = gas.overlay_limit
			var/atom/movable/gas_overlay/overlay = new()
			if(gas.tile_overlay)
				overlay.icon_state = gas.tile_overlay
			gas_data.tile_overlay[gas.id] = overlay
		if(gas.overlay_limit) gas_data.overlay_limit[gas.id] = gas.overlay_limit
		gas_data.flags[gas.id] = gas.flags
		gas_data.burn_product[gas.id] = gas.burn_product

	return 1

/atom/movable/gas_overlay
	name = "gas"
	desc = "you shouldn't be seeing this"
	icon = 'icons/effects/tile_effects.dmi'
	icon_state = "generic"
	plane = DEFAULT_PLANE
	layer = FLY_LAYER
	vis_flags = EMPTY_BITFIELD
	appearance_flags = KEEP_APART
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/gas_overlay/Initialize()
	. = ..()
	animate(src, alpha = 175, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = 255, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/atom/movable/gas_overlay/temp_overlay
	icon = 'icons/effects/temp_effects.dmi'
	layer = FIRE_LAYER

/atom/movable/gas_overlay/temp_overlay/proc/update_alpha_animation(new_alpha)
	if(new_alpha == alpha)
		return

	animate(src, alpha = new_alpha)
	alpha = new_alpha
	animate(src, alpha = 0.8 * new_alpha, time = 10, easing = SINE_EASING | EASE_OUT, loop = -1)
	animate(alpha = new_alpha, time = 10, easing = SINE_EASING | EASE_IN, loop = -1)

/atom/movable/gas_overlay/temp_overlay/heat
	plane = TEMPERATURE_EFFECT_PLANE
	render_source = HEAT_EFFECT_TARGET
	icon = null
	icon_state = null
