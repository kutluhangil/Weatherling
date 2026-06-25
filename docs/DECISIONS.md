# Açık Kararlar — Seçilen Varsayılanlar

Master Plan §23. Aşağıdakiler planın **kalın yazılı önerileriyle** ilerletildi.
Değiştirmek istersen burayı güncelle; çoğu yayından önce serbestçe değişebilir.

| # | Karar | Seçim | Not |
|---|-------|-------|-----|
| 1 | Yaratık yaşlanır mı? | **Hayır** — kullanıcının evresinde doğar, kalır (ayna ilkesi). İlerleme bond/skill ile. | Opsiyonel "Yaşam Yolculuğu" modu Faz 2'de eklenebilir. |
| 2 | Backend | **Supabase** (auth + bulut kayıt + RLS) | Faz 8. Yerel-öncelik korunur; backend olmadan da tam oynanır. |
| 3 | Hava sağlayıcı | **Open-Meteo** (anahtarsız, ücretsiz, gizlilik dostu) | Premium gerekirse Supabase Edge proxy. |
| 4 | Ölüm mekaniği | **Yok** — "küsme + geri kazanma" | Cozy çekirdek. `NeedsService` taban korumalı. |
| 5 | Application ID / marka | **`com.rebuildrebreak.weatherling`** | ⚠️ İlk Play yayınından **sonra değişmez**. Yayından önce kesinleştir. |
| 6 | Play hesabı türü | **Karara bağlandı (Faz 12)** | Kişisel → 12 kişi/14 gün kapalı test kapısı. Organizasyon muaf. |
| 7 | Min yaş / çocuk verisi | **Her yaşa uygun, çocuklara yönelik değil**; küçük yaşta yalnızca yerel oyun, bulut için yetişkin onayı | KVKK/COPPA/GDPR-K etkisi. |
| 8 | İlk lansman dili | **TR + EN** baştan | i18n iskeleti hazır (tr.po/en.po). |

> Bunlar Faz 0 iskeletini etkilemedi (varsayılanlarla ilerlendi). #5 marka adını
> netleştirmek istersen `project.godot`, `export_presets.cfg`, `LICENSE` içinde
> tek string değişikliğiyle güncellenir.
