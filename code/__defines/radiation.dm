#define MAX_RADIATION_DIST (world.view * 2)
#define RADIATION_DISTANCE_MULT(DST) (log(2, max(2, DST + 2)))
#define RADIATION_MIN_IONIZATION (10 ELECTRONVOLT)
#define RADIATION_CALC_OBJ_RESIST(rad_info, obj) ((obj.atom_flags & ATOM_FLAG_OPEN_CONTAINER) ? 0 : get_rad_resist_value(obj.rad_resist_type, rad_info.radiation_type))

#define RADIATION_ALPHA_PARTICLE "alpha_particle"
#define RADIATION_BETA_PARTICLE  "beta_particle"
#define RADIATION_HAWKING        "hawking"

#define IS_VALID_RADIATION_TYPE(ty) (ty == RADIATION_ALPHA_PARTICLE || ty == RADIATION_BETA_PARTICLE || ty == RADIATION_HAWKING)
#define IS_PARTICLE_RADIATION(ty) (ty == RADIATION_ALPHA_PARTICLE || ty == RADIATION_BETA_PARTICLE)
#define IS_THERMAL_RADIATION(ty) (ty == RADIATION_HAWKING)
#define IS_ELECTROMAGNETIC_RADIATION(ty) IS_THERMAL_RADIATION(ty)
