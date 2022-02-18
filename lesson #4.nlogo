breed [ peoples people ]                    ; creating a population of people who will move around aimlessly
breed [ butterflies butterfly ]             ; creating a population of butterflies who will move around aimlessly but also seen the people
breed [ food flowers ]                      ; creating a population of flowers for the butterflies to feed from

butterflies-own [ people_seen people_hit    ; this creates 2 variables which will be used to count the total people seen and total people hit by each agent
health robustness speed_variation           ; this creates 3 variables for health, durability and speed
per_vis_rad per_vis_ang                     ; this creates variables for personalised vision cones
food_around_me closest_food                 ; this creates 2 variables to save the locations of food
]

food-own [ amount ]                         ; this creates a variable for the food to establish amount of the resource

globals [rad]                               ; this creates a global variable called rad

to setup                                    ; this creates a function called setup
  clear-all                                 ; this clears the world of any previous activities
  reset-ticks                               ; this resets the ticks counter
  set rad 5                                 ; this sets the global variable rad to 3

  create-peoples number_of_people [         ; this creates the number of people that your global variable states determined by the slider
    setxy random-xcor random-ycor           ; this sets the starting position of the people to a random location in the world
    set color gray                          ; this sets the color of the people to gray
    set size 10                             ; this sets the size of the people to 10
    set shape "person"                      ; this sets the shape of the people to a person
  ]

  create-butterflies number_of_butterfiles [; this creates the number of butterflies that your global variable states determined by the slider
    setxy random-xcor random-ycor           ; this sets the starting position of the butterflies to a random location in the world
    set color blue                          ; this sets the color of the butterflies to blue
    set size 10                             ; this sets the size of the butterflies to 10
    set shape "butterfly"                   ; this sets the shape of the butterflies to a butterfly

    ; making our butterflies unique
    set health 50 + random 50               ; this sets the health of the butterfly by adding 50 + a random allocation up to 50
    adjust_vision_cone                      ; this calls the adjust_vision_cone fuction to setup the vision cone
    set robustness random 10                ; this sets the robustness variable to a random value up to 10. lower means the butterfly is less affected by collisions
    set speed_variation random 10           ; this sets the speed_variation variable to a random value up to 10. the higher the value the faster the butterfly
    set heading 0                           ; this sets the starting heading of the butterfly to 0 (for demonstration of speed difference)
    pen-down                                ; this puts the pen down so you can see where the butterfly moves
  ]

  create-food 10 [                          ; this creates X number of new food plants for the butterflies to feed from
    grow_food                               ; this calls the grow_food function
  ]
end

to grow_food                                ; this creates a function called grow_food
  setxy random-xcor random-ycor             ; this sets the position of the food to a random location in the world
  set color yellow                          ; this sets the color of the food to yellow
  set size 10                               ; this sets the size of the food to 10
  set shape "plant"                         ; this sets the shape of the food to a plant
  set amount random 100                     ; this sets the amount of food per plant to a random value up to 100
end

to go                                       ; this creates a function called go
  make_people_move                          ; this calls the make_people_move function
  reset_patch_colour                        ; this calls the reset_patch_colour function
  make_butterflies_move                     ; this calls the make_butterflies_move function
  tick                                      ; this adds 1 to the tick counter
  grow_more_food                            ; this calls the grow_more_food function
end

to make_people_move                         ; this creates a function called make_people_move
  ask peoples [                             ; this asks all of the people in the population to do what is in the brackets
    set color gray                          ; this sets the color of each person to gray
    right ( random pwr - ( pwr / 2))        ; this turns the person right relative to its current heading by a random degree number using the range set within pwr NOTE: if negative it will turn left
    forward people_speed                    ; this sets the speed at which the people move
  ]
end

to reset_patch_colour                       ; this creates a function called reset_patch_color
  ask patches [                             ; this asks all of the patches in the population to do what is in the brackets
    set pcolor black                        ; this sets the color of each patch to black
  ]
end

to make_butterflies_move                                       ; this is defining a function called make_butterflies_move
  ask butterflies [                                            ; this asks all of the butterflies in the population to do what is in the brackets
    ifelse health > 0 [                                        ; if health is greater than 0 then (still alive)...
      show_visualisations                                      ; call the show_visualisations function
      set color blue                                           ; this sets the color of each butterfly to blue
      let have_seen_person people_function                     ; this creates a local variable called have_seen_person the fills it with the return of the function people_function
      let can_smell_food food_function 30                      ; this creates a local variable called can_smell_food then fills it with the return of the function food_function whilst passing 30
      ifelse ( have_seen_person = true ) [                     ; if local variable have_seen_person is true...
        right 180                                              ; set heading of the butterfly to 180 (turn around to avoid!)
        ][                                                     ; otherwise...
        ifelse ( can_smell_food = true ) and ( health < 100) [ ; if local variable can_smell_food is true...
          set heading ( towards closest_food )                 ; set heading towards closest food source
          ][                                                   ; otherwise...
          right (random bwr - (bwr / 2))                       ; this turns the butterfly right relative to its current heading by a random degree number using the range set within bwr NOTE: if negative it will turn left
      ]]
      forward butterflies_speed + ( speed_variation * 0.1 )    ; moves butterfly forward by the butterflies_speed variable
    ][                                                         ; otherwise...
      set color gray                                           ; set color to gray to indicate dead butterfly
      die                                                      ; this kills off the butterfly
    ]
  ]
end

to show_visualisations                            ; this creates a function called show_visualisations
  if show_col_rad = true [                        ; this will switch on the visualisation of the collision radius if the switch is set to true
    ask patches in-radius rad [                   ; this sets up a radius around the butterfly to the value of the global variable rad which we are using to display the size of the radius by changing the patch color
      set pcolor orange                           ; this sets the patch color to orange
    ]
  ]
  if show_vis_cone = true [                       ; this will switch on the visualisation of the vision cone if the switch is set to true
    ask patches in-cone per_vis_rad per_vis_ang [ ; this sets up a vision cone in front of the butterfly to the value of the global variables per_vis_rad per_vis_ang which we are using to display the size of the radius by changing the patch color
      set pcolor red                              ; this sets the patch color to red
    ]
  ]
end

to-report food_function [sensitivity]                            ; this creates a reporting function called food_function and expects a value for sensitivity
  set food_around_me other ( food in-radius sensitivity )        ; this sets the food_around_me variable to the ID's of the food within the sensitivity radius
  set closest_food min-one-of food_around_me [distance myself]   ; this sets the closest_food variable to the ID of the closest food source
  let can_smell_food [false]                                     ; this creates a local variable called can_smell_food and sets it to false
  let eating_food [false]                                        ; this creates a local variable called eating_food and sets it to false

  if health < 100 [                                              ; if health is less than 100 then...
    ask food in-radius rad [                                     ; this sets up a radius around the food to the value of the global variable rad which we are using for collision detection with people
      ifelse amount > 0 [                                        ; if amount (a food variable) is greater than 0...
        set eating_food true                                     ; set the local variable called eating_food to true indicating the butterfly is eating
        set amount amount - 5                                    ; reduces 5 from the amount variable in the food
        set color color - .25                                    ; reduce the color intensity of the food by .25
      ][                                                         ; otherwise...
        die                                                      ; there is no food left so kill the good agent
      ]
    ]
  ]

  if eating_food = true [                         ; if eating_food is true then...
    set health health + 5                         ; add 5 to health of butterfly
    adjust_vision_cone                            ; call adjust_vision_cone function as health impact on the vison of the butterfly
  ]

  if (closest_food != nobody) [                   ; if closest_food is not empty (the butterfly can smell food in range) then...
    set can_smell_food true                       ; set can_smell_food to true
  ]
  report can_smell_food                           ; return value of can_smell_food to location where function was called
end

to-report people_function                         ; this creates a reporting function called people_function
  let seen [false]                                ; this creates a local variable called seen
  let hit [false]                                 ; this creates a local variable called hit
  let person_hit 0    ;+++++++++++++++++++++++++++; this creates a local variable calles person_hit and sets it to 0

  ask peoples in-cone per_vis_rad per_vis_ang [   ; this sets up a vison cone on the butterfly with the parameters from per_vis_rad per_vis_ang and detects what people are within this cone
    set color green                               ; this sets the color of the person detected within the vision code of the butterfly to green
    set seen true                                 ; this sets the local variable called seen to true indicating that a person has been seen
  ]

  ask peoples in-radius rad [                     ; this sets up a radius around the butterfly to the value of the global variable rad which we are using for collision detection with people
    set hit true                                  ; this sets the local variable called hit to true indicating that a person has collided with the butterfly
    set person_hit who ;++++++++++++++++++++++++++; this sets the local variable called person_hit to the individual who
    show person_hit
  ]

  ifelse seen = true [                            ; if then else statement based on the local variable seen, if seen = true then...
    set people_seen people_seen + 1               ; add 1 to the people_seen count
    set color white                               ; set color of butterfly to white
    ;right 180     ;-------------------------------; set heading of the butterfly to 180 (turn around to avoid!)
  ][                                              ; if seen = false...
    ;right (random bwr - (bwr / 2)) ;--------------; this turns the butterfly right relative to its current heading by a random degree number using the range set within bwr NOTE: if negative it will turn left
  ]

  if hit = true [                                 ; if statement based on the local variable hit, if seen = true then...
    set people_hit people_hit + 1               ; add 1 to the people_hit count
    set color green                             ; set color of butterfly to green
    set health health - robustness ;++++++++++++; adjust health of butterfly to health - collision penalty (robustness)
    adjust_vision_cone ;++++++++++++++++++++++++; calls adjust_vision_cone to update the vision parameters based on heath changes
  ]
  report seen ;+++++++++++++++++++++++++++++++++++; return true or false based in local variable seen
end

to adjust_vision_cone                                        ; this creates a function called adjust_vision_cone
  if ((vis_rad + random 20)*(health * 0.01)) > 0 [           ; if the calculation if greater than 0 then...
    set per_vis_rad ((vis_rad + random 20)*(health * 0.01))  ; set the personal vision radius to factor in some randomness and health (less health = less vision)
  ]
  if ((vis_ang + random 20)*(health * 0.01)) > 0 [           ; if the calculation if greater than 0 then...
    set per_vis_ang ((vis_ang + random 20)*(health * 0.01))  ; set the personal vision angle to factor in some randomness and health (less health = less vision)
  ]
end

to grow_more_food                           ; this creates a function called grow_more_food
  if ticks > 1000 [                         ; if the current number of ticks is greater than 100 then...
    ask patch random-xcor random-ycor [     ; ask a (1) patch in a random location (x, y coordinate) to do the following...
      sprout-food 1 [grow_food]             ; sprout (create new) food (1 in this instance) then call the grow_food function to set the parameters of the food
    ]
    reset-ticks                             ; this resets the ticks counter back to 0
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
226
10
836
621
-1
-1
2.0
1
10
1
1
1
0
1
1
1
-150
150
-150
150
1
1
1
ticks
30.0

BUTTON
33
36
99
69
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
103
35
184
68
go (forever)
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
15
205
109
238
vis_rad
vis_rad
0
50
17.0
1
1
NIL
HORIZONTAL

SLIDER
115
205
209
238
vis_ang
vis_ang
0
180
75.0
1
1
NIL
HORIZONTAL

SLIDER
15
339
209
372
number_of_people
number_of_people
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
14
86
208
119
number_of_butterfiles
number_of_butterfiles
0
20
6.0
1
1
NIL
HORIZONTAL

SLIDER
15
417
209
450
pwr
pwr
10
180
17.0
1
1
NIL
HORIZONTAL

SLIDER
15
378
209
411
people_speed
people_speed
1
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
15
165
209
198
bwr
bwr
10
180
11.0
1
1
NIL
HORIZONTAL

SLIDER
14
126
208
159
butterflies_speed
butterflies_speed
0
10
1.1
.1
1
NIL
HORIZONTAL

SWITCH
15
245
209
278
show_col_rad
show_col_rad
0
1
-1000

SWITCH
15
286
209
319
show_vis_cone
show_vis_cone
0
1
-1000

PLOT
842
46
1061
196
Model stats
Time
Quantity
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Food" 1.0 0 -1184463 true "" "plot count food"
"Butterflies" 1.0 0 -13345367 true "" "plot count butterflies"
"People" 1.0 0 -2674135 true "" "plot count peoples"
"Vpods" 1.0 0 -13840069 true "" "plot count venom"

@#$#@#$#@
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
setup
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
