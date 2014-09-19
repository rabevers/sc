;------------------------------------------------------------------------------
;   Digital I/O example for the LaunchPad
;   Read the status of built in push button - P1.3
;      (Note that P1.3 is "1" when the push button is open
;       and "0" when the button is closed)
;   Red light if the button is not pushed - P1.0
;   Green light if the button is pushed - P1.6
;   Build with Code Composer Studio
;------------------------------------------------------------------------------

            .cdecls C,LIST,"msp430g2553.h"  ; cdecls tells assembler to allow
                                            ; the c header file

;------------------------------------------------------------------------------
;   Main Code
;------------------------------------------------------------------------------

            .text                           ; program start
            .global _main		    ; define entry point

_main       mov.w   #0280h,SP               ; initialize stack pointer
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; stop watchdog timer

            bis.b   #11111111b,&P1DIR       ; make P1.0 and P1.6 output
                                            ; all others are inputs by default

Mainloop    bis.b   #11110000b,&P1OUT       ; clear P1.0 (red off)
            jmp     Mainloop                ; jump to the Mainloop label

;------------------------------------------------------------------------------
;   Interrupt Vectors
;------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  _main

            .end
