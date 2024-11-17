.data
	# Matriz
	num: .double 123.45600
	
	# aux
	
	dezDouble: .double 10.00
	zeroDouble: .double 0.00

.text

.globl main
main:
	li $a0, 6
	li $v0, 9
	syscall # aloca espaco para o array
	
	move $s2, $v0 # ARRAY ESTA EM S2
	
	l.d $f0, num
	l.d $f2, dezDouble
	l.d $f4, zeroDouble
	
	li $t0, 0
	
	jal arrumaNum
arrumaNum:
	cvt.w.d $f2, $f0
	
	# sub.d $f4, $f0, $f2
	
	# print as integer
	mfc1 $a0, $f2
	mtc1 $a0,$f6
	
	cvt.d.w $f6, $f6
	
	sub.d $f4, $f0, $f6
	#li $v0, 1
	#syscall
	
	mov.d $f12, $f4
	li $v0, 3
	syscall
	
	li $v0, 10
	syscall
	
	mov.d $f0, $f10
	li $v0, 3
	syscall