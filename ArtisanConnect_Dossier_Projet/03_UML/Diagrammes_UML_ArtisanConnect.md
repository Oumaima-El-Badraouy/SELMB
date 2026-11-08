# Diagrammes UML — ArtisanConnect

Les diagrammes de cas d'utilisation, classes et séquences sont inclus dans le cahier des charges afin de garder les règles métier et leur représentation synchronisées.

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
