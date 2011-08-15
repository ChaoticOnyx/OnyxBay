#ifndef __MAIN_H__
#define __MAIN_H__

#include <windows.h>

/*  To use this exported function of dll, include this header
 *  in your project.
 */

#ifdef BUILD_DLL
    #define DLL_EXPORT __declspec(dllexport)
#else
    #define DLL_EXPORT __declspec(dllimport)
#endif


#ifdef __cplusplus
extern "C"
{
#endif

extern "C" float temperature(int n, float *v[]);
extern "C" float *zone_update(int n, float *v[]);

#ifdef __cplusplus
}
#endif

#endif // __MAIN_H__
