	list	p=16f648a
	radix dec
#include "p16f648a.inc"
;--------------------------------------------------------
; config word(s)
;--------------------------------------------------------
	__config 0x3f78
#include sine.inc

    CBLOCK 0x20
i_cycle
W_temp
STATUS_temp
TH_h
TH_l
T_h
T_l
wMode
    ENDC


;DEEPROM     CODE                     ; let's put initial values to eeprom
;    de 0x69, 0xFF

RES_VECT    CODE    0x0000          ; processor reset vector
    NOP                             ; for ICD
    GOTO    START

INT_VECT    CODE    0x0004          ; interrupt vector
    GOTO    INTERRUPT


MAIN_PROG   CODE                    ; let linker place main program

START



INTERRUPT
    MOVWF   W_temp          ; copy W to temp register, could be in either bank
    SWAPF   STATUS, W       ; swap status to be saved into W
    BCF     STATUS, RP0     ; change to bank 0 regardless ofcurrent bank
    MOVWF   STATUS_temp     ; save status to bank 0 register
                            ; why we are here?
;--- here starts ISR

EXIT_INT
    SWAPF   STATUS_temp, W  ; swap STATUS_TEMP register into W, sets bank to original state
    MOVWF   STATUS          ; move W into STATUS register
    SWAPF   W_temp, F       ; swap W_TEMP
    SWAPF   W_temp, W       ; swap W_TEMP into W

    RETFIE

    END