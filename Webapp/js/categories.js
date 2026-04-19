/** Labels catégories — alignés sur S.categoryLabel (mobile) */
(function (global) {
  const MAP = {
    '': 'الكل',
    plumbing: 'سباكة',
    painting: 'دهان',
    carpentry: 'نجارة',
    electricity: 'كهرباء',
    tiling: 'بلاط',
    hvac: 'تكييف',
    zellige: 'الزليج',
    pottery: 'الفخار',
    leather: 'الجلد',
    dinanderie: 'الدندانة',
    wood_traditional: 'النجارة التقليدية',
    carpet_weaving: 'السجاد',
    textile_fouta: 'النسيج',
    henna: 'الحناء',
    plaster_gebs: 'الجص والزخرفة',
    basketry: 'الحصر',
    embroidery: 'التطريز',
    calligraphy: 'الخط',
    argan_cosmetics: 'الأرغان',
    traditional_food: 'مأكولات تقليدية',
    jewelry_berber: 'الحلي',
    wrought_iron: 'الحدادة التقليدية',
  };

  function categoryLabel(key) {
    if (key == null || key === '') return MAP[''];
    return MAP[key] || String(key);
  }

  global.AlAselCategories = { categoryLabel };
})(typeof window !== 'undefined' ? window : globalThis);
