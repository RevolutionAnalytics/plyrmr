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

# function manip

comp = 
	function(...) {
		funs = list(...)
		funs = strip.nulls(funs)
		if(length(funs) == 1)
			funs[[1]]
		else		
			do.call(Compose, funs)}

make.map.fun = 
	function(keyf, valf, ungroup) {
		if(is.null(valf)) 
			valf = identity 
		function(k, v) {
			w = safe.cbind(k, valf(safe.cbind(k, v)))
			if (ungroup) k = NULL
			k = {	
				if(is.null(keyf)) k 
				else safe.cbind(k, keyf(v))}
			keyval(k, w)}}

make.reduce.fun = 
	function(valf, ungroup) 
		make.map.fun(NULL, valf, ungroup)

make.combine.fun = Curry(make.reduce.fun, ungroup = FALSE)

#pipes

is.data = 
	function(x)
		inherits(x, "pipe")

as.character.pipe = 
	function(x, ...) 
		paste(
			"Slots set:", 
			paste(names(unclass(x)), collapse = ", "), "\n",
			"Input:",
			paste(as.character(x[["input"]]), collapse = ","),
			"\n")

print.pipe =
	function(x, ...) {
		print(as.character(x))
		invisible(x)}

make.f1 = 
	function(f, ...) {
		dot.args = dots(...)
		freeze.env(
			function(.x) {
				.y = do.call(f, c(list(.x), dot.args))
				if(is.data.frame(.y))
					.y else {
						if(is.matrix(.y))
							as.data.frame(.y, stringsAsFactors = F)
						else 
							data.frame(x = .y, stringsAsFactors = F)}})}
do =  
	function(.data, f, ...){
		f1 = make.f1(f, ...)
		if(is.null(.data$group))
			.data$map = comp(.data$map, f1)
		else
			.data$reduce = comp(.data$reduce, f1)
		.data}

group = 
	function(.data, ..., recursive = FALSE, envir = parent.frame()) {
		force(envir)
		dot.args = dots(...)
		gbf = 
			group.f(
				.data, 
				function(.y) 
					do.call(CurryHalfLazy(select, .envir = envir), c(list(.y), dot.args)),
				recursive = recursive)}

group.f = 
	function(.data, f, ..., recursive = FALSE) {
		f1 = make.f1(f, ...)
		if(is.null(.data$group)){
			.data$group = f1
			if(recursive) 
				.data$recursive.group = TRUE
			.data}
		else
			group.f(
				input(run(.data, input.format = "native")), 
				f1, 
				recursive = recursive)}

ungroup = 
	function(.data) {
		if(is.grouped(.data)) {
			.data$ungroup = TRUE
			input(run(.data, input.format = "native"))}
		else
			.data}

group.together = 
	function(.data, recursive = TRUE) {
		if(is.grouped(.data)) 
			.data
		else
			group(.data, 1, recursive = recursive)}

is.grouped = 
	function(.data)
		!is.null(.data[["group"]])

mr.options = 
	function(.data, ...) {
		args = list(...)
		.data[names(args)] = args
		.data }

mrexec =
	function(mr.args, input.format)
		as.big.data(
			do.call(mapreduce, mr.args),
			format = input.format)

run = 
	function(.data, input.format, ...) {
		pipe = .data
		if(
			all(
				sapply(
					pipe[qw(map, reduce, group)], 
					is.null))) { 
			if(!is.null(pipe[["output"]])) {
				dfs.mv(pipe[["input"]]$data, pipe[["output"]])
				as.big.data(pipe[["output"]], pipe[["input"]]$format)}
			else {
				pipe[["input"]]}}
		else {
			mr.args = list()
			mr.args$input = pipe$input$data
			mr.args$input.format = pipe$input$format
			mr.args$output = pipe[['output']]
			mr.args$output.format = pipe[['output.format']]
			mr.args = strip.nulls(mr.args)
			mr.args$map = 
				make.map.fun(
					keyf = pipe$group, 
					valf = pipe$map,
					pipe$ungroup)
			if(!is.null(pipe$reduce) &&
				 	!is.null(pipe$group)) {
				mr.args$reduce = 
					make.reduce.fun(
						valf = pipe$reduce, 
						pipe$ungroup)}
			if(!is.null(pipe$recursive.group) &&
				 	pipe$recursive.group) {
				mr.args.combine =
					make.combine.fun(pipe$reduce)}
			mrexec(mr.args, input.format)}}

output = 
	function(.data, path = NULL, format = "native", input.format = format) {
		if(missing(input.format) && !is.character(format))
			stop("need to specify a custom input format for a custom output")
		.data[["output.format"]] = format
		.data[["output"]] = path
		as.big.data(.data, input.format)}

as.big.data.pipe = run

as.pipe = function(x, ...) UseMethod("as.pipe")

as.pipe.big.data = 
	function(x, ...) 
		structure(
			strip.null.args(
				input = x,
				ungroup = FALSE),
			class = "pipe")

as.pipe.data.frame = 
	function(x, ...) 
		as.pipe(as.big.data(x, "native"))

as.pipe.character = 
as.pipe.function = 
	function(x, format = "native", ...) 
		as.pipe(as.big.data(x, format))

as.pipe.list = Compose(as.big.data, as.pipe)

as.data.frame.pipe =
	function(x, ...)
		as.data.frame(
			as.big.data(x, "native"))

input = as.pipe

magic.wand = 
	function(f) 
		setMethodS3(
			as.character(substitute(f)), 
			"pipe", 
			function(.data, ...) 
				do(.data, f, ...),
			envir=parent.frame())
