# example of density estimate using slider for bandwidth
# uses plotframe.coffee

(( ->

  d3.json "density.json", (mixData) ->
  
    # functions for printing rounded numbers
    twodigits = d3.format ".2f"
    threedigits = d3.format ".3f"
  
    # variables I'll use for density estimate
    bandwidth = 1
    nPoints = 250
    xMin = 10
    xMax = 50
  
    # standard normal density function
    dnorm = (x) -> 
      Math.exp(-0.5*x*x)/Math.sqrt(2*Math.PI)
    
    # calculate density estimate
    densityEstimate = (data, bw, minx, maxx, numpoints) ->
      xy = []
      for i in [0...numpoints]
        xy[i] = x: minx + (maxx-minx)*i/numpoints, y:0.0
      for i in [0...numpoints]
        for j in [0...data.length]
          xy[i].y += dnorm((xy[i].x-data[j])/bw)/bw/data.length
      xy
    
    
    args = 
      chartname: "#density_estimate"
      xlab: ""
      ylab: ""
      pad:
        bottom: 90
        left: 100
        top: 0
        right: 10
        scale: 0.05
      tickPadding: 8
      ylab_rotate: 0
  
    # plot frame and get scales
    svgscale = plotframe densityEstimate(mixData, 0.1, xMin, xMax, nPoints), args
    
    line = d3.svg.line()
             .x((d) -> svgscale.x(d.x))
             .y((d) -> svgscale.y(d.y))
             .interpolate("linear")
    
    path = svgscale.svg.append("svg:path")
                   .attr("fill", "none")
                   .attr("stroke","slateblue")
                   .attr("stroke-width", 3)
                   .attr("d", line(densityEstimate(mixData, bandwidth, xMin, xMax, nPoints)))
    
    bwtext = d3.select("body")
               .selectAll("#bandwidth")
    
    d3.select("input[type=range]").on "change", ->
           bandwidth = Math.pow(10, this.value)
           path.transition().attr("d", line(densityEstimate(mixData, bandwidth, xMin, xMax, nPoints)))
           if bandwidth > 0.095
             bwtext.transition().text("Bandwidth = " + twodigits(bandwidth))
           else
             bwtext.transition().text("Bandwidth = " + threedigits(bandwidth))

))()
  