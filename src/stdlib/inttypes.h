#ifndef INTTYPES_H
#define INTTYPES_H

// Signed integer types
typedef signed char        int8_t;
typedef signed short       int16_t;
typedef signed int         int32_t;
typedef signed long long   int64_t;

// Unsigned integer types
typedef unsigned char      uint8_t;
typedef unsigned short     uint16_t;
typedef unsigned int       uint32_t;
typedef unsigned long long uint64_t;

// Size types
typedef unsigned long long size_t;
typedef signed long long   ssize_t;

// Pointer types
typedef unsigned long long uintptr_t;
typedef signed long long   intptr_t;

// Boolean type
//typedef uint8_t bool;
//#define true  1
//#define false 0

// NULL pointer
#define NULL ((void*)0)

// Useful macros
#define UINT8_MAX   0xFF
#define UINT16_MAX  0xFFFF
#define UINT32_MAX  0xFFFFFFFF
#define UINT64_MAX  0xFFFFFFFFFFFFFFFF

#define INT8_MAX    127
#define INT8_MIN    (-128)
#define INT16_MAX   32767
#define INT16_MIN   (-32768)
#define INT32_MAX   2147483647
#define INT32_MIN   (-2147483648)
#define INT64_MAX   9223372036854775807LL
#define INT64_MIN   (-9223372036854775807LL - 1)

#endif // INTTYPES_H
