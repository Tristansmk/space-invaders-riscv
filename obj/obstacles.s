################################
# struct Obstacle :            #
# 1er int : adresse (position) #
################################

.data
# Obstacles :
O_nombre:.word 4
O_position_y: .word 0
O_position_x: .word 3
O_hauteur: .word 2
O_largeur: .word 5
O_espacement_horiz: 2
O_couleur: .word 0x00ffff00

.text
##############################################
## Fonction O_creer:                         #
##                                           #
## Entrees : aucunes                         #
##                                           #
## Sorties : a0 <- tableau d obstacles       #
##                                           #
## (Creer la struct Obstacles)               #
##############################################
O_creer:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

    # calcul de position y
    jal I_hauteur
    li a1 5
	div a1 a0 a1 
	li a0 4
	mul t1 a1 a0 # y (1/5 de l ecran)
	la t0 O_position_y
	sw t1 (t0)

	lw t0 O_largeur
	lw t6 O_espacement_horiz
	add t6 t6 t0 # larg + espacement

	lw t0 O_nombre 
	lw t1 O_position_x # x de base
	lw t2 O_position_y # y de base
	
	li a0 4
	mul a0 t0 a0 # taille des obstacles en mem (4 * nb d env.)
	li a7 9
	ecall

	mv t3 a0 # adresse
	mv t4 a0 # sauvegarde de l adresse

Loop_O_creer:
	beq t0 zero Fin_O_creer

	mv a0 t1 # x
	mv a1 t2 # y
	jal I_xy_to_addr
	sw a0 0(t3) # stocker l adresse

	addi t0 t0 -1
	addi t3 t3 4
	add t1 t1 t6 # x += larg + espace_horiz
	j Loop_O_creer

Fin_O_creer:
	mv a0 t4 # rendre l adresse du tab d env.
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


##############################################
## Fonction O_afficher:                      #
##                                           #
## Entrees : a0 <- tableau d obstacles       #
##                                           #
## Sorties : aucunes                         #
##                                           #
## (Affiche la struct Obstacles)             #
##############################################
O_afficher:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	mv t0 a0 # t0 addr du tab
	lw t2 O_nombre

Loop_O_afficher:
	beq t2 zero Fin_O_afficher
	lw a0 0(t0)
	jal I_addr_to_xy

	lw a2 O_largeur
	lw a3 O_hauteur
	lw a4 O_couleur
	jal I_rectangle

	addi t2 t2 -1
	addi t0 t0 4
	j Loop_O_afficher

Fin_O_afficher:
	# Fin
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