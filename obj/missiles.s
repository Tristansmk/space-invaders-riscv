#######################################
# struct Missile (3 int) :            #
# 1er int : x                         #
# 2eme int : y                        #
# 3eme int : direction (0 bas 1 haut) #
# 4eme int : M. suivant               #
# Missile en vie ? : 0 non, 1 : Oui   #
#######################################

.data
# Missiles :
M_couleur: .word 0xFFFFFF
M_vitesse: .word 5
M_hauteur: .word 5
M_largeur: .word 1

# Chaine de missile
M_nombres: .word 0

.text
##################################################
## Fonction M_creer:                             #
##                                               #
## Entrees :                                     #
##    a0 <- addresse du lanceur de missile       #
##                (spawn du missile)             #
##    a1 <- direction du missile                 # 
##            (bas / haut)                       #
## Sorties : a0 <- tableau du missile            #
##                                               #
## (Creer la struct Missile)                     #
##################################################
M_creer:
    addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	# test du nb de missiles
	lw t0 M_nombres
	beqz t0 premier_missile # si c est le premier missile creer la chaine, sinon ajouter a la chaine

M_creer_suivant:
	mv t1 a1 # adresse du depart du missile
    jal I_addr_to_xy 
    mv t0 a0
    li a0 20
    li a7 9
    ecall

    sw t0 0(a0) # x
    sw a1 4(a0) # y
    sw t1 8(a0) # direction
	sw zero 12(a0) # missile suivant
	li t6 1
	sw t6 16(a0) # vie du missile

	lw t0 M_nombres # nb de misisles dans la chaine
	mv t2 s4 # premier missile de la chaine missile	
	
	li t1 1

Loop_M_creer:
	beq t0 t1 Fin_Loop_M_creer
	lw t2 12(t2) # prendre l adresse du missile suivant
	addi t0 t0 -1
	j Loop_M_creer

Fin_Loop_M_creer:
	sw a0 12(t2) # pointer l ancien missile sur le nouveau

	# incrementer le nb de missile
	la t0 M_nombres
	lw t1 M_nombres
	addi t1 t1 1
	sw t1 (t0)
	j Fin_M_creer

premier_missile:
    mv t1 a1
    jal I_addr_to_xy
    mv t0 a0
    li a0 20
    li a7 9
    ecall

    sw t0 0(a0) # x
    sw a1 4(a0) # y
    sw t1 8(a0) # direction
	sw zero 12(a0) # missile suivant
	li t6 1
	sw t6 16(a0) # vie du missile

	# incrementer le nb de missile
	la t0 M_nombres
	lw t1 M_nombres
	addi t1 t1 1
	sw t1 (t0)
	
	mv s4 a0 # stocker le debut de la chaine missile dans le registre sauvarder s3

Fin_M_creer:
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
## Fonction M_afficher:                      #
##                                           #
## Entrees :                                 #
##          a0 <- tableau du missile         #
##                                           #
## Sorties : aucunes                         #
##                                           #
## (Affiche la struct Missile)               #
##############################################
M_afficher:
    addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	lw t1 M_nombres
	beqz t1 Fin_M_affichage # si pas de missiles dans la chaine on sort
	# missiles presents dans la chaine : on affiche ->   
	mv t0 s4 # premier missile de la chaine missile

Loop_M_affichage:
	beqz t1 Fin_M_affichage # si plus de missile on sort

test_vie_affichage:
	lw t6 16(t0)
	beqz t6 test_vie_affichage_fin

    lw a0 (t0)
    lw a1 4(t0)
    lw a2 M_largeur
    lw a3 M_hauteur
    lw a4 M_couleur

	# dessiner le missile
    jal I_rectangle

test_vie_affichage_fin:
	lw t0 12(t0) # aller au missile suivant
	addi t1 t1 -1 # decrementer nb de missiles
	j Loop_M_affichage

Fin_M_affichage:
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
## Fonction M_deplacer:                      #
##                                           #
## Entrees :                                 #
##          a0 <- tableau du missile         #
##                                           #
## Sorties : aucunes                         #
##                                           #
## (Deplace la struct Missile)               #
##############################################
M_deplacer:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	lw t2 M_nombres
	beqz t2 Fin_M_deplacer # si pas de missiles dans la chaine on sort
	# missiles presents dans la chaine : on affiche ->   
	mv t0 s4 # premier missile de la chaine missile
	jal I_hauteur
	mv t4 a0 # hauteur

Loop_M_deplacer:
	beqz t2 Fin_M_deplacer # si plus de missile on sort

test_vie_deplacer:
	lw t6 16(t0)
	beqz t6 Fin_Loop_M_deplacer

	lw t1 8(t0) # direction du missile
	beqz t1 M_deplacer_bas # test de direction

M_deplacer_haut:	
	lw t1 4(t0)
	beqz t1 effacer_missile
	addi t1 t1 -1 # monter le missile en y
	sw t1 4(t0)
	j Fin_Loop_M_deplacer

M_deplacer_bas:
	lw t1 4(t0)
	beq t1 t4 effacer_missile
	addi t1 t1 1 # descendre le missile en y
	sw t1 4(t0)
	j Fin_Loop_M_deplacer

effacer_missile:
	li t6 0
	sw t6 16(t0) # effacer le missile

Fin_Loop_M_deplacer:
	lw t0 12(t0) # aller au missile suivant
	addi t2 t2 -1 # decrementer nb de missiles
	j Loop_M_deplacer

Fin_M_deplacer:
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