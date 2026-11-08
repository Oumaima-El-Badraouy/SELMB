# Guide et gabarit PERT — ArtisanConnect
> Ce document ne contient volontairement **ni durées, ni chemin critique, ni calcul déjà réalisé**. L'équipe doit les produire à partir du backlog et faire valider ses hypothèses.

## 1. Ce qu'il faut préparer
1. Reprendre les tâches principales du backlog Trello, sans forcément recopier chaque sous-tâche.
2. Donner un identifiant court à chaque activité (A, B, C…).
3. Estimer les durées en jours ouvrés avec l'équipe.
4. Noter les prédécesseurs indispensables : ceux qui bloquent vraiment le démarrage.
5. Faire le passage avant, puis le passage arrière. Une marge nulle indique une activité critique.

## 2. Calculs à appliquer
- **Passage avant** : `ES = max(EF des prédécesseurs)`; `EF = ES + durée`. Sans prédécesseur, `ES = 0`.
- **Durée du projet** : maximum des `EF` des activités finales.
- **Passage arrière** : activité finale : `LF = durée totale`, `LS = LF − durée`. Sinon : `LF = min(LS des successeurs)`.
- **Marge totale** : `LS − ES` (ou `LF − EF`). Marge égale à zéro = activité du chemin critique.

## 3. Tableau de calcul à compléter
| Act. | Activité | Durée | Prédécesseur(s) | ES | EF | LS | LF | Marge |
|---|---|---:|---|---:|---:|---:|---:|---:|
| A | [ex. cadrage — à préciser] | [ ] | — | [ ] | [ ] | [ ] | [ ] | [ ] |
| B | [à compléter] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| C | [à compléter] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| … | [ajouter toutes les activités retenues] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

## 4. Gabarit Mermaid
Remplacez les crochets par vos activités et ajoutez/supprimez les nœuds. N'appliquez le style `critical` qu'après les calculs.
```mermaid
flowchart LR
  A["A — [activité]<br/>[durée]"] --> B["B — [activité]<br/>[durée]"]
  B --> C["C — [activité]<br/>[durée]"]
  %% Ajoutez les branches parallèles et convergences réelles.
  %% classDef critical fill:#a6403a,color:#fff;
  %% class [identifiants à marge nulle] critical;
```

## 5. Contrôle avant remise
- Les tâches du Gantt et les activités PERT désignent les mêmes livrables.
- Toute activité, sauf la première, a un prédécesseur justifié.
- Les convergences utilisent un maximum au passage avant et un minimum au passage arrière.
- La durée finale PERT est cohérente avec le Gantt de huit semaines.
- Le chemin critique est démontré par les marges, jamais choisi intuitivement.
