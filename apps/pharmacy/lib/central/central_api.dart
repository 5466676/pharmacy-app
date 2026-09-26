import 'dart:typed_data';

import 'package:doaya_core/doaya_core.dart';

/// The pharmacy side of Doaya online (patients' cases and pickup orders),
/// reached through this pharmacy's own server at `/central/…`: it adds the
/// pharmacy key and the signed-in account's name. See docs/DECISIONS.md.

DateTime? _date(Object? v) => v == null ? null : DateTime.parse(v as String);
String? _str(Object? v) => v as String?;

class CasePatient {
  CasePatient.fromJson(Map<String, Object?> j)
    : id = j['id'] as String?,
      hasFile = j['has_file'] == true,
      name = j['name']! as String,
      phone = j['phone']! as String,
      age = j['age'] as int?,
      sex = j['sex'] as String?;

  /// For the patient's health file (Phase 5).
  final String? id;
  final bool hasFile;
  final String name;
  final String phone;
  final int? age;

  /// `m` | `f`.
  final String? sex;
}

/// Case states on the central server.
abstract final class CaseStatus {
  static const sent = 'sent';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const pickedUp = 'picked_up';
  static const needsDoctor = 'needs_doctor';
  static const emergency = 'emergency';
  static const closed = 'closed';

  /// Still waiting for the pharmacist.
  static const open = {sent, preparing, emergency};
  static const finished = {pickedUp, needsDoctor, closed};
}

class CaseBrief {
  CaseBrief.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      status = j['status']! as String,
      urgent = j['urgent']! as bool,
      redFlag = _str(j['red_flag']),
      doctorAdvice = _str(j['doctor_advice']),
      title = j['title']! as String,
      patient = CasePatient.fromJson(j['patient']! as Map<String, Object?>),
      sentAt = _date(j['sent_at']),
      updatedAt = _date(j['updated_at'])!;

  final String id;
  final String status;
  final bool urgent;
  final String? redFlag;

  /// «لازم دكتور»: the assistant told the patient to see a doctor soon.
  final String? doctorAdvice;
  final String title;
  final CasePatient patient;
  final DateTime? sentAt;
  final DateTime updatedAt;

  bool get open => CaseStatus.open.contains(status);
}

class CaseMessage {
  CaseMessage.fromJson(Map<String, Object?> j)
    : id = j['id']! as int,
      role = j['role']! as String,
      text = j['text']! as String,
      quickReplies = (j['quick_replies'] as List?)?.cast<String>(),
      author = _str(j['author']),
      photoId = _str(j['photo_id']),
      createdAt = _date(j['created_at'])!;

  final int id;

  /// A photo the patient sent (a prescription, a box).
  final String? photoId;

  /// patient | assistant | pharmacist | system
  final String role;
  final String text;
  final List<String>? quickReplies;
  final String? author;
  final DateTime createdAt;
}

/// What the assistant gathered, as the pharmacist reads it first.
class CaseSummary {
  CaseSummary.fromJson(Map<String, Object?> j)
    : symptoms = (j['symptoms'] as List? ?? const []).cast<String>(),
      duration = _str(j['duration']),
      age = _str(j['age']),
      sex = _str(j['sex']),
      pregnancy = _str(j['pregnancy']),
      allergies = _str(j['allergies']),
      medications = _str(j['medications']),
      conditions = _str(j['conditions']),
      deniedRedFlags = (j['denied_red_flags'] as List? ?? const []).cast<String>(),
      notes = _str(j['notes']);

  final List<String> symptoms;
  final String? duration;
  final String? age;
  final String? sex;
  final String? pregnancy;
  final String? allergies;
  final String? medications;
  final String? conditions;
  final List<String> deniedRedFlags;
  final String? notes;
}

class CaseDetail {
  CaseDetail.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      status = j['status']! as String,
      urgent = j['urgent']! as bool,
      redFlag = _str(j['red_flag']),
      doctorAdvice = _str(j['doctor_advice']),
      summary = j['summary'] == null
          ? null
          : CaseSummary.fromJson(j['summary']! as Map<String, Object?>),
      decision = j['decision'] as Map<String, Object?>?,
      handledBy = _str(j['handled_by']),
      sentAt = _date(j['sent_at']),
      messages = [
        for (final m in j['messages']! as List) CaseMessage.fromJson(m as Map<String, Object?>),
      ],
      patient = CasePatient.fromJson(j['patient']! as Map<String, Object?>);

  final String id;
  final String status;
  final bool urgent;
  final String? redFlag;
  final String? doctorAdvice;
  final CaseSummary? summary;
  final Map<String, Object?>? decision;
  final String? handledBy;
  final DateTime? sentAt;
  final List<CaseMessage> messages;
  final CasePatient patient;

  bool get open => CaseStatus.open.contains(status);
}

/// One medicine the pharmacist gives, with their own instructions.
class DecisionItem {
  const DecisionItem({
    required this.name,
    required this.quantity,
    required this.instructions,
    this.productId,
    this.timesPerDay,
    this.days,
    this.priceMinor,
  });

  final String? productId;
  final String name;
  final int quantity;
  final String instructions;
  final int? timesPerDay;
  final int? days;
  final int? priceMinor;

  Map<String, Object?> toJson() => {
    'product_id': productId,
    'name': name,
    'quantity': quantity,
    'instructions': instructions,
    'times_per_day': timesPerDay,
    'days': days,
    'price_minor': priceMinor,
  };
}

abstract final class OrderStatus {
  static const sent = 'sent';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const pickedUp = 'picked_up';
  static const rejected = 'rejected';
  static const cancelled = 'cancelled';

  static const open = {sent, preparing};
}

class OrderLine {
  OrderLine.fromJson(Map<String, Object?> j)
    : productId = j['product_id']! as String,
      name = j['name']! as String,
      requested = j['requested']! as int,
      quantity = j['quantity']! as int,
      priceMinor = j['price_minor']! as int;

  final String productId;
  final String name;
  final int requested;
  final int quantity;
  final int priceMinor;
}

class PatientOrder {
  PatientOrder.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      status = j['status']! as String,
      lines = [for (final l in j['lines']! as List) OrderLine.fromJson(l as Map<String, Object?>)],
      totalMinor = j['total_minor']! as int,
      note = _str(j['note']),
      pharmacistNote = _str(j['pharmacist_note']),
      handledBy = _str(j['handled_by']),
      photoId = _str(j['photo_id']),
      createdAt = _date(j['created_at'])!,
      patient = CasePatient.fromJson(j['patient']! as Map<String, Object?>);

  final String id;

  /// The prescription photo sent with the order.
  final String? photoId;
  final String status;
  final List<OrderLine> lines;
  final int totalMinor;
  final String? note;
  final String? pharmacistNote;
  final String? handledBy;
  final DateTime createdAt;
  final CasePatient patient;

  bool get open => OrderStatus.open.contains(status);
}

// ─── «ملف المريض» (Phase 5) ────────────────────────────────────────────────

/// allergy | condition | medication | pregnancy | weight | note.
class FileFact {
  FileFact.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      kind = j['kind']! as String,
      text = j['text']! as String,
      instructions = (j['detail'] as Map?)?['instructions'] as String?,
      confirmed = j['confirmed'] == true,
      addedBy = _str(j['added_by']),
      endsAt = _date(j['ends_at']);

  final String id;
  final String kind;
  final String text;
  final String? instructions;

  /// Added or checked by a pharmacist (else the patient said so).
  final bool confirmed;
  final String? addedBy;
  final DateTime? endsAt;
}

class FileProposalItem {
  FileProposalItem.fromJson(Map<String, Object?> j)
    : id = j['id']! as String,
      kind = j['kind']! as String,
      text = j['text']! as String,
      forPharmacist = j['needs'] == 'pharmacist';

  final String id;
  final String kind;
  final String text;
  final bool forPharmacist;
}

class PatientFile {
  PatientFile.fromJson(Map<String, Object?> j)
    : facts = [for (final f in j['facts']! as List) FileFact.fromJson(f as Map<String, Object?>)],
      proposals = [
        for (final p in j['proposals']! as List)
          FileProposalItem.fromJson(p as Map<String, Object?>),
      ],
      pastCases = (j['history']! as List).length,
      limited = j['limited'] == true;

  final List<FileFact> facts;
  final List<FileProposalItem> proposals;
  final int pastCases;

  /// The patient chose another pharmacy: only this one's past cases.
  final bool limited;
}

/// Calls through the linked pharmacy server.
class CentralApi {
  CentralApi(this._remote);
  final SyncRemote _remote;

  Future<Map<String, Object?>> linkState() async =>
      (await _remote.getJson('central-link'))! as Map<String, Object?>;

  Future<void> link(String url, String key) =>
      _remote.putJson('central-link', {'url': url, 'key': key});

  Future<void> unlink() => _remote.deleteJson('central-link');

  Future<List<CaseBrief>> cases() async => [
    for (final c in (await _remote.getJson('central/cases'))! as List)
      CaseBrief.fromJson(c as Map<String, Object?>),
  ];

  Future<CaseDetail> caseDetail(String id) async =>
      CaseDetail.fromJson((await _remote.getJson('central/cases/$id'))! as Map<String, Object?>);

  Future<CaseDetail> _case(String path, [Object? body]) async =>
      CaseDetail.fromJson((await _remote.postJson(path, body))! as Map<String, Object?>);

  /// «اسأل المريض سؤال».
  Future<CaseDetail> ask(String id, String text) =>
      _case('central/cases/$id/messages', {'text': text});

  Future<CaseDetail> preparing(String id) => _case('central/cases/$id/preparing');

  Future<CaseDetail> decide(String id, List<DecisionItem> items, {String? note}) =>
      _case('central/cases/$id/decision', {
        'items': [for (final i in items) i.toJson()],
        'note': note,
      });

  Future<CaseDetail> needsDoctor(String id, {String? text}) =>
      _case('central/cases/$id/needs-doctor', text == null ? null : {'text': text});

  Future<CaseDetail> pickedUp(String id) => _case('central/cases/$id/picked-up');

  Future<CaseDetail> close(String id) => _case('central/cases/$id/close');

  /// The assistant got something wrong: logged for review (never used for
  /// automatic training).
  Future<void> correct(String id, {required String correction, int? messageId, String? field}) =>
      _remote.postJson('central/cases/$id/corrections', {
        'target': messageId != null ? 'message' : 'summary',
        'message_id': messageId,
        'field': field,
        'correction': correction,
      });

  Future<PatientFile> patientFile(String patientId) async => PatientFile.fromJson(
    (await _remote.getJson('central/patients/$patientId/file'))! as Map<String, Object?>,
  );

  Future<void> addFact(String patientId, String kind, String text) =>
      _remote.postJson('central/patients/$patientId/file/facts', {'kind': kind, 'text': text});

  Future<void> confirmFact(String patientId, String factId) =>
      _remote.postJson('central/patients/$patientId/file/facts/$factId/confirm');

  Future<void> endFact(String patientId, String factId) =>
      _remote.postJson('central/patients/$patientId/file/facts/$factId/end');

  Future<void> decideProposal(String patientId, String proposalId, {required bool accept}) =>
      _remote.postJson('central/patients/$patientId/file/proposals/$proposalId', {
        'accept': accept,
      });

  /// A patient's photo, through the pharmacy's own server.
  Future<Uint8List> photo(String id) => _remote.getBytes('central/photos/$id');

  Future<List<PatientOrder>> orders() async => [
    for (final o in (await _remote.getJson('central/orders'))! as List)
      PatientOrder.fromJson(o as Map<String, Object?>),
  ];

  Future<PatientOrder> setOrderStatus(
    String id,
    String status, {
    Map<String, int>? quantities,
    String? note,
  }) async => PatientOrder.fromJson(
    (await _remote.postJson('central/orders/$id/status', {
          'status': status,
          'quantities': ?quantities,
          'note': ?note,
        }))!
        as Map<String, Object?>,
  );
}
