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

console.log ""

# for loop with 
for i,j in list
  console.log "i = #{i}, j=#{j}, list[#{j}]=#{list[j]}, cubedList[#{j}]=#{cubedList[j]}"
  
console.log ""
