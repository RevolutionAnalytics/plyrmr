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

# a do.call varant which takes a mix of ... args and a list of args
do.call.dots = 
	function(what, ..., args, quote = FALSE, envir = parent.frame()) {
		force(envir)
		do.call(what, c(list(...), args), quote = quote, envir = envir)}

# retun a function whose env is a copy of the original env (one level only)
freeze.env = 
	function(x) {
		envx = environment(x)
		if(!is.null(envx)) {
			nenv = as.environment(as.list(envx))
			parent.env(nenv) = parent.env(envx)
			environment(x) = nenv}
		x}
