# function that does all of the work
draw = (data) ->

  w = 1000
  h = 500
  pad = 20

  console.log(data.ind.length)

  xScale = d3.scale.linear()
             .domain([0, data.ind.length-1])
             .range([pad, w-pad])

  yScale = d3.scale.linear()
             .domain([-1, 1])
             .range([h-pad, pad])

  svg = d3.select("body").append("svg")
          .attr("width", w)
          .attr("height", h)

  svg.append("rect")
     .attr("x", 0)
     .attr("y", 0)
     .attr("height", h)
     .attr("width", w)
     .attr("fill", "none")
     .attr("stroke", "black")
     .attr("stroke-width", 2)

  svg.selectAll("circle.med")
     .data(data.ind)
     .enter()
     .append("circle")
     .attr("class", "med")
     .attr("cx", (d,i) -> xScale(i))
     .attr("cy", (d) -> yScale(data.quant[4][d]))
     .attr("r", 3)
     .attr("fill", "none")
     .attr("stroke", "black")
     .attr("stroke-width", "2")

  colors = ["blue", "green", "orange", "red"]

  for j in [0..3]
    svg.selectAll("circle.qu#{j}")
       .data(data.ind)
       .enter()
       .append("circle")
       .attr("class", "qu#{j}")
       .attr("cx", (d,i) -> xScale(i))
       .attr("cy", (d) -> yScale(data.quant[j][d]))
       .attr("r", 3)
       .attr("fill", "none")
       .attr("stroke", colors[j])
       .attr("stroke-width", "1")

  for j in [5..8]
    svg.selectAll("circle.qu#{j}")
       .data(data.ind)
       .enter()
       .append("circle")
       .attr("class", "qu#{j}")
       .attr("cx", (d,i) -> xScale(i))
       .attr("cy", (d) -> yScale(data.quant[j][d]))
       .attr("r", 3)
       .attr("fill", "none")
       .attr("stroke", colors[j-5])
       .attr("stroke-width", "1")

# load json file and call draw function
d3.json("hypo.json", draw)
