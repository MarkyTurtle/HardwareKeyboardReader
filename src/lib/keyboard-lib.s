

                INCLUDE     "../include/hardware/cia.i"

                ;---------------------- init keyboard -------------------------
                ; Set up CIAA and INTENA for keyboard control.
                ;
                ; timer a - used for keyboard ack, one shot, 85 microseconds
                ; SP interrupt used to read keycode
                ; TA interrupt used to cancel keyboard ack signal
                ;
init_keyboard
                lea     CUSTOM,a6
                lea     $bfe001,a5                          ; CIAA

                bclr.b  #0,ciacra(a5)                       ; stop timer A
                move.b  #$3d,ciatalo(a5);                   ; 65 approx 85 microseconds for kayboard ack signal
                move.b  #$00,ciatahi(a5);
                bset.b  #3,ciacra(a5);                      ; set one shot mode
                bclr.b  #0,ciacra(a5)                       ; stop timer A


                bclr.b  #CIACRAB_SPMODE,ciacra(a5)          ; clear SPMODE bit (input)
                move.b  #%10001000,ciaicr(a5)               ; Enable SP interrupt (keyboard serial data) - level 2 (PORTS)
                move.b  #%10000001,ciacra(a5)               ; Enable Timer A interrupt (kayboard ack) - level 2 (PORTS)

                move.w  #$c008,INTENA(a6)                   ; Enable PORTS - Level 2 Interrupt
                rts




                even
keyboard_buffer_start
keyboard_queue  dc.b    0,0,0,0,0,0,0,0,0,0
keyboard_buffer_end
                even
keyboard_head   dc.l    keyboard_queue
keyboard_tail   dc.l    keyboard_queue
keyboard_count  dc.w    $0


                ; ----------------- enqueue keycode ----------------
                ; enqueue raw keycode into the keyboard queue
                ; IN:
                ;   d0.b - raw key code
                ; OUT:
                ;   d0.b = 0 for success, -1 if queue is full.
                ;
enqueue_keycode cmp.w   #$0a,keyboard_count
                bge.s   .queue_full

                move.l  a0,-(a7)
                move.l  keyboard_tail,a0
                cmp.l   #keyboard_buffer_end,a0
                bne.s   .no_wrap
.wrap           move.l  #keyboard_buffer_start,keyboard_tail
                move.l  keyboard_tail,a0
.no_wrap        move.b  d0,(a0)+
                move.l  a0,keyboard_tail
                add.w   #1,keyboard_count
                moveq   #0,d0
                move.l  (a7)+,a0
                rts
.queue_full
                moveq   #-1,d0
                rts



                ; ----------------- enqueue keycode ----------------
                ; enqueue raw keycode into the keyboard queue
                ; IN:
                ;   no parameters
                ; OUT:
                ;   d0.b - raw key code, or -1 if queue is empty
                ;
dequeue_keycode tst.w   keyboard_count
                beq.s   .queue_empty

                move.l  a0,-(a7)
                move.l  keyboard_head,a0
                cmp.l   #keyboard_buffer_end,a0
                bne.s   .no_wrap
.wrap           move.l  #keyboard_buffer_start,keyboard_head
                move.l  keyboard_head,a0
.no_wrap        move.b  (a0)+,d0
                move.l  a0,keyboard_head
                sub.w   #1,keyboard_count
                move.l  (a7)+,a0
                rts

.queue_empty
                moveq   #-1,d0
                rts



                ; --------------------- level 2 keyboard handler -------------------------
                ; This function is intended to be called by your Level 2 Interrupt
                ; handler. 
                ;
                ; IN:
                ;   d0.b -  CIAA ICR value
                ; OUT:
                ;   d0.b -  raw keycode, or -1 if no key code was read.
                ;
level2_keyboard_handler

                ; check if ciaa interrupt
                btst.l   #$07,d0                        ; test IR bit.
                bne.s   .do_keyboard_handler            ; is ciaa interrupt
                rts                                     ; no, early exit

.do_keyboard_handler
                movem.l d1/a5,-(a7)
                lea     $bfe001,a5                      ; CIAA


                ; Has previous keyboard ack completed?
.chk_timer_a    btst.l  #CIAICRB_TA,d0                  ; test for CIAA Timer A - underflow
                beq.s   .chk_keydata

                ; Yes, end keyboard ack signal
.is_timer_a     move.b  ciacra(a5),d1
                and.b   #%10111110,d1                   ; clear SPMODE (keyboard acknowledge), force timer stop
                move.b  d1,ciacra(a5)       
                move.w  #$000,$dff180

                ; No...
                ; Is a keycode available to read?
.chk_keydata    btst    #$03,d0                         ; test for serial data ready (keyboard)
                beq.s   .no_keycode

                ; Yes, Read keycode & Start keyboard ack signal
.read_keycode   moveq   #0,d0
                move.b  ciasdr(a5),d0                   ; read raw keyboard keycode.              
                not.b   d0
                ror.b   #1,d0
                move.b  ciacra(a5),d1              
                or.b    #%01011001,d1                   ; ciaa - timer a - single shot, set SPMODE (keyboard acknowledge)
                move.b  d1,ciacra(a5)
                movem.l (a7)+,d1/a5
                rts

.no_keycode     ; No, return no keycode value
                movem.l (a7)+,d1/a5
                moveq   #-1,d0
                rts


