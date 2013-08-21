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

where = function(.data, ...) UseMethod("where")

setMethodS3(
	"where",
	"data.frame",
	function(.data, ..., envir = parent.frame())
		do(
			.data, 
			function(.x, cond) .x[cond, ], 
			...,
			named = FALSE,
			envir = envir))

#(function(){x = 5; where.data.frame(mtcars, cyl>x)})()

select = function(.data, ..., replace = TRUE) UseMethod("select")
setMethodS3(
	"select",
	"data.frame",
	function(.data, ..., replace = TRUE, envir = parent.frame()) {
		force(envir)
		do(
			.data, 
			function(.x, ...) {
				if(replace) data.frame(...) 
				else cbind(.x, data.frame(...))}, 
			...,
			envir = envir)})

#(function(){v = 5+ select.data.frame(mtcars, cy32 = cyl^2, carb + 5)})()
