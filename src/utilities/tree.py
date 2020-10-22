import networkx as nx
import graphviz
from networkx.drawing.nx_agraph import graphviz_layout
import copy
import pandas as pd
import numpy as np
import ast

# return info to print the tree
def compute_graph(pens_addr):
    pens = pd.read_csv(pens_addr)

    axes = ["cohort1", 
            "cohort2", 
            "cohort3", 
            "cohort4"]
    
    options = [[[True], [False]],
               [[True], [False]],
               [[True], [False]],
               [[True], [False]]]
    
    start = [[True, False],
             [True, False],
             [True, False],
             [True, False]]
    
    layers = [[start]]
    edges = []
    
    for i in range(len(axes)):
        new_layer = []
        for j in range(len(layers[-1])):
            for k in range(len(options[i])):
                node = copy.deepcopy(layers[-1][j])
                node[i] = options[i][k]
                new_layer.append(node)
                edges.append((str(layers[-1][j]), str(node)))
        layers.append(new_layer)
        
    def node2filter(node):
      c1, c2, c3, c4 = node
      filtered = pens[pens["cohort1"].isin(c1) & \
                      pens["cohort2"].isin(c2) & \
                      pens["cohort3"].isin(c3) & \
                      pens["cohort4"].isin(c4) & \
                      pens["mode"].isin(["map"])]
      
      return filtered
    
    tree = nx.DiGraph()
    for layer in layers:
        for node in layer:
            label = str(node).replace("], [", "]\n [")[1:-1]
            tree.add_nodes_from([(str(node), {"label": label})])
            
    for edge in edges:
        tree.add_edge(edge[0], edge[1])
    
    positions = graphviz_layout(tree, prog='dot')
    
    nodes = []
    node_x = []
    node_y = []
    for node in tree.nodes:
        nodes.append(node)
        x, y = positions[node]
        node_x.append(x)
        node_y.append(y)
    
    edge_x = []
    edge_y = []
    for edge in tree.edges():
        x0, y0 = positions[edge[0]]
        x1, y1 = positions[edge[1]]
        edge_x.append(x0)
        edge_x.append(x1)
        edge_x.append(None)
        edge_y.append(y0)
        edge_y.append(y1)
        edge_y.append(None)
        
    return {"nodes": nodes,
            "node_x": node_x, 
            "node_y": node_y, 
            "edge_x": edge_x, 
            "edge_y": edge_y}
        
# given some hyperparameters, look up the penetrance for those choices
# average over the unspecified hyperparameters
def lookup_penetrance_tree(node, lvwt_th, sbp_th, quadrant, pens_addr):
    c1, c2, c3, c4 = ast.literal_eval(node)
    pens = pd.read_csv(pens_addr)

    filtered = pens[
      pens["cohort1"].isin(c1) & \
      pens["cohort2"].isin(c2) & \
      pens["cohort3"].isin(c3) & \
      pens["cohort4"].isin(c4) & \
      pens["mode"].isin(["map"])
    ]
    
    if float(lvwt_th) > 0:
        filtered = filtered[
          filtered["LVWT threshold"].astype(float) == float(lvwt_th)
        ]
    if float(sbp_th) > 0:
        filtered = filtered[
          filtered["SBP threshold"].astype(float) == float(sbp_th)
        ]
    if float(quadrant) > 0:
        filtered = filtered[
          filtered["quadrant"].astype(float) == float(quadrant)
        ]
        
    return np.mean(filtered["penetrance"].astype(float))
