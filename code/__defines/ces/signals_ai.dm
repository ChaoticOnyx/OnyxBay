///sent from ai controllers when they possess a pawn: (datum/ai_controller/source_controller)
#define SIGNAL_AI_CONTROLLER_POSSESSED_PAWN "ai_controller_possessed_pawn"
///sent from ai controllers when they pick behaviors: (list/datum/ai_behavior/old_behaviors, list/datum/ai_behavior/new_behaviors)
#define SIGNAL_AI_CONTROLLER_PICKED_BEHAVIORS "ai_controller_picked_behaviors"
///sent from ai controllers when a behavior is inserted into the queue: (list/new_arguments)
#define SIGNAL_AI_CONTROLLER_BEHAVIOR_QUEUED(type) "SIGNAL_AI_CONTROLLER_BEHAVIOR_QUEUED_[type]"
/// Signal sent when a blackboard key is set to a new value
#define SIGNAL_AI_BLACKBOARD_KEY_SET(blackboard_key) "ai_blackboard_key_set_[blackboard_key]"
/// Signal sent when a blackboard key is cleared
#define SIGNAL_AI_BLACKBOARD_KEY_CLEARED(blackboard_key) "ai_blackboard_key_clear_[blackboard_key]"
///Signal sent when a bot is reset
#define SIGNAL_AI_BOT_RESET "bot_reset"

///from [/datum/move_loop/start_loop] ():
#define COMSIG_MOVELOOP_START "moveloop_start"
///from [/datum/move_loop/stop_loop] ():
#define COMSIG_MOVELOOP_STOP "moveloop_stop"
///from [/datum/move_loop/process] ():
#define COMSIG_MOVELOOP_PREPROCESS_CHECK "moveloop_preprocess_check"
	#define MOVELOOP_SKIP_STEP (1<<0)
///from [/datum/move_loop/process] (result, visual_delay): //Result is an enum value. Enums defined in __DEFINES/movement.dm
#define COMSIG_MOVELOOP_POSTPROCESS "moveloop_postprocess"
//from [/datum/move_loop/has_target/jps/recalculate_path] ():
#define COMSIG_MOVELOOP_JPS_REPATH "moveloop_jps_repath"
///from [/datum/move_loop/has_target/jps/on_finish_pathing]
#define COMSIG_MOVELOOP_JPS_FINISHED_PATHING "moveloop_jps_finished_pathing"
///Return values for moveloop Move()
#define MOVELOOP_FAILURE 0
#define MOVELOOP_SUCCESS 1
#define MOVELOOP_NOT_READY 2

///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
