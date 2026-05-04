library(shiny)
library(shinyMobile)
library(leaflet)
library(leaflet.extras)
library(htmlwidgets)
library(htmltools)
library(sf)

addResourcePath(prefix = 'www', directoryPath = './www')

# 1. Carrega dados fora do UI/Server para performance
source("script_1.R") 

ui <- f7Page(
  title = "BatLagoa",
  allowPWA = TRUE,          
 # manifest = "manifest.json", 
  head = tags$head(
    tags$link(rel = "apple-touch-icon", href = "apple-icon_192x192.png"),
    tags$link(rel = "manifest", href = "manifest.json"),
    tags$style(HTML("
      .leaflet-control-zoom-in, .leaflet-control-zoom-out, .leaflet-control-layers-toggle { 
        width: 45px !important; 
        height: 45px !important; 
        line-height: 45px !important; 
        font-size: 24px !important;
      }
      .info.legend { font-size: 14px !important; background: rgba(255,255,255,0.8) !important; padding: 6px 8px !important; }
      .leaflet-bottom { bottom: 65px !important; }
      .toolbar-tabbar { height: 48px !important; }
      #mapa_app { height: calc(100vh - 98px) !important; }
    ")) # Fechamento correto do style
  ),
  options = list(theme = "auto", dark = TRUE), 
  
  f7TabLayout(
    navbar = f7Navbar(
      title = "Batimetria da Lagoa da Conceição",
      hairline = TRUE
    ),
    f7Tabs(
      animated = TRUE,
      f7Tab(
        title = "Mapa",
        tabName = "map_tab",
        icon = f7Icon("map"), 
        active = TRUE,
        leafletOutput("mapa_app", height = "calc(100vh - 100px)")
      ),
      f7Tab(
        title = "Sobre",
        tabName = "info_tab",
        icon = f7Icon("info_circle"),
        f7Block(
          f7BlockTitle("Projeto BatLagoa"),
          p("Este app permite visualizar as profundidades da Lagoa da Conceição em tempo real."),
          p("Dados de batimetria obtidos do Geoportal da Prefeitura de Florianópolis."),
          p("Fonte dos dados: ", a("Geoportal PMF", href = "https://geoportal.pmf.sc.gov.br/downloads/camadas-em-sig-do-mapa", target = "_blank")),
          p("Desenvolvido por Marcio Baldissera Cure de forma independente."),
          p(" "),
          p("Navegue com responsabilidade. Respeite as regras de navegação e preserve o meio ambiente."),
          p("Regulamento Internacional para Evitar Abalroamentos no Mar: ", 
            a("RIPEAM", href = "https://www.marinha.mil.br/salvamarbrasil/sites/www.marinha.mil.br.salvamarbrasil/files/ripeam_colreg_consolidada_com_emd_dez2013.pdf", target = "_blank")
          ),
          br(),
          f7Button(
            label = "Dúvidas, sugestões ou comentários?", 
            color = "blue",
            href = "mailto:marciobcure@gmail.com"
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  output$mapa_app <- renderLeaflet({
    leaflet(batimetria_latlong) |> 
      addProviderTiles(providers$Esri.WorldImagery, group = "Satélite") |> 
      addTiles(group = "Mapa de Ruas") |> 
      addPolygons(
        fillColor = ~pal(z), 
        fillOpacity = 0.7, 
        color = "white", 
        weight = 0.5, 
        group = "Batimetria",
        popup = ~paste0("<div style='font-size: 17px; padding: 10px;'>",
                        "<b>Profundidade:</b> ", z, " m",
                        "</div>"),
        popupOptions = popupOptions(maxWidth = 300, minWidth = 150),
        options = pathOptions(attribution = "Autor: Marcio Baldissera Cure / Dados: PMF")
      ) |> 
      addLayersControl(
        baseGroups = c("Satélite", "Mapa de Ruas"),
        overlayGroups = c("Batimetria"),           
        options = layersControlOptions(collapsed = FALSE)
      ) |> 
      addControlGPS(
        options = gpsOptions(
          position = "topleft", 
          activate = TRUE, 
          autoCenter = TRUE, 
          maxZoom = 18,
          setView = TRUE
        )
      ) |> 
      addLegend(
        pal = pal, 
        values = ~z, 
        title = "Profundidade (m)", 
        position = "bottomright"
      )
  })
}

shinyApp(ui, server)
