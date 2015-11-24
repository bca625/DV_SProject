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
                     menuItem("Blended Data: College vs. NBA", tabName = "blending", icon = icon("link"))
                   )
  ),
  dashboardBody(
    tabItems(
      #first tab content
      tabItem(tabName = "pointsbydiv",
              h4("Points by Division: "),
              h5("There are two big barometers in determining how successful a team is: how good are their players, and how tough was their competition? A team with a winning record in some conference full of scrubs like the AEC, isn't going to get the same credit or recognition as a team who battled it out through the grueling SEC or ACC conferences. To get a look at just how these conferences stack up against each other, we've created a bar chart of the total points scored by the schools in each division using the average amount of points and the 95% confidence interval as a reference line."),
              plotOutput("pointsbydiv"),
              h5("We can see the conferences that stand out above the rest. The ACC with powerhouses like Duke, North Carolina, Virginia, and Louisville; and the SEC with the 38-1 Kentucky Wildcats. And if you look right on the reference line you'll see the Big 12 conference, home to the University of Texas at Austin, sitting perfectly at the average.")
      ),
      
      
      tabItem(tabName = "pointsbypos",
              h4("Points by Position: "),
              h5("Prior to the NBA Draft, the two most talked about prospects were Duke's Jahlil Okafor and Kentucky's Karl-Anthony Towns, who both happen to be 7-foot tall, 260 pound athletic freaks-of-nature. However, the Los Angeles Lakers broke-away from their history of drafting big men, and selected Ohio State University's 6'5 point guard D'Angelo Russell with the number 2 pick. The Laker's front office caught a lot of flak for not going big, and only time will tell whether or not they made the right choice. For now, we can visualize the scoring contributions in college basketball by adding the 'position' dimension to color on the previous bar chart."),
              plotOutput("pointsbypos"),
              h5("We can see that a bulk of the scoring comes from Guard and Forward positions with the Centers putting up a few points here and there.")
      ),
      
      
      tabItem(tabName = "classcrosstab",
              h4("Points By Classification in Big 12: "),
              h5("Narrowing our view down to just the Big 12 conference, we can create a crosstab of the average points per game, broken down by school, classification, and position. We use a key performance indicator to classify the scoring performance according to where they fit within the quartiles. Scoring performances within the first quartile are labelled Low, second quartile labelled Below Average, third quartile labelled Above Average, and fourth quartile labelled High. The HPIs are tied to interact sliders so that the user can change them as they see fit."),
              sliderInput("KPI1", 
                          "KPI Low Max value:", 
                          min = 0,
                          max = 5, 
                          value = 3),
              sliderInput("KPI2", 
                          "KPI Medium Max value:", 
                          min = 5,
                          max = 13, 
                          value = 7),
              plotOutput("classcrosstab"),
              h5("Keep in mind that these are averages for ALL players at each position, so a performance like Myles Turners's 10.15 points per game would be averaged with fellow Freshman Jordan Barnett's 1.90 points per game.")
      ),
      
      tabItem(tabName = "poscrosstab",
              h4("Points By Position in Big 12: "),
              h5("This crosstab is similr to the previous one, however players are grouped by position and not their classification. For example, in this case, Myle's Turners number would be averaged with all the other forwards at Texas."),
              sliderInput("KPI1", 
                          "KPI Low Max value:", 
                          min = 0,
                          max = 5, 
                          value = 3),
              sliderInput("KPI2", 
                          "KPI Medium Max value:", 
                          min = 5,
                          max = 13, 
                          value = 7),
              plotOutput("poscrosstab")
      ),
      
      tabItem(tabName = "assistsbypos",
              h5("While the scoreboard ultimately decides who wins or loses the ball game, there is much more to the game of basketball than just scoring points. Players can make their mark on the stat sheets on both offense and defense contributing through assists, rebounds, blocks, and steals."),
              h5("Offensively, players can facilitate by creating scoring opportunities for their teammates and racking up assists. Taller, more athletic players can also snag rebounds of a missed shot, allowing the team another chance at scoring. We plot both the assist and rebound numbers of each player against the amount of minutes they played. To provide a little more insight into how each role contributes, we color each point of the scatter plot by position."),
              h4("Assists by Position: "),
              plotOutput("assistsbypos"),
              h5("It can be seen from the scatter plots that guards facilitate for their teammates at a much higher rate than forwards or centers. This is why a talented guard like D'Angelo Russell can get picked second overall in the draft in front of taller, more athletic players.")
      ),

      tabItem(tabName = "rebsbypos",
              h4("Rebounds by Position: "),
              plotOutput("rebsbypos"),
              h5("The revesre seems to be true for rebounds, as the centers and forwards towering over the competition are able to snag the most rebounds off missed shots")
      ),

      tabItem(tabName = "stealsbypos",
              h5("A similar trend appears in the defensive statistics as the quick, dextruous guards are able to steal the ball by playing the passing lanes or just plain ripping the ball from the guy they're defending. The towering big men, clogging up the area around the basket are more adept at swatting shots that come their way. They block more shots than their less vertically-gifted couterparts."),
              h4("Steals by Position: "),
              plotOutput("stealsbypos")
      ),

      tabItem(tabName = "blocksbypos",
              h4("Blocks by Position: "),
              plotOutput("blocksbypos")
      ),
      
      tabItem(tabName = "blending",
              h4("Blended Data: College Basketball Stars vs. NBA Rookies"),
              h5("Every year, around 60 exceptional college basketball players see their dreams come to fruition as they get drafted into the National Basketball Association. These players, who have been the top dogs on evry team they've been on, are thrust into the gaunlet against some of the best athletes in the world. Egos are shattered as high school phenoms and hometown heroes become role-players and bench warmers. To visualize just how these players transition into the pros, we blended our 2014-2015 college basketball data with data from the current NBA season."),
              plotOutput("blending1"),
              h5("We are only a few weeks into the current NBA season so the sample size is fairly small. However, we are still able to see the growing pains of many of the new NBA recruits."),
              plotOutput("blending2")
      )
      
    )
  )
)
