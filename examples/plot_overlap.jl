using Plasmo
using Plots, PlasmoPlots
gr()

include(joinpath(@__DIR__, "_create_example_graph.jl"))

graph0 = build_graph_example()

projection = Plasmo.hyper_projection(graph0)

expanded_graphs = [Plasmo.expand(projection, graph0.subgraphs[i], 1) for i in 1:3]

plt_graph3 = layout_plot(
    graph0,
    expanded_graphs;
    node_labels=true,
    markersize=20,
    labelsize=10,
    linewidth=4,
    layout_options=Dict(:tol => 0.001, :C => 2, :K => 4, :iterations => 10),
);

plt_matrix3 = matrix_plot(
    graph0, expanded_graphs; node_labels=true, subgraph_colors=true, labelsize=12
);
