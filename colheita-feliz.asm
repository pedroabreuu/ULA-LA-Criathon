.data
 
    msg_menu:       .asciiz "\n========== BEM-VINDO AO COLHEITA FELIZ! ==========\n"
    msg_op1:        .asciiz "1 - Inserir Leituras (Clima + Solo)\n"
    msg_op2:        .asciiz "2 - Processar Irrigacao e Relatorio\n"
    msg_op3:        .asciiz "3 - Sair\n"
    msg_escolha:    .asciiz "Opcao: "
    
    msg_vel:        .asciiz "\n[SENSOR] Velocidade do Vento (km/h): "
    msg_dir:        .asciiz "[SENSOR] Direcao do Vento (0-360): "
    msg_umid:       .asciiz "[SENSOR] Umidade do Solo (%): "
    msg_n:          .asciiz "[SENSOR] Nivel de Nitrogenio (0-10): "
    msg_p:          .asciiz "[SENSOR] Nivel de Fosforo (0-10): "
    msg_k:          .asciiz "[SENSOR] Nivel de Potassio (0-10): "
    

    msg_res_clima:  .asciiz "\n===== RELATORIO DE ATUACAO =====\n"
    msg_pressao:    .asciiz "1. Pressao da Agua (Vel + 1): "
    msg_bar:        .asciiz " bar\n"
    msg_rotacao:    .asciiz "2. Rotacao do Irrigador (Contra o vento): "
    msg_graus:      .asciiz " graus\n"
    
    msg_analise_npk:.asciiz "\n===== ANALISE NUTRICIONAL =====\n"
    msg_orig:       .asciiz "Niveis Originais (N-P-K): "
    msg_sort:       .asciiz "Prioridade de Reposicao (Menor -> Maior): "
    msg_espaco:     .asciiz " | "
    msg_alerta:     .asciiz "\n[ACAO] O nutriente mais critico esta abaixo de 5! APLICAR ADUBO.\n"
    msg_ok:         .asciiz "\n[ACAO] Solo Saudavel. Nao adubar.\n"


    # vetor 1: Clima [0]=Velocidade, [4]=Direcao, [8]=Umidade
    array_clima:    .word 0, 0, 0   
    
    # vetor 2: Nutrientes [0]=N, [4]=P, [8]=K
    array_npk:      .word 0, 0, 0   
    array_sort:     .word 0, 0, 0 

.text
.globl main

main:
loop_menu:
    li $v0, 4
    la $a0, msg_menu
    syscall
    la $a0, msg_op1
    syscall
    la $a0, msg_op2
    syscall
    la $a0, msg_op3
    syscall
    la $a0, msg_escolha
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, call_leitura
    beq $t0, 2, call_processamento
    beq $t0, 3, exit_prog
    j loop_menu

call_leitura:
    jal func_ler_completo
    j loop_menu

call_processamento:
    jal func_processar_tudo
    j loop_menu

exit_prog:
    li $v0, 10
    syscall

# clima (Vento/Umidade) E nutrientes (NPK)
func_ler_completo:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $t0, array_clima     # aponta para clima
    la $t1, array_npk       # aponta para npk
    la $t2, array_sort      # copia

    li $v0, 4
    la $a0, msg_vel
    syscall
    li $v0, 5
    syscall
    sw $v0, 0($t0)

    # direcao
    li $v0, 4
    la $a0, msg_dir
    syscall
    li $v0, 5
    syscall
    sw $v0, 4($t0)

    # umidade
    li $v0, 4
    la $a0, msg_umid
    syscall
    li $v0, 5
    syscall
    sw $v0, 8($t0)

    # npk
    # N
    li $v0, 4
    la $a0, msg_n
    syscall
    li $v0, 5
    syscall
    sw $v0, 0($t1)
    sw $v0, 0($t2)

    # P
    li $v0, 4
    la $a0, msg_p
    syscall
    li $v0, 5
    syscall
    sw $v0, 4($t1)
    sw $v0, 4($t2)

    # K
    li $v0, 4
    la $a0, msg_k
    syscall
    li $v0, 5
    syscall
    sw $v0, 8($t1)
    sw $v0, 8($t2)

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

func_processar_tudo:
    addi $sp, $sp, -4       # abre pilha
    sw $ra, 0($sp)          # salva retorno para main

    li $v0, 4
    la $a0, msg_res_clima
    syscall

    la $t0, array_clima

    # calculo pressao
    li $v0, 4
    la $a0, msg_pressao
    syscall

    lw $t1, 0($t0)
    addi $a0, $t1, 1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_bar
    syscall

    # rotacao
    li $v0, 4
    la $a0, msg_rotacao
    syscall

    lw $t1, 4($t0)
    addi $t2, $t1, 180
    li $t3, 360
    div $t2, $t3
    mfhi $a0
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_graus
    syscall

    # bubble sort
    li $v0, 4
    la $a0, msg_analise_npk
    syscall
    la $a0, msg_orig
    syscall
    
    la $t1, array_npk
    lw $a0, 0($t1)
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    lw $a0, 4($t1)
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    lw $a0, 8($t1)
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    jal alg_bubble_sort

    li $v0, 4
    la $a0, msg_sort
    syscall
    
    la $t1, array_sort
    lw $s0, 0($t1)
    
    move $a0, $s0
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    lw $a0, 4($t1)
    li $v0, 1
    syscall
    li $v0, 4
    la $a0, msg_espaco
    syscall
    lw $a0, 8($t1)
    li $v0, 1
    syscall

    li $t5, 5
    blt $s0, $t5, status_critico
    
    li $v0, 4
    la $a0, msg_ok
    syscall
    j fim_func_processar

status_critico:
    li $v0, 4
    la $a0, msg_alerta
    syscall

fim_func_processar:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

alg_bubble_sort:
    # salva contexto
    addi $sp, $sp, -12
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)

    la $s0, array_sort
    
    # compara 0 e 1
    lw $s1, 0($s0)
    lw $s2, 4($s0)
    ble $s1, $s2, jump1
    sw $s2, 0($s0)
    sw $s1, 4($s0)
jump1:
    lw $s1, 4($s0)
    lw $s2, 8($s0)
    ble $s1, $s2, jump2
    sw $s2, 4($s0)
    sw $s1, 8($s0)
jump2:
    lw $s1, 0($s0)
    lw $s2, 4($s0)
    ble $s1, $s2, jump3
    sw $s2, 0($s0)
    sw $s1, 4($s0)
jump3:
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    addi $sp, $sp, 12
    jr $ra

.data
newline: .asciiz "\n"
