GLOBAL_LIST_EMPTY(holomarkers)
GLOBAL_LIST_EMPTY(holocache)
GLOBAL_LIST_EMPTY(holomaps)

#define HOLOMAP_WALKABLE_TILE			"#66666699"
#define HOLOMAP_CONCRETE_TILE			"#FFFFFFDD"
#define HOLOMAP_GLASS_TILE				"#b0d0ffdd"

#define HOLOMAP_AREACOLOR_COM			"#447FC299"
#define HOLOMAP_AREACOLOR_SEC			"#AE121299"
#define HOLOMAP_AREACOLOR_MED			"#35803099"
#define HOLOMAP_AREACOLOR_RND			"#A154A699"
#define HOLOMAP_AREACOLOR_ENG 			"#F1C23199"
#define HOLOMAP_AREACOLOR_CRG			"#E06F0099"
#define HOLOMAP_AREACOLOR_CIV			"#63f04799"
#define HOLOMAP_AREACOLOR_ARRIVALS		"#0000FFCC"
#define HOLOMAP_AREACOLOR_ESCAPE		"#FF0000CC"
#define HOLOMAP_AREACOLOR_HALLWAYS		"#FFFFFF66"

#define HOLOMAP_FILTER_DEATHSQUAD				1
#define HOLOMAP_FILTER_ERT						2
#define HOLOMAP_FILTER_NUKEOPS					4
#define HOLOMAP_FILTER_ELITESYNDICATE			8
#define HOLOMAP_FILTER_VOX						16
/// For use with area markers and wayfinding pinpointers
#define HOLOMAP_FILTER_STATIONMAP				32

#define HOLOMAP_OFFSET_X 127.5
#define HOLOMAP_OFFSET_Y 127.5

///Holomap offset for small images
#define HOLOMAP_CORRECTOR_X_SMALL 6
#define HOLOMAP_CORRECTOR_Y_SMALL 6

///Holomap offset for big (32x32) images
#define HOLOMAP_CORRECTOR_X_BIG 16
#define HOLOMAP_CORRECTOR_Y_BIG 16

#define COLOR_HMAP_DEAD "#d3212d"
#define COLOR_HMAP_INCAPACITATED "#ffef00"
#define COLOR_HMAP_DEFAULT "#006e4e"

GLOBAL_LIST_INIT(holomap_frequency_deathsquad, list("frequency" = rand(1200, 1600), "encryption" = rand(1, 100)))
GLOBAL_LIST_INIT(holomap_frequency_ert, list("frequency" = rand(1200, 1600), "encryption" = rand(1, 100)))
GLOBAL_LIST_INIT(holomap_frequency_nuke, list("frequency" = rand(1200, 1600), "encryption" = rand(1, 100)))
GLOBAL_LIST_INIT(holomap_frequency_elitesyndie, list("frequency" = rand(1200, 1600), "encryption" = rand(1, 100)))
GLOBAL_LIST_INIT(holomap_frequency_vox, list("frequency" = rand(1200, 1600), "encryption" = rand(1, 100)))
