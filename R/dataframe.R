# Copyright 2013 Revolution Analytics
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

do = function(.data, ...) UseMethod("do")

setMethodS3(
	"do",
	"data.frame", 
	function(.data, f,  ..., named = TRUE,  envir = parent.frame(1)) {
		dotlist = {
			if(named)
				named_dots(...)
			else
				dots(...) }
		env = list2env(.data, parent = envir)
		dotvals = lapply(dotlist, function(x) eval(x, env))
		do.call.dots(f, .data, args = dotvals)})

where = function(.data, ...) UseMethod("where")

setMethodS3(
	"where",
	"data.frame",
	function(.data, ...)
		do.data.frame(
			.data, 
			function(.x, cond) .x[cond, ], 
			...,
			named = FALSE))

#(function(){x = 5; where.data.frame(mtcars, cyl>x)})()

select = function(.data, ..., replace = TRUE) UseMethod("select")
setMethodS3(
	"select",
	"data.frame",
	function(.data, ..., replace = TRUE)
		do.data.frame(
			.data, 
			function(.x, ...) {
				if(replace) data.frame(...) 
				else cbind(.x, data.frame(...))}, 
			...))

#(function(){v = 5+ select.data.frame(mtcars, cy32 = cyl^2, carb + 5)})()
