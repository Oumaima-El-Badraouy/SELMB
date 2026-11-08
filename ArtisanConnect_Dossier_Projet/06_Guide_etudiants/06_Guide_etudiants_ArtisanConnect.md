# Guide étudiants — ArtisanConnect
## Bien démarrer le projet de Génie Logiciel

Bienvenue. ArtisanConnect est une marketplace web : les artisans marocains publient des produits et les clients les découvrent, les placent dans un panier puis créent une commande. L'objectif du module n'est pas seulement de coder : vous devez expliquer le besoin, planifier, concevoir, tester et démontrer votre solution.

> **Hypothèses de cadrage.** Le planning démarre le 9 novembre 2026, dure huit semaines de cinq jours ouvrés et suppose une équipe de quatre étudiants : chef·fe de projet/analyste, concepteur·rice UX, développeur·se back-end et développeur·se front-end/intégrateur·rice. Le paiement en ligne, la livraison et les notifications externes ne sont pas inclus dans le MVP : une commande est une demande confirmée par l'artisan. Les choix techniques proposés sont à valider avec l'encadrant.


## 1. Comprendre le projet
Le problème est la dispersion de l'offre artisanale. Votre MVP apporte un catalogue structuré et un suivi de commande. Ne confondez pas le dossier cible avec le code existant « Al Asel » : il contient des profils/demandes mais pas encore toutes les fonctions de marketplace définies ici.

### Rôles
- **Client** : crée un compte, recherche, consulte, gère son panier et ses commandes.
- **Artisan** : complète son profil, publie ses produits, règle le stock et traite les commandes.
- **Administrateur** : modère comptes, produits et catégories; supervise les commandes.

## 2. Ce que vous devez développer
Priorité 1 : authentification et rôles. Priorité 2 : produits/catégories et recherche. Priorité 3 : stock, panier et commande. Priorité 4 : espaces artisan et administration. Le paiement réel et la livraison sont hors MVP : ne les commencez pas avant que le parcours de base fonctionne.

## 3. Technologies proposées
Front-end : React + Vite, TypeScript, CSS/Tailwind si validé. Back-end : Node.js, Express, API REST. Base de données : PostgreSQL avec Prisma (ou une adaptation validée de Firebase). Outils : Git/GitHub, Trello, Mermaid et un gestionnaire de variables d'environnement. Ne commitez jamais `.env`, jetons ou mots de passe.

## 4. Travailler en équipe
Attribuez un rôle principal à chacun, sans créer des silos : chef·fe de projet/analyste, UX, back-end, front-end/intégration. Toute tâche passe par une branche, une pull request et une revue par un pair. Faites un point court régulier : ce qui est terminé, ce qui bloque, ce qui sera fait ensuite.

## 5. Utiliser Trello
Le tableau contient `Product Backlog`, `À faire`, `En cours`, `En revue`, `Terminé`. Une carte va de gauche à droite. Ne placez en « En cours » que ce que vous avez commencé; gardez une seule carte active par personne si possible. Lisez la description : elle donne responsable, dépendances, checklist et critères d'acceptation. Importez le CSV fourni suivant le guide Trello.

## 6. Lire le Gantt et le PERT
Le **Gantt** donne les dates, durées et tâches parallèles. Le **PERT** montre les dépendances. Les activités rouges sont critiques : tout retard les concernant retarde la livraison. G et I ont une marge de six jours dans le modèle; ce n'est pas une invitation à les repousser.

## 7. Démarrage pas à pas
1. Lisez le cahier des charges et validez les hypothèses avec l'encadrant.
2. Créez le tableau Trello, importez le backlog et affectez les rôles.
3. Ouvrez le Gantt/PERT; découpez la première semaine en tâches réalisables.
4. Initialisez le dépôt, le README, les conventions de branches et l'environnement.
5. Produisez et faites valider UML, maquettes et contrat API.
6. Implémentez une tranche verticale : inscription → produit → panier → commande.
7. Ajoutez les droits artisan/admin puis l'interface responsive.
8. Écrivez des tests, réalisez la recette, corrigez et préparez la démonstration.

## 8. Livrables attendus
Cahier des charges, backlog/Trello, Gantt, PERT, UML, maquettes, code versionné, README d'installation, tests/preuves de recette, rapport et présentation. Les parties du rapport « résultats » ne doivent être remplies qu'avec des preuves réelles.

## 9. Erreurs à éviter
- Ajouter des fonctionnalités non validées avant le MVP.
- Faire confiance au prix ou au stock envoyé par le navigateur.
- Autoriser un artisan à modifier le produit d'un autre.
- Décrémenter le stock sans transaction lors de la commande.
- Affirmer qu'un test ou un déploiement a été effectué sans preuve.
- Attendre la fin pour intégrer front-end et back-end.

## 10. Roadmap
S1 analyse; S2 planification/UML; S3 architecture/UX; S4-S5 noyaux back-end et front-end; S6 intégration; S7 tests; S8 documentation, répétition et livraison. Consultez `02_Gestion_de_projet/02_Diagramme_Gantt.mmd` pour les dates détaillées.
