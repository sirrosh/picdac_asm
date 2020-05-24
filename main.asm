list	p=16f648a
radix dec
#include "p16f648a.inc"
;__config 0x3f78
__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF

#define SINE_TABLE_ADDRESS	0x0200
#define SINE_TABLE_ADDRESS_H	0x02

SINE_TABLE	CODE	SINE_TABLE_ADDRESS
SINE_8
#include "sine.inc"

    CBLOCK 0x70 ; 0x70-0x7F -- 16 bytes of bank independent memory block
i_cycle
W_temp
W_swap
STATUS_temp
    ENDC


;DEEPROM     CODE                     ; let's put initial values to eeprom
;    de 0x69, 0xFF

RES_VECT    CODE    0x0000          ; processor reset vector
    NOP                             ; for ICD
    GOTO    START

INT_VECT    CODE    0x0004          ; interrupt vector
    GOTO    INTERRUPT

TABLEREAD   CODE    0x0006          ; table read routine, should be at fixed address
TBLRD
    MOVWF   W_swap                  ; pageselw SINE_8 also spoils W_reg
    MOVLW   SINE_TABLE_ADDRESS_H
    MOVWF   PCLATH
    MOVFW   W_swap
    MOVWF   PCL                     ; a table would start at the segment boundary
    RETURN                          ; this should never been executed

MAIN_PROG   CODE                    ; let linker place main program

START
    banksel TRISB
    CLRF   TRISB            ; port B to output
    banksel PORTB
    CLRF   i_cycle
MAIN_LOOP
    MOVFW  i_cycle
    CALL   TBLRD
    MOVWF  PORTB
    INCF   i_cycle
    pageselw $
    GOTO   MAIN_LOOP



;--- ISR stub
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