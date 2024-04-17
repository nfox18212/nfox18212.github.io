#pragma once

#include <stdbool.h>
#include <stdint.h>
#include "debug_config.h"

#define clearscreen 0xC  // form feed character to clear screen
#define newline 0xDA // carriage return and newline

// these two functions are implemented in assembly
extern void goback(uint32_t addr);     // debug function to jump back to assembly and we can go to a faulted instruction
extern void output_string(char *str);  // print to uart
extern void output_character(char a);

// fault handling functions
uint32_t handle_memfualt(uint32_t mmsr);
uint32_t handle_busfault(uint32_t bfsr);
// there's no ufar register like there is for memory or bus faults

// error message printing
void mmsrprint(uint32_t mmsr);
void bfsrprint(uint32_t bfsr);
void ufsrprint(uint32_t ufsr);

void handlefault(void);
void customfault(uint32_t baddr);
void normalfault(void);
void serial_init(void);
