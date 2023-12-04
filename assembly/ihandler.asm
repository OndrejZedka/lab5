.equ LEDS0, 0x2000
.equ LEDS1, 0x2004
.equ LEDS2, 0x2008
.equ PULSEWIDTH, 0x200C
.equ EDGECAPTURE, 0x2034
_start:
	br main
interrupt_handler:
; ============= PUSH ON STACK ================
	addi sp, sp, 0 ; A DEFINIR !!!!!!!!!!!!
;	stw at, 0(sp)  ; exemple

; ||  ||  ||     
; ||  ||  ||   
;              
; ()  ()  ()  
   #       #######    #    ### ######  ####### 
  # #      #         # #    #  #     # #       
 #   #     #        #   #   #  #     # #       
#     #    #####   #     #  #  ######  #####   
#######    #       #######  #  #   #   #       
#     #    #       #     #  #  #    #  #       
#     #    #       #     # ### #     # #######  



;=============================
	rdctl t0, ctl4 ;ipending check bit 0 et 1
	andi t1, t0, 1
	addi t2, zero, 1
	beq t1,t2, timerirq ;si le irq(0) vaut 1 c'est un interrupt du timer donc on y jump
	andi t1, t0, 4
	addi t2,zero,4
	beq t1,t2, buttonirq ; si le irq(2) vaut 1 interrupt button => on y jump
	jmpi end_interrupt
timerirq:

buttonirq:
	ldw t0, EDGECAPTURE(zero)
	stw zero, EDGECAPTURE(zero)
	ldw t1, LEDS1(zero)
	srli t0, t0, 30
	addi t2, zero, 1
button1:
	bne t0, t2, button2 ;check si le button0 est pressed
	addi t1, t1,-1
	stw t1,LEDS1(zero)
	jmpi end_interrupt
button2:
	addi t2, zero, 2
    bne t0,t2, end_interrupt ;check si le button 1 est pressed
	addi t1, t1, 1
	stw t1, LEDS1(zero)
	jmpi end_interrupt
end_interrupt:
; ============= POP FROM STACK ================
;	ldw at, 0(sp)  ; exemple
	addi sp, sp, 0 ; A DEFINIR !!!!!!!!!!!!
; ||  ||  ||     
; ||  ||  ||   
;              
; ()  ()  ()  
   #       #######    #    ### ######  ####### 
  # #      #         # #    #  #     # #       
 #   #     #        #   #   #  #     # #       
#     #    #####   #     #  #  ######  #####   
#######    #       #######  #  #   #   #       
#     #    #       #     #  #  #    #  #       
#     #    #       #     # ### #     # #######
	addi ea, ea, -4
	eret
main:
	addi sp, zero, LEDS ; init stack pointer (à la fin de la ram comme dans le lab d'avant)
	addi t1, zero,0 ;Counter infini
loopmain:
	stw zero, LEDS2(zero)
	stw t1, LEDS2(zero)
	addi t1, t1, 1
	jmpi loopmain