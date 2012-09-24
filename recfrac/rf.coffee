# plot recombination fractions/LOD scores for all pairs of chromosomes

margin = {top: 100, right: 100, bottom: 100, left:100}
width = 720
height = 720
zmax = 12 # maximum LOD score

log2 = (x) -> Math.log(x)/Math.log(2.0)
onedigit = d3.format ".1f"
twodigits = d3.format ".2f"
reverselabels = (label) ->
  rc = label.split("c")
  tmp = rc[0].split("r")
  ["r", rc[1], "c", tmp[1]].join("")

rf = []
chr = []
markers = []
cells = []
xscale = []
yscale = []
zscale = []
matrix = []


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

  # create matrix of rec fracs and LODs
  for i in [0...nmar]
    matrix[i] = d3.range(nmar).map((j) -> {rf: null, lod:null})

  rf.forEach((cell) ->
    if cell.row > cell.col
      matrix[cell.row][cell.col].rf = cell.value
      matrix[cell.col][cell.row].rf = cell.value
    else if cell.row < cell.col
      matrix[cell.row][cell.col].lod = cell.value
      matrix[cell.col][cell.row].lod = cell.value)

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
    cell.value = zmax if cell.value > zmax)


  # the pixels
  cells = svg.selectAll(".cell")
      .data(rf)
    .enter().append("rect")
      .attr("class", "cell")
      .attr("x", (d) -> xscale(d.row))
      .attr("y", (d) -> yscale(d.col))
      .attr("width", xscale.rangeBand())
      .attr("height", yscale.rangeBand())
      .attr("id", (d) -> "r#{d.row}c#{d.col}")
      .style("fill", (d) -> zscale(d.value))

  cells.on("mouseover", ->
    d3.select(this).style("stroke","green")
    label = reverselabels(this.id)
    console.log("#{this.id} #{label}")
    svg.selectAll("##{label}").style("stroke","red"))

  cells.on("mouseout", ->
    d3.select(this).style("stroke","none")
    label = reverselabels(this.id)
    console.log("#{this.id} #{label}")
    svg.selectAll("##{label}").style("stroke","none"))

  cells.on("click", (d) ->
    d3.selectAll("#tooltip").transition().duration(500).attr("opacity",0).remove()
    svg.append("text")
        .text(->
          if d.row is d.col
            markers[d.row].marker
          else
            "#{markers[d.row].marker} : #{markers[d.col].marker}"
        )
        .attr("id", "tooltip")
        .style("font-family", "sans-serif")
        .attr("text-anchor", ->
          if d.row < nmar/2
            "start"
          else
            "end"
        )
        .attr("x", ->
          if d.row < nmar/2
            xscale(d.row)+xscale.rangeBand()*1.5
          else
            xscale(d.row)-xscale.rangeBand()/2
        )
        .attr("y", yscale(d.col)+yscale.rangeBand())
    if d.row != d.col
      svg.append("text")
          .text(->
              "rf = #{twodigits(matrix[d.row][d.col].rf)}    lod = #{onedigit(matrix[d.row][d.col].lod)}"
          )
          .attr("id", "tooltip")
          .style("font-family", "sans-serif")
          .attr("text-anchor", ->
            if d.col < nmar/2
              "start"
            else
              "end"
          )
          .attr("x", ->
            if d.col < nmar/2
              xscale(d.col)+xscale.rangeBand()*1.5
            else
              xscale(d.col)-xscale.rangeBand()/2
          )
          .attr("y", yscale(d.row)+yscale.rangeBand())
  )


  # add black border
  svg.append("rect")
      .attr("class", "border")
      .attr("width", width)
      .attr("height", height)

  # add horizontal lines at chromosome boundaries
  svg.selectAll("#hchr")
      .data(chr)
    .enter().append("line")
      .attr("class", "border")
      .attr("id", "hchr")
      .attr("x1", (d) -> 0)
      .attr("x2", (d) -> width)
      .attr("y1", (d) -> yscale(d.hi))
      .attr("y2", (d) -> yscale(d.hi))

  # add vertical lines at chromosome boundaries
  svg.selectAll("#vchr")
      .data(chr)
    .enter().append("line")
      .attr("class", "border")
      .attr("id", "vchr")
      .attr("x1", (d) -> xscale(d.hi+1))
      .attr("x2", (d) -> xscale(d.hi+1))
      .attr("y1", (d) -> 0)
      .attr("y2", (d) -> height)

  # chromosome labels above
  svg.selectAll("#xlab")
      .data(chr)
    .enter().append("text")
      .attr("class", "axis")
      .attr("id", "xlab")
      .attr("x", (d) -> (xscale(d.lo)+xscale(d.hi)+xscale.rangeBand())/2)
      .attr("y", -5)
      .attr("text-anchor", "middle")
      .text((d) -> d.chr)

  # chromosome labels on right
  svg.selectAll("#ylab")
      .data(chr)
    .enter().append("text")
      .attr("class", "axis")
      .attr("id", "ylab")
      .attr("y", (d) -> (yscale(d.hi)+yscale(d.lo))/2+yscale.rangeBand())
      .attr("x", width+10)
      .attr("text-anchor", "middle")
      .text((d) -> d.chr)

)
