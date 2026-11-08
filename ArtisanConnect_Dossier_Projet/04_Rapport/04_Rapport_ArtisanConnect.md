# Rapport de projet — ArtisanConnect
## Plateforme web de mise en relation et de commercialisation de produits artisanaux marocains

**Établissement :** [À compléter]  
**Module :** Génie Logiciel  
**Encadrant·e :** [À compléter]  
**Équipe :** [À compléter]  
**Année universitaire :** [À compléter]  
**Version :** document préparatoire, 8 novembre 2026

> **Avertissement méthodologique.** Ce rapport documente la cible du projet et son plan de réalisation. Les rubriques marquées `[À compléter après réalisation]` ne constituent pas une affirmation de développement, de déploiement ni de test effectué.

## Remerciements
[Facultatif — à compléter par l'équipe.]

## Résumé
ArtisanConnect est un projet pédagogique de marketplace dédié aux produits artisanaux marocains. Il propose un catalogue, une recherche, un panier, un cycle de commande, une gestion des stocks et des espaces différenciés pour client, artisan et administrateur. Le projet mobilise analyse des besoins, UML, architecture web, planification et stratégie de test. Le MVP exclut volontairement le paiement réel et la logistique afin de concentrer l'effort sur un parcours cohérent et sécurisé.

## Table des matières
1. Introduction générale · 2. Contexte et problématique · 3. Analyse des besoins · 4. Cahier des charges · 5. Gestion et planification · 6. Conception UML · 7. Architecture · 8. Réalisation · 9. Tests et validation · Conclusion · Perspectives · Annexes

## Introduction générale
La transformation numérique peut accroître la visibilité des ateliers artisanaux et simplifier la découverte d'une offre locale. Ce travail fixe un cadre de réalisation mesurable pour une équipe d'étudiants, de l'expression du besoin à la livraison. Les décisions présentées sont des hypothèses à faire valider avant implémentation.

## Chapitre 1 — Contexte et problématique
L'offre artisanale est souvent répartie entre boutiques, réseaux sociaux et contacts directs. Le client manque d'un catalogue structuré et l'artisan d'un moyen unifié de gérer les produits et les demandes. La problématique retenue est donc : **comment fournir un parcours web simple qui rende les produits découvrables, permette une demande de commande traçable et donne à l'artisan la maîtrise de son catalogue ?**

Le dépôt étudié contient une application existante « Al Asel » : mobile Flutter et API Express/Firebase, avec profils, demandes, messagerie et publications. Il n'apporte pas encore le panier, les commandes et la gestion de produit/stock du présent cahier. Cette distinction évite d'attribuer au code existant des fonctions qu'il ne possède pas.

## Chapitre 2 — Analyse des besoins
Les acteurs sont le visiteur, le client, l'artisan et l'administrateur. Le client doit rechercher, comparer, ajouter au panier et suivre ses commandes. L'artisan doit contrôler son profil, ses produits, son stock et les commandes reçues. L'administrateur doit garantir l'intégrité de la place de marché. Les qualités attendues sont sécurité, ergonomie responsive, performance raisonnable et maintenabilité.

## Chapitre 3 — Cahier des charges
Le cahier des charges détaillé est fourni dans `01_Cahier_des_charges/01_Cahier_des_charges_ArtisanConnect.md`. Le périmètre MVP couvre inscription, catalogue, filtres, fiche produit, panier, commande, historique, gestion artisan et administration. La règle structurante est la commande mono-artisan et transactionnelle : prix et stock sont revérifiés sur le serveur.

## Chapitre 4 — Gestion et planification du projet
La méthode recommandée est un flux itératif à tableaux Trello : backlog priorisé, tâches prêtes, en cours, en revue et terminées. Le projet est planifié sur huit semaines. Le chemin critique de 40 jours est A-B-C-D-E-F-H-J-K-L-M; les maquettes et le parcours front-end disposent d'une marge de six jours dans le modèle PERT. Voir le Gantt et PERT en annexe.

## Chapitre 5 — Conception UML
Le modèle comprend Utilisateur spécialisé en Client et Artisan, Produit, Catégorie, Panier/LignePanier et Commande/LigneCommande. Les relations protègent l'historique : une ligne de commande garde le prix unitaire validé, et un produit commandé est archivé plutôt que supprimé. Les cas d'utilisation et séquences détaillés se trouvent dans le cahier des charges.

## Chapitre 6 — Architecture et conception technique
Une architecture React/Vite, Express REST et PostgreSQL est proposée. L'API versionnée porte les validations, RBAC et transactions. Les images sont placées dans un stockage objet et les secrets restent dans les variables d'environnement. Cette proposition peut être adaptée à l'API Express/Firebase existante uniquement après étude des migrations, de la modélisation et des règles de sécurité.

## Chapitre 7 — Réalisation et développement
### État de réalisation
**[À compléter après réalisation.]** À renseigner avec les versions utilisées, liens de dépôts, captures d'écran, endpoints développés, migrations exécutées et décisions effectivement prises.

### Plan de réalisation
Commencer par le socle (repo, environnement, authentification et schéma), puis catalogue/stock, panier/commande, écrans, intégration et recette. Chaque pull request doit relier ses critères d'acceptation, tests et capture de démonstration.

## Chapitre 8 — Tests et validation
### Stratégie prévue
Tests unitaires : calculs de total, transitions de statut, autorisations et disponibilité. Tests d'intégration : endpoints authentifiés, transaction de commande et isolation des ressources. Tests de parcours : inscription, recherche, panier, confirmation et traitement artisan. Tests manuels : responsive, navigateurs récents, erreurs et états vides.

### Résultats
**[À compléter après réalisation.]** Tableau recommandé : identifiant de test, précondition, résultat attendu, résultat observé, statut, preuve/lien et anomalie associée. Aucun résultat n'est déclaré dans cette version.

## Conclusion générale
ArtisanConnect propose un périmètre réaliste pour apprendre à transformer un besoin métier en logiciel planifié, conçu et vérifiable. La priorité est la cohérence du cycle produit-stock-commande et le respect des permissions.

## Perspectives
Paiement via prestataire, livraison, avis vérifiés, messagerie, analytics, multilingue et multi-vendeur sont des évolutions conditionnées à une validation fonctionnelle, juridique et technique.

## Annexes
- Annexe A : cahier des charges.
- Annexe B : Gantt et PERT.
- Annexe C : export Trello.
- Annexe D : fiches de recette **[à produire pendant les tests]**.
