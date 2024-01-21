/// Gets the sign of x, returns -1 if negative, 0 if 0, 1 if positive
#define MATH_SIGN(x) ( ((x) > 0) - ((x) < 0) )
#define QUANTIZE(variable) (round(variable, ATMOS_PRECISION))

/// Linear conversion from range of [minx, maxx] to [miny, maxy] regarding the value x. Clamps excesses.
#define TRANSLATE_RANGE(x, minx, maxx, miny, maxy) clamp(((x - minx) * (maxy - miny) / (maxx - minx)) + miny, miny, maxy)
