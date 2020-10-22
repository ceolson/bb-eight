library(reticulate)
library(plotly)
library(purrr)
library(stringr)
library(readr)

##########################################################################
# Hyperparameters:
# c1 is whether cohort 1 is included, analogous for c2, c3, c4
#
# lvwt_th and sbp_th divide the space of individuals into four quadrants
# quadrant selects which one is the cases
#
#         sbp_th
#           |
#      2    |    1
#           |
#   --------+-------- lvwt_th
#           |
#      3    |    4
#           |
##########################################################################

# IF YOU DON'T ALREADY HAVE data/pens.csv, RUN THIS SECTION
# This will use scripts/compute_pens.py to compute penetrances 
# for various choices of hyperparameters and save them in a 
# csv file. It takes several hours to run.
# =========================================================
# py_install(c("scipy",
#              "pandas",
#              "numpy",
#              "sqlite",
#              "networkx",
#              "python-graphviz",
#              "pydot",
#              "pygraphviz"))
# 
# source_python("scripts/compute_pens.py")
# pens <- compute_pens("data/bdc-test.db", "data/variants.db")
# 
# pens$cohort1 <- sapply(pens$cohort1, '[[', 1)
# pens$cohort2 <- sapply(pens$cohort2, '[[', 1)
# pens$cohort3 <- sapply(pens$cohort3, '[[', 1)
# pens$cohort4 <- sapply(pens$cohort4, '[[', 1)
# pens$quadrant <- sapply(pens$quadrant, '[[', 1)
# 
# write.csv(pens, file = "data/pens.csv")
# =========================================================

# IF YOU ALREADY HAVE data/pens.csv, JUST RUN THIS
# =========================================================
pens <- read_csv("data/pens.csv")
# =========================================================

# Jiggle discrete variables for better plotting
pens$cohort1_noisy = as.integer(pens$cohort1) + runif(nrow(pens), min = -0.2, max = 0.2)
pens$cohort2_noisy = as.integer(pens$cohort2) + runif(nrow(pens), min = -0.2, max = 0.2)
pens$cohort3_noisy = as.integer(pens$cohort3) + runif(nrow(pens), min = -0.2, max = 0.2)
pens$cohort4_noisy = as.integer(pens$cohort4) + runif(nrow(pens), min = -0.2, max = 0.2)
pens$quadrant_noisy = as.integer(pens$quadrant) + runif(nrow(pens), min = -0.2, max = 0.2)

# SCATTERPLOT
# <><><><><><><><><><><><><><><><><><><><>
fig <- plot_ly(pens, 
               x = ~`cohort1_noisy`, 
               y = ~`cohort1_noisy`,
               xaxis = list(title = ""),
               yaxis = list(title = ""),
               hoverinfo = 'text',
               text = ~paste('Penetrance: ', penetrance, '<br>',
                             'Mode: ', mode, '<br>',
                             "Cohort 1:", cohort1, "<br>",
                             "Cohort 2:", cohort2, "<br>",
                             "Cohort 3:", cohort3, "<br>",
                             "Cohort 4:", cohort4, "<br>",
                             "LVWT threshold:", `LVWT threshold`, "<br>",
                             "SBP threshold:", `SBP threshold`, "<br>",
                             "Quadrant:", quadrant
               ),
               type = 'scatter',
               mode = 'marker',
               marker = list(color = ~penetrance,
                             size = ~penetrance,
                             opacity = 0.5,
                             sizeref = max(filter(pens, mode == "map")$penetrance) / 50,
                             sizemin = 3,
                             showscale = TRUE),
               transforms = list(list(type = 'filter',    # filter by estimate mode
                                      target = ~mode,
                                      operation = '=',
                                      value = "map"
               ))
    ) %>%
    layout(xaxis = list(title = "", zeroline = FALSE), 
           yaxis = list(title = "", zeroline = FALSE)) %>%
    layout(
        updatemenus = list(
            list(type = "dropdown",                # x axis dropdown
                 x = 0.55,
                 y = 1,
                 buttons = list(
                     list(method = "restyle",
                          label = "Cohort 1",
                          args = list(
                              "x", list(pens$cohort1_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 2",
                          args = list(
                              "x", list(pens$cohort2_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 3",
                          args = list(
                              "x", list(pens$cohort3_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 4",
                          args = list(
                              "x", list(pens$cohort4_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "LVWT threshold",
                          args = list(
                              "x", list(pens$`LVWT threshold`)
                          )
                     ),
                     list(method = "restyle",
                          label = "SBP threshold",
                          args = list(
                              "x", list(pens$`SBP threshold`)
                          )
                     ),
                     list(method = "restyle",
                          label = "quadrant",
                          args = list(
                              "x", list(pens$quadrant_noisy)
                          )
                     )
                 )
            ),
            list(type = "dropdown",                # y axis dropdown
                 y = 0.5,
                 buttons = list(
                     list(method = "restyle",
                          label = "Cohort 1",
                          args = list(
                              "y", list(pens$cohort1_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 2",
                          args = list(
                              "y", list(pens$cohort2_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 3",
                          args = list(
                              "y", list(pens$cohort3_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "Cohort 4",
                          args = list(
                              "y", list(pens$cohort4_noisy)
                          )
                     ),
                     list(method = "restyle",
                          label = "LVWT threshold",
                          args = list(
                              "y", list(pens$`LVWT threshold`)
                          )
                     ),
                     list(method = "restyle",
                          label = "SBP threshold",
                          args = list(
                              "y", list(pens$`SBP threshold`)
                          )
                     ),
                     list(method = "restyle",
                          label = "quadrant",
                          args = list(
                              "y", list(pens$quadrant_noisy)
                          )
                     )
                 )
            ),
            list(type = "dropdown",                # estimate mode dropdown
                 buttons = list(
                     list(method = "restyle",
                          args = list(list(
                              "transforms[0].value" = list("map"),
                              "marker.sizeref" = list(max(filter(pens, mode == "map")$penetrance) / 50)
                          )),
                          label = "MAP"),
                     list(method = "restyle",
                          args = list(list(
                              "transforms[0].value" = list("95"),
                              "marker.sizeref" = list(max(filter(pens, mode == "95")$penetrance) / 50)
                          )),
                          label = "95"),
                     list(method = "restyle",
                          args = list(list(
                              "transforms[0].value" = list("5"),
                              "marker.sizeref" = list(max(filter(pens, mode == "5")$penetrance) / 50)
                          )),
                          label = "5")
                 )
            )
        )
    )
# <><><><><><><><><><><><><><><><><><><><>

# TREE
# <><><><><><><><><><><><><><><><><><><><>
source_python("scripts/tree.py")
graph_info <- compute_graph("data/pens.csv")

# just some formatting stuff to make nice labels
nodes2label <- function(node) {
    split <- strsplit(node, "\\], \\[")
    return(lapply(split, function(str) return(str_remove_all(str, "[\\[\\]]")))[[1]])
}
graph_info$labels = lapply(graph_info$nodes, nodes2label)

# given a lvwt_th, sbp_th, and quadrant, output a tree plotly figure
make_tree_fig <- function(lvwt_th, sbp_th, quadrant) {
    if (lvwt_th == "all") {
        lvwt_th = -1    # tree.py understands -1 as "unspecified"
    }
    if (sbp_th == "all") {
        sbp_th = -1     # tree.py understands -1 as "unspecified"
    }
    
    fig2 <- plot_ly(
        x=graph_info$edge_x, 
        y=graph_info$edge_y,
        line=list(width=0, color="#888"),
        hoverinfo="none",
        mode="marker+lines",
        type="scatter"
    ) %>%
        add_trace(
            x=graph_info$edge_x,
            y=graph_info$edge_y,
            line=list(width=1, color="#888"),
            hoverinfo="none",
            mode="marker+lines",
            type="scatter"
        ) %>%
        add_trace(
            x=graph_info$node_x, 
            y=graph_info$node_y,
            mode="marker+lines",
            type="scatter",
            hoverinfo="text",
            text=paste("Penetrance",
                       lapply(graph_info$nodes, 
                              function(node) 
                                  return(lookup_penetrance_tree(node, 
                                                                 lvwt_th, 
                                                                 sbp_th, 
                                                                 quadrant, 
                                                                 "data/pens.csv"))), 
                       "<br>",
                       "Cohort 1?", sapply(graph_info$labels, '[[', 1), "<br>",
                       "Cohort 2?", sapply(graph_info$labels, '[[', 2), "<br>",
                       "Cohort 3?", sapply(graph_info$labels, '[[', 3), "<br>",
                       "Cohort 4?", sapply(graph_info$labels, '[[', 4)),
            marker=list(
                color=lapply(graph_info$nodes, 
                             function(node) 
                                 return(lookup_penetrance_tree(node, 
                                                                lvwt_th, 
                                                                sbp_th, 
                                                                quadrant, 
                                                                "data/pens.csv"))),
                showscale = TRUE,
                size=30,
                line=list(width=2, color='Black')
            )) %>%
        add_trace(
            x=-80,
            y=unique(graph_info$node_y) - 70,
            mode="text",
            text=c("Cohort 1", "Cohort 2", "Cohort 3", "Cohort 4", "")
        ) %>%
        add_trace(
            x=c(600, 1050),
            y=unique(graph_info$node_y)[1] - 70,
            mode="text",
            text=c("<--  include", "exclude  -->")
        ) %>%
        layout(xaxis=list(zeroline = FALSE,
                          showline = FALSE,
                          showticklabels = FALSE,
                          showgrid = FALSE),
               yaxis=list(zeroline = FALSE,
                          showline = FALSE,
                          showticklabels = FALSE,
                          showgrid = FALSE),
               showlegend = FALSE
        )
    return(fig2)
}
# <><><><><><><><><><><><><><><><><><><><>

ui <- fluidPage(
    headerPanel('Effect of Hyperparameter Selection on Penetrance Estimates'),
    mainPanel(
        h2("Scatterplot"),
        h5("Colors of nodes are the penetrance computed with the specified hyperparameters. Discrete variables are randomly preturbed for easier visualization."),
        plotlyOutput("plot"),
        h2("Inclusion/Exclusion of Cohorts"),
        h5("Colors of nodes are the MAP penetrance, averaged over the unspecified choices of hyperparameters."),
        selectInput(
            "lvwt_th",
            "LVWT threshold",
            append(c("all"), seq(0.6, 1., by = 0.05), )
        ),
        selectInput(
            "sbp_th",
            "SBP threshold",
            append(c("all"), seq(0.6, 1., by = 0.05))
        ),
        plotlyOutput('tree')
    )
)

server <- function(input, output) {
    output$plot <- renderPlotly(
        fig
    )
    output$tree <- renderPlotly(
        make_tree_fig(
            lvwt_th = input$lvwt_th,
            sbp_th = input$sbp_th,
            1           # only do quadrant 1
        )
    )
}

shinyApp(ui,server)