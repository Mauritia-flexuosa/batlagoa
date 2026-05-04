# Carrega e prepara dados da Batimetria da Lagoa da Conceição
# Marcio Baldissera Cure
# 02/05/2026
# Dados obtidos em https://geoportal.pmf.sc.gov.br/downloads/camadas-em-sig-do-mapa

library(sf)

bat <- st_read("./batimetria_lagoa_conceicao/batimetria_lagoa_conceicao.shp") #|> 
#  mutate(z = -z) |> filter(z > 0)
# canal <- st_read("./canal_barra_lagoa/canal_barra_lagoa.shp")

# Converter para o sistema de coordenadas do Leaflet (WGS84)
batimetria_latlong <- st_transform(bat, crs = 4326)

pal <- colorNumeric(
  palette = "YlGnBu", # Poderia ser tb "Blues", "viridis", "mako"
  domain = batimetria_latlong$z,
  reverse = TRUE # TRUE para que cores escuras sejam o fundo
)