#ui.R 

library(shiny)
require(shinydashboard)
require(leaflet)

# Define UI for application that plots random distributions 
dashboardPage(
  # Application title
  dashboardHeader(title = "NCAA Men's Basketball Data", titleWidth = 350),
  dashboardSidebar(width = 350,
                   sidebarMenu(
                     menuItem("Points By Division", tabName = "pointsbydiv", icon = icon("bar-chart")),
                     menuItem("Points By Position", tabName = "pointsbypos", icon = icon("bar-chart")),
                     menuItem("Points By Classification in Big 12", tabName = "classcrosstab", icon = icon("table")),
                     menuItem("Points By Position in Big 12", tabName = "poscrosstab", icon = icon("table")),
                     menuItem("Assists By Position", tabName = "assistsbypos", icon = icon("line-chart")),
                     menuItem("Rebounds By Position", tabName = "rebsbypos", icon = icon("line-chart")),
                     menuItem("Steals By Position", tabName = "stealsbypos", icon = icon("line-chart")),
                     menuItem("Blocks By Position", tabName = "blocksbypos", icon = icon("line-chart")),
                     menuItem("Blending", tabName = "blending", icon = icon("link"))
                   )
  ),
  dashboardBody(
    tabItems(
      #first tab content
      tabItem(tabName = "pointsbydiv",
              h4("Points by Division: "),
              plotOutput("pointsbydiv")
      ),
      
      tabItem(tabName = "pointsbypos",
              h4("Points by Position: "),
              plotOutput("pointsbypos")
      ),
      
      tabItem(tabName = "classcrosstab",
              h4("Scatterplot: "),
              plotOutput("classcrosstab")
      ),
      
      tabItem(tabName = "poscrosstab",
              h4("Scatterplot: "),
              plotOutput("poscrosstab")
      ),
      
      tabItem(tabName = "assistsbypos",
              h4("Assists by Position: "),
              plotOutput("assistsbypos")
      ),
      
      tabItem(tabName = "rebsbypos",
              h4("Rebounds by Position: "),
              plotOutput("rebsbypos")
      ),

      tabItem(tabName = "stealsbypos",
              h4("Steals by Position: "),
              plotOutput("stealsbypos")
      ),
      
      tabItem(tabName = "blocksbypos",
              h4("Blocks by Position: "),
              plotOutput("blocksbypos")
      )
    )
  )
)
