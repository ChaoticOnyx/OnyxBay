#define GET_AI_BEHAVIOR(behavior_type) GLOB.ai_behaviors[behavior_type]
#define GET_TARGETING_STRATEGY(targeting_type) GLOB.ai_targeting_strategies[targeting_type]
#define HAS_AI_CONTROLLER_TYPE(thing, type) istype(thing?.ai_controller, type)

//AI controller flags
//If you add a new status, be sure to add it to the ai_controllers subsystem's ai_controllers_by_status list.
///The AI is currently active.
#define AI_STATUS_ON "ai_on"
///The AI is currently offline for any reason.
#define AI_STATUS_OFF "ai_off"
///The AI is currently in idle mode.
#define AI_STATUS_IDLE "ai_idle"

///For JPS pathing, the maximum length of a path we'll try to generate. Should be modularized depending on what we're doing later on
#define AI_MAX_PATH_LENGTH 30 // 30 is possibly overkill since by default we lose interest after 14 tiles of distance, but this gives wiggle room for weaving around obstacles
#define AI_BOT_PATH_LENGTH 150

// How far should we, by default, be looking for interesting things to de-idle?
#define AI_DEFAULT_INTERESTING_DIST 10

///Cooldown on planning if planning failed last time

#define AI_FAILED_PLANNING_COOLDOWN (1.5 SECONDS)

///Flags for ai_behavior new()
#define AI_CONTROLLER_INCOMPATIBLE (1<<0)

//Return flags for ai_behavior/perform()
///Update this behavior's cooldown
#define AI_BEHAVIOR_DELAY (1<<0)
///Finish the behavior successfully
#define AI_BEHAVIOR_SUCCEEDED (1<<1)
///Finish the behavior unsuccessfully
#define AI_BEHAVIOR_FAILED (1<<2)

#define AI_BEHAVIOR_INSTANT 0

///Does this task require movement from the AI before it can be performed?
#define AI_BEHAVIOR_REQUIRE_MOVEMENT (1<<0)
///Does this require the current_movement_target to be adjacent and in reach?
#define AI_BEHAVIOR_REQUIRE_REACH (1<<1)
///Does this task let you perform the action while you move closer? (Things like moving and shooting)
#define AI_BEHAVIOR_MOVE_AND_PERFORM (1<<2)
///Does finishing this task not null the current movement target?
#define AI_BEHAVIOR_KEEP_MOVE_TARGET_ON_FINISH (1<<3)
///Does this behavior NOT block planning?
#define AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION (1<<4)

///AI flags
/// Don't move if being pulled
#define STOP_MOVING_WHEN_PULLED (1<<0)
/// Continue processing even if dead
#define CAN_ACT_WHILE_DEAD (1<<1)
/// Stop processing while in a progress bar
#define PAUSE_DURING_DO_AFTER (1<<2)
/// Continue processing while in stasis
#define CAN_ACT_IN_STASIS (1<<3)

//Base Subtree defines

///This subtree should cancel any further planning, (Including from other subtrees)
#define SUBTREE_RETURN_FINISH_PLANNING 1

//Generic subtree defines

/// probability that the pawn should try resisting out of restraints
#define RESIST_SUBTREE_PROB 50
///macro for whether it's appropriate to resist right now, used by resist subtree
#define SHOULD_RESIST(source) (source.on_fire || source.buckled || HAS_TRAIT(source, TRAIT_RESTRAINED) || (source.pulledby && source.pulledby.grab_state > GRAB_PASSIVE))
///macro for whether the pawn can act, used generally to prevent some horrifying ai disasters
#define IS_DEAD_OR_INCAP(source) (source.incapacitated() || source.stat)

GLOBAL_LIST_INIT(all_radial_directions, list(
	"NORTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTH),
	"NORTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHEAST),
	"EAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = EAST),
	"SOUTHEAST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHEAST),
	"SOUTH" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTH),
	"SOUTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = SOUTHWEST),
	"WEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = WEST),
	"NORTHWEST" = image(icon = 'icons/testing/turf_analysis.dmi', icon_state = "red_arrow", dir = NORTHWEST)
))

/// Blackboard field for the most recent command the pet was given
#define BB_ACTIVE_PET_COMMAND "BB_active_pet_command"

/// Blackboard field for what we actually want the pet to target
#define BB_CURRENT_PET_TARGET "BB_current_pet_target"
/// Blackboard field for how we target things, as usually we want to be more permissive than normal
#define BB_PET_TARGETING_STRATEGY "BB_pet_targeting"
/// Typecache of weakrefs to mobs this mob is friends with, will follow their instructions and won't attack them
#define BB_FRIENDS_LIST "BB_friends_list"
///the list of items we are afraid of
#define BB_LIST_SCARY_ITEMS "list_scary_items"
///our teleportation ability
#define BB_DEMON_TELEPORT_ABILITY "demon_teleport_ability"
///the destination of our teleport ability
#define BB_TELEPORT_DESTINATION "teleport_destination"
///the ability to clone ourself
#define BB_DEMON_CLONE_ABILITY "demon_clone_ability"
///our slippery ice ability
#define BB_DEMON_SLIP_ABILITY "demon_slip_ability"
///the turf we are escaping to
#define BB_ESCAPE_DESTINATION "escape_destination"

// bot keys
///The first beacon we find
#define BB_BEACON_TARGET "beacon_target"
///The last beacon we found, we will use its codes to find the next beacon
#define BB_PREVIOUS_BEACON_TARGET "previous_beacon_target"
///Location of whoever summoned us
#define BB_BOT_SUMMON_TARGET "bot_summon_target"
///salute messages to beepsky
#define BB_SALUTE_MESSAGES "salute_messages"
///the beepsky we will salute
#define BB_SALUTE_TARGET "salute_target"
///our announcement ability
#define BB_ANNOUNCE_ABILITY "announce_ability"
///list of our radio channels
#define BB_RADIO_CHANNEL "radio_channel"
///list of unreachable things we will temporarily ignore
#define BB_TEMPORARY_IGNORE_LIST "temporary_ignore_list"

// medbot keys
///the patient we must heal
#define BB_PATIENT_TARGET "patient_target"
///list holding our wait dialogue
#define BB_WAIT_SPEECH "wait_speech"
///what we will say to our patient after we heal them
#define BB_AFTERHEAL_SPEECH "afterheal_speech"
///things we will say when we are bored
#define BB_IDLE_SPEECH "idle_speech"
///speech unlocked after being emagged
#define BB_EMAGGED_SPEECH "emagged_speech"
///speech when we are tipped
#define BB_WORRIED_ANNOUNCEMENTS "worried_announcements"
///speech when our patient is near death
#define BB_NEAR_DEATH_SPEECH "near_death_speech"
///in crit patient we must alert medbay about
#define BB_PATIENT_IN_CRIT "patient_in_crit"
///how much time interval before we clear list
#define BB_UNREACHABLE_LIST_COOLDOWN "unreachable_list_cooldown"
///can we clear the list now
#define	BB_CLEAR_LIST_READY "clear_list_ready"

// cleanbots
///key that holds the foaming ability
#define BB_CLEANBOT_FOAM "cleanbot_foam"
///key that holds decals we hunt
#define BB_CLEANABLE_DECALS "cleanable_decals"
///key that holds blood we hunt
#define BB_CLEANABLE_BLOOD "cleanable_blood"
///key that holds pests we hunt
#define BB_HUNTABLE_PESTS "huntable_pests"
///key that holds emagged speech
#define BB_CLEANBOT_EMAGGED_PHRASES "emagged_phrases"
///key that holds drawings we hunt
#define BB_CLEANABLE_DRAWINGS "cleanable_drawings"
///Key that holds our clean target
#define BB_CLEAN_TARGET "clean_target"
///key that holds the janitor we will befriend
#define BB_FRIENDLY_JANITOR "friendly_janitor"
///key that holds the victim we will spray
#define BB_ACID_SPRAY_TARGET "acid_spray_target"
///key that holds trash we will burn
#define BB_HUNTABLE_TRASH "huntable_trash"

//hygienebots
///key that holds our threats
#define BB_WASH_THREATS "wash_threats"
///key that holds speech when we find our target
#define BB_WASH_FOUND "wash_found"
///key that holds speech when we cleaned our target
#define BB_WASH_DONE "wash_done"
///key that holds target we will wash
#define BB_WASH_TARGET "wash_target"
///key that holds how frustrated we are when target is running away
#define BB_WASH_FRUSTRATION "wash_frustration"
///key that holds cooldown after we finish cleaning something, so we dont immediately run off to patrol
#define BB_POST_CLEAN_COOLDOWN "post_clean_cooldown"
//bot navigation beacon defines
#define NAVBEACON_PATROL_MODE "patrol"
#define NAVBEACON_PATROL_NEXT "next_patrol"
#define NAVBEACON_DELIVERY_MODE "delivery"
#define NAVBEACON_DELIVERY_DIRECTION "dir"
