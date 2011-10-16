/** \file utils.hpp
    \brief Generally useful utils.

    This file includes a set of functions and macros that make life in C++ easier. While this file
    might provide utils that rely on other libraries to function, this module itself tries to avoid
    including other modules in order to avoid too high compile time.
*/


#pragma once

#include <stdlib.h>
#include <iostream>
#include <time.h>

#define CENTER 0
#define NORTH 1
#define SOUTH 2
#define EAST  4
#define WEST  8
#define UP    16
#define DOWN  32

#define NORTHEAST 5
#define NORTHWEST 9
#define SOUTHEAST 6
#define SOUTHWEST 10

// macro to make iterating over vectors a bit easier
#define FOREACH(vector_type,vector,varname) for(vector_type::iterator varname=vector.begin();varname != vector.end(); varname++)
#define has_key(container,key) (container.find(key) != container.end())
#define has_value(container,value) (container.find(value) != container.end())

// checks whether the string buffer at position pos is equal to the char* compare
#define findstring(buffer,pos,compare) !memcmp(&buffer[pos],compare,sizeof(compare)-1)

using namespace std;
typedef long int32;
typedef unsigned long uint32;
typedef short int16;
typedef unsigned short uint16;
typedef char int8;
typedef unsigned char uint8;

// used to convert to nanoseconds and back
#define MILLION 1000000

/// Get time reference in microseconds
#define get_utime() ( clock() * (MILLION / CLOCKS_PER_SEC) )

/// A rect usually represents a pixel range on the map
class Rect {
    public:
    int left,top,width,height;
    Rect(int left, int top, int width, int height) :
        left(left), top(top), width(width), height(height) {}
    inline int right() {return left+width;}
    inline int bottom() {return top+height;}
};

/** \brief Holds a fixlen bytebuffer

    This class is used to handle buffers of fixed size
    that are not NULL-terminated.

    The necessary memory to hold the data will be allocated
    and the data itself can be modified at any time as long
    as the length is not changed.
**/
class bytes {
public:
    void* data;
    uint32 size;

    /// Allocate s bytes of data
    void init(uint32 s) {
        size = s;
        data = malloc(size);
    }

    /// Use the pre-allocated data, will be free'd by this class
    void init(uint32 s, void* d) {
        size = s;
        data = d;
    }

    /// This doesn't allocate the memory in order to achieve vector compatability
    bytes() : data(NULL) { };

    /// Make sure data is free'd when this object is destroyed
    ~bytes() {
        if(data != NULL) {
            free(data);
        }
    }
};

static inline double seconds() {
    return ((double) clock()) / CLOCKS_PER_SEC;
}
