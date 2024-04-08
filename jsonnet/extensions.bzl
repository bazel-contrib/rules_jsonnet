def _get_jsonnet_compiler(module_ctx):
    """_get_jsonnet_compiler resolves a Jsonnet compiler from the module graph."""

    modules_with_compiler = [
        module
        for module in module_ctx.modules
        if module.tags.compiler
    ]

    if not modules_with_compiler:
        return "go"

    for module in modules_with_compiler:
        if len(module.tags.compiler) != 1:
            fail(
                "Only one compiler can be specified, got: %s" %
                [compiler.name for compiler in module.tags.compiler],
            )

        if module.is_root:
            return module.tags.compiler[0].name

    compiler_name = modules_with_compiler[0].tags.compiler[0].name
    for module in modules_with_compiler:
        if module.tags.compiler[0].name != compiler_name:
            fail(
                "Different compilers specified by different modules, got: %s. " %
                [compiler_name, module.tags.compiler[0].name] +
                "Specify a compiler in the root module to resolve this.",
            )

    return compiler_name

def _jsonnet_impl(module_ctx):
    _jsonnet_toolchain_repo(
        name = "rules_jsonnet_toolchain",
        compiler = _get_jsonnet_compiler(module_ctx),
    )

jsonnet = module_extension(
    implementation = _jsonnet_impl,
    tag_classes = {
        "compiler": tag_class(
            attrs = {
                "name": attr.string(),
            },
        ),
    },
)

def _jsonnet_toolchain_repo_impl(ctx):
    ctx.file(
        "BUILD.bazel",
        content = """
alias(
    name = "toolchain",
    actual = "@io_bazel_rules_jsonnet//jsonnet:%s_jsonnet_toolchain",
)
""" % ctx.attr.compiler,
        executable = False,
    )

_jsonnet_toolchain_repo = repository_rule(
    implementation = _jsonnet_toolchain_repo_impl,
    attrs = {
        "compiler": attr.string(),
    },
)
