# test of brush
# 
width = 900
height = 600
pad = 25
radius = 4
npoints = 100

svg = d3.select("div#graph")
        .append("svg")
        .attr({width: width, height: height})

svg.append("rect")
   .attr({x:0, y:0, height:height, width:width})
   .attr({fill:"none", stroke:"black"})

data = d3.range(npoints).map (i) ->
          {x: Math.floor(Math.random()*width), y: Math.floor(Math.random()*height)}

xscale = d3.scale.linear().domain([0, width])
              .range([0, width])
yscale = d3.scale.linear().domain([0, height])
              .range([height, 0])

svg.append("g").classed("pointgroup", true)
   .selectAll("empty")
   .data(data)
   .enter()
   .append("circle")
   .attr("id", (d,i) -> "pt#{i}")
   .attr("cx", (d) -> xscale(d.x))
   .attr("cy", (d) -> yscale(d.y))
   .attr("r", radius)

brushstart = () ->
    svg.select(".pointgroup")
       .classed("selecting", true)

brushmove = () ->
    e = brush.extent()
    svg.selectAll("circle")
        .classed("selected", (d) ->
            e[0][0] <= d.x and d.x <= e[1][0] and
            e[0][1] <= d.y and d.y <= e[1][1])

brushend = () ->
    svg.select(".pointgroup")
       .classed("selecting", false)

# I ran into trouble when I defined brush before I defined
# brushstart, brushmove, brushend; in retrospect, that's not surprising
brush = d3.svg.brush()
              .x(xscale)
              .y(yscale)
              .on("brushstart", brushstart)
              .on("brush", brushmove)
              .on("brushend", brushend)

svg.call(brush)
