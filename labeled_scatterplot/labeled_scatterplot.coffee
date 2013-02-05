dataset = [{x: 2.9, y: 13.1},
           {x: 11.3, y: 26.8},
           {x: 10.4, y: 14},
           {x: 16, y: 25.3},
           {x: 13.5, y: 18.8},
           {x: 10.1, y: 20.2},
           {x: 13.1, y: 27.8},
           {x: 9.7, y: 18.1},
           {x: 9.1, y: 15.3},
           {x: 15.2, y: 24},
           {x: 9.1, y: 24.1},
           {x: 16.6, y: 25.6},
           {x: 13.9, y: 24.9},
           {x: 6.6, y: 15.9},
           {x: 2.8, y: 12.8},
           {x: 4, y: 13.9},
           {x: 12.8, y: 24.5},
           {x: 8.6, y: 22.3},
           {x: 2.7, y: 17.3},
           {x: 11.2, y: 19.6}]

h=500
w=1000
pad=20
svg = d3.select("body").append("svg")
        .attr("height", h)
        .attr("width", w)

xScale = d3.scale.linear()
           .domain([d3.min(dataset, (d) -> d.x),
                    d3.max(dataset, (d) -> d.x)])
           .range([pad, w-pad])

yScale = d3.scale.linear()
           .domain([d3.min(dataset, (d) -> d.y),
                    d3.max(dataset, (d) -> d.y)])
           .range([h-pad, pad])

svg.append("rect")
   .attr("x", 0)
   .attr("y", 0)
   .attr("width", w)
   .attr("height", h)
   .attr("fill", "white")
   .attr("stroke", "black")
   .attr("stroke-width", 5)
  
svg.selectAll("circle")
  .data(dataset)
  .enter()
  .append("circle")
  .attr("cx", (d) -> xScale(d.x))
  .attr("cy", (d) -> yScale(d.y))
  .attr("r", 5)
  .style("fill", (d,i) ->
    return "blue" if i <= 10
    "red")

svg.selectAll("text")
  .data(dataset)
  .enter()
  .append("text")
  .text((d,i) -> i+1)
  .attr("x", (d) ->
    xv = xScale(d.x)
    return xv+8 if xv < w*0.8
    xv-8)
  .attr("y", (d) -> yScale(d.y))
  .attr("font-family", "arial")
  .attr("dominant-baseline", "middle")
  .attr("text-anchor", (d) ->
    xv = xScale(d.x)
    return "start" if xv < w*0.8
    "end")

