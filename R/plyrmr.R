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


cbind.kv = 
	function(k, v) {
		if(is.null(k)) v
		else cbind(k,v)}

mk.mr.fun = 
	function(f)
		function(.data, ...) 
			mapreduce(
				.data,
				map = 
					function(k,v) {
						v = cbind.kv(k, v)
						f(v, ...)})

transform.mr = mk.mr.fun(transform)

subset.mr = mk.mr.fun(subset.mr)
filter.mr = subset.mr

mutate.mr = mk.mr.fun(mutate)
summarize.mr = mk.mr.fun(summarize)
select.mr = summarize.mr


ddply.mr = 
	function(.data,.variables, .fun, .null)
		mapreduce(
			.data, 
			map = 
				function(k,v) {
					v = cbind.kv(k, v)
					keyval(summarize(v, .variables), v)},
			reduce = 
				function(k, vv)
					ddply(vv, .variables, .fun))

save.mr =
	function(big.data, path)
	{ 
		#backend indepenendent mv here
	}

from.dfs = function(...) values(rmr2::from.dfs(...))

merge.mr = 
	function(
		x, 
		y, 
		by, 
		by.x = by, 
		by.y = by, 
		all = FALSE, 
		all.x = all, 
		all.y = all) {
		mk.map = 
			function(by)
				function(k,v) keyval(v[, by], v)
		equijoin(
			left.input = x, 
			right.input = y, 
			map.left = mk.map(by.x), 
			map.right = mk.map(by.y), 
			outer = 
				switch(
					all.x + all.y, 
					"", 
					if(all.x) "left" else "right", 
					"full"))}

quantile.mr = 
	function(x, ..., probs = 1000, na.rm = FALSE, names = TRUE) {
		midprobs =
			function(N) {
				probs = seq(0,1,1/N)
				(probs[-1] + probs[-length(probs)])/2}
		mr.fun = 
			function(reduce = T)
				function(k, v) {
					keyval(
						1, 
						quantile(
							v, 
							..., 
							probs = {
								if(!reduce)
									midprobs(ceiling(probs*length(v)/rmr.options("keyval.length")))
								else
									midprobs(probs)},
							na.rm = na.rm, 
							names = names,
							type = 8))}
		from.dfs(
			mapreduce(
				x, 
				map = mr.fun(F),
				reduce = mr.fun(T), 
	  		combine = mr.fun(F)))}

top.k.mr = 
	function(x, k, by, decreasing) {
		mr.fun = 
			function(k,v)
				keyval(
					1, 
					head(
						v[
							do.call(
								Curry(
									order, 
									decreasing = decreasing),
								v[,c("cyl", "carb")]),],
						k))
		from.dfs(
			mapreduce(
				x, 
				map = mr.fun, 
				reduce = mr.fun, 
				combine = T))}
		
	