"""Red-flag rules: the first safety layer, run on every patient message
before any LLM (docs/SPEC.md §2.1).

Arabic is normalized first (diacritics, letter variants, Arabic digits,
stretched letters), then keyword/pattern rules for formal Arabic and Syrian
dialect are matched. A rule is cancelled only by a negation just before it
in the same clause («ما عندي وجع بصدري»), never for self-harm, poisoning or
a feverish infant. When in doubt a rule fires: a false alarm costs a phone
call, a missed one can cost a life. The LLM classifier is the second layer
and only ever adds alarms.

Every rule is backed by sentences in tests/test_redflags.py.
"""

import re
from collections.abc import Callable
from dataclasses import dataclass

_DIACRITICS = re.compile(r"[ً-ٰٟـ]")
_LETTERS = str.maketrans(
    {
        "أ": "ا",
        "إ": "ا",
        "آ": "ا",
        "ٱ": "ا",
        "ى": "ي",
        "ة": "ه",
        "ؤ": "و",
        "ئ": "ي",
        "،": ",",
        "؛": ";",
        "؟": "?",
        **{chr(0x0660 + i): str(i) for i in range(10)},
        **{chr(0x06F0 + i): str(i) for i in range(10)},
    }
)
_STRETCHED = re.compile(r"(.)\1{2,}")


def normalize(text: str) -> str:
    """Folds spelling variants so one rule covers them: «ألمٌ في الصّدرِ» and
    «الم في الصدر» match alike; «كتيييير» → «كتير»; «٣٩» → «39»."""
    t = _DIACRITICS.sub("", text).translate(_LETTERS).lower()
    t = _STRETCHED.sub(r"\1", t)
    return re.sub(r"\s+", " ", t).strip()


@dataclass(frozen=True)
class RedFlagHit:
    category: str
    matched: str
    # emergency: ambulance now (the rules only ever say this) · doctor: not
    # an emergency, but a doctor should examine the patient soon (model).
    level: str = "emergency"


# Words that cancel a symptom named right after them, and words that start a
# new clause (a negation before them doesn't reach past).
_NEGATIONS = {"ما", "مافي", "مافيه", "ماعندي", "ماعنده", "ماعندها", "لا", "ولا", "بدون", "بلا"}
_NEGATIONS |= {"مو", "مش", "مانو", "مانه"}
_CLAUSE = {"بس", "لكن", "بينما", "اما", "بعدين", "هلق"}


def _negated(text: str, start: int) -> bool:
    before = re.split(r"[,.?!;:\n]", text[:start])[-1].split()
    for word in reversed(before[-4:]):
        if word in _NEGATIONS:
            return True
        if word in _CLAUSE or (word.startswith("و") and len(word) > 2):
            return False
    return False


def _any(*patterns: str) -> list[re.Pattern[str]]:
    return [re.compile(p) for p in patterns]


# Patterns are written on normalized text: ه for ة, ي for ى, ا for أ/إ/آ.
_BODY_PREFIX = r"(?:ب|في|علي|ع)?\s?(?:ال)?"
_BLEED = r"(?:نزيف|نزف|(?:ت|ي|ب)نزف|\bب?دم\b)"

_RULES: list[tuple[str, bool, list[re.Pattern[str]]]] = [
    # (category, a negation can cancel it, patterns)
    (
        "self_harm",
        False,
        _any(
            r"(?:ا|ي|ت|ن)?موت\s+(?:حالي|نفسي|حاله|حالو|حالها|نفسه)",
            r"(?:ا|ي|ت|ب)?نتحر|انتحار",
            r"(?:ا|ي|ت)?قتل\s+(?:حالي|نفسي|حاله|نفسه|حالها)",
            r"ما\s+(?:عاد\s+|بقي\s+)?بدي\s+(?:ضل\s+)?(?:ا)?عيش|مابدي\s+عيش",
            r"بدي\s+خلص\s+من\s+(?:حياتي|عمري)",
            r"(?:جرحت|اذيت|ضربت)\s+(?:حالي|نفسي)",
            r"suicid|kill myself",
        ),
    ),
    (
        "poisoning",
        False,
        _any(
            r"(?:بلع|بلعت|بلعو|ابتلع|ابتلعت|شرب|شربت|شربو)\s+(?:\S+\s+)?"
            r"(?:حبوب|حبات|علبه\s+(?:دوا|حبوب|كامله)|كلور|مبيد|مازوت|بنزين|اسيد"
            r"|مي\s+نار|ماء\s+نار|منظف|مطهر|سبيرتو|كاز|فلاش)",
            r"(?:اخد|اخدت|اخدو|اكل|اكلت)\s+(?:\S+\s+)?"
            r"(?:علبه\s+(?:دوا|حبوب|كامله)|ظرف\s+كامل|كميه\s+كبيره|حبوب\s+كتير|دوا\s+كتير)",
            r"جرعه\s+(?:زايده)|اوفر\s?دوز|overdose",
            r"\bانسم\S*|\bتسمم\S*|مسموم",
        ),
    ),
    (
        "pregnancy_bleeding",
        True,
        _any(
            rf"(?:حامل|\bبالحمل\b|\bحمل\b)[^.?!\n]*?{_BLEED}",
            rf"{_BLEED}[^.?!\n]*?(?:حامل|\bبالحمل\b)",
        ),
    ),
    (
        "chest_pain",
        True,
        _any(
            r"(?:وجع|الم|ضغط|ثقل|عصره|نغزه|نغزات)\s+(?:شديد\s+|قوي\s+)?"
            rf"{_BODY_PREFIX}(?:صدر|صدري|صدره|صدرها|قلب|قلبي|قلبه)\b",
            r"\b(?:صدري|قلبي|صدره|قلبه|صدرها)\s+(?:عم\s+)?(?:ي|ب|بي|عم ي)?"
            r"(?:وجعني|وجعه|وجعها|وجع|عصرني|عصره|عصر)",
            r"جلطه\s+قلبيه|ذبحه\s+صدريه|احتشاء",
            r"chest pain|heart attack",
        ),
    ),
    (
        "breathing",
        True,
        _any(
            rf"ضيق(?:ه)?\s+{_BODY_PREFIX}نفس",
            r"ما\s+(?:عم\s+)?(?:اقدر|قادر|قادره|فيني|يقدر|تقدر|فيه|فيها)\s+(?:ا|ي|ت)?تنفس",
            r"(?:مو|مش)\s+(?:قادر|قادره)\s+(?:ا|ي|ت)?تنفس",
            r"(?:نفسي|نفسه|نفسها)\s+(?:مقطوع|انقطع|عم\s+ينقطع)|انقطع\s+نفس",
            r"(?:ي|ا|ت|ب)?ختنق|اختناق|مخنوق",
            r"(?:شفافه|شفافها|شفافي|شفايفه|شفايفها|شفايفي|لونه|لونها|وجهه)\s+(?:صار(?:ت)?\s+)?"
            r"(?:زرق|ازرق|زرقا|زرقوا|ازرقت|ازرقوا)",
            rf"صعوبه\s+{_BODY_PREFIX}تنفس",
            r"can'?t breathe|shortness of breath",
        ),
    ),
    (
        "stroke",
        True,
        _any(
            r"(?:تمه|تمي|تمها|فمه|فمي|ثمه|وجهه|وجهي|وجها)\s+(?:صار\s+)?"
            r"(?:معوج|عوج|مايل|مال|نازل|نزل)",
            r"\bنص\s+(?:وجهي|وجهه|وجها|جسمي|جسمه|جسمها)",
            r"(?:ايدي|ايده|ايدها|اجري|اجره|رجلي|رجله|نصي|نصه)\s+(?:\S+\s+){0,2}?"
            r"(?:فجاه|انشلت|انشل|ما\s+عم\s+(?:ت|ي)تحرك)",
            r"(?:لسانه|لساني|لسانها|حكيه|حكيي|كلامه|كلامي)\s+(?:\S+\s+)?"
            r"(?:تقل|ثقل|ثقيل|تقيل|تخربط|متلعثم)",
            r"جلطه\s+دماغيه|سكته\s+دماغيه|\bانشل\S*",
            r"\bstroke\b",
        ),
    ),
    (
        "bleeding",
        True,
        _any(
            r"(?:نزيف|نزف)\s+(?:قوي|كتير|شديد|غزير|ما\s+عم\s+يوقف)",
            r"(?:ي|ت|ب)?نزف\s+(?:كتير|وما|ما\s+عم|بقوه|بشده)",
            r"(?:استفرغ|استفرغت|يستفرغ|تستفرغ|استفراغ|اقيا|قيء|تقيا|تقيات)\s+(?:\S+\s+)?دم",
            r"(?:ي|ت|ا|ب)?سعل\s+دم|سعال\s+(?:فيه\s+)?دم",
            r"(?:البراز|براز|الخروج)\s+(?:\S+\s+)?(?:اسود|فيه\s+دم|دم)",
            r"\bال?دم\s+ما\s+(?:عم\s+)?(?:يوقف|وقف)",
        ),
    ),
    (
        "seizure",
        True,
        _any(
            r"نوبه\s+(?:صرع|اختلاج|تشنج)",
            r"اختلاج|(?:ي|ت)ختلج",
            r"(?:ي|ت)?تشنج\S*(?!\s+(?:ب|في)?\s?(?:ال)?"
            r"(?:عضل|عضله|رجل|رجلي|اجر|اجري|ضهر|ضهري|رقبه|معده|بطن|قولون|كولون))",
        ),
    ),
    (
        "unconscious",
        True,
        _any(
            r"(?:فقد|فاقد|فاقده|فقدت|غاب\s+عن|راح\s+عن)\s+(?:ال)?وعي\S*",
            r"\b(?:ا|ان)?غمي?\s+(?:عليه|عليها|علي|عليي)|مغمي\s+عليه",
            r"ما\s+عم\s+(?:ي|ت)(?:صحي|فيق)",
            r"(?:وقع|وقعت|سقط)\s+(?:\S+\s+)?و?ما\s+(?:عم\s+)?(?:ي|ت)(?:رد|حكي|فيق|صحي)",
        ),
    ),
    (
        "anaphylaxis",
        True,
        _any(
            r"(?:ورم|تورم|انتفخ|نفخ|انفخ|ورمت|تورمت|انتفخت)\s+(?:\S+\s+)?"
            r"(?:وجهي|وجهه|وجها|شفافي|شفافه|شفافها|شفايفي|شفايفه|لساني|لسانه|لسانها"
            r"|حلقي|حلقه|رقبتي|تمي|تمه)",
            r"(?:وجهي|وجهه|شفافي|شفافه|شفايفه|لساني|لسانه|لسانها|حلقي|حلقه)\s+(?:\S+\s+)?"
            r"(?:ورم|تورم|انتفخ|نفخ|منفوخ|وارم)",
            r"(?:حلقي|حلقه|حلقها|زلعومي|زلعومه)\s+(?:عم\s+)?(?:ي|ت)?(?:سكر|نغلق|ضيق|سد)",
        ),
    ),
    (
        "severe_headache",
        True,
        _any(
            rf"تيبس\s+{_BODY_PREFIX}رقب",
            r"(?:رقبتي|رقبته|رقبتها)\s+(?:\S+\s+)?(?:متيبسه|يابسه|متخشبه)",
            r"(?:اسوا|اقوي|اشد)\s+صداع|صداع\s+(?:مفاجي|فجاه)",
        ),
    ),
]

_FEVER = re.compile(r"حرار|سخن|سخون|مسخن|\bحمي\b|\bحمه\b|fever")
_NEWBORN = re.compile(r"رضيع|مولود|خديج|نونو")
_AGE_DAYS = re.compile(r"عمر(?:ه|ها|و)?\s+\d+\s+(?:يوم|ايام|اسبوع|اسابيع|جمعه|جمعات)")
_AGE_MONTHS = re.compile(r"عمر(?:ه|ها|و)?\s+(?:(\d+)\s+)?(شهرين|شهر|شهور|اشهر)")


def _infant_fever(t: str) -> str | None:
    """A baby up to 3 months old with any fever."""
    if not _FEVER.search(t):
        return None
    if m := (_NEWBORN.search(t) or _AGE_DAYS.search(t)):
        return m.group(0)
    for m in _AGE_MONTHS.finditer(t):
        months = int(m.group(1)) if m.group(1) else (2 if m.group(2) == "شهرين" else 1)
        if months <= 3:
            return m.group(0)
    return None


_CHECKS: list[tuple[str, Callable[[str], str | None]]] = [("infant_fever", _infant_fever)]


def check(message: str) -> RedFlagHit | None:
    """The first red flag in a patient's message, or None."""
    t = normalize(message)
    for category, cancellable, patterns in _RULES:
        for p in patterns:
            for m in p.finditer(t):
                if cancellable and _negated(t, m.start()):
                    continue
                return RedFlagHit(category, m.group(0))
        if category == "poisoning":  # infants right after the never-cancelled rules
            for name, fn in _CHECKS:
                if hit := fn(t):
                    return RedFlagHit(name, hit)
    return None
