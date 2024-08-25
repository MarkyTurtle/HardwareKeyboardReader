

                section panel,code_c


                ;--------------------- includes and constants ---------------------------
                INCDIR      "include"
                INCLUDE     "hw.i"


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

                ;   a0 - ptr to screen buffer
                ;   a1 - ptr to character
                ;lea     screenbuffer,a0
                ;moveq   #'a',d0
                ;jsr     display_character

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
                lea     bplptrs,a0
                move.l  #screenbuffer,d0
                move.w  d0,6(a0)
                swap    d0
                move.w  d0,2(a0)

                jsr     clear_screen_buffer

                lea     copperlist,a0
                move.l  a0,COP1LC(a6)
                move.w  #$8380,DMACON(a6)               ; MASTER,BPL,COPPER
                rts


clear_screen_buffer
                lea     screenbuffer,a0
                move.w  #(10*256)-1,d7
.clear_loop     move.l  #0,(a0)+
                dbra    d7,.clear_loop
                rts



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


                ; enable interrupts
                move.w  #$c020,INTENA(a6)               ; enable VERTB interrupt
                move.w  #$c020,INTENA(a6)               ; enable VERTB interrupt
                rts



interrupt_handlers_table
                dc.l    default_interrupt_handler
                dc.l    default_interrupt_handler
                dc.l    level3_interrupt_handler
                dc.l    default_interrupt_handler
                dc.l    default_interrupt_handler
                dc.l    default_interrupt_handler


level3_interrupt_handler
                movem.l d0-d7/a0-a6,-(a7)
                lea     CUSTOM,a6
                move.w  INTREQR(a6),d0

                btst.l  #5,d0
                beq     .end_handler


.end_handler
                and.w  #$0070,d0
                move.w  d0,INTREQ(a6)
                movem.l (a7)+,d0-d7/a0-a6

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

                dc.w    $4001,$fffe
                dc.w    COLOR00,$000f
                dc.w    $4101,$fffe
                dc.w    COLOR00,$0000

                dc.w    $ffff,$fffe
                dc.w    $ffff,$fffe



                even
textstring      
                dc.b    "abcdefghijklmnopqrstuvwxyz",13,10
                dc.b    "a b c d e f g h i j k l m n o p q r s t u v w x y z",13,10
                dc.b    "tab",09,"test",09,09,"tab",09,"test",09,"tab",13,10
                dc.b    "tab",09,"test",09,"tab",09,"test",09,"tab",13,10
                dc.b    "tab",09,"test",09,"tabtab",09,"testtest",09,"tabtabtab",09,"testtesttest",13,10
                dc.b    0,0,0,0


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
                sub.b   #'a',d0
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



                ; ---------------------- chip mem buffers ----------------------
                even
screenbuffer    dcb.b   40*256,$f0


character_table
                dc.l    charA
                dc.l    charB
                dc.l    charC
                dc.l    charD
                dc.l    charE
                dc.l    charF
                dc.l    charG
                dc.l    charH
                dc.l    charI
                dc.l    charJ
                dc.l    charK
                dc.l    charL
                dc.l    charM
                dc.l    charN
                dc.l    charO
                dc.l    charP
                dc.l    charQ
                dc.l    charR
                dc.l    charS
                dc.l    charT
                dc.l    charU
                dc.l    charV
                dc.l    charW
                dc.l    charX
                dc.l    charY
                dc.l    charZ


                even
font            
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
                dc.w    %1000100000000000
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
                dc.w    %1000100000000000
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



