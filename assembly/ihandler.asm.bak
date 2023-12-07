.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSEWIDTH, 0x200C
.equ PERIOD_REG, 0x2024
.equ CONTROL_REG, 0x2028
.equ STATUS_REG, 0x202C
.equ EDGECAPTURE, 0x2034

_start:
	br main
interrupt_handler:
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

;	rdctl t0, ienable
;	stw t0, 32(sp) ; store ienable
	stw ea, 32(sp) ; store exception return address

;	addi t0, zero, 1
;	wrctl status, t0 ; enable interrupts

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
	ldw t0, LEDS1(zero) 
	addi t0, t0, 1
	stw t0, LEDS1(zero)
	stw zero, STATUS_REG(zero) ; clear TO bit to reset the irq
	jmpi end_interrupt

buttonirq:
	ldw t0, EDGECAPTURE(zero)
	stw zero, EDGECAPTURE(zero)
	ldw t1, LEDS0(zero)
	andi t0, t0, 3 ; on veut juste les deux derniers bits de edgecapture
button0:
	addi t2, zero, 1
	bne t0, t2, button1 ;check si le button0 est pressed
	addi t1, t1,-1
	stw t1, LEDS0(zero)
	jmpi end_interrupt
button1:
	addi t2, zero, 2
    bne t0, t2, end_interrupt ;check si le button 1 est pressed
	addi t1, t1, 1
	stw t1, LEDS0(zero)
	jmpi end_interrupt
end_interrupt:
; ============= POP FROM STACK ================
;	wrctl status, zero ; disable interrupts

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




main:
	addi sp, zero, LEDS0 ; init stack pointer (a la fin de la ram comme dans le lab d'avant)
	stw zero, LEDS0(zero); init premier compteur a 0
	stw zero, LEDS1(zero); init deuxieme a 0
	stw zero, LEDS2(zero); init troisieme a 0
	addi t0, zero, 999 ; on veut une periode de 1000 donc 999 -> 0
	stw t0, PERIOD_REG(zero)
	addi t0, zero, 11 ; 1011 en binaire dcp on active les start, ito et cont bits
	stw t0, CONTROL_REG(zero)
	addi t0, zero, 5 ; 101 in binary 
	wrctl ienable, t0 ; choose wich external devices can send irqs
	addi t0, zero, 1
	wrctl status, t0 ; enable interrupts

	addi t1, zero, 0 ;Counter infini
loopmain:
	addi t1, t1, 1
	stw t1, LEDS2(zero)
	jmpi loopmain