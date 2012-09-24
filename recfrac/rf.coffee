# plot recombination fractions/LOD scores for all pairs of chromosomes

margin = {top: 160, right: 10, bottom: 10, left:160}
width = 720
height = 720
zmax = 12 # maximum LOD score

log2 = (x) -> Math.log(x)/Math.log(2.0)

rf = []
chr = []
markers = []
cells = []
xscale = []
yscale = []
zscale = []


# create SVG element and shift it down and to right
svg = d3.select("body").selectAll("#rf").append("svg")
    .attr("width", width + margin.left + margin.right)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(#{margin.left},#{margin.top})")


d3.json("rf.json", (rfdata) ->
  markers = rfdata.markers
  nmar = markers.length
  chr = rfdata.chr
  nchr = chr.length
  rf = rfdata.rf

  # scales for pixels
  xscale = d3.scale.ordinal().domain(d3.range(nmar)).rangeBands([0, width])
  yscale = d3.scale.ordinal().domain(d3.range(nmar)).rangeBands([height, 0])

  # scale for pixel color (orange indicates missing values)
  zscale = d3.scale.linear().domain([-1, 0, zmax]).range(["orange", "white", "blue"])

  # plug in -1 for nulls
  rf.forEach((cell) -> cell.value = -1 if cell.value is null)
       
  # threshold the values and transform recombination fractions
  rf.forEach((cell) -> 
    cell.state = 0
    if cell.value is null
      cell.value = 0.5 if cell.row < cell.col
      cell.value = 0 if cell.row > cell.col

    if cell.row == cell.col
      cell.value = zmax
    else if cell.row > cell.col
      if cell.value != -1
        cell.value = 0.5 if cell.value > 0.5
        cell.value = -4*(log2(cell.value)+1)/12*zmax
    cell.value = zmax if cell.value > zmax
  )    
        
#  # background rectangle
#  svg.append("rect")
#      .attr("id", "bgrect")
#      .attr("width", width)
#      .attr("height", height)

  # the pixels
  cells = svg.selectAll(".cell")
      .data(rf)
    .enter().append("rect")
      .attr("class", "cell")
      .attr("x", (d) -> xscale(d.row-1))
      .attr("y", (d) -> yscale(d.col-1))
      .attr("width", xscale.rangeBand())
      .attr("height", yscale.rangeBand())
      .attr("id", (d) -> "#{d.row}_#{d.col}")
      .style("fill", (d) -> zscale(d.value))

  cells.on("mouseover", ->
    d3.select(this).style("stroke","orange").style("stroke-width", 2))

  cells.on("mouseout", ->
    d3.select(this).style("stroke","none"))
  
  # add black border
  border = svg.append("rect")
      .attr("class", "border")
      .attr("width", width)
      .attr("height", height)

  chrborder = svg.selectAll("#chr")
      .data(chr)
    .enter().append("rect")
      .attr("class", "border")
      .attr("id", "chr")
      .attr("x", (d) -> xscale(d.lo-1))
      .attr("y", (d) -> yscale(d.hi-1))
      .attr("width", (d) -> xscale.rangeBand()*d.nmar)
      .attr("height", (d) -> yscale.rangeBand()*d.nmar)
)
