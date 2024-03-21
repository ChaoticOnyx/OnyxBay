
/*
	from stddef.dm, planes & layers built into byond.
	FLOAT_LAYER = -1
	AREA_LAYER = 1
	TURF_LAYER = 2
	OBJ_LAYER = 3
	MOB_LAYER = 4
	FLY_LAYER = 5
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	EFFECTS_LAYER = 5000
	TOPDOWN_LAYER = 10000
	BACKGROUND_LAYER = 20000
	------
	FLOAT_PLANE = -32767
*/

#define LOWEST_PLANE -200

#define CLICKCATCHER_PLANE -100

#define OPENSPACE_PLANE -8
#define OVER_OPENSPACE_PLANE        -7

#define WARP_EFFECT_PLANE -6

#define BLACKNESS_PLANE                 -5 //Blackness plane as per DM documentation.

#define SPACE_PLANE               -4
	#define SPACE_LAYER                  1
#define SKYBOX_PLANE              -3
	#define SKYBOX_LAYER                 1
#define DUST_PLANE                 -2
	#define DEBRIS_LAYER                 1
	#define DUST_LAYER                   2

#define TURF_PLANE -1

#define DEFAULT_PLANE                   1
	#define PLATING_LAYER               1
	//ABOVE PLATING
	#define HOLOMAP_LAYER               1.01
	#define DECAL_PLATING_LAYER         1.02
	#define DISPOSALS_PIPE_LAYER        1.03
	#define LATTICE_LAYER               1.04
	#define PIPE_LAYER                  1.05
	#define WIRE_LAYER                  1.06
	#define WIRE_TERMINAL_LAYER         1.07
	#define ABOVE_WIRE_LAYER            1.08
	//TURF PLANE
	#define TURF_LAYER					2
	#define TURF_DETAIL_LAYER           2.01
	#define TURF_SHADOW_LAYER           2.02
	//ABOVE TURF
	#define DECAL_LAYER                 2.03
	#define RUNE_LAYER                  2.04
	#define ABOVE_TILE_LAYER            2.05
	#define EXPOSED_PIPE_LAYER          2.06
	#define EXPOSED_WIRE_LAYER          2.07
	#define EXPOSED_WIRE_TERMINAL_LAYER 2.08
	#define CATWALK_LAYER               2.09
	#define ABOVE_CATWALK_LAYER         2.10
	#define BLOOD_LAYER                 2.11
	#define MOUSETRAP_LAYER             2.12
	#define PLANT_LAYER                 2.13
	#define AO_LAYER                    2.14
	//HIDING MOB
	#define HIDING_MOB_LAYER            2.15
	#define SHALLOW_FLUID_LAYER         2.16
	#define MOB_SHADOW_LAYER            2.17
	//OBJ
	#define BELOW_DOOR_LAYER            2.18
	#define OPEN_DOOR_LAYER             2.19
	#define BELOW_TABLE_LAYER           2.20
	#define TABLE_LAYER                 2.21
	#define BELOW_OBJ_LAYER             2.22
	#define STRUCTURE_LAYER             2.23
	#define WINDOW_INNER_LAYER          2.23
	#define WINDOW_FRAME_LAYER          2.24
	#define WINDOW_OUTER_LAYER          2.25
	#define WINDOW_BORDER_LAYER         2.26
	#define ABOVE_STRUCTURE_LAYER       2.27
	// OBJ_LAYER                        3
	#define ABOVE_OBJ_LAYER             3.01
	#define CLOSED_DOOR_LAYER           3.02
	#define ABOVE_DOOR_LAYER            3.03
	#define SIDE_WINDOW_LAYER           3.04
	#define FULL_WINDOW_LAYER           3.05
	#define ABOVE_WINDOW_LAYER          3.06
	#define HOLOMAP_OVERLAY_LAYER       3.061
	//LYING MOB AND HUMAN
	#define LYING_MOB_LAYER             3.07
	#define LYING_HUMAN_LAYER           3.08
	#define BASE_ABOVE_OBJ_LAYER        3.09
	//HUMAN
	#define BASE_HUMAN_LAYER            3.10
	//MOB
	#define MECH_UNDER_LAYER            3.11
	// MOB_LAYER                        4
	#define MECH_BASE_LAYER             4.01
	#define MECH_INTERMEDIATE_LAYER     4.02
	#define MECH_PILOT_LAYER            4.03
	#define MECH_LEG_LAYER              4.04
	#define MECH_COCKPIT_LAYER          4.05
	#define MECH_ARM_LAYER              4.06
	#define MECH_GEAR_LAYER             4.07
	//ABOVE HUMAN
	#define ABOVE_HUMAN_LAYER           4.08
	#define VEHICLE_LOAD_LAYER          4.09
	#define CAMERA_LAYER                4.10
	//BLOB
	#define BLOB_SHIELD_LAYER           4.11
	#define BLOB_NODE_LAYER             4.12
	#define BLOB_CORE_LAYER	            4.13
	//EFFECTS BELOW LIGHTING
	#define BELOW_PROJECTILE_LAYER      4.14
	#define DEEP_FLUID_LAYER            4.15
	#define FIRE_LAYER                  4.16
	#define PROJECTILE_LAYER            4.17
	#define ABOVE_PROJECTILE_LAYER      4.18
	#define SINGULARITY_LAYER           4.19
	#define SINGULARITY_EFFECT_LAYER    4.20
	#define POINTER_LAYER               4.21
	#define MIMICED_LIGHTING_LAYER      4.22	// Z-Mimic-managed lighting

	//FLY_LAYER                          5
	#define CHAT_LAYER                  5.0001
	#define CHAT_LAYER_MAX              5.9999
	//OBSERVER
	#define OBSERVER_LAYER              5.1

	#define OBFUSCATION_LAYER           5.2
	#define BASE_AREA_LAYER             999

#define OBSERVER_PLANE             2

#define LIGHTING_PLANE             3 // For Lighting. - The highest plane (ignoring all other even higher planes)
	#define LIGHTBULB_LAYER        0
	#define LIGHTING_LAYER         1
	#define ABOVE_LIGHTING_LAYER   2

#define EFFECTS_ABOVE_LIGHTING_PLANE   4 // For glowy eyes, laser beams, etc. that shouldn't be affected by darkness
	#define EYE_GLOW_LAYER         1
	#define BEAM_PROJECTILE_LAYER  2
	#define SUPERMATTER_WALL_LAYER 3
	#define SPLASH_TEXT_LAYER      4

#define OBFUSCATION_PLANE				5 // AI

#define FULLSCREEN_PLANE                6 // for fullscreen overlays that do not cover the hud.

	#define FULLSCREEN_LAYER    0
	#define DAMAGE_LAYER        1
	#define IMPAIRED_LAYER      2
	#define BLIND_LAYER         3
	#define CRIT_LAYER          4

#define HUD_PLANE                    7
	#define UNDER_HUD_LAYER              0
	#define HUD_BASE_LAYER               1
	#define HUD_CLICKABLE_LAYER          2
	#define HUD_ITEM_LAYER               3
	#define HUD_ABOVE_ITEM_LAYER         4
	#define HUD_HOLOMARKER_LAYER         5
	#define HUD_HOLOMARKER_SELF_LAYER    6

#define ABOVE_HUD_PLANE              8
	#define ABOVE_HUD_LAYER              5

/// This plane masks out lighting, to create an "emissive" effect for e.g glowing screens in otherwise dark areas.
#define EMISSIVE_PLANE 10
#define EMISSIVE_TARGET "*emissive"
	/// The layer you should use when you -really- don't want an emissive overlay to be blocked.
	#define EMISSIVE_LAYER_UNBLOCKABLE 9999

/// For previews in Character setup. I have no fucking idea why it's like that, and at this point I'm not sure
/// I'd ever want to. It DOES work somehow and I'm more than willing to just keep things the way they are. ~ToTh
#define PREVIEW_PLANE 20

//-------------------- Rendering ---------------------

#define LETTERBOX_RENDERER 			"LETTERBOX"
#define SPACE_RENDERER 				"SPACE"
#define SKYBOX_RENDERER 			"SKYBOX"
#define TURF_RENDERER 				"TURF"
#define GAME_RENDERER 				"GAME"
#define OBSERVERS_RENDERER 			"OBSERVERS"
#define LIGHTING_RENDERER 			"LIGHTING"
#define ABOVE_LIGHTING_RENDERER 	"ABOVE_LIGHTING"
#define SCREEN_EFFECTS_RENDERER 	"SCREEN_EFFECTS"
#define INTERFACE_RENDERER 			"INTERFACE"
#define OPEN_SPACE_RENDERER 		"OPEN_SPACE"
#define WARP_EFFECT_RENDERER 		"WARP_EFFECT"
#define OBFUSCATION_RENDERER 		"OBFUSCATION"

#define SCENE_GROUP_RENDERER 		"SCENE_GROUP"
#define SCREEN_GROUP_RENDERER 		"SCREEN_GROUP"
#define FINAL_GROUP_RENDERER 		"FINAL_GROUP"

/// Semantics - The final compositor or a filter effect renderer
#define RENDER_GROUP_NONE null

/// Things to be drawn within the game context
#define RENDER_GROUP_SCENE 990

/// Things to be drawn within the screen context
#define RENDER_GROUP_SCREEN 995

/// The final render group, for compositing
#define RENDER_GROUP_FINAL 999


/// Causes the atom to ignore clicks, hovers, etc.
#define MOUSE_OPACITY_UNCLICKABLE 0

/// Causes the atom to catch clicks, hovers, etc.
#define MOUSE_OPACITY_NORMAL 1

/// Causes the atom to catch clicks, hovers, etc, taking priority over NORMAL for a shared pointer target.
#define MOUSE_OPACITY_PRIORITY 2


/atom/plane = DEFAULT_PLANE

#define DEFAULT_APPEARANCE_FLAGS (PIXEL_SCALE)

/atom/appearance_flags = DEFAULT_APPEARANCE_FLAGS
/atom/movable/appearance_flags = DEFAULT_APPEARANCE_FLAGS | TILE_BOUND | LONG_GLIDE // Most AMs are not visibly bigger than a tile.
/image/appearance_flags = DEFAULT_APPEARANCE_FLAGS
/mutable_appearance/appearance_flags = DEFAULT_APPEARANCE_FLAGS // Inherits /image but re docs, subject to change


/image/proc/plating_decal_layerise()
	plane = DEFAULT_PLANE
	layer = DECAL_PLATING_LAYER

/image/proc/turf_decal_layerise()
	plane =  DEFAULT_PLANE
	layer = DECAL_LAYER

/atom/proc/hud_layerise()
	plane = HUD_PLANE
	layer = HUD_ITEM_LAYER

/atom/proc/reset_plane_and_layer()
	plane = initial(plane)
	layer = initial(layer)
