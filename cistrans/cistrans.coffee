# function that does all of the work
draw = (data) ->

  # dimensions of panels
  w = [800, 800, 300, 300]
  h = [800, 300, 1100/2, 1100/2]
  pad = {left:60, top:40, right:40, bottom: 40}

  left = [pad.left, pad.left,
          pad.left + w[0] + pad.right + pad.left,
          pad.left + w[0] + pad.right + pad.left]
  top =  [pad.top,
          pad.top + h[0] + pad.bottom + pad.top,
          pad.top,
          pad.top + h[2] + pad.bottom + pad.top]
  right = []
  bottom = []
  for i of left
    right[i] = left[i] + w[i]
    bottom[i] = top[i] + h[i]
          
  totalw = right[2] + pad.right
  totalh = bottom[1] + pad.bottom

  # height of marker ticks in lower-left panel
  tickHeight = (bottom[1] - top[1])*0.02

  # jitter amounts for PXG plot
  jitterAmount = (right[3] - left[3])/50
  jitter = []
  for i of data.phevals
    jitter[i] = (2.0*Math.random()-1.0) * jitterAmount

  # colors definitions
  lightGray = d3.rgb(230, 230, 230)
  darkGray = d3.rgb(200, 200, 200)
  pink = "#E9CFEC"
  purple = "#8C4374"

  # create SVGs
  svg = d3.select("div#cistrans").append("svg")
          .attr("width", totalw)
          .attr("height", totalh)

  # gray backgrounds
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "innerBox")

  # calculate X and Y scales, using cM positions
  totalChrLength = 0;
  for c in data.chrnames
    totalChrLength += (data.chr[c].end_cM - data.chr[c].start_cM)
  console.log("totalChrLength: #{totalChrLength}")

#  peaks = svg.selectAll("empty")
#             .data(

  # black borders
  for j of left
    svg.append("rect")
       .attr("x", left[j])
       .attr("y", top[j])
       .attr("height", h[j])
       .attr("width", w[j])
       .attr("class", "outerBox")

# load json file and call draw function
d3.json("data/insulin_eqtl.json", draw)
