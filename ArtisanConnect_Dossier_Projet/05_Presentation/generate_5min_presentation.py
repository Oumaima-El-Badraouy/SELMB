"""Generate the five-minute ArtisanConnect academic presentation.

Run from the repository root:
    python3 ArtisanConnect_Dossier_Projet/05_Presentation/generate_5min_presentation.py
"""
from __future__ import annotations

from pathlib import Path

from PIL import Image
from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Inches, Pt

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
CAPTURES = ROOT / "captures"
CAPTURES.mkdir(exist_ok=True)

SOURCE_CAPTURES = {
    "01-landing.png": Path("/opt/cursor/artifacts/01-al-asel-landing-page.png"),
    "02-client-registration.png": Path("/opt/cursor/artifacts/02-client-registration-form.png"),
    "03-artisan-registration.png": Path("/opt/cursor/artifacts/03-artisan-registration-workspace.png"),
}
for target_name, source in SOURCE_CAPTURES.items():
    if not source.exists():
        raise FileNotFoundError(f"Capture required not found: {source}")
    # Browser capture extensions are not always reliable (a WEBP can be named .png).
    # Normalize to a genuine PNG accepted by PowerPoint.
    with Image.open(source) as source_image:
        source_image.convert("RGB").save(CAPTURES / target_name, "PNG")

LANDING = CAPTURES / "01-landing.png"
CLIENT = CAPTURES / "02-client-registration.png"
ARTISAN = CAPTURES / "03-artisan-registration.png"
LOGO = REPO / "Webapp/assets/branding/logo_al_asel.png"
BACKGROUND = REPO / "Webapp/assets/branding/site-page-bg.png"

# Moroccan-inspired palette used by the running application.
NAVY = RGBColor(15, 40, 64)
TEAL = RGBColor(31, 109, 114)
GOLD = RGBColor(218, 161, 61)
TERRACOTTA = RGBColor(184, 92, 46)
CREAM = RGBColor(249, 246, 239)
INK = RGBColor(27, 43, 52)
MUTED = RGBColor(87, 103, 111)
WHITE = RGBColor(255, 255, 255)

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)


def fill_background(slide, color=CREAM):
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = color


def add_text(slide, text, x, y, w, h, size=20, color=INK, bold=False,
             align=PP_ALIGN.LEFT, font="Aptos Display", valign=MSO_ANCHOR.TOP):
    box = slide.shapes.add_textbox(Inches(x), Inches(y), Inches(w), Inches(h))
    tf = box.text_frame
    tf.clear()
    tf.word_wrap = True
    tf.vertical_anchor = valign
    p = tf.paragraphs[0]
    p.text = text
    p.alignment = align
    p.font.name = font
    p.font.size = Pt(size)
    p.font.bold = bold
    p.font.color.rgb = color
    return box


def add_rect(slide, x, y, w, h, color, radius=False, transparency=0):
    shape = slide.shapes.add_shape(
        MSO_SHAPE.ROUNDED_RECTANGLE if radius else MSO_SHAPE.RECTANGLE,
        Inches(x), Inches(y), Inches(w), Inches(h),
    )
    shape.fill.solid()
    shape.fill.fore_color.rgb = color
    shape.fill.transparency = transparency
    shape.line.fill.background()
    return shape


def add_picture_cover(slide, image_path, x, y, w, h):
    """Add an image while preserving aspect ratio and filling the requested frame."""
    image = Image.open(image_path)
    iw, ih = image.size
    image_ratio = iw / ih
    frame_ratio = w / h
    picture = slide.shapes.add_picture(str(image_path), Inches(x), Inches(y), width=Inches(w), height=Inches(h))
    if image_ratio > frame_ratio:
        visible = frame_ratio / image_ratio
        picture.crop_left = picture.crop_right = (1 - visible) / 2
    else:
        visible = image_ratio / frame_ratio
        picture.crop_top = picture.crop_bottom = (1 - visible) / 2
    return picture


def add_title(slide, number, title, subtitle=None):
    add_text(slide, f"{number:02d}", .72, .45, .55, .3, 11, GOLD, True)
    add_text(slide, title, .72, .78, 11.3, .55, 29, NAVY, True)
    if subtitle:
        add_text(slide, subtitle, .74, 1.38, 11, .35, 12, MUTED)
    add_rect(slide, .72, 1.84, 1.1, .05, GOLD)


def add_footer(slide, label="ArtisanConnect · Génie Logiciel"):
    add_text(slide, label, .72, 7.08, 6, .2, 9, MUTED)
    add_text(slide, "5 min", 11.85, 7.08, .75, .2, 9, MUTED, align=PP_ALIGN.RIGHT)


def bullet(slide, text, x, y, accent=TEAL):
    add_rect(slide, x, y + .10, .11, .11, accent, radius=True)
    add_text(slide, text, x + .23, y, 4.55, .4, 16, INK)


def add_image_card(slide, image, x, y, w, h, caption):
    add_rect(slide, x - .06, y - .06, w + .12, h + .42, WHITE, radius=True)
    add_picture_cover(slide, image, x, y, w, h)
    add_text(slide, caption, x + .14, y + h + .09, w - .28, .2, 10, MUTED, align=PP_ALIGN.CENTER)


# 01 — Cover
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_picture_cover(slide, LANDING, 0, 0, 13.333, 7.5)
add_rect(slide, 0, 0, 13.333, 7.5, NAVY, transparency=20)
add_rect(slide, .68, .65, 6.5, 5.7, NAVY, radius=True, transparency=10)
if LOGO.exists():
    slide.shapes.add_picture(str(LOGO), Inches(.98), Inches(.95), height=Inches(.78))
add_text(slide, "ArtisanConnect", 1.0, 2.12, 5.55, .65, 36, WHITE, True)
add_text(slide, "Valoriser l’artisanat marocain\npar une expérience numérique simple.", 1.03, 2.95, 5.45, 1.1, 21, WHITE)
add_rect(slide, 1.03, 4.52, 1.15, .06, GOLD)
add_text(slide, "Projet de Génie Logiciel · Présentation 5 minutes", 1.03, 4.8, 5.35, .35, 13, RGBColor(225, 231, 227))
add_text(slide, "Équipe : [à compléter]  ·  Encadrant·e : [à compléter]", 1.03, 5.34, 5.35, .35, 11, RGBColor(225, 231, 227))

# 02 — Problem
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide)
add_title(slide, 2, "Le défi", "Les artisans ont du savoir-faire; leur visibilité numérique reste fragmentée.")
for x, icon, heading, body in [
    (.78, "01", "Découvrir", "Le client ne trouve pas facilement une offre locale structurée."),
    (4.55, "02", "Comparer", "Informations, disponibilité et confiance sont dispersées."),
    (8.32, "03", "Suivre", "L’artisan manque d’un parcours simple pour gérer la demande."),
]:
    add_rect(slide, x, 2.35, 3.18, 2.75, WHITE, radius=True)
    add_rect(slide, x + .28, 2.66, .58, .42, TEAL, radius=True)
    add_text(slide, icon, x + .28, 2.73, .58, .18, 10, WHITE, True, align=PP_ALIGN.CENTER)
    add_text(slide, heading, x + .3, 3.35, 2.55, .35, 20, NAVY, True)
    add_text(slide, body, x + .3, 3.86, 2.55, .82, 13, MUTED)
add_text(slide, "Notre intention : rendre la rencontre client–artisan plus visible, plus fluide et plus traçable.", .92, 5.7, 11.35, .45, 18, NAVY, True, align=PP_ALIGN.CENTER)
add_footer(slide)

# 03 — Solution
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide, NAVY)
add_title(slide, 3, "La réponse : une plateforme qui relie", "Un parcours clair — de la découverte au suivi.",)
for idx, (title, text, color) in enumerate([
    ("1. Explorer", "Trouver un artisan ou une offre selon le besoin.", TEAL),
    ("2. Échanger", "Créer une demande et centraliser les informations.", GOLD),
    ("3. Gérer", "Donner à l’artisan un espace pour son profil et son activité.", TERRACOTTA),
]):
    x = .92 + idx * 4.14
    add_rect(slide, x, 2.42, 3.43, 2.58, color, radius=True)
    add_text(slide, title, x + .28, 2.81, 2.85, .4, 21, WHITE, True)
    add_text(slide, text, x + .28, 3.62, 2.76, .75, 14, WHITE)
    if idx < 2:
        add_text(slide, "→", x + 3.55, 3.38, .42, .35, 26, WHITE, True, align=PP_ALIGN.CENTER)
add_text(slide, "Un MVP centré sur l’utilité avant la complexité.", .9, 5.72, 11.5, .35, 18, WHITE, True, align=PP_ALIGN.CENTER)
add_footer(slide)

# 04 — Actors
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide)
add_title(slide, 4, "Trois rôles, une même plateforme", "Chaque rôle reçoit les informations et actions dont il a besoin.")
roles = [
    ("Client", "Découvrir\nCréer une demande\nSuivre l’échange", TEAL),
    ("Artisan", "Présenter son activité\nRépondre aux demandes\nMettre en valeur son savoir-faire", TERRACOTTA),
    ("Administrateur", "Superviser\nModérer\nGarantir la qualité", NAVY),
]
for i, (role, tasks, color) in enumerate(roles):
    x = .93 + i * 4.12
    add_rect(slide, x, 2.28, 3.35, 3.15, WHITE, radius=True)
    add_rect(slide, x, 2.28, 3.35, .58, color, radius=True)
    add_text(slide, role, x + .3, 3.05, 2.72, .35, 21, color, True, align=PP_ALIGN.CENTER)
    add_text(slide, tasks, x + .45, 3.75, 2.45, 1.22, 14, MUTED, align=PP_ALIGN.CENTER)
add_footer(slide)

# 05 — Real screen: landing
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide)
add_title(slide, 5, "Une identité numérique ancrée dans l’artisanat", "Capture réelle — page d’accueil de l’interface web existante.")
add_image_card(slide, LANDING, .92, 2.12, 7.23, 4.16, "Page d’accueil : identité, accès et points d’entrée")
bullet(slide, "Une identité visuelle inspirée du zellige et du tissage.", 8.65, 2.45, GOLD)
bullet(slide, "Des chemins visibles vers l’inscription et l’exploration.", 8.65, 3.34, TEAL)
bullet(slide, "Une interface responsive pensée pour faciliter la découverte.", 8.65, 4.23, TERRACOTTA)
add_footer(slide)

# 06 — Real screen: client
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide, RGBColor(239, 245, 244))
add_title(slide, 6, "Parcours client : démarrer simplement", "Capture réelle — formulaire d’inscription client.")
add_image_card(slide, CLIENT, 6.6, 2.05, 5.72, 4.35, "Inscription client")
add_text(slide, "L’idée clé", .88, 2.47, 4.3, .38, 22, NAVY, True)
bullet(slide, "Réduire les frictions au premier contact.", .9, 3.2, TEAL)
bullet(slide, "Recueillir uniquement les informations utiles.", .9, 4.12, GOLD)
bullet(slide, "Conduire ensuite vers l’exploration et la demande.", .9, 5.04, TERRACOTTA)
add_footer(slide)

# 07 — Real screen: artisan
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide)
add_title(slide, 7, "Parcours artisan : rendre le savoir-faire visible", "Capture réelle — espace d’inscription et de présentation artisan.")
add_image_card(slide, ARTISAN, .84, 2.06, 6.02, 4.32, "Création d’un profil artisan")
add_text(slide, "Ce que la plateforme valorise", 7.44, 2.45, 4.8, .38, 20, NAVY, True)
bullet(slide, "Le métier, la localisation et les informations de contact.", 7.44, 3.18, TERRACOTTA)
bullet(slide, "La présentation de l’atelier et du portfolio.", 7.44, 4.08, GOLD)
bullet(slide, "Une base pour recevoir et traiter des demandes.", 7.44, 4.98, TEAL)
add_footer(slide)

# 08 — Technology
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide, NAVY)
add_title(slide, 8, "Une architecture simple à expliquer", "Les technologies observées dans le dépôt existant.")
layers = [
    ("Interface", "Web HTML/CSS/JS\n+ application Flutter", TEAL),
    ("API", "Node.js + Express\nRoutes versionnées", GOLD),
    ("Données", "Firebase / stockage\nServices métier", TERRACOTTA),
]
for i, (heading, content, color) in enumerate(layers):
    x = .95 + i * 4.08
    add_rect(slide, x, 2.55, 3.3, 2.15, color, radius=True)
    add_text(slide, heading, x + .27, 2.93, 2.75, .35, 21, WHITE, True, align=PP_ALIGN.CENTER)
    add_text(slide, content, x + .25, 3.57, 2.8, .63, 14, WHITE, align=PP_ALIGN.CENTER)
    if i < 2:
        add_text(slide, "→", x + 3.4, 3.34, .45, .4, 25, WHITE, True, align=PP_ALIGN.CENTER)
add_text(slide, "Objectif technique : une base maintenable, testable et évolutive.", .9, 5.64, 11.45, .35, 17, WHITE, True, align=PP_ALIGN.CENTER)
add_footer(slide)

# 09 — Method / evidence
slide = prs.slides.add_slide(prs.slide_layouts[6])
fill_background(slide)
add_title(slide, 9, "Du besoin à un projet maîtrisé", "La qualité ne vient pas seulement du code.")
steps = [
    ("01", "Cadrer", "Besoin, rôles et périmètre MVP"),
    ("02", "Concevoir", "UML, parcours et architecture"),
    ("03", "Construire", "Itérations, intégration et revue"),
    ("04", "Valider", "Tests, preuves et démonstration"),
]
for i, (number, title, subtitle) in enumerate(steps):
    x = .78 + i * 3.13
    add_rect(slide, x, 2.62, 2.57, 2.32, WHITE, radius=True)
    add_text(slide, number, x + .28, 2.92, .45, .28, 13, GOLD, True)
    add_text(slide, title, x + .3, 3.47, 1.95, .35, 20, NAVY, True)
    add_text(slide, subtitle, x + .3, 4.03, 1.92, .5, 12, MUTED)
    if i < 3:
        add_text(slide, "→", x + 2.68, 3.5, .35, .35, 20, TEAL, True, align=PP_ALIGN.CENTER)
add_text(slide, "Le dossier fourni sert de guide : l’équipe construit et justifie ses propres Gantt et PERT.", .92, 5.72, 11.3, .35, 16, NAVY, True, align=PP_ALIGN.CENTER)
add_footer(slide)

# 10 — Conclusion
slide = prs.slides.add_slide(prs.slide_layouts[6])
add_picture_cover(slide, LANDING, 0, 0, 13.333, 7.5)
add_rect(slide, 0, 0, 13.333, 7.5, NAVY, transparency=14)
add_rect(slide, 1.1, 1.05, 11.13, 5.1, NAVY, radius=True, transparency=8)
add_text(slide, "ArtisanConnect", 1.48, 1.65, 4.2, .55, 31, WHITE, True)
add_text(slide, "Une plateforme qui rapproche les clients\net les artisans autour de leur savoir-faire.", 1.48, 2.55, 6.4, .92, 23, WHITE)
add_rect(slide, 1.48, 3.87, 1.05, .06, GOLD)
add_text(slide, "Prochaine étape : démontrer un parcours utilisateur de bout en bout.", 1.48, 4.32, 8.45, .35, 16, RGBColor(229, 234, 230))
add_text(slide, "Merci · Questions ?", 1.48, 5.2, 5.7, .35, 20, WHITE, True)

output = ROOT / "05_Presentation_ArtisanConnect.pptx"
prs.save(output)

speaker_script = """\
# Script oral — ArtisanConnect (5 minutes)
> Utilisez ce script comme fil conducteur, pas comme texte à lire. Les captures intégrées au support sont réelles; ne présentez pas des fonctionnalités non visibles ou non implémentées comme terminées.

| Slide | Temps | Message oral essentiel |
|---|---:|---|
| 1. Titre | 20 s | « ArtisanConnect veut faciliter la rencontre entre clients et artisans marocains en valorisant le savoir-faire local. » |
| 2. Défi | 30 s | « Le problème n’est pas l’absence de savoir-faire : c’est la dispersion de l’information, de la découverte et du suivi. » |
| 3. Solution | 30 s | « Nous proposons un parcours simple : explorer, échanger, puis permettre à l’artisan de gérer sa présence. » |
| 4. Rôles | 25 s | « Le client, l’artisan et l’administrateur n’ont pas les mêmes besoins; les rôles structurent donc la plateforme. » |
| 5. Accueil | 35 s | « Voici l’interface web réelle : son identité s’inspire de l’artisanat et les accès principaux sont immédiats. » |
| 6. Client | 35 s | « Le premier objectif est de diminuer la friction : une inscription claire avant de découvrir et demander un service. » |
| 7. Artisan | 35 s | « L’artisan renseigne son métier, sa zone et son profil pour rendre son activité compréhensible et visible. » |
| 8. Architecture | 30 s | « Le dépôt existant s’appuie sur une interface web/Flutter, une API Express et Firebase. Cette séparation aide la maintenance. » |
| 9. Méthode | 30 s | « Nous cadrons, concevons, construisons puis validons. Les Gantt et PERT sont des exercices que l’équipe justifie à partir des activités. » |
| 10. Conclusion | 20 s | « Notre priorité est un parcours utile et démontrable. La prochaine preuve attendue est une démonstration de bout en bout. » |

**Total : 290 secondes (4 min 50 s).** Gardez environ 10 secondes de marge pour les transitions.

## Conseils de présentation
- Montrez les écrans, ne les lisez pas.
- Sur les slides 5 à 7, pointez seulement un ou deux éléments visibles.
- Dites « prototype existant » pour les écrans réellement capturés.
- Évitez d’annoncer paiement, panier ou commandes comme déjà disponibles : ces fonctions sont des objectifs du périmètre cible, pas des preuves visibles dans ces captures.
"""
(ROOT / "05_Script_oral_5_minutes.md").write_text(speaker_script, encoding="utf-8")

print(f"Created {output} with {len(prs.slides)} slides")
