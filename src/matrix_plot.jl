#Functions to plot matrix structure of optigraphs
rectangle(w, h, x, y) = Plots.Shape(x .+ [0,w,w,0], y .+ [0,0,h,h])

"""
    PlasmoPlots.matrix_plot(
        graph::OptiGraph;
        node_labels=false,
        labelsize=24,
        subgraph_colors=false,
        node_colors=false,
        markersize=1,
        include_variable_constraints=false,
    )

Plot a matrix visualization of the optigraph: `graph`. The following keyword arguments can be provided to customize the matrix visual.

* `node_labels = false`: whether to label nodes using the corresponding optinode label attribute.
* `labelsize`: the size for each node label.  Only active if `node_labels = true`.
* `subgraph_colors = false`: whether to color nodes according to their subgraph.
* `node_colors = false`: whether to color nodes.  Only active if `subgraph_colors = false`.
* `markersize = 1`: Size of the linking constraints in the matrix representation.
* `include_variable_constraints = false`: whether to include variable in set constraints
"""
function matrix_plot(
    graph::OptiGraph;
    node_labels = false,
    labelsize = 24,
    subgraph_colors = false,
    node_colors = false,
    markersize = 1,
    include_variable_constraints=false,
)

    n_graphs = Plasmo.num_local_subgraphs(graph)
    if subgraph_colors
        cols = Colors.distinguishable_colors(n_graphs + 1)
        if cols[1] == Colors.colorant"black"
            cols[1] = Colors.colorant"grey"
        end
        colors = cols[2:end]
    else
        colors = [Colors.colorant"grey" for _= 1:n_graphs]
    end

    if node_colors
        cols = Colors.distinguishable_colors(length(all_nodes(graph)) + 1)
        if cols[1] == Colors.parse(Colorant,"black")
            cols[1] = Colors.parse(Colorant,"grey")
        end
        node_cols = cols[2:end]
    end

    #Plot limits
    n_vars_total = num_variables(graph)
    n_cons_total = num_constraints(
        graph;
        count_variable_in_set_constraints=include_variable_constraints
    )

    n_all_cons_total = n_cons_total

    if n_all_cons_total >= 5
        yticks = Int64.(round.(collect(range(0,stop = n_all_cons_total,length = 5))))
    else
        yticks = Int64.(round.(collect(range(0,stop = n_all_cons_total,length = n_all_cons_total + 1))))
    end

    #Setup plot dimensions
    plt = Plots.plot(;
        xlims = [0,n_vars_total],
        ylims = [0,n_all_cons_total],
        legend = false,
        framestyle = :box,
        xlabel = "Node Variables",
        ylabel = "Constraints",
        size = (800,800),
        guidefontsize = 24,
        tickfontsize = 18,
        grid = false,
        yticks = yticks
    )

    #plot top level nodes, then start going down subgraphs
    n_link_constraints = num_local_link_constraints(graph)  #local links
    col = 0
    node_indices = Dict()
    node_col_ranges = Dict()
    for (i,node) in enumerate(Plasmo.all_nodes(graph))
        node_indices[node] = i
        node_col_ranges[node] = [col,col + Plasmo.num_variables(node)]
        col += Plasmo.num_variables(node)
    end

    row = n_all_cons_total  - n_link_constraints #- height_initial
    #draw node blocks for this graph
    for (i,node) in enumerate(local_nodes(graph))
        height = num_constraints(node, count_variable_in_set_constraints = include_variable_constraints)
        row -= height
        #row_start,row_end = node_row_ranges[node]
        row_start = row
        col_start,col_end = node_col_ranges[node]
        width = col_end - col_start

        row_end = row - height
        rec = rectangle(width,height,col_start,row_start)

        if !(node_colors)
            Plots.plot!(plt,rec,opacity = 1.0,color = :grey)
        else
            Plots.plot!(plt,rec,opacity = 1.0,color = node_cols[i])
        end
        if node_labels
            Plots.annotate!(plt,(col_start + width + col_start)/2,(row + height + row)/2,Plots.text(node.label.x,labelsize))
        end
    end

    #plot link constraints for highest level using rectangles
    row = n_all_cons_total
    #recs = []

    link_rows = []
    link_cols = []
    for link in local_link_constraints(graph)

        linkcon = constraint_object(link)
        vars = keys(linkcon.func.terms)
        for var in vars
            node = owner_model(var)

            col_start,col_end = node_col_ranges[node]
            col_start = col_start + var.index.value - 1 + 0.5

            #these are just points.
            #rec = rectangle(1,1,col_start,row)
            push!(link_rows,row - 0.5)
            push!(link_cols,col_start)
            # Plots.plot!(plt,rec,opacity = 1.0,color = :blue);
        end
        row -= 1
    end
    Plots.scatter!(
        plt,
        link_cols,
        link_rows,
        markersize = markersize,
        markercolor = :blue,
        markershape = :rect
    );

    if length(graph.optinodes) > 0
        row -= 1
    end

    _plot_subgraphs!(
        graph,
        plt,
        node_col_ranges,
        row,
        node_labels = node_labels,
        labelsize = labelsize,
        colors = colors,
        markersize = markersize
    )
    return plt
end

function _plot_subgraphs!(
    graph::OptiGraph,
    plt,
    node_col_ranges,
    row_start_graph;
    node_labels = false,
    labelsize = 24,
    colors = nothing,
    markersize = 1,
    include_variable_constraints=false,
)
    if colors == nothing
        colors = [Colors.parse(Colorant,"grey") for _= 1:Plasmo.num_local_subgraphs(graph)]
    end


    row_start_graph = row_start_graph
    for (i,subgraph) in enumerate(local_subgraphs(graph))

        link_rows = []
        link_cols = []
        row = row_start_graph

        for link in all_link_constraints(subgraph)
            linkcon = constraint_object(link)
            vars = keys(linkcon.func.terms)
            for var in vars
                node = owner_model(var)
                col_start,col_end = node_col_ranges[node]
                col_start = col_start + var.index.value - 1 + 0.5
                # rec = rectangle(1,1,col_start,row)
                # Plots.plot!(plt,rec,opacity = 1.0,color = :blue)
                push!(link_rows,row - 0.5)
                push!(link_cols,col_start)
            end
            row -= 1
        end
        Plots.scatter!(
            plt,
            link_cols,
            link_rows,
            markersize = markersize,
            markercolor = :blue,
            markershape = :rect
        );

        if !(isempty(subgraph.optinodes))
            subgraph_col_start = node_col_ranges[subgraph.optinodes[1]][1]
        else
            subgraph_col_start = 0
        end

        #draw node blocks for this graph
        for node in local_nodes(subgraph)
            height = num_constraints(
                node; count_variable_in_set_constraints=include_variable_constraints
            )
            row -= height
            row_start = row
            col_start,col_end = node_col_ranges[node]
            width = col_end - col_start

            rec = rectangle(width,height,col_start,row_start)
            Plots.plot!(plt,rec,opacity = 1.0,color = colors[i])
            if node_labels
                Plots.annotate!(
                    plt,
                    (col_start + width + col_start)/2,
                    (row + height + row)/2,
                    Plots.text(node.label.x,labelsize)
                )
            end

        end

        _plot_subgraphs!(
            subgraph,
            plt,
            node_col_ranges,
            row,
            node_labels = node_labels,
            labelsize = labelsize
        )

        num_cons = Plasmo.num_constraints(
            subgraph; count_variable_in_set_constraints=include_variable_constraints
        )
        num_vars = num_variables(subgraph)
        row_start_graph -= num_cons
        subgraph_row_start = row_start_graph

        rec = rectangle(num_vars,num_cons,subgraph_col_start,subgraph_row_start)
        Plots.plot!(plt,rec,opacity = 0.1,color = colors[i])

    end
end

#Overlap spy
function matrix_plot(
    graph::OptiGraph,
    subgraphs::Vector{OptiGraph};
    node_labels = false,
    labelsize = 24,
    subgraph_colors = true,
    include_variable_constraints=false,
)

    n_graphs = length(subgraphs)
    if subgraph_colors
        cols = Colors.distinguishable_colors(n_graphs + 1)
        if cols[1] == Colors.parse(Colorant,"black")
            cols[1] = Colors.parse(Colorant,"grey")
        end
        colors = cols[2:end]
    else
        colors = [Colors.parse(Colorant,"grey") for _= 1:n_graphs]
    end

    #Plot limits
    n_vars_total = sum(Plasmo.num_variables.(subgraphs))
    n_cons_total = sum(
        Plasmo.num_constraints.(
            subgraphs; count_variable_in_set_constraints=include_variable_constraints
        ),
    )
    n_all_cons_total = n_cons_total

    if n_all_cons_total >= 5
        yticks = Int64.(round.(collect(range(0,stop = n_all_cons_total,length = 5))))
    else
        yticks = Int64.(round.(collect(range(0,stop = n_all_cons_total,length = n_all_cons_total + 1))))
    end

    #Setup plot dimensions
    plt = Plots.plot(;
        xlims = [0,n_vars_total],
        ylims = [0,n_all_cons_total],
        legend = false,
        framestyle = :box,
        xlabel = "Node Variables",
        ylabel = "Constraints",
        size = (800,800),
        guidefontsize = 24,
        tickfontsize = 18,
        grid = false,
        yticks = yticks
    )

    row_start_graph = n_all_cons_total
    col_start_graph = 0
    for i = 1:length(subgraphs)
        subgraph = subgraphs[i]
        #column data for subgraph
        node_indices = Dict()
        node_col_ranges = Dict()

        col = col_start_graph
        for (i,node) in enumerate(all_nodes(subgraph))
            node_indices[node] = i
            node_col_ranges[node] = [col,col + num_variables(node)]
            col += num_variables(node)
        end

        #Now just plot columns of overlap nodes
        nodes = all_nodes(subgraph)
        overlap_nodes = Dict()
        for j = 1:length(subgraphs)
            if j != i
                other_subgraph = subgraphs[j]
                other_nodes = all_nodes(other_subgraph)
                overlap = intersect(nodes,other_nodes)
                overlap_nodes[j] = overlap
            end
        end
                #plot local column overlap
        link_rows = []
        link_cols = []
        row = row_start_graph
        for link in all_link_constraints(subgraph)
            row -= 1
            linkcon = constraint_object(link)
            vars = keys(linkcon.func.terms)
            for var in vars
                node = owner_model(var)
                col_start,col_end = node_col_ranges[node]
                col_start = col_start + var.index.value - 1
                push!(link_rows,row)
                push!(link_cols,col_start)
            end
        end
        Plots.scatter!(
            plt,
            link_cols,
            link_rows,
            markersize = 1,
            markercolor = :blue,
            markershape = :rect
        );

        #draw node blocks for this graph
        for node in local_nodes(subgraph)
            height = num_constraints(node, count_variable_in_set_constraints = include_variable_constraints)
            row -= height
            row_start = row
            col_start,col_end = node_col_ranges[node]
            width = col_end - col_start

            rec = rectangle(width,height,col_start,row_start)
            Plots.plot!(plt,rec,opacity = 1.0,color = colors[i])
            if node_labels
                Plots.annotate!(
                    plt,
                    (col_start + width + col_start)/2,
                    (row + height + row)/2,
                    Plots.text(node.label.x, labelsize)
                )
            end
        end

        num_cons = Plasmo.num_constraints(
            subgraph; count_variable_in_set_constraints=include_variable_constraints
        )
        num_vars = Plasmo.num_variables(subgraph)

        subgraph_plt_start = row
        rec = rectangle(num_vars,num_cons,col_start_graph,subgraph_plt_start)
        Plots.plot!(plt,rec,opacity = 0.1,color = colors[i])

        #overlap rectanges
        for (j,overlap) in overlap_nodes
            for node in overlap
                col_start,col_end = node_col_ranges[node]
                rec = rectangle(num_variables(node),num_cons,col_start,subgraph_plt_start)
                Plots.plot!(plt,rec,opacity = 0.1,color = colors[j])
            end
        end

        col_start_graph = col
        row_start_graph = row
    end

    return plt
end

Plots.spy(graph::OptiGraph;kwargs...) = matrix_plot(graph;kwargs...)
Plots.spy(graph::OptiGraph,subgraphs::Vector{OptiGraph};kwargs...) = matrix_plot(graph,subgraphs;kwargs...)
