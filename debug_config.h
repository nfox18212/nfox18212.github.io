#pragma once
// this is a configuration file for this debug module.  Use this file to enable or disable uart, interrupts, timers or gpio.
#define en_gpio_int 1 // gpio is enabled
#define en_uart_int 1 // uart is enabled
#define en_timer_int 1
#define en_uart_init 0 // use this to indicate if this code should initialize uart
#define en_uart_out 1 // if you do not have an implementation of uart_out, disable this

