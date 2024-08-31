

                section panel,code_c


                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"
                INCLUDE     "hardware/cia.i"


STACK_ADDRESS                                       
start
                lea     CUSTOM,a6
                move.w  #$7fff,INTENA(a6)
                move.w  #$7fff,DMACON(a6)
                move.w  #$7fff,INTREQ(a6)
                move.w  #$7fff,INTREQ(a6)
                lea     STACK_ADDRESS,a7            ; set stack to start of code (out of harms way)
                jsr     init_system
                jsr     init_display
                jsr     init_keyboard
                 

                ; display test text
                lea     screenbuffer,a0
                lea     textstring,a1
                jsr     display_text

                jmp     main     

main
                add.w   #$01,d0
                ;move.w  d0,$dff180
                jmp     main



                ; ------------------ initialise display ---------------------
init_display
                lea     CUSTOM,a6

                ; set copper bitplane ptrs
                lea     bplptrs,a0
                move.l  #screenbuffer,d0
                move.w  d0,6(a0)
                swap    d0
                move.w  d0,2(a0)

                jsr     clear_screen_buffer

                ; set copper listt
                lea     copperlist,a0
                move.l  a0,COP1LC(a6)
                move.w  #$8380,DMACON(a6)               ; MASTER,BPL,COPPER

                ; enable interrupts
                move.w  #$c020,INTENA(a6)               ; enable VERTB interrupt

                rts


clear_screen_buffer
                lea     screenbuffer,a0
                move.w  #(10*256)-1,d7
.clear_loop     move.l  #0,(a0)+
                dbra    d7,.clear_loop
                rts






                ; ---------------------- keycode translation table --------------------
                ; table of keycodes to characters, the keycode index into the table
                ; identifies the character for use by that key.
                ;
                ; Table Range = $00 to $6f
                ;
                even
keycode_table
                dc.b    '`',' '        ; $00
                dc.b    '1','!'
                dc.b    '2','"'
                dc.b    '3','#'
                dc.b    '4','$'
                dc.b    '5','%'
                dc.b    '6','^'
                dc.b    '7','&'
                dc.b    '8','*'
                dc.b    '9','('
                dc.b    '0',')'             ; $0a
                dc.b    '-','_'
                dc.b    '=','+'
                dc.b    '\','|'
                dc.b    ' ',' '             ; $0e - Unassigned
                dc.b    '0','0'             ; $0f - keypad - 0

                dc.b    'Q','Q'             ; $10
                dc.b    'W','W'
                dc.b    'E','E'
                dc.b    'R','R'
                dc.b    'T','T'
                dc.b    'Y','Y'
                dc.b    'U','U'
                dc.b    'I','I'
                dc.b    'O','O'
                dc.b    'P','P'
                dc.b    '[','{'
                dc.b    ']','}'             ; $1B
                dc.b    ' ',' '             ; $1c - Unassigned
                dc.b    '1','1'             ; $1d - keypad - 1
                dc.b    '2','2'             ; $1e - keypad - 2
                dc.b    '3','3'             ; $1f - keypad - 3

                dc.b    'A','A'             ; $20
                dc.b    'S','S'
                dc.b    'D','D'
                dc.b    'F','F'
                dc.b    'G','G'
                dc.b    'H','H'
                dc.b    'J','J'
                dc.b    'K','K'
                dc.b    'L','L'
                dc.b    ';',':'
                dc.b    "'",'@'
                dc.b    '#','~'             ; $2B
                dc.b    ' ',' '             ; $2c - Unassigned
                dc.b    '4','4'             ; $2d - keypad - 4
                dc.b    '5','5'             ; $2e - keypad - 5
                dc.b    '6','6'             ; $2f - keypad - 6

                dc.b    '\','|'             ; $30
                dc.b    'Z','Z'
                dc.b    'X','X'
                dc.b    'C','C'
                dc.b    'V','V'
                dc.b    'B','B'
                dc.b    'N','N'
                dc.b    'M','M'
                dc.b    ',','<'
                dc.b    '.','>'
                dc.b    '/','?'
                dc.b    ' ',' '             ; $3b - Unassigned
                dc.b    ' ',' '             ; $3c - Unassigned
                dc.b    '7','7'             ; $3d - keypad - 7
                dc.b    '8','8'             ; $3e - keypad - 8
                dc.b    '9','9'             ; $3f - keypad - 9

                dc.b    $20,$20             ; $40 - space
                dc.b    $08,$08             ; $41 - back space
                dc.b    ' ',' '             ; $42 - tab
                dc.b    $13,$13             ; $43 - keypad - enter
                dc.b    $13,$13             ; $44 - keyboard - enter
                dc.b    ' ',' '             ; $45 - Escape
                dc.b    ' ',' '             ; $46 - Delete
                dc.b    ' ',' '             ; $47 - Unassigned
                dc.b    ' ',' '             ; $48 - Unassigned
                dc.b    ' ',' '             ; $49 - Unassigned
                dc.b    '-','-'             ; $4a - keypad minus
                dc.b    ' ',' '             ; $4b - Unassigned
                ; cursor keys
                dc.b    ' ',' '             ; $4c - Cursor Up
                dc.b    ' ',' '             ; $4d - Cursor Down
                dc.b    ' ',' '             ; $4e - Cursor Right
                dc.b    ' ',' '             ; $4f - Cursor Left
                ; function keys $50 - $59
                dc.b    ' ',' '             ; $50 - F1
                dc.b    ' ',' '             ; $51 - F2
                dc.b    ' ',' '             ; $52 - F3
                dc.b    ' ',' '             ; $53 - F4
                dc.b    ' ',' '             ; $54 - F5
                dc.b    ' ',' '             ; $55 - F6
                dc.b    ' ',' '             ; $56 - F7
                dc.b    ' ',' '             ; $57 - F8
                dc.b    ' ',' '             ; $58 - F9
                dc.b    ' ',' '             ; $59 - F10
                dc.b    '(','('             ; $5a - keypad (
                dc.b    ')',')'             ; $5b - keypad )
                dc.b    '/','/'             ; $5c - keypad /
                dc.b    '*','*'             ; $5d - keypad *
                dc.b    '+','+'             ; $5e - keypad +
                dc.b    ' ',' '             ; $5f - Help
                dc.b    ' ',' '             ; $60 - Left Shift
                dc.b    ' ',' '             ; $61 - Right Shift
                dc.b    ' ',' '             ; $62 - Caps Lock
                dc.b    ' ',' '             ; $63 - Left CTRL
                dc.b    ' ',' '             ; $64 - Left ALT
                dc.b    ' ',' '             ; $65 - Right ALT
                dc.b    ' ',' '             ; $66 - Left AMIGA
                dc.b    ' ',' '             ; $67 - Right AMIGA
                dc.b    ' ',' '             ; $68 - Unassigned
                dc.b    ' ',' '             ; $69 - Unassigned
                dc.b    ' ',' '             ; $6a - Unassigned
                dc.b    ' ',' '             ; $6b - Unassigned
                dc.b    ' ',' '             ; $6c - Unassigned
                dc.b    ' ',' '             ; $6d - Unassugned
                dc.b    ' ',' '             ; $6e - Unassigned
                dc.b    ' ',' '             ; $6f - Unassigned
                even



                ; ------------------ initialise system ---------------------
init_system
                lea     CUSTOM,a6
                move.w  #$7fff,INTENA(a6)
                move.w  #$7fff,DMACON(a6)
                move.w  #$7fff,INTREQ(a6)
                move.w  #$7fff,INTREQ(a6)

                ; enter supervisor mode
                lea     .supervisor_trap(PC),a0         ; A0 = address of supervisor trap $00001F58
                move.l  a0,$80                          ; Set TRAP 0 vector
                move.l  a7,a0                           ; store stack pointer
                trap    #$00                            ; do the trap (jmp to next instruction in supervisor mode)
.supervisor_trap                                                    
                move.l  a0,a7                           ; restore the stack(never returnfrom this trap) 
 
                ; set interrupt handlers
                moveq   #$05,d7                         ; count 2 + 1 
                lea.l   interrupt_handlers_table,a0     ; L000031b0,a0
                lea.l   $00000064,a1                    ; Level 1 Autovector Address
.int_loop       move.l  (a0)+,(a1)+                     ; Set autovectors for level 1,2 & 3
                dbf.w   d7,.int_loop                    ; L000030ee

                ; reset ciaa
                lea     $bfe001,a5
                bclr.b  #0,ciacra(a5)                   ; stop timer A
                bclr.b  #0,ciacrb(a5)                   ; stop timer B
                move.b  #$7f,ciaicr(a5)                 ; disable ciaa interrupts

                ; reset ciab
                lea     $bfd000,a5
                bclr.b  #0,ciacra(a5)                   ; stop timer A
                bclr.b  #0,ciacrb(a5)                   ; stop timer B
                move.b  #$7f,ciaicr(a5)                 ; disable ciaa interrupts                

                rts



interrupt_handlers_table
                dc.l    default_interrupt_handler
                dc.l    level2_interrupt_handler
                dc.l    level3_interrupt_handler
                dc.l    default_interrupt_handler
                dc.l    default_interrupt_handler
                dc.l    default_interrupt_handler




 
                ; ---------------------- level 2 interrupt handler -----------------------
                ; The only Level 2 Interrupt is the PORTS interrupt. Nothing else can
                ; raise this interrupt. So no need to check the INTREQR bits.
                ; Just need to clear the PORTS bit when the interrupt is raised.
                ;
level2_interrupt_handler
                movem.l d0-d7/a0-a6,-(a7)

                lea     CUSTOM,a6              
                move.w  INTREQR(a6),d0
                and.w   #$0008,d0
                beq.s   .exit_level2_handler

                moveq   #0,d0
                lea     $bfe001,a5                      ; CIAA
                move.b  ciaicr(a5),d0                   ; read CIAA interrupt control register (also clears it)

                ; call d0 = level2_keyboard_handler(d0)
                jsr     level2_keyboard_handler
                cmp.b   #$ff,d0
                beq.s   .exit_level2_handler

                ; add keycode to queue
                bsr     enqueue_keycode


.exit_level2_handler
                move.w  #$0008,INTREQ(a6)               ; clear PORTS interrupt

                movem.l (a7)+,d0-d7/a0-a6
                rte






shift_pressed   dc.b    $00
                even

                ; ------------------------- level 3 interrupt handler -----------------------
level3_interrupt_handler
                movem.l d0-d7/a0-a6,-(a7)
                lea     CUSTOM,a6
                move.w  INTREQR(a6),d0

                btst.l  #5,d0
                beq     .end_handler

                moveq   #0,d0
                jsr     dequeue_keycode
                cmp.b   #$ff,d0
                beq     .end_handler

                ; check for modifier keys

                ; check shift key down
.chk_lshft_down cmp.b   #$60,d0             ; shift down
                bne.s   .chk_lshift_up
                st.b    shift_pressed
                bra     .end_handler

                ; check shift key up
.chk_lshift_up  cmp.b   #$e0,d0             ; shift up
                bne.s   .not_modifier
                sf.b    shift_pressed
                bra     .end_handler

.not_modifier
                tst.b   d0
                blt     .end_handler

                ; map keycode
                lea     keycode_table,a0
                lsl.w   #1,d0               ; d0 * 2 - map shifted keys also (2 different characters per key code)
                tst.b   shift_pressed
                beq.s   .get_char
                add.w   #1,d0
.get_char       move.b  (a0,d0.w),d0

                ; check enter key
.chk_enter      cmp.b   #$13,d0
                bne.s   .chk_backspace

                ; is enter key
                move.w  #$0,cursor_x
                add.w   #$8,cursor_y
                bra.s   .end_handler

                ; check backspace key
.chk_backspace  cmp.b   #$08,d0
                bne.s   .print_char

                bsr     cursor_left
                lea     screenbuffer,a0
                bsr     erase_character
                bra     .end_handler

                ; display character
.print_char     lea     screenbuffer,a0
                jsr     display_character
                move.w  #6,d0
                jsr     add_cursor_x

.end_handler
                and.w  #$0070,d0
                move.w  d0,INTREQ(a6)
                movem.l (a7)+,d0-d7/a0-a6
                rte


default_interrupt_handler
                lea     CUSTOM,a6
                move.w  #$7fff,INTREQ(a6)
                rte





                ;------------------------ Copper List --------------------
                even
copperlist      dc.w    DDFSTRT,$0038               ; low res dma fetch start
                dc.w    DDFSTOP,$00d0               ; low res dma fetch stop
                dc.w    DIWSTRT,$2c81              ; low res display window start
                dc.w    DIWSTOP,$2cc1               ; low res display window stop
                dc.w    BPL1MOD,$0000               ; clear even plane modulo
                dc.w    BPL2MOD,$0000               ; clear odd plane modulo
bplptrs         dc.w    BPL1PTH,$0000               ; set bitplane ptr
                dc.w    BPL1PTL,$0000               ; set bitplane ptr
                dc.w    BPLCON0,$1200               ; 1 bitplane screen
                dc.w    BPLCON1,$0000
                dc.w    BPLCON2,$0000
                dc.w    COLOR00,$0000               ; background = black
                dc.w    COLOR01,$0fff               ; foreground = white

                dc.w    $3101,$fffe,COLOR00,$000f,$3201,$fffe,COLOR00,$0000
                dc.w    $3901,$fffe,COLOR00,$000f,$3a01,$fffe,COLOR00,$0000
                dc.w    $4101,$fffe,COLOR00,$000f,$4201,$fffe,COLOR00,$0000
                dc.w    $4901,$fffe,COLOR00,$000f,$4a01,$fffe,COLOR00,$0000
                dc.w    $5101,$fffe,COLOR00,$000f,$5201,$fffe,COLOR00,$0000
                dc.w    $5901,$fffe,COLOR00,$000f,$5a01,$fffe,COLOR00,$0000
                dc.w    $6101,$fffe,COLOR00,$000f,$6201,$fffe,COLOR00,$0000
                dc.w    $6901,$fffe,COLOR00,$000f,$6a01,$fffe,COLOR00,$0000
                dc.w    $7101,$fffe,COLOR00,$000f,$7201,$fffe,COLOR00,$0000
                dc.w    $7901,$fffe,COLOR00,$000f,$7a01,$fffe,COLOR00,$0000
                dc.w    $8101,$fffe,COLOR00,$000f,$8201,$fffe,COLOR00,$0000
                dc.w    $8901,$fffe,COLOR00,$000f,$8a01,$fffe,COLOR00,$0000
                dc.w    $9101,$fffe,COLOR00,$000f,$9201,$fffe,COLOR00,$0000
                dc.w    $9901,$fffe,COLOR00,$000f,$9a01,$fffe,COLOR00,$0000
                dc.w    $a101,$fffe,COLOR00,$000f,$a201,$fffe,COLOR00,$0000
                dc.w    $a901,$fffe,COLOR00,$000f,$aa01,$fffe,COLOR00,$0000

                dc.w    $ffff,$fffe
                dc.w    $ffff,$fffe



                even
textstring      
                dc.b    "**************************************",13,10
                dc.b    "     Test Keyboard Handler & Typer    ",13,10
                dc.b    "**************************************",13,10,13,10
                dc.b    "Use the keyboard to start typing text below.",13,10
                dc.b    "'backspace' - erase a character",13,10
                dc.b    "'enter' - move to start of next line.",13,10
                dc.b    13,10
                dc.b    13,10
                dc.b    0,0


                even
cursor_x        dc.w    0
cursor_y        dc.w    0

display_width   dc.w    320-6
display_height  dc.w    256-7



                ; IN: 
                ;   d0.w - pixels to add to 'cursor_x'
add_cursor_x
                add.w   cursor_x,d0

                ; IN:
                ;   d0.w - set 'cursor_x' value
set_cursor_x    
                tst.w   d0
                bge.s   .check_max
.set_min        moveq   #$0,d0
.check_max      cmp.w   display_width,d0
                bcs.s   .set_cursor_x
                move.w  display_width,d0
.set_cursor_x   move.w  d0,cursor_x
                rts

cursor_left     
                move.l  d0,-(a7)
                moveq   #-6,d0
                bsr     add_cursor_x
                movem.l (a7)+,d0
                rts


                ; IN:
                ;   d0.w - pixels to add to 'cursor_y'
add_cursor_y
                add.w   cursor_y,d0

                ; IN:
                ;   d0.w - set 'cursor_y' value
set_cursor_y
                tst.w   d0
                bge.s   .check_max
.set_min        moveq   #$0,d0
.check_max      cmp.w   display_height,d0
                bcs.s   .set_cursor_y
                move.w  display_height,d0
.set_cursor_y   move.w  d0,cursor_y
                rts


horizontal_tab  
                move.w  #$20,d0
                and.w   #$ffe0,cursor_x
                bsr     add_cursor_x
                rts


                ; IN:
                ;   a0 - ptr to screen buffer
                ;   a1 - ptr to string - null terminated
                ;
display_text
                move.b  (a1)+,d0
.chk_space      cmp.b   #32,d0
                bne.s   .chk_cr
                move.w  #$06,d0
                bsr.s   add_cursor_x
                bra.s   display_text
.chk_cr         cmp.b   #13,d0
                bne.s   .chk_lf
.is_cr          move.w  #0,cursor_x
                bra.s   display_text
.chk_lf         cmp.b   #10,d0
                bne.s   .chk_htab
.is_lf          move.w  #8,d0
                bsr.s   add_cursor_y
                bra.s   display_text
.chk_htab       cmp.w   #9,d0
                bne.s   .chk_end
.is_htab        bsr.s   horizontal_tab
                bra.s   display_text
.chk_end        tst.b   d0
                beq.s   end_loop
                bsr.s   display_character
                move.w  #$6,d0
                bsr     add_cursor_x
                bra.s   display_text
end_loop        rts




                ; ------------------------- display character ---------------------------
                ; Display a character at the screen pixel location specified by:-
                ;   - cursor_x
                ;   - cursor_y
                ;
                ;
                ; IN:
                ;   a0.l - ptr to screen buffer
                ;   d0.b - character to display
display_character
                cmp.b   #$20,d0
                bne.s   .do_display_character
                rts

.do_display_character 
                movem.l d0-d7/a0-a2,-(sp)
                ; calculate disply buffer location
                move.w  cursor_x,d1         ; pixel value
                move.w  d1,d2
                lsr.w   #3,d2               ; d2 = byte offset
                and.w   #$0007,d1           ; d1 = pixel shift

                move.w  cursor_y,d3         ; d3 = pixel value
                move.w  d3,d4
                mulu    #40,d4              ; d4 = byte offset

                add.w   d2,d4
                lea     (a0,d4),a0          ; a0 = byte start value - destination
                                            ; d0 = pixel shift
                
                ; calculate char gfx address
                lea     character_table,a2
                sub.b   #'!',d0
                ext.w   d0
                lsl.w   #2,d0
                move.l  (a2,d0.w),a2        ; a2 = source gfx

                move.w  d1,d0
                movem.w (a2)+,d1-d7
                lsr.w   d0,d1
                eor.b   d1,1(a0)
                lsr.w   #8,d1
                eor.b   d1,(a0)

                lsr.w   d0,d2
                eor.b   d2,41(a0)
                lsr.w   #8,d2
                eor.b   d2,40(a0)

                lsr.w   d0,d3
                eor.b   d3,81(a0)
                lsr.w   #8,d3
                eor.b   d3,80(a0)

                lsr.w   d0,d4
                eor.b   d4,121(a0)
                lsr.w   #8,d4
                eor.b   d4,120(a0)

                lsr.w   d0,d5
                eor.b   d5,161(a0)
                lsr.w   #8,d5
                eor.b   d5,160(a0)

                lsr.w   d0,d6
                eor.b   d6,201(a0)
                lsr.w   #8,d6
                eor.b   d6,200(a0)

                lsr.w   d0,d7
                eor.b   d7,241(a0)
                lsr.w   #8,d7
                eor.b   d7,240(a0)     

                movem.l (sp)+,d0-d7/a0-a2
                rts




erase_character
                movem.l d0-d7/a0-a2,-(sp)
                ; calculate disply buffer location
                moveq   #0,d1
                moveq   #0,d2
                move.w  cursor_x,d1         ; pixel value
                move.w  d1,d2
                asr.w   #3,d2               ; d2/8 = byte offset
                and.w   #$0007,d1           ; d1 = pixel shift

                move.w  cursor_y,d3         ; d3 = pixel value
                move.w  d3,d4
                mulu    #40,d4              ; d4 = byte offset

                add.w   d2,d4
                lea     (a0,d4),a0          ; a0 = byte start value - destination
                                            ; d0 = pixel shift
                
                lea     char_erase,a2

                move.w  d1,d0
                movem.w (a2)+,d1-d7
                ror.w   d0,d1
                and.b   d1,1(a0)
                ror.w   #8,d1
                and.b   d1,(a0)

                ror.w   d0,d2
                and.b   d2,41(a0)
                ror.w   #8,d2
                and.b   d2,40(a0)

                ror.w   d0,d3
                and.b   d3,81(a0)
                ror.w   #8,d3
                and.b   d3,80(a0)

                ror.w   d0,d4
                and.b   d4,121(a0)
                ror.w   #8,d4
                and.b   d4,120(a0)

                ror.w   d0,d5
                and.b   d5,161(a0)
                ror.w   #8,d5
                and.b   d5,160(a0)

                ror.w   d0,d6
                and.b   d6,201(a0)
                ror.w   #8,d6
                and.b   d6,200(a0)

                ror.w   d0,d7
                and.b   d7,241(a0)
                ror.w   #8,d7
                and.b   d7,240(a0)     

                movem.l (sp)+,d0-d7/a0-a2
                rts







                ; ---------------------- chip mem buffers ----------------------
                even
screenbuffer    dcb.b   40*256,$f0


character_table
                dc.l    char_Exclaimation
                dc.l    char_DoubleQuote
                dc.l    char_Hash
                dc.l    char_Dollar
                dc.l    char_Percentage
                dc.l    char_Ampersand
                dc.l    char_Quote
                dc.l    char_LeftPar
                dc.l    char_RightPar
                dc.l    char_Asterisk
                dc.l    char_Plus
                dc.l    char_Comma
                dc.l    char_minus
                dc.l    char_Period
                dc.l    char_FSlash

                dc.l    char0           ; 0
                dc.l    char1           ; 1
                dc.l    char2           ; 2
                dc.l    char3           ; 3
                dc.l    char4           ; 4
                dc.l    char5           ; 5
                dc.l    char6           ; 6
                dc.l    char7           ; 7
                dc.l    char8           ; 8
                dc.l    char9           ; 9

                dc.l    char_colon      ; :
                dc.l    char_semicolon  ; ;
                dc.l    char_leftangle  ; <
                dc.l    char_equals     ; =
                dc.l    char_rightangle ; >
                dc.l    char_question   ; ?
                dc.l    char_at         ; @

                dc.l    charA           ; A
                dc.l    charB           ; B
                dc.l    charC           ; C
                dc.l    charD           ; D
                dc.l    charE           ; E
                dc.l    charF           ; F
                dc.l    charG           ; G
                dc.l    charH           ; H
                dc.l    charI           ; I
                dc.l    charJ           ; J
                dc.l    charK           ; K
                dc.l    charL           ; L
                dc.l    charM           ; M
                dc.l    charN           ; N
                dc.l    charO           ; O
                dc.l    charP           ; P
                dc.l    charQ           ; Q
                dc.l    charR           ; R
                dc.l    charS           ; S
                dc.l    charT           ; T
                dc.l    charU           ; U
                dc.l    charV           ; V
                dc.l    charW           ; W
                dc.l    charX           ; X
                dc.l    charY           ; Y
                dc.l    charZ           ; Z

                dc.l    char_leftsquare     ; [
                dc.l    char_backslash      ; \
                dc.l    char_rightsquare    ; ]
                dc.l    char_carot          ; ^
                dc.l    char_underscore     ; _
                dc.l    char_backtick   ; `

                dc.l    charA           ; a
                dc.l    charB           ; b
                dc.l    charC           ; c
                dc.l    charD           ; d
                dc.l    charE           ; e
                dc.l    charF           ; f
                dc.l    charG           ; g
                dc.l    charH           ; h
                dc.l    charI           ; i
                dc.l    charJ           ; j
                dc.l    charK           ; k
                dc.l    charL           ; l
                dc.l    charM           ; m
                dc.l    charN           ; n
                dc.l    charO           ; o
                dc.l    charP           ; p
                dc.l    charQ           ; q
                dc.l    charR           ; r
                dc.l    charS           ; s
                dc.l    charT           ; t
                dc.l    charU           ; u
                dc.l    charV           ; v
                dc.l    charW           ; w
                dc.l    charX           ; x
                dc.l    charY           ; y
                dc.l    charZ           ; z

                dc.l    char_UNDEF      ; {
                dc.l    char_UNDEF      ; |
                dc.l    char_UNDEF      ; }
                dc.l    char_UNDEF      ; ~
                dc.l    char_UNDEF      ; DEL

                even
font            

char_UNDEF      dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_block      dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_erase      dc.w    %0000011111111111
                dc.w    %0000011111111111
                dc.w    %0000011111111111
                dc.w    %0000011111111111
                dc.w    %0000011111111111
                dc.w    %0000011111111111
                dc.w    %0000011111111111


char_Exclaimation
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_DoubleQuote
                dc.w    %0100100000000000
                dc.w    %0100100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
char_Hash
                dc.w    %0101000000000000
                dc.w    %1111100000000000
                dc.w    %0101000000000000
                dc.w    %1111100000000000
                dc.w    %0101000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Dollar     dc.w    %0111000000000000
                dc.w    %1010000000000000
                dc.w    %0111000000000000
                dc.w    %0010100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Percentage dc.w    %1001000000000000
                dc.w    %0001000000000000
                dc.w    %0010000000000000
                dc.w    %0100000000000000
                dc.w    %0100100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Ampersand  dc.w    %0110000000000000
                dc.w    %1010000000000000
                dc.w    %1110100000000000
                dc.w    %1001000000000000
                dc.w    %0110100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Quote      dc.w    %0100000000000000
                dc.w    %0100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_LeftPar    dc.w    %0011000000000000
                dc.w    %0100000000000000
                dc.w    %1000000000000000
                dc.w    %0100000000000000
                dc.w    %0011000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_RightPar   dc.w    %0110000000000000
                dc.w    %0001000000000000
                dc.w    %0000100000000000
                dc.w    %0001000000000000
                dc.w    %0110000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Asterisk   dc.w    %1010100000000000
                dc.w    %0111000000000000
                dc.w    %1111100000000000
                dc.w    %0111000000000000
                dc.w    %1010100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Plus       dc.w    %0000000000000000
                dc.w    %0010000000000000
                dc.w    %0111000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Comma      dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %1100000000000000
                dc.w    %1000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_minus      dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_Period     dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %1100000000000000
                dc.w    %1100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_FSlash     dc.w    %0011000000000000
                dc.w    %0011000000000000
                dc.w    %0110000000000000
                dc.w    %1100000000000000
                dc.w    %1100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char0           dc.w    %0111000000000000
                dc.w    %1001100000000000
                dc.w    %1010100000000000
                dc.w    %1100100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char1           dc.w    %0110000000000000
                dc.w    %1010000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char2           dc.w    %1111000000000000
                dc.w    %0000100000000000
                dc.w    %0111000000000000
                dc.w    %1000000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char3           dc.w    %1111000000000000
                dc.w    %0000100000000000
                dc.w    %0111000000000000
                dc.w    %0000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char4           dc.w    %1000000000000000
                dc.w    %1010000000000000
                dc.w    %1111100000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char5           dc.w    %1111100000000000
                dc.w    %1000000000000000
                dc.w    %1111000000000000
                dc.w    %0000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char6           dc.w    %1111100000000000
                dc.w    %1000000000000000
                dc.w    %1111000000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char7           dc.w    %1111100000000000
                dc.w    %0000100000000000
                dc.w    %0001000000000000
                dc.w    %0010000000000000
                dc.w    %0100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char8           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char9           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_colon      dc.w    %0000000000000000
                dc.w    %0110000000000000
                dc.w    %0000000000000000
                dc.w    %0110000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_semicolon  dc.w    %0000000000000000
                dc.w    %0110000000000000
                dc.w    %0000000000000000
                dc.w    %0100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_leftangle  dc.w    %0001100000000000
                dc.w    %0110000000000000
                dc.w    %1000000000000000
                dc.w    %0110000000000000
                dc.w    %0001100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_equals     dc.w    %0000000000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_rightangle dc.w    %1100000000000000
                dc.w    %0011000000000000
                dc.w    %0000100000000000
                dc.w    %0011000000000000
                dc.w    %1100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_question   dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %0011000000000000
                dc.w    %0000000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000


char_at         dc.w    %0111000000000000
                dc.w    %1001100000000000
                dc.w    %1010100000000000
                dc.w    %1001100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000


charA           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1111100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charB           dc.w    %1111000000000000
                dc.w    %1000100000000000
                dc.w    %1111000000000000
                dc.w    %1000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charC           dc.w    %0111100000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %0111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charD           dc.w    %1111000000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charE           dc.w    %1111100000000000
                dc.w    %1000000000000000
                dc.w    %1110000000000000
                dc.w    %1000000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charF           dc.w    %1111100000000000
                dc.w    %1000000000000000
                dc.w    %1110000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charG           dc.w    %0111000000000000
                dc.w    %1000000000000000
                dc.w    %1001100000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charH           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1111100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charI           dc.w    %1111100000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charJ           dc.w    %1111100000000000
                dc.w    %0001000000000000
                dc.w    %0001000000000000
                dc.w    %1001000000000000
                dc.w    %0110000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charK           dc.w    %1000100000000000
                dc.w    %1001000000000000
                dc.w    %1110000000000000
                dc.w    %1001000000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charL           dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000    

charM           dc.w    %1000100000000000
                dc.w    %1101100000000000
                dc.w    %1010100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charN           dc.w    %1000100000000000
                dc.w    %1100100000000000
                dc.w    %1010100000000000
                dc.w    %1001100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charO           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charP           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1111000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charQ           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1001000000000000
                dc.w    %0110100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charR           dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1111000000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charS           dc.w    %0111100000000000
                dc.w    %1000000000000000
                dc.w    %0111000000000000
                dc.w    %0000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charT           dc.w    %1111100000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charU           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charV           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0101000000000000
                dc.w    %0101000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charW           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %1010100000000000
                dc.w    %1101100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charX           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0111000000000000
                dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charY           dc.w    %1000100000000000
                dc.w    %1000100000000000
                dc.w    %0111100000000000
                dc.w    %0000100000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

charZ           dc.w    %1111100000000000
                dc.w    %0000100000000000
                dc.w    %0111000000000000
                dc.w    %1000000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_leftsquare dc.w    %1111000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %1111000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_backslash  dc.w    %1000000000000000
                dc.w    %1000000000000000
                dc.w    %0100000000000000
                dc.w    %0010000000000000
                dc.w    %0010000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_rightsquare 
                dc.w    %0111100000000000
                dc.w    %0000100000000000
                dc.w    %0000100000000000
                dc.w    %0000100000000000
                dc.w    %0111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_carot      dc.w    %0010000000000000
                dc.w    %0101000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_underscore
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %1111100000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000

char_backtick   dc.w    %1000000000000000
                dc.w    %0100000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000
                dc.w    %0000000000000000



                include "lib/keyboard-lib.s"

