.data
    # Mensagens do menu principal
    msg_menu:       .asciiz "\n========== SISTEMA DE IRRIGACAO ==========\n"
    msg_opcao1:     .asciiz "1 - Tela de Sensores\n"
    msg_opcao2:     .asciiz "2 - Tela de Resultados\n"
    msg_opcao3:     .asciiz "3 - Sair\n"
    msg_escolha:    .asciiz "Escolha uma opcao: "
    
    # Mensagens da tela de sensores
    msg_sensores:   .asciiz "\n===== TELA DE SENSORES =====\n"
    msg_vel_vento:  .asciiz "Digite a velocidade do vento (mph): "
    msg_int_vento:  .asciiz "Digite a intensidade do vento (mph): "
    msg_umidade:    .asciiz "Digite a umidade do solo (0-100 por cento): "
    msg_salvos:     .asciiz "\nDados salvos com sucesso!\n"
    
    # Mensagens da tela de resultados
    msg_result:     .asciiz "\n===== TELA DE RESULTADOS =====\n"
    msg_dados:      .asciiz "\n--- Dados dos Sensores ---\n"
    msg_vel_label:  .asciiz "Velocidade do vento: "
    msg_int_label:  .asciiz "Intensidade do vento: "
    msg_umi_label:  .asciiz "Umidade do solo: "
    msg_mph:        .asciiz " mph\n"
    msg_percent:    .asciiz " por cento\n"
    
    msg_analise:    .asciiz "\n--- Analise do Sistema ---\n"
    msg_irrig_int:  .asciiz "Intensidade do Irrigador: "
    msg_nivel_agua: .asciiz "Nivel de Agua: "
    msg_status:     .asciiz "Status: "
    
    # Niveis e status
    nivel_baixo:    .asciiz "BAIXO\n"
    nivel_medio:    .asciiz "MEDIO\n"
    nivel_alto:     .asciiz "ALTO\n"
    nivel_max:      .asciiz "MAXIMO\n"
    
    status_ok:      .asciiz "Sistema operando normalmente\n"
    status_atencao: .asciiz "ATENCAO: Condicoes criticas detectadas!\n"
    
    msg_sem_dados:  .asciiz "\nNenhum dado foi coletado ainda!\n"
    msg_invalida:   .asciiz "\nOpcao invalida! Tente novamente.\n"
    msg_fim:        .asciiz "\nEncerrando sistema...\n"
    
    newline:        .asciiz "\n"
    
    # Variaveis para armazenar os valores dos sensores
    velocidade_vento:   .word 0
    intensidade_vento:  .word 0
    umidade_solo:       .word 0
    dados_coletados:    .word 0  # Flag: 0=nao coletados, 1=coletados

.text
.globl main

main:
    # Loop principal do sistema
menu_principal:
    # Exibir menu
    li $v0, 4
    la $a0, msg_menu
    syscall
    
    la $a0, msg_opcao1
    syscall
    
    la $a0, msg_opcao2
    syscall
    
    la $a0, msg_opcao3
    syscall
    
    la $a0, msg_escolha
    syscall
    
    # Ler opçao do usuario
    li $v0, 5
    syscall
    move $t0, $v0  # $t0 = opçao escolhida
    
    # Processar escolha
    beq $t0, 1, tela_sensores
    beq $t0, 2, tela_resultados
    beq $t0, 3, sair_programa
    
    # Opçao invalida
    li $v0, 4
    la $a0, msg_invalida
    syscall
    j menu_principal

#==========================================
# TELA DE SENSORES
#==========================================
tela_sensores:
    # Exibir cabeçalho
    li $v0, 4
    la $a0, msg_sensores
    syscall
    
    # Ler velocidade do vento
    la $a0, msg_vel_vento
    syscall
    
    li $v0, 5
    syscall
    sw $v0, velocidade_vento
    
    # Ler intensidade do vento
    li $v0, 4
    la $a0, msg_int_vento
    syscall
    
    li $v0, 5
    syscall
    sw $v0, intensidade_vento
    
    # Ler umidade do solo
    li $v0, 4
    la $a0, msg_umidade
    syscall
    
    li $v0, 5
    syscall
    sw $v0, umidade_solo
    
    # Marcar que dados foram coletados
    li $t0, 1
    sw $t0, dados_coletados
    
    # Confirmar salvamento
    li $v0, 4
    la $a0, msg_salvos
    syscall
    
    j menu_principal

#==========================================
# TELA DE RESULTADOS
#==========================================
tela_resultados:
    # Verificar se ha dados coletados
    lw $t0, dados_coletados
    beqz $t0, sem_dados
    
    # Exibir cabeçalho
    li $v0, 4
    la $a0, msg_result
    syscall
    
    # Exibir dados dos sensores
    la $a0, msg_dados
    syscall
    
    # Velocidade do vento
    la $a0, msg_vel_label
    syscall
    
    li $v0, 1
    lw $a0, velocidade_vento
    syscall
    
    li $v0, 4
    la $a0, msg_mph
    syscall
    
    # Intensidade do vento
    la $a0, msg_int_label
    syscall
    
    li $v0, 1
    lw $a0, intensidade_vento
    syscall
    
    li $v0, 4
    la $a0, msg_mph
    syscall
    
    # Umidade do solo
    la $a0, msg_umi_label
    syscall
    
    li $v0, 1
    lw $a0, umidade_solo
    syscall
    
    li $v0, 4
    la $a0, msg_percent
    syscall
    
    # ANALISE E DECISoES
    la $a0, msg_analise
    syscall
    
    #--- Determinar intensidade do irrigador ---
    la $a0, msg_irrig_int
    syscall
    
    lw $t1, intensidade_vento
    li $t2, 10
    
    bgt $t1, $t2, irrigador_medio  # Se > 10mph, usar medio
    
    # Senao, usar baixo
irrigador_baixo:
    la $a0, nivel_baixo
    syscall
    j analise_agua
    
irrigador_medio:
    la $a0, nivel_medio
    syscall
    
    #--- Determinar nivel de agua ---
analise_agua:
    la $a0, msg_nivel_agua
    syscall
    
    lw $t3, umidade_solo
    li $t4, 30  # Limiar de umidade baixa
    
    blt $t3, $t4, agua_maxima  # Se umidade < 30 por cento, usar maximo
    
    # Umidade adequada
    li $t5, 60
    blt $t3, $t5, agua_media  # Se umidade < 60 por cento, usar medio
    
    # Umidade alta
agua_baixa:
    la $a0, nivel_baixo
    syscall
    j status_sistema
    
agua_media:
    la $a0, nivel_medio
    syscall
    j status_sistema
    
agua_maxima:
    la $a0, nivel_max
    syscall
    
    #--- Status do sistema ---
status_sistema:
    li $v0, 4
    la $a0, msg_status
    syscall
    
    # Verificar condiçoes criticas
    lw $t1, intensidade_vento
    lw $t3, umidade_solo
    
    li $t2, 20   # Vento muito forte
    li $t4, 20   # Umidade muito baixa
    
    # Se vento > 20 OU umidade < 20, status de atençao
    bgt $t1, $t2, status_critico
    blt $t3, $t4, status_critico
    
    # Sistema normal
    la $a0, status_ok
    syscall
    j menu_principal
    
status_critico:
    la $a0, status_atencao
    syscall
    j menu_principal

#==========================================
# SEM DADOS
#==========================================
sem_dados:
    li $v0, 4
    la $a0, msg_sem_dados
    syscall
    j menu_principal

#==========================================
# SAIR DO PROGRAMA
#==========================================
sair_programa:
    li $v0, 4
    la $a0, msg_fim
    syscall
    
    li $v0, 10
    syscall
