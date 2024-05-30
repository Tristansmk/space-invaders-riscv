.data
# variables de fenetres
# merci de laisser les tailles de fenetres dans leur etat actuelle
hauteur: .word 256 # hauteur de la fenetre (en pixels)
largeur: .word 256 # largeur de la fenetre (en pixels)
taillePixelH: .word 8 # taille d un pixel en y
taillePixelW: .word 8 # taille d un pixel en x

# variables fonctionnelles du programme
I_buff: .word 0 # adresse de la memoire image d ecriture
I_visu: .word 0 # adresse memoire image visuelle
taille_buffer: .word 0 # taille des buffers i_buff et i_visu (4 octects par int)
rougehexa: .word 0x00ff0000 # rouge en hexa pour des tests rapides
saut: .asciz "\n"

# gerer les entrees clavier
RCR_ADDR: .word 0xffff0000
RDR_ADDR: .word 0xffff0004
ASCII_i: .word 105
ASCII_p: .word 112
ASCII_o: .word 111
ASCII_q: .word 113
touche_n: .asciz "Touche non reconnue, touche accepetee : i (gauche), o (missile), p (droite), q (sortir)\n"
touches_du_jeu: .asciz "Touche du jeu : i (gauche), o (missile), p (droite), q (sortir)\n"
envg: .asciz "Fin de partie, les envahisseurs ont gagnes !"
joueurg: .asciz "Fin de partie, vous avez gagne !"
msgsortie: .asciz "\nVous avez abandonne la partie !\n"

.text
####################################
## Fonction I_largeur              #
##                                 #
## Aucunes entrees                 #
## Sorties :                       #
##  a0 <- Hauteur ecran en Units   #
####################################
I_largeur:
	# sauvgarde des vars temp en pile
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw a1 24(sp)
	sw ra 28(sp)
	
	# Programme
	lw t0 largeur
	lw t1 taillePixelW
	div a0 t0 t1 # largeur en Units
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw t4 16(sp)
	lw t5 20(sp)
	lw a1 24(sp)
	lw ra 28(sp)
	addi sp sp 32
	jr ra
	
####################################
## Fonction I_largeur              #
##                                 #
## Entrees:                        #
## Sorties :                       #
##  a0 <- Largeur ecran en Units   #
####################################
I_hauteur:
	# sauvgarde des vars temp en pile
	addi sp sp -12
	sw t0 (sp)
	sw t1 4(sp)
	sw ra 8(sp)
	
	# programme
	lw t0 hauteur
	lw t1 taillePixelH
	div a0 t0 t1 # hauteur en Units
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw ra 8(sp)
	addi sp sp 12
	jr ra
	
####################################
## Fonction I_creer:               #
##                                 #
## Aucunes entrees                 #
## Sorties : aucunes               #
##                                 #
## (Creer I_buff, I_visu et charge #
## la taille des buffers)          #
####################################
I_creer:
	# sauvgarde des vars temp en pile
	addi sp sp -16
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw ra 12(sp)
	
	# prog
	li t2 32 # taille de 4 octets en bits
	jal I_largeur
	mv t0 a0 # t0 = units en largeur
	jal I_hauteur
	mv t1 a0 # t0 = units en hauteur
	mul a0 t0 t1 # largeur * hauteur
	mul a0 a0 t2 # sizeof(l * h)
	mv t2 a0
	li a7 9 # allocations de la memoire image
	ecall
	la t0 I_visu
	sw a0 0(t0) # stock adresse de la memoire dans I_buff
	
	# creation de I_visu
	mv a0 t2
	li a7 9 # allocations de la memoire image d affichage
	ecall
	la t0 I_buff
	sw a0 0(t0) # stock adresse de la memoire dans I_visu
	
	# stocker la taille des buffers pour eviter les calculs inutiles
	li t1 8
	div t2 t2 t1
	la t0 taille_buffer
	sw t2 0(t0)
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw ra 12(sp)
	addi sp sp 16
	jr ra
	
#########################################
## Fonction I_xy_to_addr:               #
##                                      #
## Entrees :                            #
##            a0 <- x                   #
##            a1 <- y                   #
##                                      #
## Sorties :                            #
##  a0 <- addr de x et y dans le buffer #
##                                      #
##  (prends un xy et renvoie sa place   #
##  dans la memoire image)              #
#########################################
I_xy_to_addr:
	# sauvgarde des vars temp en pile 
	addi sp sp -20
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw ra 16(sp)
	
	# vars init
	mv t0 a0 # x
	mv t1 a1 # y
	li t2 4 # size of int
	li t3 0
	
	# mettre x et y sous forme int
	mul t0 t0 t2 # x * 4
	mul t1 t1 t2 # y * 4
	
	# calcul
	jal I_largeur
	mv t2 a0
	lw a0 I_buff # adresse memoire image
	mul t3 t1 t2 # y * nb lignes
	add a0 a0 t3
	add a0 a0 t0 # y * nb lignes + x
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw ra 16(sp)
	addi sp sp 20
	
	# fin prog
	jr ra
	
#########################################
## Fonction I_addr_to_xy:               #
##                                      #
## Entrees :                            #
##          a0 <- addr                  #
## Sorties :                            #
##    a0 <- x                           #
##    a1 <- y                           #
##                                      #
##  (Prend une adresse et renvoie       #
##   son xy, sa place dans I_buff)      #
#########################################
I_addr_to_xy:
	# sauvgarde des vars temp en pile 
	addi sp sp -20
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw ra 16(sp)
	
	# programme
	mv t0 a0
	lw t1 I_buff
	sub t0 t0 t1
	srli t0 t0 2
	jal I_largeur
	mv t3 a0
	div t1 t0 t3
	rem t0 t0 t3 
	mv a0 t0 # x
	mv a1 t1 # y

	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw ra 16(sp)
	addi sp sp 20
	
	# fin prog
	jr ra
	
#########################################
## Fonction I_plot:                     #
##                                      #
## Entrees :                            #
##          a0 <- x                     #
##          a1 <- y                     #
##          a2 <- couleur               #
## Sorties :  aucunes                   #
##                                      #
##  (Dessine un pixel dans I_buff)      #
#########################################
I_plot:
	# sauvgarde des vars temp en pile 
	addi sp sp -8
	sw t0 (sp)
	sw ra 4(sp)
	
	mv t0 a2 # couleur
	jal I_xy_to_addr
	sw t0 (a0) # dessiner le pixel a son adresse dans la mémoire
	
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw ra 4(sp)
	addi sp sp 8
	
	#fin
	jr ra

#########################################
## Fonction I_effacer:                  #
##                                      #
## Entrees : aucunes                    #
## Sorties : aucunes                    #
##                                      #
## (efface I_buff)                      #
#########################################
I_effacer:
	# sauvgarde des vars temp en pile 
	addi sp sp -16
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw ra 12(sp)
	
	lw t0 I_buff # adresse memoire image  
	li t1 0 # couleur (noire)
	lw t2 taille_buffer # taille de la memoire image
	add t2 t0 t2
	
Loop_Effacer:
	beq t0 t2 Fin_effacer # si t0 == t2 -> Fin_effacer sinon on continue d ajouter du noire a l int suivant
	sw t1 (t0) # mettre du noire dans l adresse t0
	addi t0 t0 4 # incrementation de l adresse de la memoire image
	j Loop_Effacer
	
Fin_effacer:
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw ra 12(sp)
	addi sp sp 16
	
	jr ra

#########################################
## Fonction I_rectangle:                #
##                                      #
## Entrees : aucunes                    #
##    a0 <- x                           #
##    a1 <- y                           #
##    a2 <- largeur                     #
##    a3 <- hauteur                     #
##    a4 <- couleur                     #
##                                      #
## Sorties : aucunes                    #
##                                      #
## (Dessine un rectangle dans I_buff)   #
#########################################
I_rectangle:
	# sauvgarde des vars temp en pile 
	addi sp sp -20
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw ra 16(sp)
	
	# Prologue
	mv t0 a0 # x
	mv t4 t0 # x sauvegarde
	mv t1 a1 # y
	mv t2 a2 # largeur
	mv t3 a3 # hauteur
	mv a2 a4 # couleur
	addi t1 t1 -1 # necessaire pr premiere boucle
	
# (Premiere boucle for pour tous les y)
Loop_Rectangle:
	li t5 0
	mv t0 t4
	beq t3 zero Fin_Rectangle # si hauteur == 0 alors fin fct  
	
	# Decrementation premiere boucle
	addi t1 t1 1
	addi t3 t3 -1
	
# (Premiere boucle for pour tous les x)
Loop2_Rectangle:
	beq t5 t2 Loop_Rectangle
	mv a0 t0 # x
	mv a1 t1 # y
	jal I_plot # dessiner le pixel
	# Incrementation deuxieme boucle
	addi t5 t5 1 
	addi t0 t0 1
	j Loop2_Rectangle
	
Fin_Rectangle:
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw ra 16(sp)
	addi sp sp 20
	jr ra
	
##################################################
## Fonction I_buff_to_I_visu:                    #
##                                               #
## Entrees : aucunes                             #
## Sorties : aucunes                             #
##                                               #
## (transfere I_buff dans I_visu pour affichage) #
##################################################
I_buff_to_I_visu:
	# sauvgarde des vars temp en pile 
	addi sp sp -20
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw ra 16(sp)
	
	lw t0 I_buff # adresse memoire image
	lw t3 I_visu # adresse de mem affiche  
	lw t2 taille_buffer # taille de la memoire image
	add t2 t0 t2
	
Loop_I_buff_to_I_visu:
	beq t0 t2 Fin_I_buff_to_I_visu # si t0 == t2 -> Fin_effacer sinon on continue d ajouter du noire a l int suivant
	lw t1 (t0) # charger la valeur dans I_buff
	sw t1 (t3) # mettre la valeur dans I_visu
	addi t0 t0 4 # incrementation de I_buff
	addi t3 t3 4 # incrementation de I_visu
	j Loop_I_buff_to_I_visu
	
Fin_I_buff_to_I_visu:
	# restaurations des vars temp en pile
	lw t0 (sp)
	lw t1 4(sp)
	lw t2 8(sp)
	lw t3 12(sp)
	lw ra 16(sp)
	addi sp sp 20
	
	# fin
	jr ra

##################################################
## Fonction Fin_Partie:                          #
##                                               #
## Entrees : a0 <- 0 = env. gagne 1 = J gagne ?  #
## Sorties : aucunes                             #
##                                               #
## (transfere I_buff dans I_visu pour affichage) #
##################################################
Fin_Partie:
	addi sp sp -32
	sw t0 (sp)
	sw t1 4(sp)
	sw t2 8(sp)
	sw t3 12(sp)
	sw t4 16(sp)
	sw t5 20(sp)
	sw t6 24(sp)
	sw ra 28(sp)

	beqz a0 envgagnent
	la a0 joueurg
	li a7 4
	ecall
	j exit

envgagnent:
	la a0 envg
	li a7 4
	ecall
	j exit

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
