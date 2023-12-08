.equ    RAM, 0x1000
.equ    LEDs, 0x2000
.equ    TIMER, 0x2020
.equ    BUTTON, 0x2030
.equ    LFSR, RAM

br main
br interrupt_handler

main:
    ; Variable initialization for spend_time
    addi t0, zero, 18
    stw t0, LFSR(zero)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING ABOVE THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    ; WRITE YOUR CONSTANT DEFINITIONS AND main HERE

	addi sp, zero, LEDs ; init stack pointer
	addi t0, zero, 5 ; 101 in binary 
	wrctl ienable, t0 ; choose wich external devices can send irqs
	addi t0, zero, 1
	wrctl status, t0 ; enable interrupts

	addi t0, zero, 76 ; 1001100 en binaire
	slli t0, t0, 16 
	addi t0, t0, 19263 ; t0 =  4 999 999 (on veut une periode de 100ms donc 5 000 000 clock cycles)
;	addi t0, zero, 300 ; <================================================= ENLEVER APRES ==================================================================
	stw t0, TIMER+4(zero) ; init period reg du timer
	addi t0, zero, 11 ; 1011 en binaire dcp on active les start, ito et cont bits
	stw t0, TIMER+8(zero) ; control reg du timer
	stw zero, RAM+16(zero)
	stw zero, RAM+8(zero)
	add a0, zero, zero
	call display
; FAUT INIT LE COUNTER MAIS JSP SI SUFFIT DANS UN REGISTER OU BIEN SI C EST MIEUX DE LE STOCK DANS LA RAM (JE DIRAIS RAM POUR ETRE SUR QU IL Y AIT PAS DE MERDE DANS LE HANDLER)

infinite_loop:
	jmpi infinite_loop


interrupt_handler:
    ; WRITE YOUR INTERRUPT HANDLER HERE
; ============= PUSH ON STACK ================
	addi sp, sp, -36 
	stw t0, 0(sp) 
	stw t1, 4(sp) 
	stw t2, 8(sp) 
	stw t3, 12(sp) 
	stw t4, 16(sp) 
	stw t5, 20(sp) 
	stw t6, 24(sp) 
	stw t7, 28(sp) 

;	rdctl t0, ienable ; ====== ON AVAIT PAS BESOIN DE CA DANS LE LAB 2 MAIS MTN PT OUI
;	stw t0, 32(sp) ; store ienable ; ====== ON AVAIT PAS BESOIN DE CA DANS LE LAB 2 MAIS MTN PT OUI
	stw ea, 32(sp) ; store exception return address

;	addi t0, zero, 1 ; ===== A METTRE DANS BUTTON IRQ JE CROIS
;	wrctl status, zero ; enable interrupts ; ===== A METTRE DANS BUTTON IRQ JE CROIS

;=============================
	rdctl t0, ctl4 ;ipending (les bits 0 et 2 nous interessent)
	andi t1, t0, 1
	addi t2, zero, 1
	beq t1, t2, timerirq ;si le irq(0) vaut 1 c'est un interrupt du timer donc on y jump
	andi t1, t0, 4
	addi t2, zero,4
	beq t1, t2, buttonirq ; si le irq(2) vaut 1 interrupt button => on y jump
	jmpi end_interrupt

timerirq:
; A FAIRE INCREMENTER COUNTER ET DECIDER SI ON APPELLE DISPLAY OU PAS

	stw zero, TIMER+12(zero) ; clear TO bit to reset the irq
	ldw t0, RAM+16(zero) 
	addi a0, t0, 1 
	stw a0, RAM+16(zero)
	ldw t1, RAM+8(zero);check si on vient d'un boutton irq
	andi t1, t1, 1
	addi t2, zero, 1
	beq t1, t2, end_timerirq ;skip le +1 du counter (le fait a la fin de button)
	call display
end_timerirq:
	stw zero, RAM+8(zero) ;je le met � zero pour que dans button on check si il faut display
	jmpi end_interrupt

buttonirq:
	ldw t0, BUTTON+4(zero)
	stw zero, BUTTON+4(zero) ; reset 

	andi t0, t0, 1 ; on veut juste le dernier bit de edgecapture
	beq t0, zero, end_interrupt ; check si le button 0 est pressed sinon on va a la fin
	addi t1, zero,1
	stw t1, RAM+8(zero);Set 1 pour le timerirq
	
	addi sp, sp, -36 
	stw t0, 0(sp) 
	stw t1, 4(sp) 
	stw t2, 8(sp) 
	stw t3, 12(sp) 
	stw t4, 16(sp) 
	stw t5, 20(sp) 
	stw t6, 24(sp) 
	stw t7, 28(sp)
	stw ea, 32(sp)

	addi t0, zero, 1
	wrctl status, t0 ;active les interrupt
	call spend_time ; <====================== IMPORTANT REMETTRE APRES ==========================================================================================
;	addi t0, zero, 100 ; <================================================= ENLEVER APRES ==================================================================
;test_loop_a_enlever: ; <================================================= ENLEVER APRES ==================================================================
;	addi t0, t0, -1 ; <================================================= ENLEVER APRES ==================================================================
;	bne t0, zero, test_loop_a_enlever ; <================================================= ENLEVER APRES ==================================================================
	
	wrctl status, zero ; desactive les interrupt	
	ldw t0, 0(sp) 
	ldw t1, 4(sp) 
	ldw t2, 8(sp) 
	ldw t3, 12(sp) 
	ldw t4, 16(sp) 
	ldw t5, 20(sp) 
	ldw t6, 24(sp) 
	ldw t7, 28(sp)

	ldw ea, 32(sp)
	addi sp, sp, 36

	
	ldw t0, RAM+8(zero)
	bne t0, zero, skip_button
	ldw a0, RAM+16(zero)
	call display
skip_button:
	stw zero, RAM+8(zero) ; a la fin de button RAM+8 vaut zero
; A FAIRE APPELER SPEND_TIME MAIS FAUT ENABLE LES INTERRUPTS AVANT ET DCP FAUT SASSSURER QU ON A MIS TOUS LES TRUCSS IMPORTANTS SUR LE STACK (COMME DANS L EXEMPLE DU COURS?)
; JE CROIS ON VEUT JUSTE LES INTERRUPTS DU TIMER MAIS PAS CEUX DU BOUTON DCP FAUDRAIT CHANGER IENABLE JE CROIS
; APRES LE RETOUR DE LA FONCTION FAUT TOUT RESTORE COMME AVANT ET DISABLE INTERRUPTS A NOUVEAU

end_interrupt:
; ============= POP FROM STACK ================
;	wrctl status, zero ; disable interrupts ; ===== A METTRE DANS BUTTON IRQ JE CROIS

	ldw t0, 0(sp) 
	ldw t1, 4(sp) 
	ldw t2, 8(sp) 
	ldw t3, 12(sp) 
	ldw t4, 16(sp) 
	ldw t5, 20(sp) 
	ldw t6, 24(sp) 
	ldw t7, 28(sp)

	ldw ea, 32(sp)
	addi sp, sp, 36

	addi ea, ea, -4
	eret ; will enable interrupts again



; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING BELOW THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ----------------- Common functions --------------------
; a0 = tenths of second
display:
    addi   sp, sp, -20
    stw    ra, 0(sp)
    stw    s0, 4(sp)
    stw    s1, 8(sp)
    stw    s2, 12(sp)
    stw    s3, 16(sp)
    add    s0, a0, zero
    add    a0, zero, s0
    addi   a1, zero, 600
    call   divide
    add    s0, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 100
    call   divide
    add    s1, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 10
    call   divide
    add    s2, zero, v0
    add    s3, zero, v1

    slli   s3, s3, 2
    slli   s2, s2, 2
    slli   s1, s1, 2
    ldw    s3, font_data(s3)
    ldw    s2, font_data(s2)
    ldw    s1, font_data(s1)

    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    addi   t6, zero, 4
    minute_loop_s3:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s2
    or     s3, s3, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s3

    minute_s2:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s2:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s1
    or     s2, s2, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s2

    minute_s1:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s1:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_end
    or     s1, s1, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s1

    minute_end:
    stw    s1, LEDs(zero)
    stw    s2, LEDs+4(zero)
    stw    s3, LEDs+8(zero)

    ldw    ra, 0(sp)
    ldw    s0, 4(sp)
    ldw    s1, 8(sp)
    ldw    s2, 12(sp)
    ldw    s3, 16(sp)
    addi   sp, sp, 20

    ret

flip_leds:
    addi t0, zero, -1
    ldw t1, LEDs(zero)
    xor t1, t1, t0
    stw t1, LEDs(zero)
    ldw t1, LEDs+4(zero)
    xor t1, t1, t0
    stw t1, LEDs+4(zero)
    ldw t1, LEDs+8(zero)
    xor t1, t1, t0
    stw t1, LEDs+8(zero)
    ret

spend_time:
    addi sp, sp, -4
    stw  ra, 0(sp)
    call flip_leds
    ldw t1, LFSR(zero)
    add t0, zero, t1
    srli t1, t1, 2
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    andi t0, t0, 1
    slli t0, t0, 7
    srli t1, t1, 1
    or t1, t0, t1
    stw t1, LFSR(zero)
    slli t1, t1, 15
    addi t0, zero, 1
    slli t0, t0, 22
    add t1, t0, t1

spend_time_loop:
    addi   t1, t1, -1
    bne    t1, zero, spend_time_loop
    
    call flip_leds
    ldw ra, 0(sp)
    addi sp, sp, 4

    ret

; v0 = a0 / a1
; v1 = a0 % a1
divide:
    add    v0, zero, zero
divide_body:
    add    v1, a0, zero
    blt    a0, a1, end
    sub    a0, a0, a1
    addi   v0, v0, 1
    br     divide_body
end:
    ret



font_data:
    .word 0x7E427E00 ; 0
    .word 0x407E4400 ; 1
    .word 0x4E4A7A00 ; 2
    .word 0x7E4A4200 ; 3
    .word 0x7E080E00 ; 4
    .word 0x7A4A4E00 ; 5
    .word 0x7A4A7E00 ; 6
    .word 0x7E020600 ; 7
    .word 0x7E4A7E00 ; 8
    .word 0x7E4A4E00 ; 9
    .word 0x7E127E00 ; A
    .word 0x344A7E00 ; B
    .word 0x42423C00 ; C
    .word 0x3C427E00 ; D
    .word 0x424A7E00 ; E
    .word 0x020A7E00 ; F
