"""Prescription photos: the patient sends one in a consultation or with a
pickup order. Files live in `<data_dir>/photos/`; only the patient who sent
one and the pharmacy it went to can open it."""

from pathlib import Path

from fastapi import APIRouter, Request, UploadFile
from fastapi.responses import Response
from sqlalchemy.orm import Session

from .deps import DbSession, Patient, PharmacyCaller, error
from .models import Consultation, PatientOrder, PatientProfile, Photo
from .security import new_id

router = APIRouter(tags=["photos"])

# Phones shrink photos before sending (the app asks for ~1600 px); this
# still leaves room for a sharp shot of a prescription.
MAX_BYTES = 5 * 1024 * 1024

_MAGIC = (
    (b"\xff\xd8\xff", "image/jpeg"),
    (b"\x89PNG\r\n\x1a\n", "image/png"),
)


def _kind(data: bytes) -> str | None:
    for magic, kind in _MAGIC:
        if data.startswith(magic):
            return kind
    if data[:4] == b"RIFF" and data[8:12] == b"WEBP":
        return "image/webp"
    return None


def _dir(request: Request) -> Path:
    return Path(request.app.state.settings.data_dir) / "photos"


async def save_photo(
    request: Request, db: Session, patient_id: str, pharmacy_id: str, file: UploadFile
) -> Photo:
    """Checks it's a real image of a sane size (by its bytes, not its
    name) and keeps it."""
    data = await file.read(MAX_BYTES + 1)
    if len(data) > MAX_BYTES:
        raise error(413, "photo_too_big")
    kind = _kind(data)
    if kind is None:
        raise error(415, "not_an_image")
    photo = Photo(
        id=new_id(),
        patient_id=patient_id,
        pharmacy_id=pharmacy_id,
        content_type=kind,
        size=len(data),
    )
    folder = _dir(request)
    folder.mkdir(parents=True, exist_ok=True)
    (folder / photo.id).write_bytes(data)
    db.add(photo)
    db.flush()
    return photo


def _file(request: Request, photo: Photo) -> Response:
    path = _dir(request) / photo.id
    if not path.exists():
        raise error(404, "photo_not_found")
    return Response(
        path.read_bytes(),
        media_type=photo.content_type,
        headers={"cache-control": "private, max-age=86400"},
    )


@router.post("/photos")
async def upload(file: UploadFile, p: Patient, db: DbSession, request: Request) -> dict:
    """A photo to send with an order (`photo_id` in POST /orders)."""
    prof = db.get(PatientProfile, p.user_id)
    if prof is None or prof.pharmacy_id is None:
        raise error(409, "no_pharmacy")
    photo = await save_photo(request, db, p.user_id, prof.pharmacy_id, file)
    db.commit()
    return {"id": photo.id}


@router.get("/photos/{photo_id}")
def mine(photo_id: str, p: Patient, db: DbSession, request: Request) -> Response:
    photo = db.get(Photo, photo_id)
    if photo is None or photo.patient_id != p.user_id:
        raise error(404, "photo_not_found")
    return _file(request, photo)


@router.get("/pharmacy-api/photos/{photo_id}")
def theirs(photo_id: str, caller: PharmacyCaller, db: DbSession, request: Request) -> Response:
    """Only once it reached the pharmacy: a sent case, or an order."""
    photo = db.get(Photo, photo_id)
    if photo is None or photo.pharmacy_id != caller.pharmacy_id:
        raise error(404, "photo_not_found")
    sent = photo.order_id is not None or (
        photo.consultation_id is not None
        and (c := db.get(Consultation, photo.consultation_id)) is not None
        and c.sent_at is not None
    )
    if not sent:
        raise error(404, "photo_not_found")
    return _file(request, photo)


def attach_to_order(db: Session, patient_id: str, order: PatientOrder, photo_id: str) -> None:
    photo = db.get(Photo, photo_id)
    if (
        photo is None
        or photo.patient_id != patient_id
        or photo.pharmacy_id != order.pharmacy_id
        or photo.order_id is not None
        or photo.consultation_id is not None
    ):
        raise error(400, "bad_photo")
    photo.order_id = order.id
    order.photo_id = photo.id
