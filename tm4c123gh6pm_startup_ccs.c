//*****************************************************************************
//
// Startup code for use with TI's Code Composer Studio.
//
// Copyright (c) 2011-2014 Texas Instruments Incorporated.  All rights
// reserved. Software License Agreement
//
// Software License Agreement
//
// Texas Instruments (TI) is supplying this software for use solely and
// exclusively on TI's microcontroller products. The software is owned by
// TI and/or its suppliers, and is protected under applicable copyright
// laws. You may not combine this software with "viral" open-source
// software in order to form a larger program.
//
// THIS SOFTWARE IS PROVIDED "AS IS" AND WITH ALL FAULTS.
// NO WARRANTIES, WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT
// NOT LIMITED TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. TI SHALL NOT, UNDER ANY
// CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
// DAMAGES, FOR ANY REASON WHATSOEVER.
//
//*****************************************************************************

#include "debug.h"

//*****************************************************************************
//
// Forward declaration of the default fault handlers.
//
//*****************************************************************************
void ResetISR(void);
static void NmiSR(void);
static void FaultISR(void);
static void IntDefaultHandler(void);

//*****************************************************************************
//
// External declaration for the reset handler that is to be called when the
// processor is started
//
//*****************************************************************************
extern void _c_int00(void);
extern void UART0_Handler(void);
extern void Switch_Handler(void);
extern void Timer_Handler(void);

//*****************************************************************************
//
// Linker variable that marks the top of the stack.
//
//*****************************************************************************
extern uint32_t __STACK_TOP;

//*****************************************************************************
//
// External declarations for the interrupt handlers used by the application.
//
//*****************************************************************************
// To be added by user

//*****************************************************************************
// global variable for debug function
static bool cangoback = false;
//*****************************************************************************
//
// The vector table.  Note that the proper constructs must be placed on this to
// ensure that it ends up at physical address 0x0000.0000 or at the start of
// the program if located at a start address other than 0.
//
//*****************************************************************************
#pragma DATA_SECTION(g_pfnVectors, ".intvecs")
void (*const g_pfnVectors[])(void) = {
    (void (*)(void))((uint32_t)&__STACK_TOP),
    // The initial stack pointer
    ResetISR,           // The reset handler
    NmiSR,              // The NMI handler
    FaultISR,           // The hard fault handler
    IntDefaultHandler,  // The MPU fault handler
    IntDefaultHandler,  // The bus fault handler
    IntDefaultHandler,  // The usage fault handler
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // SVCall handler
    IntDefaultHandler,  // Debug monitor handler
    0,                  // Reserved
    IntDefaultHandler,  // The PendSV handler
    IntDefaultHandler,  // The SysTick handler
    IntDefaultHandler,  // GPIO Port A
    IntDefaultHandler,  // GPIO Port B
    IntDefaultHandler,  // GPIO Port C
    IntDefaultHandler,  // GPIO Port D
    IntDefaultHandler,  // GPIO Port E
    UART0_Handler,      // UART0 Rx and Tx
    IntDefaultHandler,  // UART1 Rx and Tx
    IntDefaultHandler,  // SSI0 Rx and Tx
    IntDefaultHandler,  // I2C0 Master and Slave
    IntDefaultHandler,  // PWM Fault
    IntDefaultHandler,  // PWM Generator 0
    IntDefaultHandler,  // PWM Generator 1
    IntDefaultHandler,  // PWM Generator 2
    IntDefaultHandler,  // Quadrature Encoder 0
    IntDefaultHandler,  // ADC Sequence 0
    IntDefaultHandler,  // ADC Sequence 1
    IntDefaultHandler,  // ADC Sequence 2
    IntDefaultHandler,  // ADC Sequence 3
    IntDefaultHandler,  // Watchdog timer
    Timer_Handler,      // Timer 0 subtimer A
    IntDefaultHandler,  // Timer 0 subtimer B
    IntDefaultHandler,  // Timer 1 subtimer A
    IntDefaultHandler,  // Timer 1 subtimer B
    IntDefaultHandler,  // Timer 2 subtimer A
    IntDefaultHandler,  // Timer 2 subtimer B
    IntDefaultHandler,  // Analog Comparator 0
    IntDefaultHandler,  // Analog Comparator 1
    IntDefaultHandler,  // Analog Comparator 2
    IntDefaultHandler,  // System Control (PLL, OSC, BO)
    IntDefaultHandler,  // FLASH Control
    Switch_Handler,     // GPIO Port F
    IntDefaultHandler,  // GPIO Port G
    IntDefaultHandler,  // GPIO Port H
    IntDefaultHandler,  // UART2 Rx and Tx
    IntDefaultHandler,  // SSI1 Rx and Tx
    IntDefaultHandler,  // Timer 3 subtimer A
    IntDefaultHandler,  // Timer 3 subtimer B
    IntDefaultHandler,  // I2C1 Master and Slave
    IntDefaultHandler,  // Quadrature Encoder 1
    IntDefaultHandler,  // CAN0
    IntDefaultHandler,  // CAN1
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // Hibernate
    IntDefaultHandler,  // USB0
    IntDefaultHandler,  // PWM Generator 3
    IntDefaultHandler,  // uDMA Software Transfer
    IntDefaultHandler,  // uDMA Error
    IntDefaultHandler,  // ADC1 Sequence 0
    IntDefaultHandler,  // ADC1 Sequence 1
    IntDefaultHandler,  // ADC1 Sequence 2
    IntDefaultHandler,  // ADC1 Sequence 3
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // GPIO Port J
    IntDefaultHandler,  // GPIO Port K
    IntDefaultHandler,  // GPIO Port L
    IntDefaultHandler,  // SSI2 Rx and Tx
    IntDefaultHandler,  // SSI3 Rx and Tx
    IntDefaultHandler,  // UART3 Rx and Tx
    IntDefaultHandler,  // UART4 Rx and Tx
    IntDefaultHandler,  // UART5 Rx and Tx
    IntDefaultHandler,  // UART6 Rx and Tx
    IntDefaultHandler,  // UART7 Rx and Tx
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // I2C2 Master and Slave
    IntDefaultHandler,  // I2C3 Master and Slave
    IntDefaultHandler,  // Timer 4 subtimer A
    IntDefaultHandler,  // Timer 4 subtimer B
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // Timer 5 subtimer A
    IntDefaultHandler,  // Timer 5 subtimer B
    IntDefaultHandler,  // Wide Timer 0 subtimer A
    IntDefaultHandler,  // Wide Timer 0 subtimer B
    IntDefaultHandler,  // Wide Timer 1 subtimer A
    IntDefaultHandler,  // Wide Timer 1 subtimer B
    IntDefaultHandler,  // Wide Timer 2 subtimer A
    IntDefaultHandler,  // Wide Timer 2 subtimer B
    IntDefaultHandler,  // Wide Timer 3 subtimer A
    IntDefaultHandler,  // Wide Timer 3 subtimer B
    IntDefaultHandler,  // Wide Timer 4 subtimer A
    IntDefaultHandler,  // Wide Timer 4 subtimer B
    IntDefaultHandler,  // Wide Timer 5 subtimer A
    IntDefaultHandler,  // Wide Timer 5 subtimer B
    IntDefaultHandler,  // FPU
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // I2C4 Master and Slave
    IntDefaultHandler,  // I2C5 Master and Slave
    IntDefaultHandler,  // GPIO Port M
    IntDefaultHandler,  // GPIO Port N
    IntDefaultHandler,  // Quadrature Encoder 2
    0,                  // Reserved
    0,                  // Reserved
    IntDefaultHandler,  // GPIO Port P (Summary or P0)
    IntDefaultHandler,  // GPIO Port P1
    IntDefaultHandler,  // GPIO Port P2
    IntDefaultHandler,  // GPIO Port P3
    IntDefaultHandler,  // GPIO Port P4
    IntDefaultHandler,  // GPIO Port P5
    IntDefaultHandler,  // GPIO Port P6
    IntDefaultHandler,  // GPIO Port P7
    IntDefaultHandler,  // GPIO Port Q (Summary or Q0)
    IntDefaultHandler,  // GPIO Port Q1
    IntDefaultHandler,  // GPIO Port Q2
    IntDefaultHandler,  // GPIO Port Q3
    IntDefaultHandler,  // GPIO Port Q4
    IntDefaultHandler,  // GPIO Port Q5
    IntDefaultHandler,  // GPIO Port Q6
    IntDefaultHandler,  // GPIO Port Q7
    IntDefaultHandler,  // GPIO Port R
    IntDefaultHandler,  // GPIO Port S
    IntDefaultHandler,  // PWM 1 Generator 0
    IntDefaultHandler,  // PWM 1 Generator 1
    IntDefaultHandler,  // PWM 1 Generator 2
    IntDefaultHandler,  // PWM 1 Generator 3
    IntDefaultHandler   // PWM 1 Fault
};

//*****************************************************************************
//
// This is the code that gets called when the processor first starts execution
// following a reset event.  Only the absolutely necessary set is performed,
// after which the application supplied entry() routine is called.  Any fancy
// actions (such as making decisions based on the reset cause register, and
// resetting the bits in that register) are left solely in the hands of the
// application.
//
//*****************************************************************************
void ResetISR(void) {
  //
  // Jump to the CCS C initialization routine.  This will enable the
  // floating-point unit as well, so that does not need to be done here.
  //
  __asm("    .global _c_int00\r\n"
        "    b.w     _c_int00");
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a NMI.  This
// simply enters an infinite loop, preserving the system state for examination
// by a debugger.
//
//*****************************************************************************
static void NmiSR(void) {
  //
  // Enter an infinite loop.
  //
  while (1) {
  }
}

//*****************************************************************************
//
// This is the code that gets called when the processor receives a fault
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void FaultISR(void) {
  int cont = 0;  // should only be modified by debugger
  /*
   * Allow me to copy into an editor what the faulted instruction is, and copy
   * r3 to preserve it.  goback goes to one before the faulted instruction.
   */
  while (!cont) {
    // spin
  }

  uint32_t badaddr;                                   // technically this should be a pointer, but it doesn't matter.  its not going to be used anywhere except in assembly, so type doesn't really matter
  volatile void *cfsr = (volatile void *)0xE000ED28;  // address of the configurable fault status register, can get further information from bitmasking this

  // preserve r0 by pushing it to the stack
  asm(
      "preserve_r0:\n str sp!, [r0, #0]");

  uint32_t mmsr = (*(uint32_t *)cfsr) & (uint32_t)0xFF;        // memfault status register is only 1 byte in size
  uint32_t bfsr = (*(uint32_t *)cfsr) & (uint32_t)0xFF00;      // bus fault status reg also one byte in size, at 0xE000ED29, shift bitmask
  uint32_t ufsr = (*(uint32_t *)cfsr) & (uint32_t)0xFFFF0000;  // usage fault status reg is upper halfword, mask for just that

  if (mmsr != 0) {
    badaddr = handle_memfualt(mmsr);
  }

  if (bfsr != 0) {
    badaddr = handle_busfault(mmsr);
  }

  if (ufsr != 0) {
    // no address register associated with a usage fault
    ufsrprint(ufsr);
  }

  if (cangoback) {
    goback(badaddr);  // goes back to assembly passing in the bad address
  } 

  // if we get here, we can't go back.  
  char* finalmsg = "No valid address found, cannot go back.\r\n";
  output_string(finalmsg);
  for(;;){
    // spin forever
  }
}

uint32_t handle_memfualt(uint32_t mmsr) {
  volatile void *mmar = (volatile void *)0xE000ED34;  // address of the MemManage Address Register
  // - contains address of faulted instruction
  mmsrprint(mmsr);

  uint32_t badaddr = *(uint32_t *)mmar;  // dereference mmar to get the address of the faulted instruction
  return badaddr;
}

void mmsrprint(uint32_t mmsr) {
  // now we print to uart what the type of error is
  uint32_t MMARVALID = mmsr & 0x80;
  uint32_t MLSPERR = mmsr & 0x20;
  uint32_t MSTKERR = mmsr & 0x10;
  uint32_t MUNSTKERR = mmsr & 0x08;
  uint32_t DACCVIOL = mmsr & 0x02;
  uint32_t IACCVIOL = mmsr & 0x01;

  char *msg = "N/A\r\n";
  // there's no == because it'll do this if MMARVALID is nonzero, and MMARVALID will only ever be zero or nonzero.
  if (MMARVALID) {
    msg = "MMAR Contains valid fault address\r\n";
    cangoback = true;
  } else {
    msg = "value in MMAR is not a valid fault addres\r\n";
  }

  output_string(msg);  // goes to assembly

  if (MLSPERR) {
    msg = "a MemManage fault occurred during floating-point lazy state preservation.\r\n";
  } else {
    msg = "no MemManage fault occurred during floating-point lazy state preservation\r\n";
  }

  output_string(msg);

  if (MSTKERR) {
    msg = "stacking for an exception entry has caused one or more access violations. When this bit is 1, the SP is still adjusted but the values in the context area on the stack might be incorrect. The processor has not written a fault address to the MMAR.\r\n";
  } else {
    msg = "no stacking fault.\r\n";
  }

  output_string(msg);

  if (MUNSTKERR) {
    msg = "unstack for an exception return has caused one or more access "
          "violations. This fault is chained to the handler. This means "
          "that when this bit is 1, the original return stack is still "
          "present. The processor has not adjusted the SP from the failing "
          "return, and has not performed a new save. The processor has not "
          "written a fault address to the MMAR.\r\n";
  } else {
    msg = "no unstacking fault.\r\n";
  }

  output_string(msg);

  if (DACCVIOL) {
    msg = "The processor attempted a load or store at a location that does "
          "not permit the operation. When this bit is 1, the PC value "
          "stacked for the exception return points to the faulting "
          "instruction. The processor has loaded the MMAR with the address "
          "of the attempted access.\r\n";
  } else {
    msg = "no data access violation fault.\r\n";
  }

  output_string(msg);

  if (IACCVIOL) {
    msg = "The processor attempted an instruction fetch from a location "
          "that does not permit execution\r\n";
  } else {
    msg = "no instruction access violation fault.\r\n";
  }

  output_string(msg);
}

uint32_t handle_busfault(uint32_t bfsr) {

  volatile void *bfar = (volatile void *)0xE000ED38;
  uint32_t badaddr = *(uint32_t *)bfar;

  bfsrprint(bfsr);
  return badaddr;
}

void bfsrprint(uint32_t obfsr) {
  // types could *probably* be turned into uint8_t or a bool, but meh i don't really care and don't want to deal with type changing
  uint32_t bfsr = obfsr >> 8;

  uint32_t BFARVALID = bfsr & 0x80;
  uint32_t LSPERR = bfsr & 0x20;
  uint32_t STKERR = bfsr & 0x10;
  uint32_t UNSTKERR = bfsr & 0x08;
  uint32_t IMPRECISERR = bfsr & 0x04;
  uint32_t PRECISERR = bfsr & 0x02;
  uint32_t IBUSERR = bfsr & 0x01;

  // chain of ifs to print the message
  char *msg = "N/A\r\n";
  if (BFARVALID) {
    msg = "BFAR holds a valid fault address\r\n";
  cangoback = true;
  } else {
    msg = "value in BFAR is not a valid fault address\r\n";
  }

  output_string(msg);

  if (LSPERR) {
    msg = "a bus fault occurred during floating-point lazy state preservation\r\n";
  } else {
    msg = "no bus fault occurred during floating-point lazy state preservation\r\n";
  }

  output_string(msg);

  if (STKERR) {
    msg = "no stacking fault\r\n";
  } else {
    msg = "stacking for an exception entry has caused one or more BusFaults.\r\n";
  }

  output_string(msg);

  if (UNSTKERR) {
    msg = "unstack for an exception return has caused one or more BusFaults.\r\n";
  } else {
    msg = "no unstacking fault.\r\n";
  }

  output_string(msg);

  if (IMPRECISERR) {
    msg = "a data bus error has occurred, but the return address in the stack frame is not related to the instruction that caused the error.\r\n";
  } else {
    msg = "no imprecise data bus error.\r\n";
  }

  output_string(msg);

  if (PRECISERR) {
    msg = "a data bus error has occurred, and the PC value stacked for the exception return points to the instruction that caused the fault.\r\n";
  } else {
    msg = "no precise data bus error\r\n";
  }

  output_string(msg);

  if (IBUSERR) {
    msg = "instruction bus error.\r\n";
  } else {
    msg = "no instruction bus errorno instruction bus error.\r\n";
  }

  output_string(msg);
}

void ufsrprint(uint32_t oufsr) {

  uint32_t ufsr = oufsr >> 16;
  uint16_t DIVBYZERO = ufsr & 0x200;
  uint16_t UNALIGNED = ufsr & 0x100;
  uint16_t NOCP = ufsr & 0x008;
  uint16_t INVPC = ufsr & 0x004;
  uint16_t INVSTATE = ufsr & 0x002;
  uint16_t UNDEFINSTR = ufsr & 0x001;

  char *msg = "N/A\r\n";
  if (DIVBYZERO) {
    msg = "the processor has executed an SDIV or UDIV instruction with a divisor of 0\r\n";
  } else {
    msg = "no divide by zero fault, or divide by zero trapping not enabled\r\n";
  }

  output_string(msg);

  if (UNALIGNED) {
    msg = "The processor has made an unaligned memory access\r\n";
  } else {
    msg = " no unaligned access fault, or unaligned access trapping not enabled";
  }

  output_string(msg);

  if (NOCP) {
    msg = "The processor has attempted to access a coprocessor\r\n";
  } else {
    msg = "no UsageFault caused by attempting to access a coprocessor\r\n";
  }

  output_string(msg);

  if (INVPC) {
    msg = "the processor has attempted an illegal load of EXC_RETURN to the PC, as a result of an invalid context, or an invalid EXC_RETURN value\r\nNOTE: When this bit is set to 1, the PC value stacked for the exception return points to the instruction that tried to perform the illegal load of the PC.\r\n";
  } else {
    msg = "no invalid PC load UsageFault\r\n";
  }

  output_string(msg);

  if (INVSTATE) {
    msg = "the processor has attempted to execute an instruction that makes illegal use of the EPSR\r\n";
  } else {
    msg = "no invalid state UsageFault\r\n";
  }

  output_string(msg);

  if (UNDEFINSTR) {
    msg = "The processor has attempted to execute an undefined instruction.  When this bit is set to 1, the PC value stacked for the exception return points to the undefined instruction. An undefined instruction is an instruction that the processor cannot decode.\r\r\n";
  } else {
    msg = "no undefined instruction UsageFault.\r\n";
  }

  output_string(msg);
}
//*****************************************************************************
//
// This is the code that gets called when the processor receives an unexpected
// interrupt.  This simply enters an infinite loop, preserving the system state
// for examination by a debugger.
//
//*****************************************************************************
static void IntDefaultHandler(void) {
  //
  // Go into an infinite loop.
  //
  while (1) {
  }
}
