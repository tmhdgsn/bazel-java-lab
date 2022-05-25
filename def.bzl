def _invoker_impl(ctx):
    out = ctx.actions.declare_file("generated.yaml")

    main_advice_classpath = []
    for dep in ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list():
        main_advice_classpath += [dep.path]

    args = ctx.actions.args()

    args.add("--main_advice_classpath=" + ":".join(main_advice_classpath))
    args.add(ctx.attr.main_class)
    args.add(out)

    tool_runfiles = ctx.attr.tool[DefaultInfo].default_runfiles.files

    ctx.actions.run(
        arguments = [args],
        executable = ctx.attr._invoker[DefaultInfo].files_to_run,
        inputs = ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list() + tool_runfiles.to_list(),
        outputs = [out],
    )

    return [
        DefaultInfo(
            files = depset([out]),
        ),
    ]

invoker = rule(
    implementation = _invoker_impl,
    attrs = {
        "main_class": attr.string(mandatory = True),
        "tool": attr.label(mandatory = True),
        "_invoker": attr.label(
            default = "//invoker:Invoker",
            executable = True,
            cfg = "host",
        ),
    },
)
