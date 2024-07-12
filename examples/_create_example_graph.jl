using Plasmo

function build_graph_example()
    graph1 = OptiGraph()

    @optinode(graph1, n1)
    @variable(n1, x >= 0)
    @variable(n1, y >= 2)
    @constraint(n1, x + y >= 3)
    @objective(n1, Min, y)

    @optinode(graph1, n2)
    @variable(n2, x >= 0)
    @variable(n2, y >= 2)
    @constraint(n2, x + y >= 3)
    @objective(n2, Min, y)

    @optinode(graph1, n3)
    @variable(n3, x >= 0)
    @variable(n3, y >= 2)
    @constraint(n3, x + y >= 3)
    @objective(n3, Min, y)

    @linkconstraint(graph1, n1[:x] + n2[:x] + n3[:x] == 3)

    graph2 = OptiGraph()

    @optinode(graph2, n4)
    @variable(n4, x >= 0)
    @variable(n4, y >= 2)
    @constraint(n4, x + y >= 5)
    @objective(n4, Min, y)

    @optinode(graph2, n5)
    @variable(n5, x >= 0)
    @variable(n5, y >= 2)
    @constraint(n5, x + y >= 5)
    @objective(n5, Min, y)

    @optinode(graph2, n6)
    @variable(n6, x >= 0)
    @variable(n6, y >= 2)
    @constraint(n6, x + y >= 5)
    @objective(n6, Min, y)

    @linkconstraint(graph2, n4[:x] + n5[:x] + n6[:x] == 5)

    graph3 = OptiGraph()

    @optinode(graph3, n7)
    @variable(n7, x >= 0)
    @variable(n7, y >= 2)
    @constraint(n7, x + y >= 7)
    @objective(n7, Min, y)

    @optinode(graph3, n8)
    @variable(n8, x >= 0)
    @variable(n8, y >= 2)
    @constraint(n8, x + y >= 7)
    @objective(n8, Min, y)

    @optinode(graph3, n9)
    @variable(n9, x >= 0)
    @variable(n9, y >= 2)
    @constraint(n9, x + y >= 7)
    @objective(n9, Min, y)

    @linkconstraint(graph3, n7[:x] + n8[:x] + n9[:x] == 7)

    graph0 = OptiGraph()
    @optinode(graph0, n0)
    @variable(n0, x)
    @constraint(n0, x >= 0)

    add_subgraph(graph0, graph1)
    add_subgraph(graph0, graph2)
    add_subgraph(graph0, graph3)
    @linkconstraint(graph0, n3[:x] + n5[:x] + n7[:x] == 10)

    @linkconstraint(graph0, n0[:x] + n3[:x] == 3)
    @linkconstraint(graph0, n0[:x] + n5[:x] == 5)
    @linkconstraint(graph0, n0[:x] + n7[:x] == 7)

    return graph0
end
