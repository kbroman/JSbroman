(( -> 

flashText = d3.select("body").select("#flash")

flashToggle = 0 # when flashing, keeps track of on/off
stateToggle = 0 # goes between 0 (off), 1 (on) and 2 (flashing)

flashFunc = ->
  flashText.attr "class", ->
    if flashToggle is 5
      flashToggle = -1
      "highlight"
    else "glow"
  flashToggle++


flashInterval = setInterval flashFunc, 400

flashText.on "click", ->
    if stateToggle is 0
      clearInterval flashInterval
      d3.select(this).attr("class", "highlight")
    else if stateToggle is 1
      d3.select(this).attr("class", "glow")
    else
      d3.select(this).attr("class", "highlight")
      flashToggle = 0
      flashInterval = setInterval(flashFunc, 400)
    stateToggle++;
    if stateToggle > 2
      stateToggle = 0

))()