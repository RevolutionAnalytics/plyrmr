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

stopifnot(
	all(
		as.data.frame(do(input(mtcars), function(x) list(cyl2 =x$cyl^2))) 
		== 
			mtcars$cyl^2))

stopifnot(
	all(
		(function() {
			expo1 = 2;
			envir = sys.frame(1)
			as.data.frame(
				do(
					input(mtcars), 
					function(x , ...) {
						vars = plyrmr:::non.standard.eval(x, ..., .envir = envir)
						list(cyl2 =x$cyl^vars[['expo2']])},
					expo2 = expo1))})()		
		 == 
		 	mtcars$cyl^2))
	
