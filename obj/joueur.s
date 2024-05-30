################################
# struct joueur (3 int) :      #
# 1er int : adresse (position) #
# 2eme int : direction         #
# 3eme int : vie               #
################################

.data
# Variables globales du joueur : 
J_position_x: .word 0
J_position_y: .word 0
J_largeur: .word 6
J_hauteur: .word 2
J_vie: .word 5
J_couleur: .word 0x000000ff

.text

#######################################
## Fonction J_creer:                  #
##                                    #
## Entrees : aucunes                  #
## Sorties : a0 <- tableau du joueur  #
##                                    #
## (Creer la struct joueur)           #
#######################################
J_creer:
	# sauvgarde des vars temp en pile 
	addi sp sp -16
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw ra 12(sp)
	
	# prog
	jal I_largeur
	mv t0 a0
	li a0 2
	div t0 t0 a0
	lw a0 J_hauteur
	sub t0 t0 a0

	jal I_hauteur
	mv t1 a0

	mv a0 t0 # x
	mv a1 t1 # y
	jal I_xy_to_addr
	mv t0 a0 # adresse du joueur
	li t1 0 # direction (static)
	lw t2 J_vie # vies du joueur
	
	# reservation de memoire pour le joueur
	li a0 96 # taille du joueur en memoire
	li a7 9
	ecall
	
	# initialisation des variables du joueur
	sw t0 (a0) # addr
	sw t1 4(a0) # direction
	sw t2 8(a0) # vie
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw ra 12(sp)
	addi sp sp 16
	jr ra

#######################################
## Fonction J_deplacer:               #
##                                    #
## Entrees : a0 <- tableau du joueur  #
## Sorties : aucunes                  #
##                                    #
## (affiche la struct joueur)         #
#######################################
J_afficher:
	addi sp sp -4
	sw ra 0(sp)
	
	# ecrire le joueur dans I_buff en fonction des arguments
	mv t1 a0
	lw a0 (t1)
	jal I_addr_to_xy
	lw t1 J_hauteur
	sub a1 a1 t1
	lw a2 J_largeur # largeur
	lw a3 J_hauteur # hauteur
	lw a4 J_couleur # couleur

	jal I_rectangle # Dessiner le joueur

	# Fin
	lw ra 0(sp)
	addi sp sp 4
	jr ra

#######################################
## Fonction J_deplacer:               #
##                                    #
## Entrees : a0 <- tableau du joueur  #
## Sorties : a0 <- tableau du joueur  #
##                                    #
## (deplace le joueur)                #
#######################################
J_deplacer:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	# programme
	mv t6 a0
	mv t0 a1 #  direction
	lw a0 0(s0)
	jal I_addr_to_xy # ao -> x et a1 -> y
	mv t5 a1
	beqz t0 gauche_J_deplacer
	j droite_J_deplacer

droite_J_deplacer:
	mv t4 a0
	mv t2 a0
	jal I_largeur
	mv t1 a0
	lw t3 J_largeur
	add t2 t2 t3
	bge t2 t1 Fin_J_deplacer
	# aller à droite si pas de colision
	addi a0 t4 1 # x+1 (aller a gauche)
	mv a1 t5
	jal I_xy_to_addr
	sw a0 0(s0) # restocker l adresse
	j Fin_J_deplacer

gauche_J_deplacer:
	beq zero a0 Fin_J_deplacer
	addi a0 a0 -1 # x-1 (aller a gauche)
	jal I_xy_to_addr
	sw a0 0(s0) # restocker l adresse
	j Fin_J_deplacer

Fin_J_deplacer:

	mv a0 s0 # retourner le tableau

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
