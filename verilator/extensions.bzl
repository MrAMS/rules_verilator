"""Bazel module extension for Verilator toolchains"""

load(
    "//verilator:repositories.bzl",
    "verilator_repository",
)
load(
    "//verilator/internal:versions.bzl",
    "DEFAULT_VERSION",
)

_toolchain_attrs = {
    "name": attr.string(doc = "Name of the toolchain repository"),
    "version": attr.string(
        default = DEFAULT_VERSION,
        doc = "Verilator version to use (e.g., '4.224', '5.020')",
    ),
    "sha256": attr.string(
        default = "",
        doc = "SHA256 hash for verification (optional but recommended)",
    ),
}

def _verilator_extension_impl(module_ctx):
    """Implementation of the Verilator toolchain extension.

    This extension allows users to declare which Verilator versions they want to use.
    Multiple versions can be registered, and toolchains will be created for each.
    """

    # Collect all toolchain declarations
    toolchains = []
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            toolchains.append(struct(
                name = toolchain.name,
                version = toolchain.version,
                sha256 = toolchain.sha256,
            ))

    # If no toolchains specified, register the default
    if not toolchains:
        toolchains.append(struct(
            name = "verilator",
            version = DEFAULT_VERSION,
            sha256 = "",
        ))

    # Create verilator repositories for each declared toolchain
    for toolchain in toolchains:
        repo_name = "verilator_v{version}".format(version = toolchain.version)
        verilator_repository(
            name = repo_name,
            version = toolchain.version,
            sha256 = toolchain.sha256,
        )

    # Register all toolchains
    # Note: In Bzlmod, toolchains are registered via the generated repo
    return module_ctx.extension_metadata(
        root_module_direct_deps = [
            "verilator_v{version}".format(version = t.version)
            for t in toolchains
        ],
        root_module_direct_dev_deps = [],
    )

verilator = module_extension(
    implementation = _verilator_extension_impl,
    tag_classes = {
        "toolchain": tag_class(attrs = _toolchain_attrs),
    },
)

