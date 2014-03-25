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

library(plyrmr)

stopifnot(
	all(
		(
			function(){
				s = 5
				envir = sys.frame(sys.nframe())
				as.data.frame(where(input(mtcars), cyl > s & carb < s, .envir = envir))})() ==
			subset(mtcars, subset = cyl > 5 & carb < 5)))

stopifnot(
	all(
		(function(){as.data.frame(transmute(input(mtcars), cyl))})() ==
			subset(mtcars, select = cyl)))
