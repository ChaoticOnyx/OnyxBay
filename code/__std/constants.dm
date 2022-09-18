// Math constants.

#define M_PI    3.14159265

// kPa*L/(K*mol).
#define R_IDEAL_GAS_EQUATION       8.31
// kPa.
#define ONE_ATMOSPHERE             101.325
// (mol^3 * s^3) / (kg^3 * L).
#define IDEAL_GAS_ENTROPY_CONSTANT 1164

// Radiation constants.

// W/(m^2*K^4).
#define STEFAN_BOLTZMANN_CONSTANT    5.6704e-8
#define COSMIC_RADIATION_TEMPERATURE (3.15 KELVIN)
/// W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define AVERAGE_SOLAR_RADIATION      200
/// kPa at 20 C. This should be higher as gases aren't great conductors until they are dense. Used the critical pressure for air.
#define RADIATOR_OPTIMUM_PRESSURE    (3.771 KILO PASCALS)
/// The critical point temperature for air.
#define GAS_CRITICAL_TEMPERATURE     (132.65 KELVIN)

/// (3 cm + 100 cm * sin(3deg))/(2*(3+100 cm)). Unitless ratio.
#define RADIATOR_EXPOSED_SURFACE_AREA_RATIO 0.04 
/// m^2, surface area of 1.7m (H) x 0.46m (D) cylinder
#define HUMAN_EXPOSED_SURFACE_AREA 5.2
#define AVERAGE_HUMAN_WEIGHT (60 KILO GRAMS)
/// Cosmic microwave background
#define TCMB  (-270.45 CELSIUS)

#define ATMOS_PRECISION 0.0001

#define INFINITY	1.#INF

/// Constant radiation background, approximately the same radiation is received by astronauts every day.
#define SPACE_RADIATION                (0.0006 SIEVERT)
#define SAFE_RADIATION_DOSE            (0.001 SIEVERT)

// Energy
#define ALPHA_PARTICLE_ENERGY (5 MEGA ELECTRONVOLT)
#define BETA_PARTICLE_ENERGY  (0.5 MEGA ELECTRONVOLT)
#define HAWKING_RAY_ENERGY    (122 MILLI ELECTRONVOLT)
