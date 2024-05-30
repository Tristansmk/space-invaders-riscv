#################################
## Fonction parie 3:            #
##                              #
## Entrees : aucunes            #
## Sorties : aucunes            #
##                              #
## (Fonction animation etape 3) #
#################################
partie3:  
	addi sp sp -12
	sw t0 (sp)
	sw t2 4(sp)
	sw ra 8(sp)
	
	jal I_creer
	li t2 20 # nb de fois l animation
	lw t0 I_buff
	
Loop_animation:
	beq t2 zero Fin_animation
	mv a0 t0
	jal I_addr_to_xy
	li a2 2
	li a3 2
	lw a4 rougehexa
	jal I_rectangle
	jal I_buff_to_I_visu
	# patienter 50ms
	li a0 150
	li a7 32
	ecall
	jal I_effacer
	
	addi t0 t0 4 # adresse + 4 -> int suivant
	addi t2 t2 -1 # var incrementale
	j Loop_animation

Fin_animation:
	lw t0 (sp)
	lw t2 4(sp)
	lw ra 8(sp)
	addi sp sp 12
	jr ra

####################################
## Fonction partie4:               #
##                                 #
## Entrees : aucunes               #
## Sorties : aucunes               #
##                                 #
## scene static de fin de partie 4 #
####################################
partie4:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	jal I_creer
	jal J_creer
	jal J_afficher
	jal O_creer
	jal O_afficher
	jal E_creer
	jal E_afficher
	lw a0 I_buff # adresse du missile
	li a1 0 # direction
	jal M_creer
	jal M_afficher
	jal I_buff_to_I_visu
	jal I_effacer

	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw t4 16(sp)
	lw t5 20(sp)
	lw t6 24(sp)
	lw ra 28(sp)
	addi sp sp 32
	jr ra


#################################
## Fonction partie5:            #
##                              #
## Entrees : aucunes            #
## Sorties : aucunes            #
##                              #
## (Gère les entrees clavier)   #
#################################
partie5:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	# creation des buffers
	jal I_creer

	# afficher les touches 
	la a0 touches_du_jeu
	li a7 4
	ecall

	# creation des objets
	jal J_creer
	mv s0 a0 # s0 = joueur
	jal E_creer
	mv s1 a0 # s1 = envahisseurs
	jal O_creer
	mv s2 a0 # s2 = obstacel
	li s5 0
	# afficher le jeu
	jal afficher_partie5

	# controle des entrees clavier pour deplacer le jeu
	jal clavier

	# fin partie 5
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw t4 16(sp)
	lw t5 20(sp)
	lw t6 24(sp)
	lw ra 28(sp)
	addi sp sp 32
	jr ra

afficher_partie5:
	addi sp sp -4
	sw ra (sp)

	# afficher le jeu une premiere fois
	mv a0 s0
	jal J_afficher
	mv a0 s1
	jal E_afficher
	jal E_deplacer
	mv a0 s2
	jal O_afficher
	jal M_deplacer
	jal M_afficher
	jal M_creer_env_rand

	# attendre avant d afficher
	li a0 50
	li a7 32
	ecall

	addi s5 s5 1
	# afficher
	jal I_buff_to_I_visu
	jal I_effacer

	# fin afficher
	lw ra (sp)
	addi sp sp 4
	jr ra

clavier:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

Loop_clavier:
	# afficher le jeu
	jal afficher_partie5

	# registres clavier
	lw t1, RCR_ADDR # 1 si modif
	lw t2, RDR_ADDR # touche pressee

	# tests de touche
	lw t3, 0(t1)
	beqz t3, Loop_clavier
	lw t4, 0(t2)
	lw t5, ASCII_i
	beq t4, t5, touche_i # si touche i
	lw t5, ASCII_p
    beq t4, t5, touche_p # si touche p
    lw t5, ASCII_o
	beq t4, t5, touche_o # si touche o
	lw t5, ASCII_q
    beq t4, t5, Fin_clavier # si touche q

	# mauvaise touche 
	la a0 touche_n
	li a7 4
	ecall

	# rechercher une touche a nouveau
    j Loop_clavier

touche_i:
	mv a0 s0 # joueur
	li a1 0 # gauche
	jal J_deplacer

	# appelle j deplacer vers droite
	j Loop_clavier

touche_p:
	mv a0 s0 # joueur
	li a1 1 # droite
	jal J_deplacer

	# appelle j deplacer vers droite
	j Loop_clavier

touche_o:
	lw a0 (s0)
	addi a0 a0 -760
	li a1 1
	jal M_creer
	# appelle M_creer pos J + par J
	j Loop_clavier

Fin_clavier:
	# effacer l'ecran avant de quitter
	jal I_buff_to_I_visu

	# afficher msg de sortie
	la a0 msgsortie
	li a7 4
	ecall

	# sortir du programme
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw t4 16(sp)
	lw t5 20(sp)
	lw t6 24(sp)
	lw ra 28(sp)
	addi sp sp 32
	jr ra