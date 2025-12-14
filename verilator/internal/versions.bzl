"""Helpers for finding the repository information for a specific version"""

_MIRROR_URLS = [
    "https://github.com/verilator/verilator/archive/{}.tar.gz",
]

def _urls(version):
    if version != "master":
        version = "v" + version
    return [m.format(version) for m in _MIRROR_URLS]

def _info(version, sha256):
    return (version, struct(
        sha256 = sha256,
        strip_prefix = "verilator-{}".format(version),
        urls = _urls(version),
    ))

# Predefined versions with known SHA256 hashes (for convenience)
VERSION_INFO = dict([
    _info("4.224", "010ff2b5c76d4dbc2ed4a3278a5599ba35c8ed4c05690e57296d6b281591367b"),
    _info("master", ""),  # Hash omitted. Use at your own risk.
])

DEFAULT_VERSION = "4.224"

def version_info(version, sha256 = None):
    """Get version info for any verilator version.

    Args:
        version: Verilator version string (e.g., "4.224", "5.020", "master")
        sha256: Optional SHA256 hash for verification. If not provided and version
                is in VERSION_INFO, uses the predefined hash. Otherwise uses empty string.

    Returns:
        Struct with sha256, strip_prefix, and urls fields
    """
    # If version is in predefined list and no sha256 provided, use predefined
    if version in VERSION_INFO and sha256 == None:
        return VERSION_INFO[version]

    # Otherwise, create version info dynamically
    if sha256 == None:
        sha256 = ""

    return struct(
        sha256 = sha256,
        strip_prefix = "verilator-{}".format(version),
        urls = _urls(version),
    )
