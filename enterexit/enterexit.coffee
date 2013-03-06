
w = 500
h = 500
pad = 10

lightGray = d3.rgb(230, 230, 230)
darkGray = d3.rgb(200, 200, 200)

svg = d3.select("div#enterexit")
        .append("svg")
        .attr("height", h+2*pad)
        .attr("width", w+2*pad)

svg.append("rect")
   .attr("x", pad)
   .attr("y", pad)
   .attr("height", h)
   .attr("width", w)
   .attr("fill", lightGray)
   .attr("stroke", "black")
   .attr("stroke-width", "2")

random_datapoint = ->
  {x : Math.round(Math.random()*w), y : Math.round(Math.random()*h)}

add_datapoint = ->
  data.push(random_datapoint())

jitterAmount = 50
jitter_value = (val, max) ->
  val += Math.round(Math.random()*2*jitterAmount-jitterAmount)
  val = -val if val < 0
  val = 2*max - val if val > max
  val
  
randomize_data = ->
  for d in data
    d.x = jitter_value(d.x, w)
    d.y = jitter_value(d.y, h)

recreate_points = ->
   svg.selectAll("circle.points")
      .data(data)
      .enter()
      .append("circle")
      .attr("class", "points")
      .attr("cx", (d) -> d.x+pad)
      .attr("cy", (d) -> d.y+pad)
      .attr("r", "5")
      .attr("fill", "darkslateblue")
      .attr("stroke", "none")
      .attr("stroke-width", 2)
   svg.selectAll("circle.points")
      .data(data)
      .transition().duration(1000)
      .attr("cx", (d) -> d.x+pad)
      .attr("cy", (d) -> d.y+pad)
   svg.selectAll("circle.points")
      .data(data)
      .exit()
      .attr("r", 0).remove()

n = 5
data = []
for i in [0...n]
  data.push(random_datapoint())

recreate_points()

bh = 30
bw = 90

buttons = d3.select("div#buttons")
            .append("svg")
            .attr("height", bh+2*pad)
            .attr("width", 3*bw+6*pad)

enterbutton = buttons.append("rect")
                     .attr("x", pad)
                     .attr("y", pad)
                     .attr("height", bh)
                     .attr("width", bw)
                     .attr("fill", "lightgreen")
                     .attr("stroke", "black")
                     .attr("stroke-width", "2")

randombutton = buttons.append("rect")
                     .attr("x", 3*pad+bw)
                     .attr("y", pad)
                     .attr("height", bh)
                     .attr("width", bw)
                     .attr("fill", "lightblue")
                     .attr("stroke", "black")
                     .attr("stroke-width", "2")

exitbutton =  buttons.append("rect")
                     .attr("x", 5*pad+2*bw)
                     .attr("y", pad)
                     .attr("height", bh)
                     .attr("width", bw)
                     .attr("fill", "pink")
                     .attr("stroke", "black")
                     .attr("stroke-width", "2")

buttons.append("text")
       .attr("y", pad + bh/2)
       .attr("x", pad + bw/2)
       .text("add")

buttons.append("text")
       .attr("y", pad + bh/2)
       .attr("x", 3*pad + bw*1.5)
       .text("randomize")

buttons.append("text")
       .attr("y", pad + bh/2)
       .attr("x", 5*pad + bw*2.5)
       .text("kill")

enterbutton.on "click", ->
           add_datapoint()
           recreate_points()

randombutton.on "click", ->
           randomize_data()
           recreate_points()
