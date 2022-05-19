// Maploader bounds indices.
#define MAP_MINX 1
#define MAP_MINY 2
#define MAP_MINZ 3
#define MAP_MAXX 4
#define MAP_MAXY 5
#define MAP_MAXZ 6

/// Distance from edge to move to another z-level.
#define TRANSITION_EDGE 7

// Traits.
/// That's centcom.
#define ZTRAIT_CENTCOM  "CentCom"
/// That's station level.
#define ZTRAIT_STATION  "Station"
/// This level can't be reached by an map edge crossing, teleporting and etc.
#define ZTRAIT_SEALED   "Sealed"
/// This level is empty (just space or something).
#define ZTRAIT_EMPTY    "Empty"
/// This level has radio.
#define ZTRAIT_CONTACT  "Contact"
/// This level has some global dynamic lighting (a star or something).
/// It's like the starlight but can be changed by time.
#define ZTRAIT_GLOBAL_DYNAMIC_LIGHTING "lighting"
