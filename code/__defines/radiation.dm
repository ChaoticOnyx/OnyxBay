// For effect_flags
/// Does not pass the radiation.
#define EFFECT_FLAG_RAD_SHIELDED (1 << 0)

// Radiation levels
/// Around the level at which radiation starts to become harmful.
#define RAD_LEVEL_LOW 0.5
#define RAD_LEVEL_MODERATE 5
#define RAD_LEVEL_HIGH 25
#define RAD_LEVEL_VERY_HIGH 75

/// Radiation will not affect a tile when below this value.
#define RADIATION_THRESHOLD_CUTOFF 0.1
