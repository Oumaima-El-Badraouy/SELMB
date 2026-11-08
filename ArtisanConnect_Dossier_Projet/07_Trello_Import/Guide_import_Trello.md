# Guide d'import Trello — ArtisanConnect
## Ce qui a été fourni
`Trello_ArtisanConnect.csv` contient 33 cartes du backlog, avec phase, priorité, rôle responsable, estimation, dépendances, checklist et critères d'acceptation. Un export CSV ne peut pas garantir la création native des checklists, membres ou labels dans toutes les interfaces Trello : vérifiez les champs après import.

## Création du tableau
1. Dans Trello, créez le tableau **ArtisanConnect – Gestion de projet Génie Logiciel**.
2. Ajoutez les listes dans cet ordre : **Product Backlog**, **À faire**, **En cours**, **En revue**, **Terminé**.
3. Utilisez l'importeur CSV disponible dans votre espace Trello ou créez les cartes à partir des lignes du CSV. Mappez `Name` sur le titre et `Description` sur la description.
4. Créez dix labels : `Phase 1 : Analyse et cahier des charges` à `Phase 10 : Présentation et livraison`; appliquez le label indiqué par le CSV.
5. Convertissez le champ `Checklist` en checklist native si l'importeur ne le fait pas. Affectez les responsables fictifs par rôle ou remplacez-les par les membres de l'équipe.
6. Gardez tout le travail non démarré dans Product Backlog. Déplacez seulement les tâches prêtes vers À faire.

## Politique de suivi
Une carte ne passe en Terminé qu'après revue et lorsque tous ses critères d'acceptation sont satisfaits. Les dépendances sont informatives : ne démarrez pas une carte bloquée sans lever explicitement le blocage.
