JsonnetToolchainInfo = provider(
    doc = "Jsonnet toolchain provider",
    fields = {
        "compiler": "The file to the Jsonnet compiler",
        "create_directory_flags": "The flags to pass when creating a directory.",
        "manifest_file_support": (
            "If the Jsonnet compiler supports writing the output filenames to a " +
            "manifest file."
        ),
    },
)

def _jsonnet_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        jsonnetinfo = JsonnetToolchainInfo(
            compiler = ctx.executable.compiler,
            create_directory_flags = ctx.attr.create_directory_flags,
            manifest_file_support = ctx.attr.manifest_file_support,
        ),
    )
    return [toolchain_info]

jsonnet_toolchain = rule(
    implementation = _jsonnet_toolchain_impl,
    doc = "The Jsonnet compiler information.",
    attrs = {
        "compiler": attr.label(
            executable = True,
            cfg = "exec",
        ),
        "create_directory_flags": attr.string_list(
            mandatory = True,
            doc = (
                "The flags passed to the Jsonnet compiler when a directory " +
                "must be created."
            ),
        ),
        "manifest_file_support": attr.bool(
            mandatory = True,
            doc = (
                "If the Jsonnet compiler supports writing the output filenames " +
                "to a manifest file."
            ),
        ),
    },
)
