/mob
	density = 1

	plane = DEFAULT_PLANE
	layer = MOB_LAYER
	appearance_flags = PIXEL_SCALE | LONG_GLIDE | TILE_BOUND
	animate_movement = 2
	virtual_mob = /mob/observer/virtual/mob

	blocks_emissive = EMISSIVE_BLOCK_GENERIC

	movement_handlers = list(
		/datum/movement_handler/mob/relayed_movement,
		/datum/movement_handler/mob/death,
		/datum/movement_handler/mob/conscious,
		/datum/movement_handler/mob/eye,
		/datum/movement_handler/move_relay,
		/datum/movement_handler/mob/buckle_relay,
		/datum/movement_handler/mob/delay,
		/datum/movement_handler/mob/stop_effect,
		/datum/movement_handler/mob/physically_capable,
		/datum/movement_handler/mob/physically_restrained,
		/datum/movement_handler/mob/space,
		/datum/movement_handler/mob/multiz,
		/datum/movement_handler/mob/movement
	)

	var/mob_flags

	var/list/client_images = list() // List of images applied to/removed from the client on login/logout
	var/datum/mind/mind

	var/lastKnownIP = null
	var/computer_id = null

	var/client/my_client // Need to keep track of this ourselves, since by the time Logout() is called the client has already been nulled

	var/stat = 0 //Whether a mob is alive or dead. TODO: Move this to living - Nodrak

	var/atom/movable/screen/hands = null
	var/atom/movable/screen/pullin = null
	var/atom/movable/screen/purged = null
	var/atom/movable/screen/internals = null
	var/atom/movable/screen/oxygen = null
	var/atom/movable/screen/i_select = null
	var/atom/movable/screen/m_select = null
	var/atom/movable/screen/toxin = null
	var/atom/movable/screen/fire = null
	var/atom/movable/screen/bodytemp = null
	var/atom/movable/screen/healths = null
	var/atom/movable/screen/pains = null
	var/atom/movable/screen/throw_icon = null
	var/atom/movable/screen/block_icon = null
	var/atom/movable/screen/blockswitch_icon = null
	var/atom/movable/screen/nutrition_icon = null
	var/atom/movable/screen/pressure = null
	var/atom/movable/screen/pain = null
	var/atom/movable/screen/poise_icon = null
	var/atom/movable/screen/gun/item/item_use_icon = null
	var/atom/movable/screen/gun/radio/radio_use_icon = null
	var/atom/movable/screen/gun/move/gun_move_icon = null
	var/atom/movable/screen/gun/run/gun_run_icon = null
	var/atom/movable/screen/gun/mode/gun_setting_icon = null

	var/atom/movable/screen/movable/ability_master/ability_master = null

	// Logging
	var/list/logging = list(INDIVIDUAL_SAY_LOG, INDIVIDUAL_OOC_LOG)

	/*A bunch of this stuff really needs to go under their own defines instead of being globally attached to mob.
	A variable should only be globally attached to turfs/objects/whatever, when it is in fact needed as such.
	The current method unnecessarily clusters up the variable list, especially for humans (although rearranging won't really clean it up a lot but the difference will be noticable for other mobs).
	I'll make some notes on where certain variable defines should probably go.
	Changing this around would probably require a good look-over the pre-existing code.
	*/
	var/atom/movable/screen/zone_sel/zone_sel = null

	var/use_me = 1 //Allows all mobs to use the me verb by default, will have to manually specify they cannot
	var/damageoverlaytemp = 0
	var/obj/machinery/machine = null // Old bay code TOTALLY worth refactoring. For now, set and unset it ONLY by using set_machine(obj) and unset_machine() or GC will come and strangle you in your sleep.
	var/poll_answer = 0.0
	var/sdisabilities = 0	//Carbon
	var/disabilities = 0	//Carbon

	var/last_pull_sound = 0
	var/atom/movable/pulling = null
	var/other_mobs = null
	var/next_move = null
	var/hand = null
	var/real_name = null

	var/bhunger = 0			//Carbon

	var/last_pain_message
	var/next_pain_time = 0

	var/druggy = 0			//Carbon
	var/confused = 0		//Carbon
	var/sleeping = 0		//Carbon
	var/resting = 0			//Carbon
	var/lying = 0
	var/lying_prev = 0
	var/hanging = FALSE
	var/hanging_prev = FALSE
	var/ignore_pull_slowdown = FALSE

	var/unacidable = 0
	var/list/pinned = list()            // List of things pinning this creature to walls (see living_defense.dm)
	var/list/embedded = list()          // Embedded items, since simple mobs don't have organs.
	var/list/languages = list()         // For speaking/listening.
	var/species_language = null			// For species who want reset to use a specified default.
	var/only_species_language  = 0		// For species who can only speak their default and no other languages. Does not effect understanding.
	var/list/speak_emote = list("says") // Verbs used when speaking. Defaults to 'say' if speak_emote is null.
	var/emote_type = 1		// Define emote default type, 1 for seen emotes, 2 for heard emotes
	var/facing_dir = null   // Used for the ancient art of moonwalking.

	var/name_archive //For admin things like possession

	var/timeofdeath = 0
	var/ghostizing = FALSE

	var/bodytemperature = 310.055	//98.7 F
	/// Tracks whether our temp changed
	var/bodytemperature_lasttick
	var/default_pixel_x = 0
	var/default_pixel_y = 0

	var/shakecamera = 0
	var/a_intent = I_HELP//Living
	var/m_intent = M_RUN//Living
	var/obj/buckled = null//Living
	var/obj/item/l_hand = null//Living
	var/obj/item/r_hand = null//Living
	var/obj/item/back = null//Human/Monkey
	var/obj/item/storage/s_active = null//Carbon
	var/obj/item/clothing/mask/wear_mask = null//Carbon

	var/list/grabbed_by = list(  )

	var/in_throw_mode = 0

	var/inertia_dir = 0

//	var/job = null//Living

	var/can_pull_size = ITEM_SIZE_NO_CONTAINER // Maximum w_class the mob can pull.
	var/can_pull_mobs = MOB_PULL_SAME          // Whether or not the mob can pull other mobs.

	var/datum/dna/dna = null//Carbon
	var/list/mutations = list() //Carbon -- Doohl
	//see: setup.dm for list of mutations

	/// Total radiation dose. Sv.
	var/radiation = SPACE_RADIATION
	var/rad_resist_type = /datum/rad_resist/mob

	var/voice_name = "unidentifiable voice"

	var/faction = "neutral" //Used for checking whether hostile simple animals will attack you, possibly more stuff later
	var/blinded = null
	var/ear_deaf = null		//Carbon

	var/blocking = 0
	var/parrying = 0

//The last mob/living/carbon to push/drag/grab this mob (mostly used by metroids friend recognition)
	var/weakref/LAssailant = null // Must be mob/living/carbon

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

	var/update_icon = 1 //Set to 1 to trigger update_icons() at the next life() call

	var/status_flags = CANSTUN|CANWEAKEN|CANPARALYSE|CANPUSH	//bitflags defining which status effects can be inflicted (replaces canweaken, canstun, etc)

	var/area/lastarea = null
	var/lastemote = 0 // Emote sound delay

	var/digitalcamo = 0 // Can they be tracked by the AI?

	var/obj/control_object //Used by admins to possess objects. All mobs should have this var

	//Whether or not mobs can understand other mobtypes. These stay in /mob so that ghosts can hear everything.
	var/universal_speak = 0 // Set to 1 to enable the mob to speak to everyone -- TLE
	var/universal_understand = 0 // Set to 1 to enable the mob to understand everyone, not necessarily speak

	//If set, indicates that the client "belonging" to this (clientless) mob is currently controlling some other mob
	//so don't treat them as being SSD even though their client var is null.
	var/mob/teleop = null

	/// Reference to the turf currently being examined in the stat panel.
	var/turf/listed_turf

	var/mob_size = MOB_MEDIUM
	var/throw_multiplier = 1

	var/paralysis = 0
	var/stunned = 0
	var/weakened = 0
	var/drowsyness = 0.0//Carbon

	var/memory = ""
	var/flavor_text = ""
	var/list/flavor_texts = list()
	var/datum/browser/show_inventory

	var/last_time_pointed_at = 0

	/// Contains [/atom/movable/screen/movable/alert] only.
	///
	/// On [/mob] so clientless mobs will throw alerts properly.
	var/list/alerts = list()

	var/is_view_shifted = FALSE

	/// Icon state name for speech bubble
	var/bubble_icon = "default"
	/// Icon used for the typing indicator's bubble
	var/active_typing_indicator
	/// Icon used for the thinking inicator's bubble
	var/active_thinking_indicator
	/// Is user typing in character
	var/thinking_IC = FALSE
	/// Whether typing indicator sould be shown
	var/thinking_silent = FALSE

	var/bloody_hands = null
	var/mob/living/carbon/human/bloody_hands_mob
	var/track_blood = 0
	var/list/feet_blood_DNA
	var/track_blood_type
	var/feet_blood_color

	/// Holder for a bugreporter datum.
	var/datum/bugreporter/bugreporter

	/// UI holder for a language menu.
	var/datum/language_menu/language_menu
	/// Associative list of procpath -> list/atom, where atom is a source a procpath comes from.
	var/list/atom_verbs
	///used to override the mouse cursor so it doesnt get reset
	var/mouse_override_icon = null

/datum/rad_resist/mob
	alpha_particle_resist = 6 MEGA ELECTRONVOLT
	beta_particle_resist = 0.1 MEGA ELECTRONVOLT
	hawking_resist = 1 ELECTRONVOLT
