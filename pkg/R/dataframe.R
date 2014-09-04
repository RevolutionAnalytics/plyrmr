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

where.data.frame_ = 
	function(.data, .cond) {
		cond = lazy_eval(.cond, .data)
		.data[cond, , drop = FALSE]}

where.data.frame = 
	function(.data, .cond) {
		cond = lazy(.cond)
		cond$expr = var.subs(cond$expr)
		where.data.frame_(.data, cond)}

transmute = function(.data, ...) UseMethod("transmute")

transmute.data.frame_ =
	function(.data, dot.args, .cbind, .columns) {
		names(dot.args) = 
			ifelse(
				names(dot.args) == "",  
				lapply(dot.args, function(x) deparse(x$expr)),
				names(dot.args))
		newcols =
			splat(data.frame)(
				c(
					lapply(
						dot.args,
						lazy_eval,
						data = .data),
					list(stringsAsFactors = FALSE)))
		if(.cbind) .columns = names(.data)
		if(!is.null(.columns)) {
			.columns = .data[,.columns, drop = FALSE]
			newcols = {
				if (nrow(newcols) * ncol(newcols) == 0)
					.columns
				else
					safe.cbind(.columns, newcols)}}
	newcols}

transmute.data.frame = 
	function(.data, ..., .cbind = FALSE, .columns = if(.cbind) names(.data) else NULL) {
		dot.args = 
			lapply(
				lazy_dots(...), 
				function(x){
					x$expr = var.subs(x$expr)
					x})
		transmute.data.frame_(.data, dot.args, .cbind = .cbind,  .columns = .columns)}

bind.cols = function(.data, ...) UseMethod("bind.cols")	

bind.cols.data.frame_ =
	function(.data, dot.args) {
		transmute.data.frame_(.data, dot.args, .cbind = TRUE)}

bind.cols.data.frame = 
	function(.data, ...) 
		bind.cols.data.frame_(.data, lazy_dots(...))

select = dplyr::select
magic.wand(select, non.standard.args = TRUE)


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
