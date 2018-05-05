# Programa utilizando a aritmética por software
.data
		# Posições de memória para as variáveis
A:		.float  0.0		# Primeiro Operando ($f1)
B:		.float  0.0		# Segundo Operando ($f2)
C:		.float  0.0		# Resultado ($f12)

OPT:		.word	0		# Codigo de operacao ($s0)
		# Além desses, os registradores de $t0 a $t9 serão utilizados no programa

		# Strings para exibição no console

CON_QRY:	.asciiz ">> "
OPT_MENU:	.asciiz	"\nChoose the operation (Single Precision):\n"
OPT_ADD:	.asciiz "0. ADD\n"
OPT_MULT:	.asciiz "1. MULT\n"
OPT_RPT:	.asciiz "\nRepeat? (0. Yes / 1. No)\n"
OPR_A:		.asciiz "\nType First Operand:\n"
OPR_B:		.asciiz "\nType Second Operand:\n"
RES:		.asciiz "\nResult: "
OVFW:		.asciiz "\nOverflow occurred"
URFW:		.asciiz "\nUnderflow occurred"


.text
main:

menu:					# Subrotina para mostrar o menu
li	$v0, 4				# Codigo de syscall ($v0) para printar string

la	$a0, OPT_MENU			# Carrega a string MENU como argumento
syscall					# Printa MENU
la	$a0, OPT_ADD			# Carrega a string ADD como argumento
syscall					# Printa ADD
la	$a0, OPT_MULT			# Carrega a string MULT como argumento
syscall					# Printa MULT
la	$a0, CON_QRY			# Carrega a string CON_QRY como argumento
syscall					# Printa CON_QRY

li	$v0, 5				# Codigo de syscall ($v0) para  code
syscall					# Lê OPT (Codigo de operacao) 
sw	$v0, OPT			# Guarda o número lido em OPT

read_operands:				# Subrotina para ler os operandos do teclado
li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, OPR_A			# Carrega a string OPR_A como argumento
syscall					# Printa OPR_A
la	$a0, CON_QRY			# Carrega a string CON_QRY como argumento
syscall					# Printa CON_QRY

li	$v0, 6				# Codigo de syscall ($v0) para leitura de float
syscall					# Lê o primeiro operando (A)
swc1 	$f0, A				# Salva o primeiro operando

li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, OPR_B			# Carrega a string OPR_B como argumento
syscall					# Printa OPR_B
la	$a0, CON_QRY			# Carrega a string CON_QRY como argumento
syscall					# Printa CON_QRY

li	$v0, 6				# Codigo de syscall ($v0) para leitura de float
syscall					# Lê o segundo operando (B)
swc1 	$f0, B				# Salva o segundo operando

extract_fields:				# Subrotina para isolar os campos do ponto flutuante
la 	$a0, A				# Carrega o endereço de A em $a0
la 	$a1, B				# Carrega o endereço de B em $a1
lw 	$t0, 0($a0) 			# Carrega o valor de A em $t0 ($t0 será o expoente de A)
addi 	$t1, $t0, 0			# Copia o valor de A em $t1 ($t1 será a mantissa de A)
lw 	$t2, 0($a1)			# Carrega o valor de B em $t2 ($t2 será o expoente de B)
addi 	$t3, $t2, 0			# Copia o valor de B em $t3 ($t3 será a mantissa de B)
sll 	$t5, $t0, 1			# Desloca A de 1 bit para a esquerda e 24 para a direita para manter apenas o expoente
srl 	$t0, $t5, 24		
srl 	$t5, $t5, 1			# Desloca $t5 de 1 bit para direita 
slt 	$t5, $t1, $t5			# Guarda o bit de sinal de A em $t5
sll 	$t6, $t2, 1			# Desloca B de 1 bit para a esquerda e 24 para a direita para manter apenas o expoente
srl 	$t2, $t6, 24		
srl 	$t6, $t6, 1			# Desloca $t6 de 1 bit para direita
slt 	$t6, $t3, $t6			# Guarda o bit de sinal de B em $t6

					# Escolha entre as operacoes (ADD ou MULT)
lw	$s0, OPT			# Carrega OPT em $s0
beq	$s0, $zero, opt_add		# Se OPT = 0 pule para opt_add
		
opt_mult:				# Subrotina de multiplicação
addi 	$t9, $zero, 254			# Guarda o maior valor possível pro expoente (254)
add 	$t0, $t0, $t2			# Soma os dois expoentes (essa soma contem 2 offsets)
addi 	$t0, $t0, -127			# Retira 1 offset da soma dos expoentes
blt 	$t0, $zero, underflow 		# Se expoente < 0, deu underflow
blt 	$t9, $t0, overflow		# Se expoente > 254, deu overflow

xor 	$t5, $t5, $t6			# XOR dos bits de sinal para determinar o sinal do produto

sll	$t1, $t1, 9			# Desloca A de 9 bits para a esquerda e 9 para a direita para manter apenas a mantissa
sll	$t3, $t3, 9			# Desloca B de 9 bits para a esquerda e 9 para a direita para manter apenas a mantissa
srl	$t1, $t1, 9			# Mantissa de A
srl	$t3, $t3, 9			# Mantissa de B
lui	$t4, 128			# Guarda 2^23 na parte superior de $t4
add	$t1, $t1, $t4			# Adiciona o bit implicito na mantissa de A
add	$t3, $t3, $t4			# Adiciona o bit implicito na mantissa de B

multu	$t1, $t3			# Multiplicação de inteiros das mantissas
mfhi	$t2				# Move o resultado do produto para $t2 e $t3
mflo	$t3			

srl 	$t7, $t2, 15			# Recupera os bits 63 a 48 do produto de 64 bits (16 bits mais significativos do HI)
bgtz 	$t7, norm			# Se não for 0, normaliza o numero
j 	assemble_FP			# Operacao concluída, remontar ponto flutuante

opt_add:				# Subrotina de soma
sll 	$t1, $t1, 9			# Desloca A de 9 bits para a esquerda e 9 para a direita para manter apenas a mantissa
sll 	$t3, $t3, 9			# Desloca B de 9 bits para a esquerda e 9 para a direita para manter apenas a mantissa
srl 	$t1, $t1, 9			# Mantissa de A
srl 	$t3, $t3, 9			# Mantissa de B
lui 	$t4, 128			# Guarda 2^23 na parte superior de $t4 (valor minimo da mantissa)
add 	$t1, $t1, $t4			# Adiciona bit implicito na mantissa de A
add 	$t3, $t3, $t4			# Adiciona bit implicito na mantissa de B

beq 	$t0, $t2, signals		# Se o expA = expB, avalie os sinais
blt 	$t0, $t2, expA_less_than_B	# Se expA < expB, incrementa expA

expB_less_than_A:			# Subrotinas para igualar os expoentes antes da soma
addi 	$t2, $t2, 1			# Incrementa expB
srl 	$t3, $t3, 1			# Desloca a mantissa de B de 1
beq 	$t0, $t2, signals		# Se igualar os expoentes, avalie os sinais
j 	expB_less_than_A		# Se não, repita

expA_less_than_B:
addi 	$t0, $t0, 1			# Incrementa expA
srl 	$t1, $t1, 1			# Desloca a mantissa de A de 1
bne 	$t0, $t2, expA_less_than_B	# Repetir ate igualar os expoentes

signals:				# Subrotina para avaliar os sinais
beq 	$t5, $t6, signals_eq		# A e B tem o mesmo sinal
blt 	$t1, $t3, sigA_less_than_B	# A < B
sub 	$t1, $t1, $t3			# A > B. Subtrai B de A e guarda em $t1
j 	exps				# Reorganizar os expoentes

sigA_less_than_B:			
sub	$t1, $t3, $t1			# Subtrai A de B e guarda em $t1
addi 	$t5, $t6, 0			# Guarda o bit de sinal do resultado em $t5
j 	exps				# Reorganizar os expoentes

signals_eq:
add 	$t1, $t1, $t3			# Soma A e B e guarda em $t1

exps:					# Subrotina para normalizar os expoentes
lui 	$t6, 255			# Guarda 255 nos 16 bits superiores = 2^23 + 2^22 + ... + 2^16
ori 	$t6, $t6, 65535			# Adiciona 2^16 - 1 em $t6 para ter a maxima mantissa
addi 	$t7, $zero, 254			# Guarda 254, o máximo valor de expoente
beq 	$t1, $zero, zero		# Se a mantissa for 0, coloca 0 no resultado
blt 	$t1, $t4, exp_decr		# Se mantissa < minimo normalizado, decrementa expoente
blt 	$t6, $t1, exp_incr		# Se mantissa > maximo normalizado, incrementa expoente
j 	assemble_FP			# Operacao concluida, remontar ponto flutuante

exp_decr:
addi 	$t0, $t0, -1			# Subtraia 1 do expoente
beq 	$t0, $zero, underflow		# Se expoente = 0, deu underflow
sll 	$t1, $t1, 1			# Multiplica por 2 a mantissa (deslocar de 1 para esquerda)
blt 	$t1, $t4, exp_decr		# Repetir até normalizar
j 	assemble_FP			# Normalizado. remontar ponto flutuante

exp_incr:
addi 	$t0, $t0, 1			# Adicione 1 no expoente
blt 	$t7, $t0, overflow		# Se expoente > maximo normaliazdo deu overflow
srl 	$t1, $t1, 1			# Divide por 2 a mantissa (deslocar de 1 para direita)
blt 	$t6, $t1, exp_incr		# Repetir até normalizar
j 	assemble_FP			# Normalizado, remontar ponto flutuante

norm:					# Subrotina para normalizar o produto
beq 	$t0, $t9, overflow		# Se expoente = 254, deu overflow
addi 	$t0, $t0, 1			# Incrementar expoente
sll 	$t2, $t2, 8			# Desloca os bits a esquerda de 16 ao 24
srl 	$t3, $t3, 24			# Pega os 8 bits mais significativos do LO
or 	$t1, $t2, $t3			# Concatena as mantissas e guarda em $t1

assemble_FP:				# Subrotina para recompor o numero em ponto flutuante
sll	$t9, $t5, 31			# Desloca o bit de sinal em 31 bits e guarda em $t9
sll	$t0, $t0, 23			# Desloca o expoente em 23 bits
or	$t9, $t9, $t0			# Concatena o bit de sinal com o expoente e guarda em $t9
addi	$t4, $t4, -1			# Monta mascara para a mantissa
and	$t1, $t1, $t4			# Aplica a mascara na mantissa 
or	$t9, $t9, $t1			# Concatena a mantissa com o restante do numero
sw	$t9, C				# Salva o resultado em C
j	display_result			# Operacao sucedida, mostre o resultado

underflow:				# Subrotina para tratar o underflow
li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, URFW			# Carrega a string URFW como argumento
syscall					# Printa URFW
zero:					# Coloca zero no resultado
sw	$zero, C			# Underflow retorna 0	
j	display_result			# Salto incondicional para evitar a rotina de overflow

overflow:				# Subrotina para tratar o overflow
li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, OVFW			# Carrega a string OVFW como argumento
syscall					# Printa OVFW
addi 	$t0, $zero, 255			# Define o expoente para 255 (infinito)
add 	$t1, $zero, $zero		# Define a mantissa para 0 (infinito)

display_result:				# Subrotina para mostrar o resultado da operacao
li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, RES			# Carrega a string RES como argumento 
syscall					# Printa RES
li	$v0, 2				# Codigo de syscall ($v0) para printar float
lwc1	$f12, C
syscall					# Printa o float presente em $f12 (Resultado)

repeat:					# Subrotina para manter o programa em loop
li	$v0, 4				# Codigo de syscall ($v0) para printar string
la	$a0, OPT_RPT			# Carrega a string OPT_RPT como argumento 
syscall					# Printa OPT_PRT
la	$a0, CON_QRY			# Carrega a string CON_QRY como argumento
syscall					# Printa CON_QRY
li	$v0, 5				# Codigo de syscall ($v0) ler inteiro
syscall					# Lê inteiro 
beq	$v0, $zero, main		# Se o inteiro lido for 0, pula para o início do programa 

end_prog:
li	$v0, 10				# Codigo de syscall ($v0) para encerrar o programa
syscall					# Encerra
