//Tool behaviour defines, used in tool_behaviour variable of /obj/item

#define TOOL_WRENCH "wrench"
#define TOOL_WELDER "welder"
#define TOOL_COIL "coil"
#define TOOL_WIRECUTTER "wirecutter"
#define TOOL_SCREWDRIVER "screwdriver"
#define TOOL_MULTITOOL "multitool"
#define TOOL_CROWBAR "crowbar"

/// Minimal duration of tool's use_tool(). If less than MIN_TOOL_SOUND_DELAY, then
/// tool_sound is played only when use_tool() is started. If more, then it is played twice.
#define MIN_TOOL_SOUND_DELAY 2 SECONDS
