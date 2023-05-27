// game.dm
//We used to use linear regression to approximate the answer, but Mloc realized this was actually faster.
//And lo and behold, it is, and it's more accurate to boot.
/proc/cheap_hypotenuse(Ax,Ay,Bx,By)
	return sqrt(abs(Ax - Bx)**2 + abs(Ay - By)**2) //A squared + B squared = C squared

// The severity of explosions. Why are these inverted? I have no idea, but git blame doesn't go back far enough for me to find out.
/// The (current) highest possible explosion severity.
#define EXPLODE_DEVASTATE 1
/// The (current) middling explosion severity.
#define EXPLODE_HEAVY 2
/// The (current) lowest possible explosion severity.
#define EXPLODE_LIGHT 3
/// The default explosion severity used to mark that an object is beyond the impact range of the explosion.
#define EXPLODE_NONE 0

// Internal explosion argument list keys.
// Must match the arguments to [/datum/controller/subsystem/explosions/proc/propagate_blastwave]
/// The origin atom of the explosion.
#define EXARG_KEY_ORIGIN "origin"
/// The devastation range of the explosion.
#define EXARG_KEY_DEV_RANGE STRINGIFY(devastation_range)
/// The heavy impact range of the explosion.
#define EXARG_KEY_HEAVY_RANGE STRINGIFY(heavy_impact_range)
/// The light impact range of the explosion.
#define EXARG_KEY_LIGHT_RANGE STRINGIFY(light_impact_range)
/// The flash range of the explosion.
#define EXARG_KEY_FLASH_RANGE STRINGIFY(flash_range)
/// Whether or not the explosion should be logged.
#define EXARG_KEY_ADMIN_LOG STRINGIFY(adminlog)
/// Whether or not the explosion should be transfered through z-levels.
#define EXARG_KEY_Z_TRANSFER STRINGIFY(z_transfer)
/// Whether or not the explosion should be shaped like circle.
#define EXARG_KEY_SHAPED STRINGIFY(shaped)
/// Whether or not the explosion should produce sound effects.
#define EXARG_KEY_SFX_TO_PLAY STRINGIFY(sfx_to_play)
