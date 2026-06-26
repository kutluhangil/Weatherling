## Tek kaynak renk paleti (DESIGN.md Pixel-Prime). Kod + theme.tres bunu kullanır.
class_name Palette
extends RefCounted

const SURFACE := Color("#1d0c24")
const DEEP_PLUM := Color("#1A0F1F")
const SURFACE_CONTAINER := Color("#2b1931")
const SURFACE_CONTAINER_HIGH := Color("#36233c")
const SURFACE_CONTAINER_LOWEST := Color("#18071e")
const DUSK_AMBER := Color("#E87C3E")
const HORIZON_GLOW := Color("#FFC078")
const PRIMARY_CONTAINER := Color("#ff9d5c")
const ON_PRIMARY_CONTAINER := Color("#743500")
const ON_SURFACE := Color("#f6d9fa")
const ON_SURFACE_VARIANT := Color("#dac2b4")
const SECONDARY_CONTAINER := Color("#622f91")
const ON_SECONDARY_CONTAINER := Color("#d4a5ff")
const TERTIARY := Color("#f8ca60")
const OUTLINE_VARIANT := Color("#544339")
const STATUS_HUNGER := Color("#FF4D6D")
const STATUS_ENERGY := Color("#4CC9F0")
const STATUS_LOVE := Color("#F72585")

# 6 ihtiyaç → bar rengi. Hijyen/sağlık/sosyal için türev tonlar.
const _NEED := {
	"hunger": STATUS_HUNGER, "energy": STATUS_ENERGY, "happiness": STATUS_LOVE,
	"hygiene": STATUS_ENERGY, "health": Color("#8fd089"), "social": Color("#deb7ff"),
}

static func need_color(key: String) -> Color:
	return _NEED.get(key, ON_SURFACE)
