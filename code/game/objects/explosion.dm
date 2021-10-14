//TODO: Flash range does nothing currently

/**
 * Makes a given atom explode.
 *
 * Arguments:
 * - [epicenter][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - z_transfer: flags that tells if we need to create another explosion on turf.
 * - shaped: if true make explosions look like circle
 * - sfx_to_play: sound to play, when expolosion near player
 */
/proc/explosion(turf/epicenter, devastation_range = 0, heavy_impact_range = 0, light_impact_range = 0, flash_range = 0, adminlog = 1, z_transfer = UP|DOWN, shaped, sfx_to_play = SFX_EXPLOSION)
	UNLINT(src = null)	//so we don't abort once src is deleted
	. = SSexplosions.explode(arglist(args))



/proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in range(range, epicenter))
		tile.ex_act(2)
