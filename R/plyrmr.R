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

constant = 
	function(x)
		function(...) x

comp = 
	function(...) {
		funs = list(...)
		funs = funs[!sapply(funs, is.null)]
		do.call(Compose, funs)}

make.mr.fun = 
	function(keyf, valf) {
		if(is.null(keyf)) 
			keyf = constant(NULL)
		function(k, v) {
			v = cbind.kv(k, v)
			keyval(keyf(v), valf(v))}}

cbind.kv = 
	function(key, val) {
		if(is.null(key)) val
		else as.data.frame(cbind(key, val))}

input =
	function(input, input.format = "native")
		list(input = input, input.format = input.format)

do = 
	function(pipe, f, ...){
		f1 = to.fun1(f, ...)
		if(is.null(pipe$group.by))
			pipe$do = comp(f1, pipe$do)
		else
			pipe$reduce = comp(constant(NULL), pipe$reduce)
		pipe}

group.by = 
	function(pipe, f, ...) {
		if(is.null(pipe$group.by))
			pipe$group.by = f
		else
			list(input = run(pipe), group.by = f)}

run = 
	function(pipe) 
		mapreduce(
			input = pipe$input,
			input.format = pipe$input.format,
			map = 
				make.mr.fun(
					keyf = {
						if(is.null(pipe$group.by))
							constant(NULL)
						else
							pipe$group.by}, 
					valf = pipe$do),
			reduce =
				if(!is.null(pipe$reduce))
					make.mr.fun( keyf = NULL, valf = pipe$reduce))

output = 
	function(pipe, output, output.format) {
		pipe$output.format = output.format
		pipe$output = output
		run(pipe)}

from.dfs = 
	function(pipe)
		values(rmr2::from.dfs(run(pipe)))

to.dfs = rmr2::to.dfs

to.fun1  = function(f, ...) function(data) f(data, ...)

subset.mr = function(pipe, ...) do(pipe, subset, ...)
filter.mr = subset.mr
transform.mr = function(pipe, ...) do(pipe, transform)
mutate.mr = function(pipe, ...) do(pipe, mutate)
summarize.mr = function(pipe, ...) do(pipe, summarize)
select.mr = summarize.mr
