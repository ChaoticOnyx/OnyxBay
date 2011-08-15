#include "main.h"

// test.dll, a win32 C++ library compiled in VC++:
#include <string.h>

extern "C" __declspec(dllexport) float temperature(int n, float *v[])
{
      if(n != 4)
      {
            return 0.0;
      }

      float temp, giver_temp;
      temp = *v[1];
      giver_temp = *v[2];

      float heat_capacity,giver_capacity;
      heat_capacity = *v[3];
      giver_capacity = *v[4];

      //var/combined_heat_capacity = giver_heat_capacity + self_heat_capacity
      //if(combined_heat_capacity != 0)
      //	temperature = (giver.temperature*giver_heat_capacity + temperature*self_heat_capacity)/combined_heat_capacity
      float combined_capacity = heat_capacity + giver_capacity;
      if(combined_capacity > 0)
      {
            return (giver_temp * giver_capacity + temp * heat_capacity)/combined_capacity;
      }
      return 0.0;
}

extern "C" __declspec(dllexport) float *zone_update(int n, float *v[])
{
      if(n != 11)
      {
            return NULL;
      }
      float oxygen, nitrogen, co2, plasma, tiles;
      float zoxygen, znitrogen, zco2, zplasma, ztiles;
      float flow;

      static float results[8];

      oxygen = *v[1];
      nitrogen = *v[2];
      co2 = *v[3];
      plasma = *v[4];
      tiles = *v[5];

      zoxygen = *v[6];
      znitrogen = *v[7];
      zco2 = *v[8];
      zplasma = *v[9];
      ztiles = *v[10];

      flow = *v[11];

      float oxy_avg, nitro_avg, co2_avg, plasma_avg;

      oxy_avg = (oxygen + zoxygen) / (tiles + ztiles);
      nitro_avg = (nitrogen + znitrogen) / (tiles + ztiles);
      co2_avg = (co2 + zco2) / (tiles + ztiles);
      plasma_avg = (plasma + zplasma) / (tiles + ztiles);

      results[1] = ((oxygen/tiles) - oxy_avg) * (1-flow/100) + oxy_avg;
      results[2] = ((nitrogen/tiles) - nitro_avg) * (1-flow/100) + nitro_avg;
      results[3] = ((co2/tiles) - co2_avg) * (1-flow/100) + co2_avg;
      results[4] = ((plasma/tiles) - plasma_avg) * (1-flow/100) + plasma_avg;

      results[5] = ((zoxygen/ztiles) - oxy_avg) * (1-flow/100) + oxy_avg;
      results[6] = ((znitrogen/ztiles) - nitro_avg) * (1-flow/100) + nitro_avg;
      results[7] = ((zco2/ztiles) - co2_avg) * (1-flow/100) + co2_avg;
      results[8] = ((zplasma/ztiles) - plasma_avg) * (1-flow/100) + plasma_avg;

      return results;
}
