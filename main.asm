;-------------------------------------------------------------------------------
;
; Main servo controller program file, based on the TI code composer studio template.
;
; Consider this a permanent work in progress. I learn new stuff every day.
;
; I started out by reading http://robotics.hobbizine.com/asmlau.html
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430g2553.h"       ; Include device header file
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------

; Define the variable space for servo settings
; Each servo reserves a number of bytes
; - current position
; - desired position
; - step size to get to the desired position
;
;
			.bss	servo1,3
			.bss	servo2,3
			.bss	servo3,3
			.bss	servo4,3
			.bss	servo5,3
			.bss	servo6,3
			.bss	servo7,3
			.bss	servo8,3
;-------------------------------------------------------------------------------
; Set the clock
;
; For now I have chosen a high clock frequency. The idea is to make the code run
; as fast as it can. That way, theoretically, there is more time available for
; the communication routines
;-------------------------------------------------------------------------------
SetDCO		mov.b CALDCO_16MHZ, DCOCTL		; Moves the value of CALDCO_16MHZ into the register DCOCTL
											; CALDCO_16MHZ       = 0x10F8; Defined in msp430g2552.cmd
;+------------+-----------+-----------+-----------+-----+-------+-------+-------+
;|	   7      |		6	  |		5	  |		4     |	3	|	2	|	1	|	0   |
;+------------+-----------+-----------+-----------+-----+-------+-------+-------+
;| 			 	  DCOx				  |					MODx					|
;+------------------------------------+-----------------------------------------+
;|	   1      |		1     |		1     |		1     |	1	|	0	|	0	|	0	|
;+------------------------------------+-----------------------------------------+
;					|						|
;					|						+ Modulator selection. These bits define how often the f DCO+1 frequency
;					|						  is used within a period of 32 DCOCLK cycles. During the remaining clock
;					|						  cycles (32-MOD) the f DCO frequency is used. Not useable when DCOx = 7.
;					+ 7 (highest possible speed)


; The MODx settings according to the docs I could find are not used. This makes me wonder why it has such a specific value.
; Why not all zeros or ones

											; CALBC1_16MHZ       = 0x10F9; Defined in msp430g2552.cmd
			mov.b CALBC1_16MHZ, BCSCTL1		; C examples state something similar but I have not yet found the exact meaning
											; Moves the value of CALBC1_16MHZ to the BCSCTL1 register

; slau144i msp430x2xx
; 5.3.2 BCSCTL1, Basic Clock System Control Register 1
; servoController_linkInfo.xml lists CALBC1_16MHZ as 0x10f9 which is the same as 1000011111001
; Since we are moving a byte the register would look like this
;
;+--------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+
;|		7		|		6		|		5		|		4		|		3		|		2		|		1		|		0		|
;+--------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+
;| 	 XT2OFF		|	   XTS		|			  DIVAx				|							  RSELx								|
;+----------------------------------------------+-------------------------------------------------------------------------------+
;|		1		|		1		|		1		|		1		|		1		|		0		|		0		|		1		|
;+----------------------------------------------+-------------------------------------------------------------------------------+
;		|				|				|								|
;		|				|				|								+ DEC 9
;		|				|				|
;		|				|				+ 11 /8
;		|				|
;		|				+ 1 High-frequency mode
;		|
;		+- XT2 is off if it is not used for MCLK or SMCLK.
;
; The actual value of RSEL seems to set the actual frequence step in the range. I can only assume The settings combined
; set the DCO to 16Mhz

;ConfigureTimerA
;			mov.b 0x00, ; Stop the timer
; configure the timer
; Start the timer up again
; @todo determine if we allow communication interrupts here


			; todo check the # in the following two statements, seems to have something to do with addressing modes
			; a recent error leads me to believe it has something to do with hex numbers
			; changing pins will be primarily related to servo control
			; Communication is probably done differently
			mov.b #0xff, P1DIR				; Set port 1 to be all outputs (high)
			mov.b #0x7e, P1OUT				; Set all pins to high

;
; Some test lines to see how to work with .bss
; @todo see how the addressing modes work. with the .bss directive I reserve several bytes with a single label. I need to figure out how to address the other bytes.
;
			mov.b	#0xff, &servo1
			mov.b	#0x00, R10
			mov.b	r10, &servo1
			mov.b	#0xff, R10
			mov.b	&servo1, R10
;			add
			nop
			nop
			nop
;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET


; DCOCTL, DCO Control register
;+--------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+
;|		7		|		6		|		5		|		4		|		3		|		2		|		1		|		0		|
;+--------------+---------------+---------------+---------------+---------------+---------------+---------------+---------------+
;| 					  DCOx						|									   MODx										|
;+----------------------------------------------+-------------------------------------------------------------------------------+
