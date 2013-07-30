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

# of perl fame
qw = function(...) as.character(match.call())[-1]

constant = 
	function(x)
		function(...) x

strip.nulls = 
	function(x) 
		x[!sapply(x, is.null)]

strip.null.args = 
	function(...)
		strip.nulls(list(...))

exclude = 
	function(x, what) {
		what = which(is.element(names(x), what))
		if(length(what) == 0) x
		else x[-what]}

fwd.args = 
	function(f, arg.map = c(), exclude.args = c()) {
		par.call = sys.call(sys.parent())  
		par.call = match.call(match.fun(par.call[[1]]), par.call)
		par.call[[1]] = f 
		eval(
			as.call(
				rename(
					exclude(
						as.list(par.call),
						exclude.args),
					arg.map,
					warn_missing = FALSE)),
			envir = parent.frame())}
