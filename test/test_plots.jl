const EXAMPLES = filter(
    ex -> endswith(ex, ".jl") && ex != "run_examples.jl",
    readdir(joinpath(@__DIR__, "../examples")),
)

for example in EXAMPLES
    if example == "_create_example_graph.jl"
        continue
    else
        include(joinpath(@__DIR__, "../examples", example))
    end
end
