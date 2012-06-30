dat = [ { "x": -0.99488,"y": -1.0107 },{ "x": 0.0058051,"y": -0.40725 },{ "x": -0.41549,"y": 1.1441 },{ "x": -1.5847,"y": 0.32019 },{ "x": -0.73274,"y": -1.0639 },{ "x": -0.5257,"y": -0.22738 },{ "x": 0.35176,"y": 0.14079 },{ "x":  1.537,"y": -0.21344 },{ "x": 0.78311,"y": -0.046108 },{ "x": 0.62435,"y": 0.67313 } ]

for i,d of dat
  d.x += 5
  d.y += d.x

svgscale = plotframe dat, {chartname: "#plotframe", xlab: "X", ylab: "Y",
pad: {bottom: 70, left: 100, top: 3, right: 3, scale: 0.05}, tickPadding: 8, ylab_rotate: 0}

svgscale.svg.selectAll("circle", {chartname: "#plotframe"})
   .data(dat)
   .enter()
   .append("circle")
   .attr("cx", (d) -> svgscale.x d.x)
   .attr("cy", (d) -> svgscale.y d.y)
   .attr("r", 5)
   .attr("fill", "slateblue")
   .on("mouseover", -> d3.select(this).transition().attr("fill", "hotpink"))
   .on("mouseover.tooltip", (d,i) -> svgscale.svg.append("text").text(i+1).attr("id", "tooltip")
      .attr("x", svgscale.x(d.x)+10).attr("y", svgscale.y(d.y)).attr("fill","hotpink")
      .attr("opacity",0).style("font-family", "sans-serif").transition().attr("opacity", 1))
   .on("mouseout", -> d3.select(this).transition().duration(500).attr("fill", "slateblue"); d3.selectAll("#tooltip").transition().duration(500).attr("opacity",0).remove())
