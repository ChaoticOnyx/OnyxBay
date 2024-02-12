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

// Engines
#define MAP_ENG_RANDOM      "random"
#define MAP_ENG_SINGULARITY "singularity"
#define MAP_ENG_MATTER      "supermatter"

// Biodomes

#define MAP_BIO_RANDOM  	"random"
#define MAP_BIO_FOREST  	"forest"
#define MAP_BIO_WINTER  	"winter"
#define MAP_BIO_BEACH   	"beach"
#define MAP_BIO_CONCERT 	"concert"
#define MAP_BIO_NANOTRASEN  "nanotrasen"

// Bars

#define MAP_BAR_RANDOM  "random"
#define MAP_BAR_CLASSIC "classic"
#define MAP_BAR_MODERN  "modern"
#define MAP_BAR_SALOON  "saloon"

// Derelicts amount
#define MAP_DERELICTS_AMOUNT  2
