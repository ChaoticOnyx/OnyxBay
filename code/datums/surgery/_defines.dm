#define SURGERY_FAILURE -1

/// Causes hands to become bloody.
#define BLOODY_HANDS (1 << 0)
/// Causes body to become bloody.
#define BLOODY_BODY  (1 << 1)

/// Delta multiplier for all surgeries, ranges from 0.9 to 1.1.
#define SURGERY_DURATION_DELTA rand(9, 11) / 10

#define CUT_DURATION            30
#define AMPUTATION_DURATION    125
#define CLAMP_DURATION          35
#define RETRACT_DURATION        25
#define CAUTERIZE_DURATION      35
#define GLUE_BONE_DURATION      35
#define BONE_MEND_DURATION      40
#define SAW_DURATION            50
#define DRILL_DURATION          70
#define ATTACH_DURATION         50
#define ORGAN_FIX_DURATION      35
#define CONNECT_DURATION        50
#define STERILIZATION_DURATION  55
#define DETACH_DURATION         52
#define TREAT_NECROSIS_DURATION 26
