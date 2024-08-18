// For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define RUNLEVEL_INIT EMPTY_BITFIELD
#define RUNLEVEL_LOBBY 0x0001
#define RUNLEVEL_SETUP 0x0002
#define RUNLEVEL_GAME 0x0004
#define RUNLEVEL_POSTGAME 0x0008

#define RUNLEVELS_ALL (~EMPTY_BITFIELD)
#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define SS_INIT_LOBBY            17
#define SS_INIT_GARBAGE          16
#define SS_INIT_EAMS             15
#define SS_INIT_CHAR_SETUP       14
#define SS_INIT_DONATIONS        13
#define SS_INIT_PLANTS           12
#define SS_INIT_WARNINGS         11
#define SS_INIT_ANTAGS           10
#define SS_INIT_MISC             9
#define SS_INIT_SKYBOX           8
#define SS_INIT_MAPPING          7
#define SS_INIT_OPEN_SPACE       6
#define SS_INIT_CIRCUIT          5
#define SS_INIT_ATOMS            4
#define SS_INIT_ICON_UPDATE      3
#define SS_INIT_RUNECHAT         2
#define SS_INIT_MACHINES         1
#define SS_INIT_DEFAULT          0
#define SS_INIT_AIR             -1
#define SS_INIT_MISC_LATE       -2
#define SS_INIT_ALARM           -3
#define SS_INIT_SHUTTLE         -4
#define SS_INIT_LIGHTING        -5
#define SS_INIT_OVERLAYS        -6
#define SS_INIT_XENOARCH        -10
#define SS_INIT_BAY_LEGACY      -12
#define SS_INIT_STORYTELLER     -15
#define SS_INIT_TICKER          -20
#define SS_INIT_EXPLOSIONS      -69
#define SS_INIT_ANNOUNCERS      -90
#define SS_INIT_VOTE      		-95
#define SS_INIT_ORDER_CHAT 		-100 // Should be last to ensure chat remains smooth during init.

// Explosion Subsystem subtasks
#define SSEXPLOSIONS_MOVABLES 1
#define SSEXPLOSIONS_TURFS    2
#define SSEXPLOSIONS_THROWS   3

// Vote subsystem counting methods
/// First past the post. One selection per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_SINGLE 1
/// Approval voting. Any number of selections per person, and the selection with the most votes wins.
#define VOTE_COUNT_METHOD_MULTI 2
