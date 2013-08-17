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

do.call.dots = 
	function(what, ..., args, quote = FALSE, envir = parent.frame())
		do.call(what, c(list(...), args), quote = quote, envir = envir)

do.data.frame = 
	function(.data, f,  ..., named = TRUE,  envir = sys.frame(1)) {
		dotlist = {
			if(named)
				named_dots(...)
			else
				dots(...) }
		env = list2env(.data, parent = envir)
		dotvals = lapply(dotlist, function(x) eval(x, env))
		do.call.dots(f, .data, args = dotvals)}


subset3.data.frame = 
	function(.data, ...)
		do.data.frame(
			.data, 
			function(x, cond) x[cond, ], 
			...,
			named = FALSE)

#(function(){x = 5; subset3.data.frame(mtcars, cyl>x)})()

select.data.frame =
	function(.data, ...)
		do.data.frame(
			.data, 
			function(x, ...) data.frame(...), 
			...)

#(function(){select.data.frame(mtcars, cyl, carb)})()

add.cols.data.frame  = 
	function(.data, ...)
		do.data.frame(.data, function(x, ...) cbind(x, data.frame(...)), ...)

#(function(){v = 4; add.cols.data.frame(mtcars, x = v)})()

map.data.frame = 
	function(.data, ...)
		do.data.frame(.data, function(x, ...) data.frame(...), ...)

# (function(){v = 5; map.data.frame(mtcars,  v + cyl)})()