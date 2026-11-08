# Tableau d'activités pour construire le Gantt et le PERT
> **Usage pédagogique :** ce tableau est l'entrée de travail de l'équipe. Il propose des activités, des estimations initiales et des prédécesseurs logiques; il ne constitue pas un Gantt ou un PERT terminé. Avant de dessiner les diagrammes, l'équipe doit valider/adapter les durées et dépendances avec l'encadrant.

## Comment l'utiliser
1. Gardez l'identifiant `Txx` : il permet de relier une ligne du tableau aux cartes Trello.
2. Confirmez qu'une étape précédente est réellement bloquante. Retirez les liens seulement « pratiques ».
3. Pour le **Gantt**, choisissez la date de départ et placez chaque activité après tous ses prédécesseurs.
4. Pour le **PERT**, reportez ID, durée et prédécesseurs; calculez ES, EF, LS, LF et la marge dans le gabarit PERT.
5. Les durées sont des estimations de départ, à adapter à la taille réelle de l'équipe. Une activité marquée `—` n'a pas de prédécesseur.

## Activités proposées
| ID | Phase | Événement / activité | Durée estimée | Étape(s) précédente(s) | Responsable |
|---|---|---|---:|---|---|
| T01 | Phase 1 : Analyse et cahier des charges | Cadrer le projet et identifier les parties prenantes | 2 j | — | Chef de projet |
| T02 | Phase 1 : Analyse et cahier des charges | Recueillir et prioriser les besoins | 4 j | T01 | Analyste |
| T03 | Phase 1 : Analyse et cahier des charges | Rédiger et faire valider le cahier des charges | 3 j | T02 | Chef de projet |
| T04 | Phase 2 : Planification du projet | Construire le backlog produit | 1 j | T03 | Product Owner fictif |
| T05 | Phase 2 : Planification du projet | Estimer les tâches et analyser les risques | 1 j | T04 | Chef de projet |
| T06 | Phase 2 : Planification du projet | Préparer Gantt, PERT et jalons | 1 j | T05 | Chef de projet |
| T07 | Phase 3 : Conception UML | Modéliser les cas d'utilisation | 2 j | T03 | Analyste |
| T08 | Phase 3 : Conception UML | Concevoir le diagramme de classes et données | 3 j | T07 | Back-end |
| T09 | Phase 3 : Conception UML | Décrire les séquences critiques | 2 j | T08 | Analyste |
| T10 | Phase 3 : Conception UML | Définir contrat API et architecture | 3 j | T08 | Back-end |
| T11 | Phase 4 : Conception UI/UX | Créer personas et parcours utilisateur | 1 j | T02 | UX/UI |
| T12 | Phase 4 : Conception UI/UX | Produire wireframes responsive | 3 j | T11 | UX/UI |
| T13 | Phase 4 : Conception UI/UX | Établir le design system | 1 j | T12 | UX/UI |
| T14 | Phase 5 : Développement Backend | Initialiser backend, base de données et CI | 2 j | T10 | Back-end |
| T15 | Phase 5 : Développement Backend | Implémenter authentification et RBAC | 3 j | T14 | Back-end |
| T16 | Phase 5 : Développement Backend | Implémenter catégories et catalogue produits | 3 j | T15 | Back-end |
| T17 | Phase 5 : Développement Backend | Implémenter stock, panier et commande | 4 j | T16 | Back-end |
| T18 | Phase 5 : Développement Backend | Implémenter administration et modération | 2 j | T15, T16 | Back-end |
| T19 | Phase 6 : Développement Frontend | Initialiser front-end et navigation | 2 j | T10, T12 | Front-end |
| T20 | Phase 6 : Développement Frontend | Développer authentification et catalogue | 3 j | T19, T15, T16 | Front-end |
| T21 | Phase 6 : Développement Frontend | Développer panier et suivi de commande | 3 j | T20, T17 | Front-end |
| T22 | Phase 6 : Développement Frontend | Développer tableaux artisan et admin | 3 j | T20, T18 | Front-end |
| T23 | Phase 6 : Développement Frontend | Rendre les écrans responsive et accessibles | 2 j | T20, T21, T22 | Front-end |
| T24 | Phase 7 : Intégration | Intégrer front-end, API et données de démonstration | 3 j | T17, T20, T22 | Intégrateur |
| T25 | Phase 7 : Intégration | Préparer déploiement de démonstration | 1 j | T24 | DevOps/Intégrateur |
| T26 | Phase 8 : Tests | Écrire tests unitaires des règles métier | 2 j | T17 | QA + Back-end |
| T27 | Phase 8 : Tests | Exécuter tests d'intégration API | 2 j | T25 | QA + Back-end |
| T28 | Phase 8 : Tests | Réaliser recette fonctionnelle et responsive | 2 j | T25, T26 | QA + équipe |
| T29 | Phase 8 : Tests | Corriger anomalies bloquantes | 2 j | T27, T28 | Équipe |
| T30 | Phase 9 : Documentation | Rédiger documentation technique et README | 2 j | T29 | Back-end + Front-end |
| T31 | Phase 9 : Documentation | Finaliser rapport, UML et preuves | 2 j | T25 | Chef de projet |
| T32 | Phase 10 : Présentation et livraison | Préparer slides et démonstration | 1 j | T29, T31 | Équipe |
| T33 | Phase 10 : Présentation et livraison | Répéter et livrer les livrables | 1 j | T32 | Chef de projet + équipe |
## Vérification avant de créer les diagrammes
- Toute activité non initiale possède un ou plusieurs IDs précédents existants.
- Les dépendances ne forment pas de boucle.
- Les activités en parallèle ont des prédécesseurs différents ou compatibles.
- La somme n'est pas la durée du projet : seuls les enchaînements dépendants déterminent la durée et le chemin critique.
