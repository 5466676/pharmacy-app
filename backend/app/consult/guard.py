"""The output guard: every assistant reply is checked before the patient
sees it. A reply that names a dose, recommends or prescribes a medicine, or
says a doctor isn't needed is replaced by a safe line and logged
(docs/SPEC.md §2.1). Dosing and decisions belong to the pharmacist."""

import re
from dataclasses import dataclass

from .redflags import normalize


@dataclass(frozen=True)
class GuardViolation:
    kind: str  # dose | prescribing | no_doctor
    matched: str


_UNIT = r"(?:mg|ml|mcg|µg|g|iu|ملغ|مغ|ملغرام|مللي|مل|ميلي|غرام|غ|ميكروغرام|وحده|وحدات)"
_FORM = (
    r"(?:حبه|حبتين|حبات|حبوب|كبسوله|كبسولتين|كبسولات|ملعقه|ملعقتين|معلقه|"
    r"نقطه|نقطتين|نقط|بخه|بختين|ظرف|ابره|تحميله)"
)
_TIMES = (
    r"(?:مره|مرتين|تلات\s+مرات|ثلاث\s+مرات|3\s+مرات|اربع\s+مرات|4\s+مرات|كل\s+\d+\s+ساعات|"
    r"كل\s+\d+\s+ساعه|كل\s+(?:ست|تمن|تماني|اربع)\s+ساعات|يوميا|باليوم|بالنهار|قبل\s+الاكل|بعد\s+الاكل)"
)
_MEDICINE = (
    r"(?:دوا|ادويه|حبوب|مضاد\s+حيوي|مضاد|مسكن|خافض|شراب|مرهم|كريم|قطره|بخاخ|فيتامين|"
    r"باراسيتامول|بنادول|بروفين|ايبوبروفين|اسبرين|سيتامول|اموكسيسيلين|[a-z][a-z]{3,})"
)

_RULES: list[tuple[str, re.Pattern[str]]] = [
    ("dose", re.compile(rf"\d+(?:[.,]\d+)?\s?{_UNIT}\b")),
    ("dose", re.compile(rf"{_FORM}\s*(?:\S+\s+){{0,3}}?{_TIMES}")),
    ("dose", re.compile(r"\b(?:the\s+)?dose\s+(?:is|of)\b|\d+\s?(?:tablets?|pills?|times a day)")),
    (
        "prescribing",
        re.compile(
            r"(?:خود|خذ|خدي|خذي|استعمل|استعملي|استخدم|استخدمي|جرب|جربي|اشرب|اشربي|بلاش\s+غير|"
            r"انصحك\s+ب|بنصحك\s+ب|بنصحك\s+تاخد|نصيحتي\s+تاخد|بوصفلك|رح\s+اوصفلك|وصفتلك|اوصي\s+ب)"
            rf"\s*(?:\S+\s+){{0,2}}?{_MEDICINE}"
        ),
    ),
    ("prescribing", re.compile(r"\b(?:i\s+)?(?:recommend|prescribe|you should take)\b")),
    (
        "no_doctor",
        re.compile(
            r"(?:ما|مو|مش)\s+(?:\S+\s+)?(?:بتحتاج|تحتاج|محتاج|بحاجه|لازم|ضروري|داعي)\s+"
            r"(?:\S+\s+){0,2}?(?:دكتور|طبيب|حكيم|مستشفي|اسعاف|طوارئ|اسعافات)"
        ),
    ),
    (
        "no_doctor",
        re.compile(r"(?:ما|مافي)\s+(?:في\s+)?داعي\s+(?:\S+\s+)?(?:تروح|تشوف|للدكتور|للطبيب)"),
    ),
    ("no_doctor", re.compile(r"(?:don'?t|do not|no)\s+need\s+(?:to\s+see\s+)?a\s+doctor")),
]


def check_reply(text: str) -> GuardViolation | None:
    t = normalize(text)
    for kind, pattern in _RULES:
        if m := pattern.search(t):
            return GuardViolation(kind, m.group(0))
    return None
