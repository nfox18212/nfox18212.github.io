#include "debug.h"
extern void lab7(void);

 int main() {
#ifdef en_uart_init
#if en_uart_init == 1
  serial_init(); // this will only be assembled if directly enabled in debug_config.h
#endif
#endif
      lab7();
}
