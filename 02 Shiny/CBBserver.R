# server.R
require("jsonlite")
require("RCurl")
require(ggplot2)
require(dplyr)
require(shiny)
require(shinydashboard)
require(leaflet)
require(DT)

shinyServer(function(input, output) {
  
  KPI_Low_Max_value <- reactive({input$KPI1})     
  KPI_Medium_Max_value <- reactive({input$KPI2})
  rv <- reactiveValues(alpha = 0.50)
  observeEvent(input$light, { rv$alpha <- 0.50 })
  observeEvent(input$dark, { rv$alpha <- 0.75 })
  
  df1 <- eventReactive(input$clicks1, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
    "select * from CBB order by pos;"
    ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_ba7433', PASS='orcl_ba7433', 
                                                                                                   MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON', p1=KPI_Low_Max_value(), p2=KPI_Medium_Max_value()), verbose = TRUE)))
  })
  
  output$distPlot1 <- renderPlot({             
    plot <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      labs(title=isolate(input$title)) +
      labs(x=paste("COLOR"), y=paste("CLARITY")) +
      layer(data=df1(), 
            mapping=aes(x=COLOR, y=CLARITY, label=SUM_PRICE), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=df1(), 
            mapping=aes(x=COLOR, y=CLARITY, fill=KPI), 
            stat="identity", 
            stat_params=list(), 
            geom="tile",
            geom_params=list(alpha=rv$alpha), 
            position=position_identity()
      )
    plot
  }) 
  
  observeEvent(input$clicks, {
    print(as.numeric(input$clicks))
  })
  
  # Begin code for Second Tab:
  
  df2 <- eventReactive(input$clicks2, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
                                                                                 "select color, clarity, avg_price, avg(avg_price) 
                                                                                 OVER (PARTITION BY clarity ) as window_avg_price
                                                                                 from (select color, clarity, avg(price) avg_price
                                                                                 from diamonds
                                                                                 group by color, clarity)
                                                                                 order by clarity;"
                                                                                 ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_UTEid', PASS='orcl_UTEid', 
                                                                                                   MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
  })
  
  output$distPlot2 <- renderPlot(height=1000, width=2000, {
    plot1 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_continuous() +
      facet_wrap(~CLARITY, ncol=1) +
      labs(title='Diamonds Barchart\nAVERAGE_PRICE, WINDOW_AVG_PRICE, ') +
      labs(x=paste("COLOR"), y=paste("AVG_PRICE")) +
      layer(data=df2(), 
            mapping=aes(x=COLOR, y=AVG_PRICE), 
            stat="identity", 
            stat_params=list(), 
            geom="bar",
            geom_params=list(colour="blue"), 
            position=position_identity()
      ) + coord_flip() +
      layer(data=df2(), 
            mapping=aes(x=COLOR, y=AVG_PRICE, label=round(AVG_PRICE - WINDOW_AVG_PRICE)), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black", hjust=-1), 
            position=position_identity()
      ) +
      layer(data=df2(), 
            mapping=aes(yintercept = WINDOW_AVG_PRICE), 
            geom="hline",
            geom_params=list(colour="red")
      )
    plot1
  })
  
  # Begin code for Third Tab:
  
  df3 <- eventReactive(input$clicks3, {data.frame(fromJSON(getURL(URLencode(gsub("\n", " ", 'skipper.cs.utexas.edu:5001/rest/native/?query=
                                                                                 """select region || \\\' \\\' || \\\'Sales\\\' as measure_names, sum(sales) as measure_values from SUPERSTORE_SALES_ORDERS
                                                                                 where country_region = \\\'United States of America\\\'
                                                                                 group by region
                                                                                 union all
                                                                                 select market || \\\' \\\' || \\\'Coffee_Sales\\\' as measure_names, sum(coffee_sales) as measure_values from COFFEE_CHAIN
                                                                                 group by market
                                                                                 order by 1;"""
                                                                                 ')), httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_UTEid', PASS='orcl_UTEid', 
                                                                                                   MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE)))
  })
  
  output$distPlot3 <- renderPlot(height=1000, width=2000, {
    plot3 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_continuous() +
      #facet_wrap(~CLARITY, ncol=1) +
      labs(title='Blending 2 Data Sources') +
      labs(x=paste("Region Sales"), y=paste("Sum of Sales")) +
      layer(data=df3(), 
            mapping=aes(x=MEASURE_NAMES, y=MEASURE_VALUES), 
            stat="identity", 
            stat_params=list(), 
            geom="bar",
            geom_params=list(colour="blue"), 
            position=position_identity()
      ) + coord_flip() +
      layer(data=df3(), 
            mapping=aes(x=MEASURE_NAMES, y=MEASURE_VALUES, label=round(MEASURE_VALUES)), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black", hjust=-0.5), 
            position=position_identity()
      )
    plot3
  })
  
  # Begin code for Fourth Tab:
  output$map <- renderLeaflet({leaflet() %>% addTiles() %>% setView(-93.65, 42.0285, zoom = 17) %>% addPopups(-93.65, 42.0285, 'Here is the Department of Statistics, ISU')
  })
  
  # Begin code for Fifth Tab:
  output$table <- renderDataTable({datatable(df1())
  })
})
