//Refreshes the icon and sets the luminosity
/obj/machinery/portable_atmospherics/hydroponics/on_update_icon()
	// Update name.
	if(seed)
		if(mechanical)
			name = "[base_name] ([seed.seed_name])"
		else
			name = "[seed.seed_name]"
	else
		SetName(initial(name))

	ClearOverlays()
	var/new_overlays = list()
	// Updates the plant overlay.
	if(seed)
		var/is_canonical = seed.is_canonical()
		if(dead)
			var/ikey
			var/image/dead_overlay

			if(is_canonical)
				ikey = "[seed.canonical_icon]-dead"
				dead_overlay = SSplants.canonical_plant_icon_cache[ikey]
				if(!dead_overlay)
					dead_overlay = image('icons/obj/hydroponics_growing_canonical.dmi', "[ikey]")
					SSplants.canonical_plant_icon_cache[ikey] = dead_overlay
			else
				ikey = "[seed.get_trait(TRAIT_PLANT_ICON)]-dead"
				dead_overlay = SSplants.plant_icon_cache[ikey]
				if(!dead_overlay)
					dead_overlay = image('icons/obj/hydroponics_growing.dmi', "[ikey]")
					dead_overlay.color = DEAD_PLANT_COLOUR
					SSplants.plant_icon_cache[ikey] = dead_overlay

			dead_overlay.pixel_y = vertical_shift
			new_overlays += dead_overlay

		else
			if(!seed.growth_stages)
				seed.update_growth_stages()

			if(!seed.growth_stages)
				var/type_description = is_canonical ? "[seed.canonical_icon] (canonical)" : "[seed.get_trait(TRAIT_PLANT_ICON)]"
				log_error("<span class='danger'>Seed type [type_description] cannot find a growth stage value.</span>")
				return

			var/overlay_stage = get_overlay_stage()

			var/ikey
			var/image/plant_overlay

			// "Canonical" plants have dedicated harvest-stage sprites
			if(is_canonical)
				if(harvest && overlay_stage == seed.growth_stages)
					ikey = "[seed.canonical_icon]-harvest"
				else
					ikey = "[seed.canonical_icon]-[overlay_stage]"
				plant_overlay = SSplants.canonical_plant_icon_cache[ikey]
				if(!plant_overlay)
					plant_overlay = image('icons/obj/hydroponics_growing_canonical.dmi', "[ikey]")
					SSplants.canonical_plant_icon_cache[ikey] = plant_overlay

				plant_overlay.pixel_y = vertical_shift
				new_overlays += plant_overlay

			// "Non-canonical" plants use separate sprites for the plant itself and its harvest
			else
				ikey = "\ref[seed]-plant-[overlay_stage]"
				plant_overlay = SSplants.plant_icon_cache[ikey]
				if(!plant_overlay)
					plant_overlay = seed.get_icon(overlay_stage)
					SSplants.plant_icon_cache[ikey] = plant_overlay

				plant_overlay.pixel_y = vertical_shift
				new_overlays += plant_overlay

				if(harvest && overlay_stage == seed.growth_stages)
					ikey = "product-[seed.get_trait(TRAIT_PRODUCT_ICON)]" + (seed.customsprite ? "" : "-[seed.get_trait(TRAIT_PLANT_COLOUR)]")
					var/image/harvest_overlay = SSplants.plant_icon_cache[ikey]

					if(!harvest_overlay)
						harvest_overlay = image('icons/obj/hydroponics_products.dmi', "[seed.get_trait(TRAIT_PRODUCT_ICON)]")
						if(!seed.customsprite)
							harvest_overlay.color = seed.get_trait(TRAIT_PRODUCT_COLOUR)
						SSplants.plant_icon_cache[ikey] = harvest_overlay

					harvest_overlay.pixel_y = vertical_shift
					new_overlays += harvest_overlay

	//Updated the various alert icons.
	if(mechanical)
		//Draw the cover.
		if(closed_system)
			new_overlays += "hydrocover"
		if(seed && health <= (seed.get_trait(TRAIT_ENDURANCE) / 2))
			new_overlays += "over_lowhealth3"
		if(waterlevel <= 10)
			new_overlays += "over_lowwater3"
		if(nutrilevel <= 2)
			new_overlays += "over_lownutri3"
		if(weedlevel >= 5 || pestlevel >= 5 || toxins >= 40)
			new_overlays += "over_alert3"
		if(harvest)
			new_overlays += "over_harvest3"

	if((!density || !opacity) && seed && seed.get_trait(TRAIT_LARGE))
		if(!mechanical)
			set_density(1)
		set_opacity(1)
	else
		if(!mechanical)
			set_density(0)
		set_opacity(0)

	AddOverlays(new_overlays)

	// Update bioluminescence.
	if(seed && seed.get_trait(TRAIT_BIOLUM))
		set_light(0.5, 0.1, round(seed.get_trait(TRAIT_POTENCY)/10), l_color = seed.get_trait(TRAIT_BIOLUM_COLOUR))
	else
		set_light(0)

/obj/machinery/portable_atmospherics/hydroponics/proc/get_overlay_stage()
	. = 1
	var/seed_maturation = seed.get_trait(TRAIT_MATURATION)
	if(age >= seed_maturation)
		. = seed.growth_stages
	else
		var/maturation = max(seed_maturation/seed.growth_stages, 1)
		. = max(1, round(age/maturation))
