"""The server's own TLS certificate, for HTTPS on the pharmacy's Wi-Fi.

There's no domain name on a local network, so no public certificate: the
server makes a self-signed one on first run and keeps it in the data folder.
Devices trust it the first time they link and remember its SHA-256
fingerprint; from then on they refuse any other certificate (pinning), so
nobody on the same Wi-Fi can read or fake the traffic.
"""

import contextlib
import datetime as dt
import hashlib
import ipaddress
import socket
from dataclasses import dataclass
from pathlib import Path

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import ec
from cryptography.x509.oid import NameOID


@dataclass(frozen=True)
class ServerCertificate:
    cert_file: Path
    key_file: Path
    # Lowercase hex SHA-256 of the certificate (DER): what devices pin.
    fingerprint: str

    @property
    def short_code(self) -> str:
        """The first 8 hex digits, grouped, for people to compare: AB12-CD34."""
        f = self.fingerprint[:8].upper()
        return f"{f[:4]}-{f[4:]}"


def fingerprint_of(cert_pem: bytes) -> str:
    cert = x509.load_pem_x509_certificate(cert_pem)
    return hashlib.sha256(cert.public_bytes(serialization.Encoding.DER)).hexdigest()


def ensure_certificate(data_dir: str | Path) -> ServerCertificate:
    """Loads the server's certificate, making one the first time."""
    d = Path(data_dir)
    d.mkdir(parents=True, exist_ok=True)
    cert_file, key_file = d / "server.crt", d / "server.key"
    if not (cert_file.exists() and key_file.exists()):
        key = ec.generate_private_key(ec.SECP256R1())
        name = x509.Name([x509.NameAttribute(NameOID.COMMON_NAME, "Doaya pharmacy server")])
        now = dt.datetime.now(dt.UTC)
        alt: list[x509.GeneralName] = [
            x509.DNSName("localhost"),
            x509.IPAddress(ipaddress.ip_address("127.0.0.1")),
        ]
        with contextlib.suppress(OSError):
            alt.append(x509.DNSName(socket.gethostname()))
        cert = (
            x509.CertificateBuilder()
            .subject_name(name)
            .issuer_name(name)
            .public_key(key.public_key())
            .serial_number(x509.random_serial_number())
            .not_valid_before(now - dt.timedelta(days=1))
            .not_valid_after(now + dt.timedelta(days=365 * 20))
            .add_extension(x509.SubjectAlternativeName(alt), critical=False)
            .sign(key, hashes.SHA256())
        )
        key_file.write_bytes(
            key.private_bytes(
                serialization.Encoding.PEM,
                serialization.PrivateFormat.PKCS8,
                serialization.NoEncryption(),
            )
        )
        key_file.chmod(0o600)
        cert_file.write_bytes(cert.public_bytes(serialization.Encoding.PEM))
    return ServerCertificate(
        cert_file=cert_file, key_file=key_file, fingerprint=fingerprint_of(cert_file.read_bytes())
    )
