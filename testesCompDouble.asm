.data
	param: .double 1.0
	v0: .double 0.5
	v1: .double 1.0
	v2: .double 1.1
	lessthan: .asciiz "The number is less than or equal to 1.0\n"
	gtthan: .asciiz "The number is greater than 1.0\n"
	noneWork: .asciiz "This did not work"
.text

.globl main
main:
	l.d $f0, param
	l.d $f2, v0
	add.d $f4, $f2, $f2
	c.le.d $f4, $f0
	bc1t 0, printLTE
	bc1f 0, printGT
	jal none
printLTE:
	la $a0, lessthan
	li $v0, 4
	syscall
	jal endpg
printGT:
	la $a0, gtthan
	li $v0, 4
	syscall
	jal endpg
none:
	la $a0, noneWork
	li $v0, 4
	syscall
	jal endpg
endpg:
	li $v0, 10
	syscall
	