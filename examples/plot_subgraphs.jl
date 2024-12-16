using Plasmo
using Plots, PlasmoPlots
gr()

include(joinpath(@__DIR__, "_create_example_graph.jl"))

graph0 = build_graph_example()

plt_graph2 = layout_plot(
    graph0;
    node_labels=true,
    markersize=60,
    labelsize=30,
    linewidth=4,
    subgraph_colors=true,
    layout_options=Dict(:tol => 0.001, :C => 2, :K => 4, :iterations => 20),
);

plt_matrix2 = matrix_plot(graph0; node_labels=true, subgraph_colors=true, markersize=16);
