/* *
* Renderers
* Renderers are virtual objects that act as draw groups of things, including
* other Renderers. Renderers are similar to older uses of PLANE_MASTER but
* employ render targets using the "*" slate prefix to draw off-screen, to be
* composited in a controlled and flexible order and in some cases, reuse for
* visual effects.
*/

/// The base /renderer definition and defaults.
/atom/movable/renderer
	appearance_flags = PLANE_MASTER
	screen_loc = "CENTER"
	plane = LOWEST_PLANE
	blend_mode = BLEND_OVERLAY
	/// The compositing renderer this renderer belongs to.
	var/group = RENDER_GROUP_FINAL

	/// The relay movable used to composite this renderer to its group.
	var/atom/movable/relay // Also see https://secure.byond.com/forum/?post=2141928 maybe.

	/// Optional blend mode override for the renderer's composition relay.
	var/relay_blend_mode

	/// If text, uses the text or, if TRUE, uses "*AUTO-[name]"
	var/render_target_name = TRUE
	var/mob/owner = null


/atom/movable/renderer/Destroy()
	owner = null
	QDEL_NULL(relay)
	return ..()


INITIALIZE_IMMEDIATE(/atom/movable/renderer)


/atom/movable/renderer/Initialize(mapload, mob/owner)
	. = ..()
	src.owner = owner
	INIT_DISALLOW_TYPE(/atom/movable/renderer)
	if (isnull(group))
		if (istext(render_target_name))
			render_target = render_target_name
		return
	if (istext(render_target_name))
		render_target = render_target_name
	else if (render_target_name)
		render_target = "*[ckey(name)]"
	relay = new
	relay.screen_loc = "CENTER"
	relay.appearance_flags = PASS_MOUSE | NO_CLIENT_COLOR | KEEP_TOGETHER
	relay.name = "[render_target] relay"
	relay.mouse_opacity = mouse_opacity
	relay.render_source = render_target
	relay.layer = (plane + abs(LOWEST_PLANE)) * 0.5
	relay.plane = group
	if (isnull(relay_blend_mode))
		relay.blend_mode = blend_mode
	else
		relay.blend_mode = relay_blend_mode

/**
* Graphic preferences
*
* Some renderers may be able to use a graphic preference to determine how to display effects. For example reduce particle counts or filter variables.
*/
/atom/movable/renderer/proc/GraphicsUpdate()
	return

/**
* Renderers on /mob
* We attach renderers to mobs for their lifespan. Only mobs with clients get
* renderers, and they are removed again when the mob loses its client. Mobs
* get their own unique renderer instances but it would not be inconceivable
* to share them globally.
*/

/// The list of renderers associated with this mob.
/mob/var/list/renderers


/// Creates the mob's renderers on /Login()
/mob/proc/CreateRenderers()
	if (!renderers)
		renderers = list()
	for (var/atom/movable/renderer/renderer as anything in subtypesof(/atom/movable/renderer))
		renderer = new renderer (null, src)
		renderers[renderer.name] = renderer
		if (renderer.relay)
			my_client.screen += renderer.relay
		my_client.screen += renderer


/// Removes the mob's renderers on /Logout()
/mob/proc/RemoveRenderers()
	if(my_client)
		for(var/renderer_name as anything in renderers)
			var/atom/movable/renderer/renderer = renderers[renderer_name]
			my_client.screen -= renderer
			if (renderer.relay)
				my_client.screen -= renderer.relay
			qdel(renderer)
	if (renderers)
		renderers.Cut()


/* *
* Plane Renderers
* We treat some renderers as planes with layers. When some atom has the same plane
* as a Plane Renderer, it is drawn by that renderer. The layer of the atom determines
* its draw order within the scope of the renderer. The draw order of same-layered things
* is probably by atom contents order, but can be assumed not to matter - if it's out of
* order, it should have a more appropriate layer value.
* Higher plane values are composited over lower. Here, they are ordered from under to over.
*/

 /// Handles byond internal letterboxing. Avoid touching.
/atom/movable/renderer/letterbox
	name  = LETTERBOX_RENDERER
	group = RENDER_GROUP_SCENE
	plane = BLACKNESS_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	blend_mode = BLEND_MULTIPLY
	color = list(null, null, null, "#0000", "#000f")
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE


/atom/movable/renderer/space
	name  = SPACE_RENDERER
	group = RENDER_GROUP_SCENE
	plane = SPACE_PLANE


/atom/movable/renderer/skybox
	name = SKYBOX_RENDERER
	appearance_flags = KEEP_TOGETHER | PLANE_MASTER
	group = RENDER_GROUP_SCENE
	plane = SKYBOX_PLANE
	blend_mode = BLEND_MULTIPLY

/atom/movable/renderer/turf
	name  = TURF_RENDERER
	group = RENDER_GROUP_SCENE
	plane = TURF_PLANE

// Draws the game world; live mobs, items, turfs, etc.
/atom/movable/renderer/game
	name  = GAME_RENDERER
	group = RENDER_GROUP_SCENE
	plane = DEFAULT_PLANE

/atom/movable/renderer/game/Initialize()
	. = ..()
	GraphicsUpdate()

/atom/movable/renderer/game/GraphicsUpdate()
	if (istype(owner) && owner.client && owner.get_preference_value("AMBIENT_OCCLUSION") == GLOB.PREF_YES)
		add_filter("AO",0,list(type = "drop_shadow", x = 0, y = -2, size = 4, color = "#04080FAA"))
	if (istype(owner) && owner.client && owner.get_preference_value("AMBIENT_OCCLUSION") == GLOB.PREF_NO)
		remove_filter("AO")

/// Draws observers; ghosts, camera eyes, etc.
/atom/movable/renderer/observers
	name  = OBSERVERS_RENDERER
	group = RENDER_GROUP_SCENE
	plane = OBSERVER_PLANE


/// Draws darkness effects.
/atom/movable/renderer/lighting
	name  = LIGHTING_RENDERER
	group = RENDER_GROUP_SCENE
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR
	relay_blend_mode = BLEND_MULTIPLY
	color = list(
		-1,  0,  0,  0, // R
		 0, -1,  0,  0, // G
		 0,  0, -1,  0, // B
		 0,  0,  0,  0, // A
		 1,  1,  1,  1  // Mapping
	)
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE

/atom/movable/renderer/lighting/Initialize(mapload, mob/owner)
	. = ..()
	owner.overlay_fullscreen("lighting_backdrop", /atom/movable/screen/fullscreen/lighting_backdrop)
	filters += filter(
		type = "alpha",
		render_source = EMISSIVE_TARGET,
		flags = MASK_INVERSE
	)

/// Draws visuals that should not be affected by darkness.
/atom/movable/renderer/above_lighting
	name  = ABOVE_LIGHTING_RENDERER
	group = RENDER_GROUP_SCENE
	plane = EFFECTS_ABOVE_LIGHTING_PLANE


/// Draws full screen visual effects, like pain and bluespace.
/atom/movable/renderer/screen_effects
	name  = SCREEN_EFFECTS_RENDERER
	group = RENDER_GROUP_SCENE
	plane = FULLSCREEN_PLANE

/atom/movable/renderer/obfuscation
	name  = OBFUSCATION_RENDERER
	group = RENDER_GROUP_SCENE
	plane = OBFUSCATION_PLANE

/// Draws user interface elements.
/atom/movable/renderer/interface
	name  = INTERFACE_RENDERER
	group = RENDER_GROUP_SCREEN
	plane = HUD_PLANE

/atom/movable/renderer/open_space
	name  =	OPEN_SPACE_RENDERER
	group = RENDER_GROUP_NONE
	plane = OPENSPACE_PLANE

/atom/movable/renderer/open_space/Initialize()
	. = ..()
	add_filter("blurry", 0, list(type="blur", size=0.65))

/* *
* Group renderers
* We treat some renderers as render groups that other renderers subscribe to. Renderers
* subscribe themselves to groups by setting a group value equal to the plane of a Group
* Renderer. This value is used for the Renderer's relay to include it into the Group, and
* the Renderer's plane is used as the relay's layer.
* Group renderers can subscribe themselves to other Group Renderers. This allows for more
* granular manipulation of how the final scene is composed.
*/

/// Render group for stuff INSIDE the typical game context - people, items, lighting, etc.
/atom/movable/renderer/scene_group
	name  = SCENE_GROUP_RENDERER
	group = RENDER_GROUP_FINAL
	plane = RENDER_GROUP_SCENE
	mouse_opacity = MOUSE_OPACITY_NORMAL

/// Render group for stuff OUTSIDE the typical game context - UI, full screen effects, etc.
/atom/movable/renderer/screen_group
	name  =	SCREEN_GROUP_RENDERER
	group = RENDER_GROUP_FINAL
	plane = RENDER_GROUP_SCREEN


/// Render group for final compositing before user display.
/atom/movable/renderer/final_group
	name  =	FINAL_GROUP_RENDERER
	group = RENDER_GROUP_NONE
	plane = RENDER_GROUP_FINAL


/* *
* Effect Renderers
* Some renderers are used to produce complex screen effects. These are drawn using filters
* rather than composition groups, and may be added to another renderer in the following
* fashion. Setting a render_target_name with no group is the expected patter for Effect
* Renderers as it allows them to draw to a slate that will be empty unless a relevant
* behavior, such as the effect atom below, causes them to be noticeable.
*/


/// Renders the /obj/effect/effect/warp example effect
/atom/movable/renderer/warp
	name  = WARP_EFFECT_RENDERER
	group = RENDER_GROUP_NONE
	plane = WARP_EFFECT_PLANE
	render_target_name = "*warp"


/// Adds the warp effect to the game rendering group
/atom/movable/renderer/scene_group/Initialize()
	. = ..()
	add_filter(WARP_EFFECT_RENDERER,0,list(type = "displace", render_source = "*warp", size = 5))

/// Example of a warp filter for /renderer use
/obj/effect/effect/warp
	plane = WARP_EFFECT_PLANE
	appearance_flags = PIXEL_SCALE
	icon = 'icons/effects/352x352.dmi'
	icon_state = "singularity_s11"
	pixel_x = -176
	pixel_y = -176


/* *
 * This system works by exploiting BYONDs color matrix filter to use layers to handle emissive blockers.
 *
 * Emissive overlays are pasted with an atom color that converts them to be entirely some specific color.
 * Emissive blockers are pasted with an atom color that converts them to be entirely some different color.
 * Emissive overlays and emissive blockers are put onto the same plane.
 * The layers for the emissive overlays and emissive blockers cause them to mask eachother similar to normal BYOND objects.
 * A color matrix filter is applied to the emissive plane to mask out anything that isn't whatever the emissive color is.
 * This is then used to alpha mask the lighting plane.
 *
 * This works best if emissive overlays applied only to objects that emit light,
 * since luminosity=0 turfs may not be rendered.
 */

/atom/movable/renderer/emissive
	name = "Emissive"
	group = RENDER_GROUP_NONE
	plane = EMISSIVE_PLANE
	mouse_opacity = MOUSE_OPACITY_UNCLICKABLE
	render_target_name = EMISSIVE_TARGET

/atom/movable/renderer/emissive/Initialize()
	. = ..()
	filters += filter(
		type = "color",
		color = GLOB.em_mask_matrix
	)
