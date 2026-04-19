/// Métiers d'art traditionnels marocains — mêmes identifiants que l'API (`/posts`, inscription artisan).
class MoroccanTrade {
  const MoroccanTrade({required this.id, required this.labelAr});

  final String id;
  final String labelAr;
}

/// Liste unique utilisée pour listes déroulantes et filtres.
const List<MoroccanTrade> moroccanTrades = [
  MoroccanTrade(id: 'zellige', labelAr: 'الزليج والفسيفساء'),
  MoroccanTrade(id: 'pottery', labelAr: 'الفخار والخزف'),
  MoroccanTrade(id: 'leather', labelAr: 'الجلد والصناعة التقليدية للبوابيش'),
  MoroccanTrade(id: 'dinanderie', labelAr: 'الدندانة والنحاس والفضة'),
  MoroccanTrade(id: 'carpet_weaving', labelAr: 'السجاد والبرود والزربية'),
  MoroccanTrade(id: 'textile_fouta', labelAr: 'النسيج'),
  MoroccanTrade(id: 'henna', labelAr: 'الحناء والنقش'),
  MoroccanTrade(id: 'plaster_gebs', labelAr: 'الجص والجبس والأرابيسك'),
  MoroccanTrade(id: 'basketry', labelAr: 'الحصر والقفاف '),
  MoroccanTrade(id: 'embroidery', labelAr: 'التطريز والصوفة والراندة'),
];

List<String> get moroccanTradeIds => moroccanTrades.map((e) => e.id).toList();

MoroccanTrade? moroccanTradeById(String? id) {
  if (id == null || id.isEmpty) return null;
  for (final t in moroccanTrades) {
    if (t.id == id) return t;
  }
  return null;
}
