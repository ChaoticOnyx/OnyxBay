// ========== BOMB DEFUSAL GAME MODE - DEFINES ==========

// Game states (per-match)
#define BOMBDEFUSAL_STATE_LOBBY     0
#define BOMBDEFUSAL_STATE_FREEZE    1
#define BOMBDEFUSAL_STATE_BUY       2
#define BOMBDEFUSAL_STATE_LIVE      3
#define BOMBDEFUSAL_STATE_ROUNDOVER 4
#define BOMBDEFUSAL_STATE_HALFTIME  5
#define BOMBDEFUSAL_STATE_GAMEOVER  6
#define BOMBDEFUSAL_STATE_WARMUP   7

// Teams
#define BOMBDEFUSAL_TEAM_T  "terrorist"
#define BOMBDEFUSAL_TEAM_CT "counter-terrorist"

// Buy menu categories
#define BOMBDEFUSAL_CAT_PISTOLS  "Pistols"
#define BOMBDEFUSAL_CAT_SMGS     "SMGs"
#define BOMBDEFUSAL_CAT_RIFLES   "Rifles"
#define BOMBDEFUSAL_CAT_HEAVY    "Heavy"
#define BOMBDEFUSAL_CAT_AMMO     "Ammo"
#define BOMBDEFUSAL_CAT_GEAR     "Gear"
#define BOMBDEFUSAL_CAT_GRENADES "Grenades"
#define BOMBDEFUSAL_CAT_MEDICAL  "Medical"

// Radio frequencies (unused range in 1200-1600)
#define BOMBDEFUSAL_FREQ_T   1215
#define BOMBDEFUSAL_FREQ_CT  1217
