dat = [ { "x": -0.99488,"y": -1.0107 },{ "x": 0.0058051,"y": -0.40725 },{ "x": -0.41549,"y": 1.1441 },{ "x": -1.5847,"y": 0.32019 },{ "x": -0.73274,"y": -1.0639 },{ "x": -0.5257,"y": -0.22738 },{ "x": 0.35176,"y": 0.14079 },{ "x":  1.537,"y": -0.21344 },{ "x": 0.78311,"y": -0.046108 },{ "x": 0.62435,"y": 0.67313 } ]

svgscale = plotframe dat, {height: 250, width: 500, xlab: "x axis", ylab: "y axis"}

svgscale.svg.selectAll("circle")
   .data(dat)
   .enter()
   .append("circle")
   .attr("cx", (d) -> svgscale.x d.x)
   .attr("cy", (d) -> svgscale.y d.y)
   .attr("r", 5)
   .attr("fill", "slateblue")
   .on("mouseover", -> d3.select(this).attr("r", 10).attr("fill", "hotpink"))
   .on("mouseout", -> d3.select(this).attr("r", 5).attr("fill", "slateblue"))
