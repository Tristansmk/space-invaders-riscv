############################################
# struct envahisseur (3 int par env.) :    #
# 1er int : adresse (position)             #
# 2eme int : direction                     #
#           (0: gauche, 2: droite) #
# 3eme int : vie                           #
############################################

.data
# envahisseurs :
E_nombre: .word 5 # pas possible de modifier le nombre -> trop complexe sinon
E_largeur: .word 3
E_hauteur: .word 1
E_couleur: .word 0x00ff0000
E_espacement_horiz: .word 1
E_deplacement: .word 0 # gauche
E_ryhtme_missiles: .word 5000
E_taille_ligne: .word 19

.text
##############################################
## Fonction E_creer:                         #
##                                           #
## Entrees : aucunes                         #
##                                           #
## Sorties : a0 <- tableau d env.            #
##                                           #
## (Creer la struct envahisseurs)            #
##############################################
E_creer:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	lw t0 E_largeur
	lw t6 E_espacement_horiz
	add t6 t6 t0 # larg + espacement

	lw t0 E_nombre 
	li t1 2 # x de base
	li t2 2 # y de base
	lw t5 E_deplacement # deplacement
	
	li a0 96
	mul a0 t0 a0 # taille des envahisseur en mem (32 * nb d env.)
	li a7 9
	ecall

	mv t3 a0 # adresse
	mv t4 a0 # sauvegarde de l adresse

Loop_E_creer:
	beq t0 zero Fin_E_creer

	mv a0 t1 # x
	mv a1 t2 # y
	jal I_xy_to_addr

	sw a0 0(t3) # 1er int addr
	lw t5 E_deplacement
	sw t5 4(t3) # 2eme int deplacement
	li t5 1 # vie à 1
	sw t5 8(t3) # 3eme  vie

	addi t0 t0 -1
	addi t3 t3 12
	add t1 t1 t6 # x += larg + espace_horiz
	j Loop_E_creer


Fin_E_creer:
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
## Fonction E_afficher:                      #
##                                           #
## Entrees : a0 <- tableau d env.            #
##                                           #
## Sorties : aucunes                         #
##                                           #
## (Affiche la struct envahisseurs)          #
##############################################
E_afficher:
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
	lw t2 E_nombre

Loop_E_afficher:
	beq t2 zero Fin_e_afficher
	lw a0 0(t0)
	jal I_addr_to_xy

	lw a2 E_largeur
	lw a3 E_hauteur
	lw a4 E_couleur
	jal I_rectangle

	addi t2 t2 -1
	addi t0 t0 12
	j Loop_E_afficher

Fin_e_afficher:
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

##############################################
## Fonction E_deplacer:                      #
##                                           #
## Entrees : a0 <- tableau d env.            #
##                                           #
## Sorties : aucunes                         #
##                                           #
## (deplace la struct envahisseurs)          #
##############################################
E_deplacer:
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
	mv t6 s1 # tab env
	lw t0 4(s1) #  direction
	lw a0 0(s1)
	jal I_addr_to_xy # ao -> x et a1 -> y
	mv t2 a0 # de base
	beqz t0 gauche_E_deplacer
	j droite_E_deplacer

droite_E_deplacer:
	jal I_largeur
	mv t1 a0
	lw t3 E_taille_ligne
	add t2 t2 t3 # x + taille ligne
	bge t2 t1 coli_droite
	# aller à droite si pas de colision
	jal E_avancer
	j Fin_E_deplacer

coli_droite: # colision mur droite
	jal E_descendre
	jal direction_inverse
	j Fin_E_deplacer

gauche_E_deplacer:
	beqz t2 coli_gauche
	# aller à droite si pas de colision
	jal E_avancer
	j Fin_E_deplacer

coli_gauche: # colision mur gauche
	jal E_descendre
	jal direction_inverse
	j Fin_E_deplacer

Fin_E_deplacer:
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

######################################################
## Fonction direction_inverse:                       #
##                                                   #
## Entrees : aucunes                                 #
## (tab env via reg. s1 reste le mm dans tt le prog) #
## Sorties : aucunes                                 #
##                                                   #
## (inverse la direction des envahisseurs)           #
######################################################
direction_inverse:
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
	lw t0 E_nombre
	mv t1 s1 # tableau d env

	lw t2 4(t1) # direction initiale
	seqz t2 t2 # t2 = direction inverse
Loop_direction_inverse:
	beqz t0 Fin_direction_inverse 
	
	sw t2 4(t1) # stocker la direction inverse

	addi t0 t0 -1 # decrementer la boucle
	addi t1 t1 12 # aller e l env suivant
	j Loop_direction_inverse

Fin_direction_inverse:
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

######################################################
## Fonction E_avancer:                               #
##                                                   #
## Entrees : aucunes                                 #
## (tab env via reg. s1 reste le mm dans tt le prog) #
## Sorties : aucunes                                 #
##                                                   #
## (avance dans la direction les envahisseurs)       #
######################################################
E_avancer:
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
	lw t0 E_nombre
	mv t1 s1 # tableau d env
	lw t2 4(t1) # direction
	beqz t2 Set_direction_gauche
Set_direction_droite:
	li t3 4
	j Loop_e_avancer
Set_direction_gauche:
	li t3 -4
	j Loop_e_avancer

Loop_e_avancer:
	beqz t0 Fin_E_avancer 

	lw t2 (t1) # stocker l adresse de base
	add t2 t2 t3 # avancer ou reculer selon la direction
	sw t2 (t1) # rendre l avancement effectif

	addi t0 t0 -1 # decrementer la boucle
	addi t1 t1 12 # aller a l env suivant
	j Loop_e_avancer

Fin_E_avancer:
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

######################################################
## Fonction E_descendre:                             #
##                                                   #
## Entrees : aucunes                                 #
## (tab env via reg. s1 reste le mm dans tt le prog) #
## Sorties : aucunes                                 #
##                                                   #
## (deplace la struct envahisseurs vers le bas)      #
######################################################
E_descendre:
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
	mv t0 s1 # t0 <- tab envahisseurs
	lw t1 E_nombre
	jal I_largeur
	mv t2 a0
	li a0 4 # size of int
	mul t2 t2 a0 # taille d une ligne dans I_buff

    lw t4 O_position_y # position en y des obstacles
	lw a0 (t0)
	jal I_addr_to_xy
	addi a1 a1 1
	li a0 0
	beq a1 t4 Fin_Partie

Loop_E_descendre:
	beqz t1 Fin_E_descendre
	
	lw t3 (t0) # adresse dans l image de l env.
	add t3 t3 t2 # ajouter une ligne (descendre en y)
	sw t3 (t0) # rendre l adresse

	addi t1 t1 -1
	addi t0 t0 12
	j Loop_E_descendre

Fin_E_descendre:
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

################################
M_creer_env_rand:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	li t0 25
	bne s5 t0 Fin_e_rand
	li s5 0

	lw a0 (s1) # addr env.
	lw a1 E_nombre # 0 - 4
	addi a1 a1 -1
	li a7 42 
	ecall
	addi a0 a0 1

	mv t0 s1 # t0 addr du tab
	mv t2 a0 # nb d env a parcourir

Loop_E_rand:
	beqz t2 Fin_Loop_E_rand
	addi t2 t2 -1
	addi t0 t0 12
	j Loop_E_rand

Fin_Loop_E_rand:
	lw a0 0(t0)
	addi a0 a0 4
	li a1 0
	jal M_creer

Fin_e_rand:
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