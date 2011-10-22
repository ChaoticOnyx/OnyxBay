#include <boost/lexical_cast.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/regex.hpp>
#include <string.h>
#include <string>

using boost::lexical_cast;
using boost::bad_lexical_cast;

#define GAS_ACCURACY 10000
#define EXCHANGE_ACCURACY 10

#ifdef __WIN32
#include "windows.h"
#endif

#include "main.h"
#include "tile.hpp"

static inline int get_total_gas(Tile* tile) {
	int rval = 0;
	for(int i = 0; i < gases_end; i++) {
		rval += tile->gases[i];
	}
	return rval;
}

// Store metadata about the simulation.
struct Simulation {
	int maxx, maxy, maxz;
	int x, y, z; // the cursor/tile we're currently working with
	std::vector<std::string> events;
};

static inline int get_tile_offset(Simulation* sim, int x, int y, int z) {
	return x + y * sim->maxx + z * sim->maxy * sim->maxx;
}

// uses static information to get the map position
static inline Tile* get_map() {
	char** memrange = (char**) 0x50000000;
	return (Tile*) (*memrange)+sizeof(Simulation);
}

// uses static information to get the metadata
static inline Simulation* get_simulation() {
	Simulation** memrange = (Simulation**) 0x50000000;
	return *memrange;
}

static inline Tile* get_tile() {
	Simulation* sim = get_simulation();
	Tile* map = get_map();
	return &map[get_tile_offset(sim, sim->x, sim->y, sim->z)];
}

#include "airflow.hpp"

// allocateMap(x,y,z)
extern "C" __declspec(dllexport) const char* allocateMap(int argc, char* args[]) {
	int x = lexical_cast<int>(args[0]);
	int y = lexical_cast<int>(args[1]);
	int z = lexical_cast<int>(args[2]);

	#ifdef _WIN32
		void** memrange = (void**) VirtualAlloc((void*) 0x50000000, 32, MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);
		if(memrange != (void*) 0x50000000) {
			return "failure";
		}
		size_t alloc_size = x * y * z * sizeof(Tile) + sizeof(Simulation);
		alloc_size *= 4;
		*memrange = malloc(alloc_size);
		if(!*memrange) return "failure";

		// initialize all the tiles to zero
		memset(*memrange, 0, alloc_size);

		Simulation* metadata = get_simulation();
		metadata->maxx = x;
		metadata->maxy = y;
		metadata->maxz = z;

		return "success";
	#endif
}

uint32* pointer_to_gas(Tile* tile, std::string gasname) {
	if(gasname == "oxygen") return &tile->gases[oxygen];
	else return 0;
}

// setTile(x,y,z)
extern "C" __declspec(dllexport) const char* setTile(int argc, char* args[]) {
	Simulation* sim = get_simulation();
	sim->x = lexical_cast<int>(args[0]);
	sim->y = lexical_cast<int>(args[1]);
	sim->z = lexical_cast<int>(args[2]);

	if(sim->x > sim->maxx || sim->y > sim->maxy || sim->z > sim->maxz) return "failure";
	return 0;
}

// setGas(gasname, amount)
// note that 1 mole of gas in SS13 equals to GAS_ACCURACY moles in our simulation
extern "C" __declspec(dllexport) const char* setGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);
	int32 amount = lexical_cast<int32>(args[1]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	if(gas) *gas = amount * GAS_ACCURACY;

	return 0;

}

// addGas(gasname, amount)
extern "C" __declspec(dllexport) const char* addGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);
	int32 amount = lexical_cast<int32>(args[1]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	if(gas) *gas += amount * GAS_ACCURACY;

	return 0;
}

// getGas(gasname)
extern "C" __declspec(dllexport) const char* getGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);

	Tile* tile = get_tile();

	uint32* gas = pointer_to_gas(tile, gasname);
	std::string rval = lexical_cast<std::string>(*gas / GAS_ACCURACY);
	return rval.c_str();
}

// getTotalGas()
extern "C" __declspec(dllexport) const char* getTotalGas(int argc, char* args[]) {
	std::string gasname = lexical_cast<std::string>(args[0]);

	Tile* tile = get_tile();

	// return the sum of all gases
	std::string rval = lexical_cast<std::string>(get_total_gas(tile) / GAS_ACCURACY);
	return rval.c_str();
}

// setDensity(direction)
extern "C" __declspec(dllexport) const char* setDensity(int argc, char* args[]) {
	Tile* tile = get_tile();

	std::string command = static_cast<std::string>(args[0]);

	tile->flags |= CNORTH;

	return 0;
}

// unsetDensity(direction)
extern "C" __declspec(dllexport) const char* unsetDensity(int argc, char* args[]) {
	Tile* tile = get_tile();

	tile->flags &= ~CNORTH;

	return 0;
}

// setDefaultAtmosphere()
extern "C" __declspec(dllexport) const char* setDefaultAtmosphere(int argc, char* args[]) {
	Tile* tile = get_tile();
	Simulation* sim = get_simulation();

	if((int) tile > ((int) ((((char*)get_simulation)) + sim->maxx * sim->maxy * sim->maxz * sizeof(Tile) + sizeof(Simulation)))) return "failure";

	tile->gases[n2]     = 80000;
	tile->gases[oxygen] = 20000;

	return 0;
}

// tick()
extern "C" __declspec(dllexport) const char* tick(int argc, char* args[]) {
	process_map();
	return 0;
}
