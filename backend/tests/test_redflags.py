"""The red-flag rules run on every patient message before any LLM. A hit
stops the consultation and sends an urgent case. These tables are the
spec: add a sentence here before changing a rule."""

import pytest

from app.consult.redflags import check, normalize

MUST_FIRE = [
    # chest pain
    ("chest_pain", "عندي وجع بصدري من الصبح"),
    ("chest_pain", "ألمٌ شديد في الصدر"),
    ("chest_pain", "صدري عم يعصرني وعرقان"),
    ("chest_pain", "في ضغط على صدري"),
    ("chest_pain", "قلبي عم يوجعني كتييير"),
    ("chest_pain", "ما عندي حرارة بس عندي وجع بصدري"),
    ("chest_pain", "I have chest pain"),
    # breathing
    ("breathing", "ما عم اقدر اتنفس"),
    ("breathing", "نفسي مقطوع"),
    ("breathing", "عندي ضيق نفس قوي"),
    ("breathing", "ضيقة بالنفس من امبارح"),
    ("breathing", "ابني عم يختنق"),
    ("breathing", "شفافه زرقوا"),
    ("breathing", "صعوبة في التنفس"),
    ("breathing", "مو قادر اتنفس منيح"),
    # stroke
    ("stroke", "تمّه معوّج فجأة"),
    ("stroke", "نص وجهي نزل"),
    ("stroke", "ايدي نملت فجأة وما عم تتحرك"),
    ("stroke", "لسانه تقل وما عم يقدر يحكي"),
    ("stroke", "خايفين تكون جلطة دماغية"),
    # bleeding
    ("bleeding", "عم ينزف كتير وما عم يوقف"),
    ("bleeding", "نزيف قوي من الجرح"),
    ("bleeding", "استفرغ دم"),
    ("bleeding", "عم يسعل دم"),
    ("bleeding", "صار البراز اسود"),
    # infants with fever
    ("infant_fever", "ابني عمره ٣ شهور وحرارته ٣٩"),
    ("infant_fever", "بنتي عمرها شهرين وسخنة كتير"),
    ("infant_fever", "المولود عنده حرارة"),
    ("infant_fever", "رضيع عمره ٢٠ يوم عنده سخونة"),
    # suicide / self-harm (never cancelled by a negation)
    ("self_harm", "بدي موّت حالي"),
    ("self_harm", "عم فكر انتحر"),
    ("self_harm", "ما عاد بدي عيش"),
    ("self_harm", "ما بدي انتحر بس تعبت"),
    ("self_harm", "جرحت حالي عن قصد"),
    # poisoning / overdose
    ("poisoning", "ابني بلع حبوب من الدرج"),
    ("poisoning", "شربت علبة دوا كاملة"),
    ("poisoning", "بنتي شربت كلور"),
    ("poisoning", "اخد جرعة زايدة"),
    ("poisoning", "انسمّ من الأكل"),
    # seizures
    ("seizure", "اجته نوبة صرع"),
    ("seizure", "ابني عم يختلج"),
    ("seizure", "صار معه تشنج"),
    # unconscious / fainting
    ("unconscious", "انغمى عليها بالحمام"),
    ("unconscious", "فقد الوعي من شوي"),
    ("unconscious", "وقع وما عم يرد"),
    ("unconscious", "ما عم يصحى"),
    # severe allergy
    ("anaphylaxis", "ورم وجهي وشفافي بعد الدوا"),
    ("anaphylaxis", "حلقي عم يسكّر"),
    ("anaphylaxis", "لسانه انتفخ"),
    # pregnancy with bleeding
    ("pregnancy_bleeding", "انا حامل بالشهر الرابع ونزل معي دم"),
    ("pregnancy_bleeding", "مرتي حامل وعم تنزف"),
    # meningitis / worst headache
    ("severe_headache", "عندي حرارة وتيبس بالرقبة"),
    ("severe_headache", "أسوأ صداع بحياتي فجأة"),
]

MUST_NOT_FIRE = [
    "عندي صداع من يومين وحرارة خفيفة",
    "لا، ولا شي",
    "ما عندي وجع بصدري",
    "ما في ضيق نفس",
    "بدون ألم بالصدر",
    "ما عندي حرارة ولا ضيق نفس",
    "عندي حرقة بالمعدة بعد الأكل",
    "عندي زكام وسعلة ناشفة",
    "رشح وعطس",
    "ايدي عم تنمل شوي لما نام عليها",
    "بدي دوا للإسهال",
    "حساسية ربيعية عيوني عم تحكني",
    "ابني عمره ٥ سنين وحرارته ٣٨",
    "رح موت من الجوع",
    "عندي صرع وبدي علبة الدوا تبعي",
    "ما في دم",
    "بدي أحسن دوا للحموضة",
    "رعاف خفيف ووقف لحاله",
    "انا حامل وبدي اسأل عن فيتامينات",
    "جرحت ايدي بالسكين جرح صغير",
    "عندي تشنج بالعضل من الرياضة",
    "شربت ظرف فوار وما تحسنت",
    "اخدت حبة بنادول وما نفعت",
    "بدي دوا القلب تبع امي",
    "وجع ضهر من الشغل",
    "عندي ضغط وسكري وبدي جهاز قياس",
    "لقاح شلل الأطفال امتى؟",
]


@pytest.mark.parametrize(("category", "text"), MUST_FIRE)
def test_fires(category, text):
    hit = check(text)
    assert hit is not None, text
    assert hit.category == category, (text, hit)


@pytest.mark.parametrize("text", MUST_NOT_FIRE)
def test_does_not_fire(text):
    assert check(text) is None, (text, check(text))


def test_normalize():
    assert normalize("ألمٌ  في الصّدرِ") == "الم في الصدر"
    assert normalize("إسعافـــ آخر ى ة") == "اسعاف اخر ي ه"
    assert normalize("كتيييير") == "كتير"
    assert normalize("٣٩ درجة") == "39 درجه"
    assert normalize("Chest PAIN") == "chest pain"


def test_patterns_are_written_on_normalized_text():
    """ى, ة, أ… never appear in a pattern: normalize() folds them away, so a
    pattern with them could never match."""
    from app.consult.redflags import _RULES

    for category, _, patterns in _RULES:
        for p in patterns:
            assert not set(p.pattern) & set("ىةأإآؤئ"), (category, p.pattern)
