/// What the patient app gets from Doaya online (backend/app/patients.py,
/// consultations.py).
library;

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);

class PharmacyBrief {
  const PharmacyBrief({
    required this.id,
    required this.name,
    required this.code,
    required this.city,
    this.address,
    this.phone,
    this.hours,
  });

  PharmacyBrief.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      name = j['name']! as String,
      code = j['code']! as String,
      city = j['city']! as String,
      address = j['address'] as String?,
      phone = j['phone'] as String?,
      hours = j['hours'] as String?;

  final String id;
  final String name;
  final String code;
  final String city;
  final String? address;
  final String? phone;
  final String? hours;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'city': city,
    'address': address,
    'phone': phone,
    'hours': hours,
  };
}

class Patient {
  const Patient({
    required this.id,
    required this.name,
    required this.phone,
    this.birthYear,
    this.sex,
    this.city,
    this.pharmacy,
  });

  Patient.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      name = j['name']! as String,
      phone = j['phone']! as String,
      birthYear = j['birth_year'] as int?,
      sex = j['sex'] as String?,
      city = j['city'] as String?,
      pharmacy = j['pharmacy'] == null
          ? null
          : PharmacyBrief.fromJson(j['pharmacy']! as Map<String, Object?>);

  final String id;
  final String name;
  final String phone;
  final int? birthYear;

  /// `m` | `f`.
  final String? sex;
  final String? city;

  /// The pharmacy the patient's cases and orders go to.
  final PharmacyBrief? pharmacy;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'birth_year': birthYear,
    'sex': sex,
    'city': city,
    'pharmacy': pharmacy?.toJson(),
  };
}

class ChatMessage {
  ChatMessage.fromJson(Map<String, Object?> j)
    : id = j['id']! as int,
      role = j['role']! as String,
      text = j['text']! as String,
      quickReplies = (j['quick_replies'] as List?)?.cast<String>() ?? const [],
      author = j['author'] as String?,
      createdAt = _date(j['created_at'])!;

  final int id;

  /// patient | assistant | pharmacist | system
  final String role;
  final String text;
  final List<String> quickReplies;
  final String? author;
  final DateTime createdAt;

  bool get mine => role == 'patient';
}

/// Consultation states (backend/app/consultations.py).
abstract final class ConsultStatus {
  static const chatting = 'chatting';
  static const summary = 'summary';
  static const sent = 'sent';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const pickedUp = 'picked_up';
  static const needsDoctor = 'needs_doctor';
  static const emergency = 'emergency';
  static const closed = 'closed';

  /// The patient talks to the assistant.
  static const withAssistant = {chatting, summary};

  /// No more messages.
  static const finished = {pickedUp, needsDoctor, closed};
}

/// The case summary fields, as the server's schema.
const summaryFields = [
  'symptoms',
  'duration',
  'age',
  'sex',
  'pregnancy',
  'allergies',
  'medications',
  'conditions',
  'denied_red_flags',
  'notes',
];

class Consultation {
  Consultation.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      pharmacyId = j['pharmacy_id']! as String,
      status = j['status']! as String,
      urgent = j['urgent']! as bool,
      redFlag = j['red_flag'] as String?,
      summary = j['summary'] as Map<String, Object?>?,
      decision = j['decision'] as Map<String, Object?>?,
      handledBy = j['handled_by'] as String?,
      createdAt = _date(j['created_at'])!,
      updatedAt = _date(j['updated_at'])!,
      messages = [
        for (final m in j['messages']! as List) ChatMessage.fromJson(m as Map<String, Object?>),
      ];

  final String id;
  final String pharmacyId;
  final String status;
  final bool urgent;
  final String? redFlag;
  final Map<String, Object?>? summary;

  /// The pharmacist's choice: items with their own instructions.
  final Map<String, Object?>? decision;
  final String? handledBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  bool get withAssistant => ConsultStatus.withAssistant.contains(status);
  bool get finished => ConsultStatus.finished.contains(status);

  /// The quick replies of the assistant's last message, while it's the last.
  List<String> get quickReplies =>
      messages.isNotEmpty && messages.last.role == 'assistant' && withAssistant
      ? messages.last.quickReplies
      : const [];

  /// A short title: the summary's symptoms or the first thing said.
  String get title {
    final s = (summary?['symptoms'] as List?)?.cast<String>();
    if (s != null && s.isNotEmpty) return s.join('، ');
    return messages.where((m) => m.mine).firstOrNull?.text ?? '';
  }
}
