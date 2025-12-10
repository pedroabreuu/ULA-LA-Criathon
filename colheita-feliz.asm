.data
    msg_menu:       .asciiz "\n========== COLHEITA FELIZ - SISTEMA DE IRRIGACAO ==========\n"
    msg_opcao1:     .asciiz "1 - Inserir Leitura dos Sensores\n"
    msg_opcao2:     .asciiz "2 - Processar e Exibir Resultados\n"
    msg_opcao3:     .asciiz "3 - Sair\n"
    msg_escolha:    .asciiz "Escolha uma opcao: "

    msg_sensores:   .asciiz "\n===== LEITURA DE SENSORES =====\n"
    
    msg_vel_vento:  .asciiz "Digite a velocidade do vento (km/h): "
    msg_dir_vento:  .asciiz "Digite a direcao do vento (0-360 graus): "
    
    msg_umidade:    .asciiz "Digite a umidade do solo (0-100%): "
    
    msg_npk_n:      .asciiz "Nivel de Nitrogenio (0-10): "
    msg_npk_p:      .asciiz "Nivel de Fosforo (0-10): "
    msg_npk_k:      .asciiz "Nivel de Potassio (0-10): "
    
    msg_salvos:     .asciiz "\nDados coletados com sucesso!\n"

    msg_result:     .asciiz "\n===== RELATORIO DE ATUACAO =====\n"
    
    msg_pressao:    .asciiz "1. Pressao da Agua (Vel + 1): "
    msg_rotacao:    .asciiz "2. Rotacao do Irrigador (Contra o vento): "
    msg_adubo:      .asciiz "3. Status da Adubacao: "
    
    msg_bar:        .asciiz " bar\n"
    msg_graus:      .asciiz " graus\n"
    
    status_adubar:  .asciiz "APLICAR ADUBO (Nutrientes Baixos)\n"
    status_solo_ok: .asciiz "SOLO SAUDAVEL (Nao adubar)\n"
    
    msg_sem_dados:  .asciiz "\nERRO: Nenhum dado foi coletado ainda!\n"
    msg_invalida:   .asciiz "\nOpcao invalida!\n"
    msg_fim:        .asciiz "\nEncerrando sistema...\n"
    newline:        .asciiz "\n"

    velocidade_vento: .word 0
    direcao_vento:    .word 0
    umidade_solo:     .word 0
    nivel_n:          .word 0
    nivel_p:          .word 0
    nivel_k:          .word 0
    dados_coletados:  .word 0 

.text
.globl main

main:
menu_principal:
    li $v0, 4
    la $a0, msg_menu
    syscall
    
    li $v0, 4
    la $a0, msg_opcao1
    syscall
    
    li $v0, 4
    la $a0, msg_opcao2
    syscall
    
    li $v0, 4
    la $a0, msg_opcao3
    syscall
    
    li $v0, 4
    la $a0, msg_escolha
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, ler_sensores
    beq $t0, 2, processar_dados
    beq $t0, 3, sair
    
    li $v0, 4
    la $a0, msg_invalida
    syscall
    j menu_principal

ler_sensores:
    li $v0, 4
    la $a0, msg_sensores
    syscall

    li $v0, 4
    la $a0, msg_vel_vento
    syscall
    li $v0, 5
    syscall
    la $t0, velocidade_vento 
    sw $v0, 0($t0)

    li $v0, 4
    la $a0, msg_dir_vento
    syscall
    li $v0, 5
    syscall
    la $t0, direcao_vento
    sw $v0, 0($t0)

    li $v0, 4
    la $a0, msg_umidade
    syscall
    li $v0, 5
    syscall
    la $t0, umidade_solo
    sw $v0, 0($t0)

    # N
    li $v0, 4
    la $a0, msg_npk_n
    syscall
    li $v0, 5
    syscall
    la $t0, nivel_n
    sw $v0, 0($t0)
    
    # P
    li $v0, 4
    la $a0, msg_npk_p
    syscall
    li $v0, 5
    syscall
    la $t0, nivel_p
    sw $v0, 0($t0)
    
    # K
    li $v0, 4
    la $a0, msg_npk_k
    syscall
    li $v0, 5
    syscall
    la $t0, nivel_k
    sw $v0, 0($t0)

    # salvar dados
    li $t1, 1
    la $t0, dados_coletados
    sw $t1, 0($t0)

    li $v0, 4
    la $a0, msg_salvos
    syscall
    j menu_principal

processar_dados:
    la $t1, dados_coletados
    lw $t0, 0($t1)
    beqz $t0, erro_sem_dados

    li $v0, 4
    la $a0, msg_result
    syscall

    # pressao
    li $v0, 4
    la $a0, msg_pressao
    syscall

    la $t2, velocidade_vento
    lw $t1, 0($t2)
    
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

    la $t2, direcao_vento
    lw $t1, 0($t2)
    
    addi $t2, $t1, 180
    
    li $t3, 360
    div $t2, $t3
    mfhi $a0

    li $v0, 1
    syscall

    li $v0, 4
    la $a0, msg_graus
    syscall

    # adubo
    li $v0, 4
    la $a0, msg_adubo
    syscall

    la $t5, nivel_n
    lw $t1, 0($t5)
    
    la $t5, nivel_p
    lw $t2, 0($t5)
    
    la $t5, nivel_k
    lw $t3, 0($t5)
    
    li $t4, 5

    blt $t1, $t4, precisa_adubar
    blt $t2, $t4, precisa_adubar
    blt $t3, $t4, precisa_adubar

    li $v0, 4
    la $a0, status_solo_ok
    syscall
    j fim_processamento

precisa_adubar:
    li $v0, 4
    la $a0, status_adubar
    syscall

fim_processamento:
    li $v0, 4
    la $a0, newline
    syscall
    j menu_principal

erro_sem_dados:
    li $v0, 4
    la $a0, msg_sem_dados
    syscall
    j menu_principal

sair:
    li $v0, 4
    la $a0, msg_fim
    syscall
    li $v0, 10
    syscall
