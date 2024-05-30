j main # Commencer le programme par la fonction main

####################################################################
# Separation des fichiers pour un code plus lisible                #
# IMPORTANT -> voir dans le fichier tools.s pour la taille d ecran #
####################################################################
# Fichier des fonctions principales
.include "./lib/tools.s"

# Fichier des fonctions de parties du projet (selection)
.include "./lib/parties.s"

# Fichiers des fonctions objet
.include "./obj/joueur.s"
.include "./obj/envahisseurs.s"
.include "./obj/obstacles.s"
.include "./obj/missiles.s"
###################################################

#######################################
## Fonction principale:               #
##                                    #
## Entrees : aucunes                  #
## Sorties : aucunes                  #
##                                    #
## (Gère toutes les autres fontions)  #
#######################################
main:
	# afficher les partie du projet souhaite
	# partie1 et partie2 inclusent dans les autres donc pas besoin
	#jal partie3 # animation d'un carre avec le double buffer
	#jal partie4 # affichage d'une scene static
	jal partie5 # affichage en direct avec les deplacements (defaut)

	# fin
	j exit

#######################################
## Fonction exit:                     #
##                                    #
## Entrees : aucunes                  #
## Sorties : aucunes                  #
##                                    #
## (Termine le programme)             #
#######################################
exit:
	li a7 10
	ecall

