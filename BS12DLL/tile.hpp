#include "utils.hpp"

#define NONSPACE   1
#define CNORTH     2
#define CSOUTH     4
#define CWEST      8
#define CEAST      16
#define CUP        32
#define CDOWN      64
#define OBJECTS    128

enum enum_gases {
	oxygen,
	toxins,
	co2,
	n2,
	n2o,
	gases_end
};

struct Tile {
	uint32 flags;

	uint32 gases[gases_end];

	uint32 temperature;
	uint32 airflow_x; // airflow on the x-axis, negative means to the left, specified in 1/1000 of the total gas
	uint32 airflow_y; // airflow on the y-axis, negative means down, specified in 1/1000 of the total gas
};
