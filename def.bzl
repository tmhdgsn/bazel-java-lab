def _merged_binary_impl(ctx):
    invoker = ctx.attr._invoker
    executable = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.symlink(output = executable, target_file = invoker[DefaultInfo].files_to_run.executable)

    runfiles = invoker[DefaultInfo].default_runfiles.merge(ctx.attr.tool[DefaultInfo].default_runfiles)
    return [
        DefaultInfo(
            executable = executable,
            runfiles = runfiles,
        ),
    ]

_merged_binary = rule(
    implementation = _merged_binary_impl,
    attrs = {
        "_invoker": attr.label(
            default = "//invoker:Invoker",
            executable = True,
            cfg = "host",
        ),
        "tool": attr.label(
            mandatory = True,
        ),
    },
    executable = True,
)

def _invoker_impl(ctx):
    out = ctx.actions.declare_file("generated.yaml")

    main_advice_classpath = []
    for dep in ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list():
        main_advice_classpath += [dep.path]

    args = ctx.actions.args()

    args.add("--main_advice_classpath=" + ":".join(main_advice_classpath))
    args.add(ctx.attr.main_class)
    args.add(out)

    ctx.actions.run(
        arguments = [args],
        executable = ctx.executable.invoker,
        inputs = ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list(),
        outputs = [out],
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
    ]

_invoker = rule(
    implementation = _invoker_impl,
    attrs = {
        "main_class": attr.string(mandatory = True),
        "invoker": attr.label(
            mandatory = True,
            executable = True,
            cfg = "host",
        ),
        "tool": attr.label(mandatory = True),
    },
)

def invoker(name, **kwargs):
    _merged_binary(
        name = name + "_invoker",
        tool = kwargs["tool"],
    )
    _invoker(
        name = name,
        invoker = name + "_invoker",
        **kwargs
    )
