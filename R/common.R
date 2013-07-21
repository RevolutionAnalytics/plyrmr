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

strip.nulls = 
	function(x) 
		x[!sapply(x, is.null)]

strip.null.args = 
	function(...)
		strip.nulls(list(...))

exclude = 
	function(x, exclude)
		x[-which(is.element(names(x), exclude))]

fwd.args = 
	function(f, arg.map = c(), exclude = c()) {
		par.call = sys.call(sys.parent())  
		par.call[[1]] = f 
		eval(
			as.call(
				rename(
					as.list(par.call),
					arg.map,
					warn_missing = FALSE)),
			envir=parent.frame())}
