# Programa utilizando as instruções nativas do MIPS
.data
		# Posições de memória para as variáveis
A:		.float  0.0		# Primeiro Operando ($f1)
B:		.float  0.0		# Segundo Operando ($f2)
C:		.float  0.0		# Resultado ($f12)

OPT:		.word	0		# Codigo de operacao ($s0)


		# Strings para exibição no console

CON_QRY:	.asciiz ">> "
OPT_MENU:	.asciiz	"\nChoose the operation (Single Precision):\n"
OPT_ADD:	.asciiz "0. ADD\n"
OPT_MULT:	.asciiz "1. MULT\n"
OPT_RPT:	.asciiz "\nRepeat? (0. Yes / 1. No)\n"
OPR_A:		.asciiz "\nType First Operand:\n"
OPR_B:		.asciiz "\nType Second Operand:\n"
RES:		.asciiz "\nResult: "


.text
main:

menu:
li	$v0, 4			# Codigo de syscall ($v0) para printar string

la	$a0, OPT_MENU		# Carrega a string MENU como argumento
syscall				# Printa MENU
la	$a0, OPT_ADD		# Carrega a string ADD como argumento
syscall				# Printa ADD
la	$a0, OPT_MULT		# Carrega a string MULT como argumento
syscall				# Printa MULT
la	$a0, CON_QRY		# Carrega a string CON_QRY como argumento
syscall				# Printa CON_QRY

li	$v0, 5			# Codigo de syscall ($v0) para  code
syscall				# Lê OPT (Codigo de operacao) 
sw	$v0, OPT		# Guarda o número lido em OPT

read_operands:
li	$v0, 4			# Codigo de syscall ($v0) para printar string
la	$a0, OPR_A		# Carrega a string OPR_A como argumento
syscall				# Printa OPR_A
la	$a0, CON_QRY		# Carrega a string CON_QRY como argumento
syscall				# Printa CON_QRY

li	$v0, 6			# Codigo de syscall ($v0) para leitura de float
syscall				# Lê o primeiro operando (A)
swc1 	$f0, A			# Salva o primeiro operando

li	$v0, 4			# Codigo de syscall ($v0) para printar string
la	$a0, OPR_B		# Carrega a string OPR_B como argumento
syscall				# Printa OPR_B
la	$a0, CON_QRY		# Carrega a string CON_QRY como argumento
syscall				# Printa CON_QRY

li	$v0, 6			# Codigo de syscall ($v0) para leitura de float
syscall				# Lê o segundo operando (B)
swc1 	$f0, B			# Salva o segundo operando

				# Escolha entre as operacoes (ADD ou MULT)
lw	$s0, OPT		# Carrega OPT em $s0
beq	$s0, $zero, opt_add	# Se OPT = 0 pule para opt_add
		
opt_mult:			# Subrotina de multiplicação
lwc1	$f1, A			# Carrega o primeiro operando
lwc1	$f2, B			# Carrega o segundo operando
mul.s	$f12, $f1, $f2		# Instrução de multiplicação em ponto flutuante
swc1	$f12, C			# Salva o resultado em C
j	display_result		# Salto incondicional para não realizar opt_add

opt_add:			# Subrotina de soma
lwc1	$f1, A			# Carrega o primeiro operando
lwc1	$f2, B			# Carrega o segundo operando
add.s	$f12, $f1, $f2		# Instrução de soma em ponto flutuante
swc1	$f12, C			# Salva o resultado em C


display_result:
li	$v0, 4			# Codigo de syscall ($v0) para printar string
la	$a0, RES		# Carrega a string RES como argumento 
syscall				# Printa RES
li	$v0, 2			# Codigo de syscall ($v0) para printar float
syscall				# Printa o float presente em $f12 (Resultado)

repeat:
li	$v0, 4			# Codigo de syscall ($v0) para printar string
la	$a0, OPT_RPT		# Carrega a string OPT_RPT como argumento 
syscall				# Printa OPT_PRT
la	$a0, CON_QRY		# Carrega a string CON_QRY como argumento
syscall				# Printa CON_QRY
li	$v0, 5			# Codigo de syscall ($v0) ler inteiro
syscall				# Lê inteiro 
beq	$v0, $zero, main	# Se o inteiro lido for 0, pula para o início do programa 

end_prog:
li	$v0, 10			# Codigo de syscall ($v0) para encerrar o programa
syscall				# Encerra
