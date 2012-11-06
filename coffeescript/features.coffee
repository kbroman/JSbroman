# features.coffee
#
# Karl Broman
# first written Nov 2012
# last modified Nov 2012
#
# Random-ish code to demonstrate language features in coffeescript
#
# to run: 'coffee features.coffee'

# a function
cube = (num) -> Math.pow num, 3

# a vector
list = [2..5]

# fancy way to do calculation on each element in a vector
cubedList = (cube num for num in list)

# print output
console.log cubedList

printBlankLine = -> console.log ""

####################
### for loops
####################
console.log '\n## for loops ##'

# for loop
# string interpolation
for i,j in list
  console.log "i = #{i}, j=#{j}, list[#{j}]=#{list[j]}, cubedList[#{j}]=#{cubedList[j]}"

# for..of rather than for..in
console.log "for i,j of list"
for i,j of list
  console.log "i = #{i}, j=#{j}"

# for..of rather than for..in
console.log "for i in list"
for i in list
  console.log "i = #{i}"

# for..of rather than for..in
console.log "for i of list"
for i of list
  console.log "i = #{i}"

####################
### strings and splats
####################
console.log '\n## strings and splats ##'

# string concatenation
x = 'Bite'
y = x + ' me'
console.log y

# other arguments
greeting = -> "Hello, #{arguments[0]}."
console.log greeting 'Karl'
console.log greeting 'Karl', 'Caleb'

greeting2 = -> "Hello, #{arguments[0].join(' and ')}."
console.log greeting2 ['Karl', 'Francis', 'Fisher']

# splats
console.log 'splats'
refine = (wheat, chaff...) ->
  console.log "First: #{wheat}"
  console.log "The rest: #{chaff.join(', ')}"

refine 'first', 'second', 'third', 'fourth'

# another splat
refine2 = (wheat, chaff..., end) ->
  console.log "First: #{wheat}"
  console.log "Middle: #{chaff.join(', ')}"
  console.log "Last: #{end}"

refine2 'first', 'second', 'third', 'fourth', 'fifth', 'sixth', 'seventh'

####################
### arrays and slices
####################
console.log '\n## arrays and slices ##'

# arrays
console.log "[2..5] = #{[2..5]}"
console.log "[2...5] = #{[2...5]}"
console.log "[5..2] = #{[5..2]}"
console.log "[5...2] = #{[5...2]}"

# slicing and splicing
letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
           'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
console.log "letters[1...4] = #{letters[1...4]}"
console.log "letters[1..4] = #{letters[1..4]}"
console.log "letters[20..-1] = #{letters[20..-1]}"
console.log "letters[-3...-1] = #{letters[-3...-1]}"
console.log "letters[23..] = #{letters[23..]}"
console.log "letters[23...] = #{letters[23...]}"

letters[1...3] = ['zz', 'zzz']
console.log "#{letters[0..4]}"

letters[1...1] = ['blah', 'blah blah']
console.log "#{letters[0..6]}"

####################
### more for loops
####################
console.log '\n## more for loops ##'

# more for loops
x = [4..15]
for xv in x when xv > 8
  console.log "#{xv} > 8"

# for ... of ... when
for index of x when x[index] > 8
  x[index] = -1
console.log x

# this loop doesn't do anything
x = [4..15]
for xv in x when xv > 8
  xv = -1
console.log x

# for ... in ... by
x = [0...500]
y = []
for i in x by 1/0.02
  y.push i
console.log y

# for ... in ... by
x = [20..0]
y = []
for i in [20..0] by -2
  y.push i
console.log y

# for ... in ... by
x = [20..0]
y = []
for i in x by 3
  y.push i
console.log y

####################
### array 'comprehensions'
####################
console.log '\n## array "comprehensions" ##'
x = [8..12]
y = (-xv for xv in x)
z = (-xv for xv of x)
console.log x
console.log y
console.log z

####################
### multi-assignments
####################
console.log '\n## multi-assignments ##'

[a, b] = [5, 8]
console.log a,b
[a, b] = [b, a]
console.log a,b

rect =
  x: 100
  y: 200
{x, y} = rect
console.log "x = #{x}"
console.log "y = #{y}"
