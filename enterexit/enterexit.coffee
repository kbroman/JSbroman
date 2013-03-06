
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

create_points = ->
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

create_points()

svg.on "click", ->
           add_datapoint()
           randomize_data()
           create_points()
