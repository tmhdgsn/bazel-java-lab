def _invoker_impl(ctx):
    out = ctx.actions.declare_file("generated.yaml")

    main_advice_classpath = []
    for dep in ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list():
        main_advice_classpath += [dep.path]

    args = ctx.actions.args()

    args.add("--main_advice_classpath=" + ":".join(main_advice_classpath))
    args.add(ctx.attr.main_class)
    args.add(out)

    resolved_tools = ctx.resolve_tools(tools = [ctx.attr.tool])
    resolved_inputs = resolved_tools[0]
    resolved_input_manifests = resolved_tools[1]
    # resolved_inputs = [<generated file subtool/libsubtool.jar>]

    runfiles = ctx.attr.tool[DefaultInfo].default_runfiles.files.to_list()
    # runfiles has the file we need (subtool/foo.yaml), but passing runfiles to ctx.actions.run inputs
    # only makes them available at execroot/my_workspace/subtool/foo.yaml

    tool_files_to_run = ctx.attr.tool[DefaultInfo].files_to_run
    # the executable and runfiles_manifest fields of the subtools FileToRunProvider are both None.

    ctx.actions.run(
        arguments = [args],
        executable = ctx.attr._invoker[DefaultInfo].files_to_run,
        inputs = ctx.attr.tool[JavaInfo].transitive_runtime_deps.to_list() + resolved_inputs.to_list() + runfiles,
        outputs = [out],
        input_manifests = resolved_input_manifests,
        tools = [tool_files_to_run],
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
