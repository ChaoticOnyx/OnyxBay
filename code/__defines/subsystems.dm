// For servers that can't do with any additional lag, set this to none in flightpacks.dm in subsystem/processing.
#define FLIGHTSUIT_PROCESSING_NONE 0
#define FLIGHTSUIT_PROCESSING_FULL 1

#define INITIALIZATION_INSSATOMS     0	// New should not call Initialize
#define INITIALIZATION_INNEW_MAPLOAD 1	// New should call Initialize(TRUE)
#define INITIALIZATION_INNEW_REGULAR 2	// New should call Initialize(FALSE)

#define INITIALIZE_HINT_NORMAL   0  // Nothing happens
#define INITIALIZE_HINT_LATELOAD 1  // Call LateInitialize
#define INITIALIZE_HINT_QDEL     2  // Call qdel on the atom

// type and all subtypes should always call Initialize in New()
#define INITIALIZE_IMMEDIATE(X) ##X/New(loc, ...){\
	..();\
	if(!(atom_flags & ATOM_FLAG_INITIALIZED)) {\
		args[1] = TRUE;\
		SSatoms.InitAtom(src, args);\
	}\
}

// Subsystem init_order, from highest priority to lowest priority
// Subsystems shutdown in the reverse of the order they initialize in
// The numbers just define the ordering, they are meaningless otherwise.

#define SS_INIT_GARBAGE          15
#define SS_INIT_EAMS             14
#define SS_INIT_CHAR_SETUP       13
#define SS_INIT_DONATIONS        12
#define SS_INIT_PLANTS           11
#define SS_INIT_WARNINGS         10
#define SS_INIT_ANTAGS           9
#define SS_INIT_MISC             8
#define SS_INIT_SKYBOX           7
#define SS_INIT_MAPPING          6
#define SS_INIT_OPEN_SPACE       5
#define SS_INIT_CIRCUIT          4
#define SS_INIT_ATOMS            3
#define SS_INIT_ICON_UPDATE      2
#define SS_INIT_MACHINES         1
#define SS_INIT_DEFAULT          0
#define SS_INIT_AIR             -1
#define SS_INIT_MISC_LATE       -2
#define SS_INIT_ALARM           -3
#define SS_INIT_SHUTTLE         -4
#define SS_INIT_LIGHTING        -5
#define SS_INIT_XENOARCH        -10
#define SS_INIT_BAY_LEGACY      -12
#define SS_INIT_STORYTELLER     -15
#define SS_INIT_TICKER          -20
#define SS_INIT_EXPLOSIONS      -69
#define SS_INIT_ORDER_CHAT 		-100 // Should be last to ensure chat remains smooth during init.

// SS runlevels

#define RUNLEVEL_INIT 0
#define RUNLEVEL_LOBBY 1
#define RUNLEVEL_SETUP 2
#define RUNLEVEL_GAME 4
#define RUNLEVEL_POSTGAME 8

// Explosion Subsystem subtasks
#define SSEXPLOSIONS_MOVABLES 1
#define SSEXPLOSIONS_TURFS    2
#define SSEXPLOSIONS_THROWS   3

#define RUNLEVELS_DEFAULT (RUNLEVEL_SETUP | RUNLEVEL_GAME | RUNLEVEL_POSTGAME)
