from __future__ import annotations

import csv
import textwrap
from pathlib import Path

from docx import Document
from docx.shared import Inches, Pt
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE
from pptx.util import Inches as PInches, Pt as PPt
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, PageBreak
from PIL import Image, ImageDraw, ImageFont

ROOT = Path("ArtisanConnect_Dossier_Projet")
CDC = ROOT / "01_Cahier_des_charges"
PROJECT = ROOT / "02_Gestion_de_projet"
UML = ROOT / "03_UML"
REPORT = ROOT / "04_Rapport"
PRESENTATION = ROOT / "05_Presentation"
GUIDE = ROOT / "06_Guide_etudiants"
TRELLO = ROOT / "07_Trello_Import"
for directory in (CDC, PROJECT, UML, REPORT, PRESENTATION, GUIDE, TRELLO):
    directory.mkdir(parents=True, exist_ok=True)

START = "09/11/2026"
ASSUMPTIONS = """\
> **Hypothèses de cadrage.** Le planning démarre le 9 novembre 2026, dure huit semaines de cinq jours ouvrés et suppose une équipe de quatre étudiants : chef·fe de projet/analyste, concepteur·rice UX, développeur·se back-end et développeur·se front-end/intégrateur·rice. Le paiement en ligne, la livraison et les notifications externes ne sont pas inclus dans le MVP : une commande est une demande confirmée par l'artisan. Les choix techniques proposés sont à valider avec l'encadrant.
"""

use_case = """\
```mermaid
flowchart LR
  C[Client] --> UC1((Créer un compte / se connecter))
  C --> UC2((Parcourir, rechercher et filtrer))
  C --> UC3((Consulter un produit))
  C --> UC4((Gérer le panier))
  C --> UC5((Passer et suivre une commande))
  A[Artisan] --> UA1((Gérer son profil))
  A --> UA2((Gérer produits et stocks))
  A --> UA3((Consulter / traiter les commandes))
  ADM[Administrateur] --> UAD1((Gérer utilisateurs et artisans))
  ADM --> UAD2((Gérer produits, catégories et commandes))
  ADM --> UAD3((Superviser la plateforme))
  UC5 --> S[(Catalogue / commandes)]
  UA2 --> S
  UA3 --> S
```
"""

classes = """\
```mermaid
classDiagram
  class Utilisateur {
    +UUID id
    +String nom
    +String email
    +String motDePasseHash
    +Role role
    +DateTime creeLe
  }
  class Artisan {
    +String nomAtelier
    +String description
    +String ville
    +String telephone
    +StatutVerification statut
  }
  class Client
  class Categorie { +UUID id +String nom +String slug }
  class Produit {
    +UUID id
    +String titre
    +Text description
    +Decimal prix
    +Int stock
    +Boolean actif
  }
  class Panier { +UUID id +Decimal total }
  class LignePanier { +Int quantite +Decimal prixUnitaire }
  class Commande {
    +UUID id
    +StatutCommande statut
    +Decimal total
    +DateTime creeLe
  }
  class LigneCommande { +Int quantite +Decimal prixUnitaire }
  Utilisateur <|-- Client
  Utilisateur <|-- Artisan
  Artisan "1" --> "*" Produit : publie
  Categorie "1" --> "*" Produit : classe
  Client "1" --> "0..1" Panier : possède
  Panier "1" *-- "*" LignePanier
  LignePanier "*" --> "1" Produit
  Client "1" --> "*" Commande : passe
  Commande "1" *-- "*" LigneCommande
  LigneCommande "*" --> "1" Produit
  Artisan "1" --> "*" Commande : reçoit
```
"""

sequences = """\
### Scénario S1 — passer une commande
```mermaid
sequenceDiagram
  actor Client
  participant Web as Application web
  participant API as API
  participant DB as Base de données
  Client->>Web: Ajoute un produit au panier
  Web->>API: POST /cart/items
  API->>DB: Vérifie produit, stock et prix
  DB-->>API: Produit disponible
  API-->>Web: Panier mis à jour
  Client->>Web: Confirme la commande
  Web->>API: POST /orders
  API->>DB: Transaction : crée commande, décrémente stock
  DB-->>API: Commande créée
  API-->>Web: Confirmation et référence
```
### Scénario S2 — artisan met à jour un produit
```mermaid
sequenceDiagram
  actor Artisan
  participant Web as Tableau de bord
  participant API as API
  participant DB as Base de données
  Artisan->>Web: Enregistre la modification
  Web->>API: PATCH /products/:id
  API->>API: Vérifie JWT, rôle et propriété
  API->>DB: Met à jour produit
  DB-->>API: Produit enregistré
  API-->>Web: Produit actualisé
```
"""

cahier = f"""\
# Cahier des charges — ArtisanConnect
## Plateforme marketplace pour l'artisanat marocain
**Version :** 1.0 · **Date de référence :** 8 novembre 2026 · **Statut :** document de cadrage pédagogique

{ASSUMPTIONS}

## 1. Présentation générale
### 1.1 Projet, contexte et problématique
ArtisanConnect est une plateforme web qui met en relation des artisans marocains et des clients désirant découvrir et acheter des produits artisanaux. Le projet répond à la faible visibilité numérique de nombreux ateliers, à la difficulté de comparer une offre dispersée et au besoin d'un suivi structuré des demandes de commande.

Le dépôt existant contient une application nommée **Al Asel**, fondée sur Flutter et une API Express/Firebase, déjà orientée profils d'artisans, demandes et messagerie. Il ne réalise pas encore le périmètre marketplace complet décrit ici (catalogue de produits, panier, commande et stock). Le présent dossier est un cadrage cible : l'équipe doit décider avec l'encadrant si elle l'étend à l'existant ou le réalise comme module séparé.

### 1.2 Justification et objectifs
La plateforme valorise le savoir-faire local, facilite la découverte par catégorie et centralise le cycle catalogue → panier → commande. Objectifs généraux : livrer un MVP démontrable, sécurisé et responsive; pratiquer l'analyse, la conception UML, la planification et les tests.

Objectifs spécifiques : permettre au client de trouver un produit; permettre à l'artisan de gérer un catalogue et son stock; donner à l'administrateur les outils de modération; conserver une trace fiable des commandes.

### 1.3 Public cible et périmètre
Public cible : clients particuliers, artisans/ateliers marocains et administrateur de plateforme. Le MVP couvre l'authentification, le catalogue, la recherche, le panier, les commandes, le stock et l'administration. Hors périmètre : paiement réel, calcul automatique de livraison, multi-vendeurs dans une même commande, application native, traduction complète et intégration ERP.

## 2. Étude des besoins
### 2.1 Acteurs
| Acteur | Finalité | Droits principaux |
|---|---|---|
| Visiteur | Découvrir l'offre | consulter catalogue public |
| Client | Acheter et suivre ses demandes | compte, panier, commandes |
| Artisan | Vendre ses créations | profil, produits, stocks, commandes reçues |
| Administrateur | Garantir la qualité de la place de marché | modération, catégories, supervision |

### 2.2 Besoins fonctionnels
Le système doit gérer l'inscription/connexion et les rôles; exposer un catalogue public avec catégories, recherche et filtres; afficher une fiche produit; conserver un panier par client; créer une commande; afficher les historiques; permettre à l'artisan de gérer profil, produits, stock et statuts de commande; permettre à l'administrateur de modérer utilisateurs, artisans, produits, catégories et commandes.

### 2.3 Besoins non fonctionnels
| Domaine | Exigence mesurable pour le MVP |
|---|---|
| Sécurité | mots de passe hachés (Argon2/bcrypt), TLS en production, contrôle d'accès par rôle, validation serveur |
| Performance | pages catalogue perçues en moins de 3 s sur connexion normale; pagination côté serveur |
| Ergonomie | parcours d'achat en 3 étapes maximum après panier; messages d'erreur explicites |
| Disponibilité | objectif pédagogique : service déployable et récupération d'erreurs; pas de SLA contractuel |
| Maintenabilité | API versionnée, composants réutilisables, linting, README et tests automatisés |
| Responsive | fonctionnement de 360 px à bureau; tests Chrome/Firefox récents |
| Données | minimisation, consentement/notice, aucune donnée bancaire stockée |

### 2.4 Contraintes, hypothèses et limites
Stack recommandée : React/Vite + Node.js/Express + PostgreSQL/Prisma ou adaptation prudente de l'API Express/Firebase existante. Git/GitHub, Trello et Mermaid sont obligatoires pour le suivi pédagogique. L'équipe ne doit pas affirmer la conformité légale ou la mise en production sans validation humaine.

## 3. Spécifications fonctionnelles
### 3.1 Client
| ID | Fonction | Description et acceptation |
|---|---|---|
| F-CLI-01 | Inscription/connexion | créer un compte, se connecter/se déconnecter; champs invalides et identifiants erronés sont traités |
| F-CLI-02 | Catalogue | consulter une liste paginée de produits actifs avec image, prix, artisan et catégorie |
| F-CLI-03 | Recherche/filtres | rechercher par texte et filtrer au minimum par catégorie, ville et fourchette de prix; combinaison conservée dans l'URL |
| F-CLI-04 | Fiche produit | consulter description, images, stock disponible, prix et artisan |
| F-CLI-05 | Panier | ajouter, modifier quantité, supprimer; total recalculé côté serveur |
| F-CLI-06 | Commande | confirmer une commande mono-artisan, recevoir référence et statut initial `en_attente` |
| F-CLI-07 | Historique | voir uniquement ses commandes et leur détail |

### 3.2 Artisan
| ID | Fonction | Description et acceptation |
|---|---|---|
| F-ART-01 | Compte/profil | renseigner atelier, description, ville, téléphone et photo facultative |
| F-ART-02 | Produits | créer, modifier, activer/désactiver ou supprimer ses produits; aucun accès aux produits d'autrui |
| F-ART-03 | Stocks | saisir un entier positif; produit indisponible si stock zéro |
| F-ART-04 | Commandes | consulter les commandes de ses produits et faire évoluer `en_attente → acceptee/refusee → preparee → terminee` |

### 3.3 Administrateur
| ID | Fonction | Description et acceptation |
|---|---|---|
| F-ADM-01 | Utilisateurs/artisans | lister, rechercher, activer/suspendre et valider un artisan |
| F-ADM-02 | Produits | consulter, masquer/restaurer un produit non conforme avec motif |
| F-ADM-03 | Commandes | consulter les commandes et leurs statuts sans modifier le contenu métier |
| F-ADM-04 | Catégories | créer, renommer, ordonner ou désactiver une catégorie non utilisée |

## 4. Spécifications non fonctionnelles détaillées
Le serveur est l'autorité pour le prix, le stock et les autorisations. Chaque endpoint protégé vérifie le jeton, le rôle et, pour une ressource artisan, la propriété. Les entrées sont validées, les requêtes sensibles journalisées sans mots de passe, les erreurs ne révèlent pas de détails internes. Les images reçoivent une limite de type/taille et un nom non prédictible. Les migrations, variables d'environnement et sauvegardes sont documentées.

## 5. Règles métier
1. Un compte a exactement un rôle actif : client, artisan ou administrateur; seul l'administrateur attribue le dernier rôle.
2. Un produit est publié par un seul artisan vérifié; titre, catégorie, prix strictement positif et stock entier ≥ 0 sont requis.
3. Un panier ne contient que des produits actifs et disponibles. Pour le MVP, il ne peut contenir que les produits d'un seul artisan; ajouter un autre artisan invite à vider ou terminer le panier.
4. Le prix et le stock sont revérifiés lors de la commande. La création est transactionnelle : commande et lignes sont créées, le stock est décrémenté, sinon aucune modification n'est conservée.
5. Une commande appartient à un client et un artisan; elle ne peut jamais être supprimée. Les changements de statut sont autorisés uniquement suivant le flux défini en F-ART-04.
6. Le client ne peut pas voir les commandes d'un autre client; l'artisan ne voit que les siennes; l'administrateur voit tout.
7. Un produit déjà présent dans une commande est archivé/désactivé, jamais effacé physiquement, afin de préserver l'historique.

## 6. Modélisation UML
### 6.1 Cas d'utilisation
{use_case}
### 6.2 Diagramme de classes
{classes}
### 6.3 Diagrammes de séquence
{sequences}

## 7. Architecture proposée
Architecture web trois couches : un front-end React responsive communique en HTTPS avec une API REST `/api/v1`; l'API Express applique authentification, validation et règles métier; PostgreSQL conserve les données relationnelles et un stockage objet conserve les médias. Cette architecture reste réalisable par des étudiants, teste les services sans navigateur et évite de placer des secrets dans le front-end.

```mermaid
flowchart LR
  B[Navigateur React/Vite] -->|HTTPS / JSON| A[API Express]
  A --> AU[Service Auth / RBAC]
  A --> CA[Service Catalogue]
  A --> CO[Service Commandes]
  AU --> DB[(PostgreSQL)]
  CA --> DB
  CO --> DB
  CA --> ST[Stockage images]
```

## 8. Planning prévisionnel
Le planning de huit semaines, les dépendances et les jalons sont détaillés dans `../02_Gestion_de_projet/02_Diagramme_Gantt.mmd` et `../02_Gestion_de_projet/03_Diagramme_PERT.md`. Les documents, la préparation de soutenance et certaines maquettes sont parallélisables; intégration et recette restent séquentielles après les noyaux front-end/back-end.

## 9. Critères de validation globaux
- Les scénarios F-CLI-01 à F-CLI-07, F-ART-01 à F-ART-04 et F-ADM-01 à F-ADM-04 sont démontrés avec données de test.
- Les permissions interdites retournent une réponse contrôlée et ne modifient aucune donnée.
- Une commande refuse une quantité supérieure au stock et conserve le prix validé au moment de la création.
- Le catalogue fonctionne sur mobile et bureau; les erreurs et états vides sont traités.
- Les tests automatisés essentiels passent, le README permet une installation reproductible et la recette signée est archivée.

## 10. Conclusion et perspectives
Le MVP privilégie un parcours fiable plutôt qu'une large couverture fonctionnelle. Après validation, les évolutions possibles sont paiement sécurisé via prestataire, livraison, avis vérifiés, messagerie, multi-vendeur, langues arabe/français et tableau de bord analytique.
"""

gantt = """\
gantt
    title ArtisanConnect — planning prévisionnel (8 semaines, 9 nov. 2026 → 3 janv. 2027)
    dateFormat  YYYY-MM-DD
    axisFormat  %d/%m
    excludes    weekends
    section Phase 1 — Analyse
    A Cadrage et kickoff                         :crit, a1, 2026-11-09, 2d
    B Entretiens, besoins et personas            :crit, a2, after a1, 4d
    C Cahier des charges et validation            :crit, a3, after a2, 3d
    Jalon : besoins validés                       :milestone, m1, after a3, 0d
    section Phase 2 — Planification
    D Backlog, estimations et risques             :crit, a4, after a3, 2d
    section Phase 3 — UML / architecture
    E Modèle de données et UML                    :crit, a5, after a4, 5d
    F Architecture, API et environnement          :crit, a6, after a5, 3d
    section Phase 4 — UI/UX
    G Wireframes et design system                 :g1, after a3, 4d
    section Phase 5 — Backend
    H Authentification, catalogue, stock, commandes :crit, h1, after a6, 8d
    section Phase 6 — Frontend
    I Parcours client, artisan et admin           :i1, after g1, 8d
    section Phase 7 — Intégration
    J Intégration API, responsive et données démo :crit, j1, after h1, 4d
    Jalon : MVP intégré                           :milestone, m2, after j1, 0d
    section Phase 8 — Tests
    K Tests unitaires, intégration et recette     :crit, k1, after j1, 4d
    section Phase 9 — Documentation
    L Documentation technique et utilisateur      :crit, l1, after k1, 3d
    section Phase 10 — Livraison
    M Soutenance, démonstration et livraison      :crit, m3, after l1, 2d
    Jalon : livraison                             :milestone, m4, after m3, 0d
"""

pert = """\
# Diagramme PERT — ArtisanConnect
## Données de calcul
Calendrier : 5 jours ouvrés/semaine, démarrage le 09/11/2026. Les durées sont des estimations pédagogiques, pas des charges constatées. Les activités critiques sont **A → B → C → D → E → F → H → J → K → L → M**, pour une durée totale de **40 jours ouvrés**, soit huit semaines.

```mermaid
flowchart LR
  A["A Cadrage<br/>2j"] --> B["B Besoins<br/>4j"] --> C["C Cahier<br/>3j"] --> D["D Planification<br/>2j"] --> E["E UML / données<br/>5j"] --> F["F Architecture<br/>3j"] --> H["H Backend<br/>8j"] --> J["J Intégration<br/>4j"] --> K["K Tests<br/>5j"] --> L["L Documentation<br/>3j"] --> M["M Livraison<br/>2j"]
  C --> G["G UI/UX<br/>4j"] --> I["I Frontend<br/>8j"] --> J
  classDef critical fill:#a6403a,color:#fff,stroke:#6d211d,stroke-width:3px;
  class A,B,C,D,E,F,H,J,K,L,M critical;
```

| Act. | Activité | Durée | Prédécesseur | ES | EF | LS | LF | Marge |
|---|---|---:|---|---:|---:|---:|---:|---:|
| A | Cadrage et kickoff | 2 | — | 0 | 2 | 0 | 2 | 0 |
| B | Besoins/personas | 4 | A | 2 | 6 | 2 | 6 | 0 |
| C | Cahier des charges | 3 | B | 6 | 9 | 6 | 9 | 0 |
| D | Backlog/planification | 2 | C | 9 | 11 | 9 | 11 | 0 |
| E | UML et modèle de données | 5 | D | 11 | 16 | 11 | 16 | 0 |
| F | Architecture/API/environnement | 3 | E | 16 | 19 | 16 | 19 | 0 |
| G | Wireframes/design system | 4 | C | 9 | 13 | 15 | 19 | 6 |
| H | Noyau back-end | 8 | F | 19 | 27 | 19 | 27 | 0 |
| I | Parcours front-end | 8 | G | 13 | 21 | 19 | 27 | 6 |
| J | Intégration | 4 | H, I | 27 | 31 | 27 | 31 | 0 |
| K | Tests et recette | 4 | J | 31 | 35 | 31 | 35 | 0 |
| L | Documentation | 3 | K | 35 | 38 | 35 | 38 | 0 |
| M | Livraison/soutenance | 2 | L | 38 | 40 | 38 | 40 | 0 |

### Vérification mathématique
Passage avant : `EF = ES + durée`; ainsi EF(M) = 38 + 2 = **40**. Passage arrière depuis LF(M)=40 : `LS = LF − durée`; pour chaque prédécesseur, `LF = min(LS des successeurs)`. La marge `LS − ES` est nulle pour A, B, C, D, E, F, H, J, K, L et M : leur chaîne est donc critique. G et I ont chacun 6 jours de marge; tout retard au-delà de cette marge retarde J et la livraison.
"""

report = f"""\
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
"""

guide = f"""\
# Guide étudiants — ArtisanConnect
## Bien démarrer le projet de Génie Logiciel

Bienvenue. ArtisanConnect est une marketplace web : les artisans marocains publient des produits et les clients les découvrent, les placent dans un panier puis créent une commande. L'objectif du module n'est pas seulement de coder : vous devez expliquer le besoin, planifier, concevoir, tester et démontrer votre solution.

{ASSUMPTIONS}

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
"""

readme = """\
# ArtisanConnect — Dossier de projet
Ce dossier pédagogique accompagne un projet de Génie Logiciel sur une marketplace de produits artisanaux marocains.

## Ordre de lecture recommandé
1. `01_Cahier_des_charges/01_Cahier_des_charges_ArtisanConnect.md` — besoin, périmètre, règles métier, UML et architecture.
2. `07_Trello_Import/Guide_import_Trello.md` puis `Trello_ArtisanConnect.csv` — organisation opérationnelle.
3. `02_Gestion_de_projet/02_Diagramme_Gantt.mmd` et `03_Diagramme_PERT.md` — calendrier, dépendances et chemin critique.
4. `04_Rapport/04_Rapport_ArtisanConnect.md` — trame académique à compléter après réalisation.
5. `05_Presentation/05_Presentation_ArtisanConnect.pptx` — support de soutenance.
6. `06_Guide_etudiants/06_Guide_etudiants_ArtisanConnect.md` — guide de démarrage.

## Important
Le dépôt comprend déjà une application « Al Asel » (Flutter/Express) orientée profils, demandes et messagerie. Les documents définissent la cible **ArtisanConnect**, qui ajoute le modèle marketplace (produits, panier, commandes, stock). Ils ne prétendent pas que ce périmètre est déjà implémenté.

Les versions PDF/DOCX/PPTX sont des exports de travail; les sources Markdown/Mermaid restent la référence modifiable.
"""

trello_tasks = [
("Phase 1 : Analyse et cahier des charges", "Cadrer le projet et identifier les parties prenantes", "Chef de projet", "Haute", "2 j", "Aucune", ["Réunir le groupe", "Identifier client/artisan/admin", "Valider le problème"], "Objectifs, périmètre et acteurs validés."),
("Phase 1 : Analyse et cahier des charges", "Recueillir et prioriser les besoins", "Analyste", "Haute", "4 j", "Cadrage", ["Rédiger personas", "Lister besoins", "Classer MVP/hors périmètre"], "Backlog de besoins relu par l'équipe."),
("Phase 1 : Analyse et cahier des charges", "Rédiger et faire valider le cahier des charges", "Chef de projet", "Haute", "3 j", "Besoins", ["Fonctionnel", "Non fonctionnel", "Règles métier", "Critères d'acceptation"], "Document versionné et validé par encadrant."),
("Phase 2 : Planification du projet", "Construire le backlog produit", "Product Owner fictif", "Haute", "1 j", "Cahier des charges", ["Créer user stories", "Ajouter priorités", "Ajouter critères"], "Toutes les fonctions MVP ont une carte."),
("Phase 2 : Planification du projet", "Estimer les tâches et analyser les risques", "Chef de projet", "Haute", "1 j", "Backlog", ["Estimer durées", "Lister risques", "Prévoir réponses"], "Estimations et risques visibles."),
("Phase 2 : Planification du projet", "Préparer Gantt, PERT et jalons", "Chef de projet", "Haute", "1 j", "Estimations", ["Définir dépendances", "Calculer chemin critique", "Faire relire"], "Gantt et PERT cohérents."),
("Phase 3 : Conception UML", "Modéliser les cas d'utilisation", "Analyste", "Haute", "2 j", "Cahier des charges", ["Acteurs", "Cas client", "Cas artisan/admin"], "Tous les besoins MVP sont couverts."),
("Phase 3 : Conception UML", "Concevoir le diagramme de classes et données", "Back-end", "Haute", "3 j", "Cas d'utilisation", ["Entités", "Relations", "Contraintes"], "Modèle cohérent avec panier/commande/stock."),
("Phase 3 : Conception UML", "Décrire les séquences critiques", "Analyste", "Moyenne", "2 j", "Diagramme de classes", ["Commande", "Mise à jour produit", "Erreurs"], "Flux et responsabilités clairs."),
("Phase 3 : Conception UML", "Définir contrat API et architecture", "Back-end", "Haute", "3 j", "Classes", ["Endpoints", "RBAC", "Erreurs", "Variables env"], "Contrat relu par front-end."),
("Phase 4 : Conception UI/UX", "Créer personas et parcours utilisateur", "UX/UI", "Moyenne", "1 j", "Besoins", ["Parcours client", "Parcours artisan", "Parcours admin"], "Parcours sans ambiguïté."),
("Phase 4 : Conception UI/UX", "Produire wireframes responsive", "UX/UI", "Haute", "3 j", "Parcours", ["Catalogue", "Fiche", "Panier", "Dashboards"], "Maquettes mobile et desktop validées."),
("Phase 4 : Conception UI/UX", "Établir le design system", "UX/UI", "Moyenne", "1 j", "Wireframes", ["Couleurs", "Typo", "Composants", "Accessibilité"], "Composants réutilisables définis."),
("Phase 5 : Développement Backend", "Initialiser backend, base de données et CI", "Back-end", "Haute", "2 j", "Architecture", ["Configuration", "Schéma/migrations", "Variables env", "Healthcheck"], "Installation reproductible."),
("Phase 5 : Développement Backend", "Implémenter authentification et RBAC", "Back-end", "Haute", "3 j", "Initialisation", ["Register/login", "Hash", "JWT/session", "Middleware rôles"], "Routes protégées et tests d'accès."),
("Phase 5 : Développement Backend", "Implémenter catégories et catalogue produits", "Back-end", "Haute", "3 j", "RBAC", ["CRUD artisan", "Lecture publique", "Recherche/filtres", "Pagination"], "Catalogue conforme au contrat."),
("Phase 5 : Développement Backend", "Implémenter stock, panier et commande", "Back-end", "Haute", "4 j", "Catalogue", ["Panier", "Transaction stock", "Lignes commande", "Statuts"], "Survente et accès non autorisés refusés."),
("Phase 5 : Développement Backend", "Implémenter administration et modération", "Back-end", "Moyenne", "2 j", "RBAC, catalogue", ["Utilisateurs", "Artisans", "Produits", "Catégories"], "Accès admin vérifié."),
("Phase 6 : Développement Frontend", "Initialiser front-end et navigation", "Front-end", "Haute", "2 j", "Wireframes, architecture", ["Routes", "Layout", "Client API", "Gestion erreurs"], "Navigation de base fonctionnelle."),
("Phase 6 : Développement Frontend", "Développer authentification et catalogue", "Front-end", "Haute", "3 j", "Navigation, API auth/catalogue", ["Formulaires", "Liste", "Filtres", "Fiche"], "Parcours visiteur/client démontrable."),
("Phase 6 : Développement Frontend", "Développer panier et suivi de commande", "Front-end", "Haute", "3 j", "API commande", ["Panier", "Validation", "Historique", "États vides"], "Commande visible dans historique."),
("Phase 6 : Développement Frontend", "Développer tableaux artisan et admin", "Front-end", "Moyenne", "3 j", "APIs artisan/admin", ["Produits", "Stock", "Commandes", "Modération"], "Droits et écrans cohérents."),
("Phase 6 : Développement Frontend", "Rendre les écrans responsive et accessibles", "Front-end", "Haute", "2 j", "Écrans principaux", ["360px", "Desktop", "Focus", "Contrastes"], "Recette responsive sans blocage."),
("Phase 7 : Intégration", "Intégrer front-end, API et données de démonstration", "Intégrateur", "Haute", "3 j", "Noyaux front/backend", ["Connecter endpoints", "Seeder", "Erreurs", "Images"], "Parcours bout en bout fonctionnel."),
("Phase 7 : Intégration", "Préparer déploiement de démonstration", "DevOps/Intégrateur", "Moyenne", "1 j", "Intégration", ["Variables env", "Build", "URL", "Journalisation"], "Build reproductible; déploiement à valider."),
("Phase 8 : Tests", "Écrire tests unitaires des règles métier", "QA + Back-end", "Haute", "2 j", "Backend", ["Totaux", "Stock", "Statuts", "RBAC"], "Tests essentiels verts."),
("Phase 8 : Tests", "Exécuter tests d'intégration API", "QA + Back-end", "Haute", "2 j", "Tests unitaires, intégration", ["Auth", "Commande", "Isolation", "Erreurs"], "Rapport de tests conservé."),
("Phase 8 : Tests", "Réaliser recette fonctionnelle et responsive", "QA + équipe", "Haute", "2 j", "Front-end intégré", ["Scénarios", "Navigateurs", "Mobile", "Anomalies"], "PV de recette complété."),
("Phase 8 : Tests", "Corriger anomalies bloquantes", "Équipe", "Haute", "2 j", "Recette", ["Trier", "Corriger", "Rejouer", "Fermer"], "Aucun défaut bloquant ouvert."),
("Phase 9 : Documentation", "Rédiger documentation technique et README", "Back-end + Front-end", "Haute", "2 j", "Intégration", ["Installation", "API", "Architecture", "Données"], "Un pair installe avec le guide."),
("Phase 9 : Documentation", "Finaliser rapport, UML et preuves", "Chef de projet", "Haute", "2 j", "Tests", ["Résultats réels", "Captures", "Annexes", "Relecture"], "Aucune affirmation non prouvée."),
("Phase 10 : Présentation et livraison", "Préparer slides et démonstration", "Équipe", "Haute", "1 j", "Documentation", ["Slides", "Script démo", "Plan B", "Chronométrage"], "Présentation lisible et répétée."),
("Phase 10 : Présentation et livraison", "Répéter et livrer les livrables", "Chef de projet + équipe", "Haute", "1 j", "Slides", ["Répartition parole", "Vérifier liens", "Exporter", "Déposer"], "Livrables complets déposés."),
]

def write(path: Path, content: str):
    path.write_text(content.rstrip() + "\n", encoding="utf-8")

write(CDC / "01_Cahier_des_charges_ArtisanConnect.md", cahier)
write(PROJECT / "02_Diagramme_Gantt.mmd", gantt)
write(PROJECT / "03_Diagramme_PERT.md", pert)
write(REPORT / "04_Rapport_ArtisanConnect.md", report)
write(GUIDE / "06_Guide_etudiants_ArtisanConnect.md", guide)
write(ROOT / "README.md", readme)
write(UML / "Diagrammes_UML_ArtisanConnect.md", "# Diagrammes UML — ArtisanConnect\n\nLes diagrammes de cas d'utilisation, classes et séquences sont inclus dans le cahier des charges afin de garder les règles métier et leur représentation synchronisées.\n\n" + use_case + "\n" + classes + "\n" + sequences)

# Raster companion of the Mermaid Gantt for viewers that do not render Mermaid.
img = Image.new("RGB", (1800, 900), "#f8f5ef")
draw = ImageDraw.Draw(img)
font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 15)
bold = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 28)
draw.text((55, 35), "ArtisanConnect — Gantt prévisionnel (8 semaines)", fill="#142c41", font=bold)
left, top, width = 520, 115, 1180
for week in range(8):
    x = left + week * width // 8
    draw.rectangle((x, top, x + width // 8, 840), outline="#c7c1b7", width=1)
    draw.text((x + 8, 85), f"S{week + 1}", fill="#0c7b7d", font=font)
items = [
    ("Cadrage / besoins / cahier", 0, 2, "#a6403a"), ("Backlog et planification", 2, 1, "#a6403a"),
    ("UML et modèle de données", 2, 1, "#a6403a"), ("Architecture / API", 3, 1, "#a6403a"),
    ("Wireframes / design system", 2, 1, "#0c7b7d"), ("Backend MVP", 4, 2, "#a6403a"),
    ("Frontend MVP", 4, 2, "#0c7b7d"), ("Intégration", 6, 1, "#a6403a"),
    ("Tests / recette", 7, 1, "#a6403a"), ("Documentation / soutenance", 7, 1, "#a6403a"),
]
for index, (label, week, span, color) in enumerate(items):
    y = 135 + index * 68
    draw.text((55, y + 14), label, fill="#142c41", font=small)
    x1 = left + week * width // 8 + 5
    x2 = left + (week + span) * width // 8 - 5
    draw.rounded_rectangle((x1, y, x2, y + 42), radius=9, fill=color)
draw.text((55, 855), "Rouge : chemin critique · Bleu-vert : activités parallélisables · Source : 02_Diagramme_Gantt.mmd", fill="#142c41", font=small)
img.save(PROJECT / "02_Diagramme_Gantt.png")

with (TRELLO / "Trello_ArtisanConnect.csv").open("w", newline="", encoding="utf-8-sig") as f:
    fields = ["List", "Name", "Description", "Labels", "Members", "Checklist", "Due"]
    writer = csv.DictWriter(f, fieldnames=fields)
    writer.writeheader()
    for phase, name, owner, priority, duration, deps, checks, acceptance in trello_tasks:
        desc = f"""Phase : {phase}\nResponsable/rôle : {owner}\nPriorité : {priority}\nEstimation : {duration}\nDépendances : {deps}\n\nCritères d'acceptation :\n{acceptance}"""
        writer.writerow({"List": "Product Backlog", "Name": name, "Description": desc,
                         "Labels": phase, "Members": owner, "Checklist": " | ".join(checks), "Due": ""})

trello_guide = """\
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
"""
write(TRELLO / "Guide_import_Trello.md", trello_guide)

# Export DOCX for the report.
doc = Document()
section = doc.sections[0]
section.top_margin = Inches(0.75)
section.bottom_margin = Inches(0.75)
styles = doc.styles
styles["Normal"].font.name = "Aptos"
styles["Normal"].font.size = Pt(10.5)
for raw in report.splitlines():
    if raw.startswith("# "):
        doc.add_heading(raw[2:], 0)
    elif raw.startswith("## "):
        doc.add_heading(raw[3:], 1)
    elif raw.startswith("### "):
        doc.add_heading(raw[4:], 2)
    elif raw.startswith("- "):
        doc.add_paragraph(raw[2:], style="List Bullet")
    elif raw.startswith("> "):
        p = doc.add_paragraph(raw[2:])
        p.style = doc.styles["Quote"]
    elif raw.strip():
        doc.add_paragraph(raw)
doc.save(REPORT / "04_Rapport_ArtisanConnect.docx")

# Simple PDF export for the cahier (text-focused; Mermaid remains available in Markdown).
pdf_styles = getSampleStyleSheet()
story = []
for raw in cahier.splitlines():
    if raw.startswith("# "):
        story.append(Paragraph(raw[2:], pdf_styles["Title"]))
        story.append(Spacer(1, 0.3 * cm))
    elif raw.startswith("## "):
        story.append(Paragraph(raw[3:], pdf_styles["Heading2"]))
    elif raw.startswith("### "):
        story.append(Paragraph(raw[4:], pdf_styles["Heading3"]))
    elif raw.startswith("```"):
        continue
    elif raw.strip() and not raw.startswith("|") and not raw.startswith(">"):
        safe = raw.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        story.append(Paragraph(safe, pdf_styles["BodyText"]))
        story.append(Spacer(1, 0.12 * cm))
SimpleDocTemplate(str(CDC / "01_Cahier_des_charges_ArtisanConnect.pdf"), pagesize=A4,
                  leftMargin=1.5*cm, rightMargin=1.5*cm, topMargin=1.5*cm, bottomMargin=1.5*cm).build(story)

# Presentation
prs = Presentation()
prs.slide_width = PInches(13.333)
prs.slide_height = PInches(7.5)
NAVY, TEAL, SAND, WHITE, ORANGE = (RGBColor(20, 44, 65), RGBColor(12, 123, 125),
                                    RGBColor(243, 234, 217), RGBColor(255, 255, 255), RGBColor(220, 125, 47))
def add_slide(title, subtitle="", bullets=None):
    slide = prs.slides.add_slide(prs.slide_layouts[6])
    bg = slide.background.fill
    bg.solid(); bg.fore_color.rgb = SAND
    bar = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, prs.slide_width, PInches(.22))
    bar.fill.solid(); bar.fill.fore_color.rgb = TEAL; bar.line.fill.background()
    box = slide.shapes.add_textbox(PInches(.8), PInches(.65), PInches(11.8), PInches(1))
    p = box.text_frame.paragraphs[0]; p.text = title; p.font.size = PPt(30); p.font.bold = True; p.font.color.rgb = NAVY
    if subtitle:
        p = box.text_frame.add_paragraph(); p.text = subtitle; p.font.size = PPt(14); p.font.color.rgb = TEAL
    if bullets:
        body = slide.shapes.add_textbox(PInches(1.05), PInches(2.0), PInches(11.2), PInches(4.6))
        tf = body.text_frame; tf.word_wrap = True
        for i, bullet in enumerate(bullets):
            p = tf.paragraphs[0] if i == 0 else tf.add_paragraph()
            p.text = bullet; p.font.size = PPt(21); p.font.color.rgb = NAVY; p.space_after = PPt(16)
    return slide

slide = add_slide("ArtisanConnect", "Projet de Génie Logiciel — marketplace de l'artisanat marocain")
shape = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, PInches(1), PInches(3), PInches(11.3), PInches(1.6))
shape.fill.solid(); shape.fill.fore_color.rgb = TEAL; shape.line.fill.background()
p = shape.text_frame.paragraphs[0]; p.text = "De la découverte d’un produit à une commande traçable"; p.font.size = PPt(28); p.font.bold = True; p.font.color.rgb = WHITE; p.alignment = PP_ALIGN.CENTER
add_slide("Le contexte", "Une visibilité numérique fragmentée", ["Offre artisanale dispersée", "Découverte et comparaison difficiles", "Gestion des produits et demandes peu centralisée"])
add_slide("Problématique", "Comment créer un parcours simple et fiable ?", ["Rendre les produits découvrables", "Permettre un cycle panier → commande", "Laisser l’artisan maître de son catalogue et de son stock"])
add_slide("Objectifs", "Un MVP cohérent et démontrable", ["Catalogue, recherche et filtres", "Panier et commande mono-artisan", "Espaces client, artisan et administrateur", "Sécurité, responsive et traçabilité"])
add_slide("Solution proposée", "Une plateforme web en trois espaces", ["Client : découvrir, acheter, suivre", "Artisan : publier, stocker, traiter", "Administrateur : modérer et superviser"])
add_slide("Acteurs", "Responsabilités distinctes", ["Visiteur : consultation publique", "Client : panier et historique", "Artisan : produits, stocks, commandes", "Administrateur : utilisateurs, catégories, modération"])
add_slide("Fonctionnalités principales", "Le périmètre MVP", ["Authentification et rôles", "Catalogue / recherche / fiche produit", "Panier et commande transactionnelle", "Tableaux de bord artisan et administration"])
add_slide("Architecture", "Web + API REST + données", ["React/Vite responsive", "Express : validation, RBAC, règles métier", "PostgreSQL : données relationnelles et transactions", "Stockage objet : images"])
add_slide("Cas d'utilisation", "Parcours clés", ["Client : consulter → panier → commande", "Artisan : gérer produit → stock → commande", "Admin : modérer utilisateurs, produits, catégories"])
add_slide("Planning Gantt", "8 semaines à partir du 9 novembre 2026", ["S1 : analyse et cadrage", "S2–S3 : planification, UML, architecture, UX", "S4–S6 : développement et intégration", "S7–S8 : tests, documentation, soutenance"])
add_slide("PERT et chemin critique", "40 jours ouvrés", ["A → B → C → D → E → F → H → J → K → L → M", "UI/UX et front-end sont parallélisables", "Marge de 6 jours sur la branche UX/front-end"])
add_slide("Maquettes UI/UX", "À insérer après conception", ["[PLACEHOLDER] Écran catalogue", "[PLACEHOLDER] Fiche produit et panier", "[PLACEHOLDER] Tableau de bord artisan", "Utiliser des captures réelles, jamais des résultats inventés"])
add_slide("Technologies proposées", "À valider avant implémentation", ["React + Vite", "Node.js + Express", "PostgreSQL + Prisma", "GitHub, Trello, Mermaid, tests automatisés"])
add_slide("Démonstration attendue", "Un parcours de bout en bout", ["Client crée un compte et recherche", "Ajoute un produit disponible au panier", "Confirme la commande", "Artisan la consulte et met à jour son statut"])
add_slide("Conclusion et perspectives", "Priorité : un MVP fiable", ["Réussite : cohérence produit-stock-commande", "Ensuite : paiement, livraison, avis, messagerie, multilingue", "Questions / validation du périmètre"])
prs.save(PRESENTATION / "05_Presentation_ArtisanConnect.pptx")

print(f"Dossier généré : {ROOT}")
