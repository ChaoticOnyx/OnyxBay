#define SURGERY_FAILURE -1
#define SURGERY_BLOCKED -2

/* some defines for often used surgery steps */

#define SURGERY_DURATION_DELTA rand(9,11) / 10 // delta multiplier for all surgeries, from 0.9 to 1.1

#define CUT_DURATION           30 // making cuts / unscrewing or deattaching organs
#define CLAMP_DURATION         35 // hemostat usage
#define RETRACT_DURATION       25 // retracting
#define CAUTERIZE_DURATION     35 // cautery
#define GLUE_BONE_DURATION     35 // bone glue
#define BONE_MEND_DURATION     40 // bone menders
#define SAW_DURATION           50 // saw
#define DRILL_DURATION         70 // drilling
#define ATTACH_DURATION        50 // attaching externals / putting something in
#define ORGAN_FIX_DURATION     35 // organs fixing / welding
#define CONNECT_DURATION       50 // fix o vein usage
