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

where.data.frame = 
	function(.data, .cond, .envir = parent.frame()) {
		force(.envir)
		cond = substitute(.cond)
		cond = 
			non.standard.eval.single(
				.data, 
				cond, 
				.named = FALSE, 
				.envir = .envir)
		.data[cond, , drop = FALSE]}

#(function(){x = 5; where(mtcars, cyl>x)})()

select = function(.data, ...) UseMethod("select")
select.data.frame =
	function(.data, ..., .replace = TRUE, .columns = NULL, .envir = parent.frame()) {
		force(.envir)
		args = 
			non.standard.eval(
			.data, 
			...,
			.named = TRUE,
			.envir = .envir)
		newcols = splat(data.frame)(c(args, list(stringsAsFactors = FALSE)))
		if(!is.null(.columns)) {
			.columns = .data[,.columns, drop = FALSE]
			newcols = {
				if (nrow(newcols) * ncol(newcols) == 0)
					.columns
				else
					safe.cbind(newcols, .columns )}}
		if(.replace)  newcols
		else safe.cbind(.data, newcols)}

#(function(){v = 5;  select(mtcars, cy32 = cyl^2, carb + 5)})()

sample = function(x, ...) UseMethod("sample")
sample.default = base::sample
sample.data.frame = 
	function(x, method = c("any", "Bernoulli", "hypergeometric"), ...) {
		args = list(...)
		switch(
			match.arg(method),
			any = head(x, args[['n']]),
			Bernoulli = 
				x[runif(nrow(x)) < args[["p"]],, drop = FALSE],
			hypergeometric = 
				x[sample(1:nrow(x), args[["n"]], replace = FALSE),,drop = FALSE])}
