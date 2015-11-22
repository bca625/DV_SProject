# server.R
require(jsonlite)
require(RCurl)
require(ggplot2)
require(dplyr)
require(tidyr)
require(shiny)
require(leaflet)
require(shinydashboard)
require(DT)

shinyServer(function(input, output) {
  
  df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="select * from CBB order by pos"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_ba7433', PASS='orcl_ba7433', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE) ))
  
  

  
  #Points By Position Bar Chart
  output$pointsbypos <- renderPlot({
    plot2 <- ggplot(df, aes(CONF, PTS, fill=POS)) + geom_bar(stat="identity") + geom_hline(yintercept=23425) + coord_flip()
    
    return(plot2)
    
  })
  
  
  #Points By Division Bar Chart
  output$pointsbydiv <- renderPlot({
    plot3 <- ggplot(df, aes(CONF, PTS, fill=CONF)) + geom_bar(stat="identity") + geom_hline(yintercept=23425) + coord_flip()
    
    return(plot3)
  })
  
  
  #Points By Classification Crosstab
  output$classcrosstab <- renderPlot({
    KPI_Low_Max_value = 3     
    KPI_Medium_Max_value = 7
    
    
    crosstab <- df %>% 
      filter(CONF == "Big 12") %>% 
      group_by(SCHOOL, CLASS) %>% 
      #summarize(sum_pts = sum(PTS), sum_games = sum(G)) %>% 
      mutate(PPG = PTS / G) %>% 
      summarize(avg_pts = mean(PPG)) %>% 
      mutate(kpi = ifelse(avg_pts <= KPI_Low_Max_value, 'Low', ifelse(avg_pts <= KPI_Medium_Max_value, 'Medium', 'High'))) %>% 
      rename(KPI=kpi)
    
    #Points by Classification in the Big 12
    plot4 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      labs(title='Points by Classification in the Big 12') +
      labs(x=paste("SCHOOL"), y=paste("CLASS")) +
      layer(data=crosstab, 
            mapping=aes(x=SCHOOL, y=CLASS, label=round(avg_pts, 2)), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=crosstab, 
            mapping=aes(x=SCHOOL, y=CLASS, fill=KPI), 
            stat="identity", 
            stat_params=list(), 
            geom="tile",
            geom_params=list(alpha=0.50), 
            position=position_identity()
      )
    
    return(plot4)
    
  })
  
  
  
  #Points By Position Crosstab
  output$poscrosstab <- renderPlot({
    KPI_Low_Max_value = 3     
    KPI_Medium_Max_value = 7
    
    crosstab <- df %>% 
      filter(CONF == "Big 12") %>% 
      group_by(SCHOOL, POS) %>% 
      #summarize(sum_pts = sum(PTS), sum_games = sum(G)) %>% 
      mutate(PPG = PTS / G) %>% 
      summarize(avg_pts = mean(PPG)) %>% 
      mutate(kpi = ifelse(avg_pts <= KPI_Low_Max_value, 'Low', ifelse(avg_pts <= KPI_Medium_Max_value, 'Medium', 'High'))) %>% 
      rename(KPI=kpi)
    
    #Points by Position
    plot5 <- ggplot() + 
      coord_cartesian() + 
      scale_x_discrete() +
      scale_y_discrete() +
      labs(title='Points by Position in the Big 12') +
      labs(x=paste("SCHOOL"), y=paste("POSITION")) +
      layer(data=crosstab, 
            mapping=aes(x=SCHOOL, y=POS, label=round(avg_pts, 2)), 
            stat="identity", 
            stat_params=list(), 
            geom="text",
            geom_params=list(colour="black"), 
            position=position_identity()
      ) +
      layer(data=crosstab, 
            mapping=aes(x=SCHOOL, y=POS, fill=KPI), 
            stat="identity", 
            stat_params=list(), 
            geom="tile",
            geom_params=list(alpha=0.50), 
            position=position_identity()
      )
    
    
    return(plot5)
  })
    
  
  
  output$assistsbypos <- renderPlot({
    
    #PNN = Position Not NUll
    PNN <- df %>% filter(POS != "null") %>% tbl_df
    
    #Assist by Position
    plot6 <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      labs(title='Assists By Position') +
      labs(x="Minutes Played", y=paste("Assists")) +
      layer(data=PNN, 
            mapping=aes(x=MP, y=AST, color=POS), 
            stat="identity", 
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            #position=position_identity()
            position=position_jitter(width=0.3, height=0)
      )
    
    return(plot6)
    
  })
  
  
  output$rebsbypos <- renderPlot({
    #PNN = Position Not NUll
    PNN <- df %>% filter(POS != "null") %>% tbl_df
    
    #Rebounds by Position
    plot7 <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      labs(title='Rebounds By Position') +
      labs(x="Minutes Played", y=paste("Total Rebounds")) +
      layer(data=PNN, 
            mapping=aes(x=MP, y=TRB, color=POS), 
            stat="identity", 
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            #position=position_identity()
            position=position_jitter(width=0.3, height=0)
      )
    
    return(plot7)
    
  })
  
  output$stealsbypos <- renderPlot({
    #PNN = Position Not NUll
    PNN <- df %>% filter(POS != "null") %>% tbl_df

    #Steals by position
    plot8 <- ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      labs(title='Steals By Position') +
      labs(x="Personal Fouls", y=paste("Steals")) +
      layer(data=PNN, 
            mapping=aes(x=as.numeric(as.character(PF)), y=as.numeric(as.character(STL)), color=POS), 
            stat="identity", 
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            #position=position_identity()
            position=position_jitter(width=0.3, height=0)
      )
    
    return(plot8)
        
  })
  
  output$blocksbypos <- renderPlot({
    #PNN = Position Not NUll
    PNN <- df %>% filter(POS != "null") %>% tbl_df

    #Blocks by Position
    ggplot() + 
      coord_cartesian() + 
      scale_x_continuous() +
      scale_y_continuous() +
      labs(title='Blocks By Position') +
      labs(x="Personal Fouls", y=paste("Blocks")) +
      layer(data=PNN, 
            mapping=aes(x=as.numeric(as.character(PF)), y=as.numeric(as.character(BLK)), color=POS), 
            stat="identity", 
            stat_params=list(), 
            geom="point",
            geom_params=list(), 
            #position=position_identity()
            position=position_jitter(width=0.3, height=0)
      )    
  })
  
  
})