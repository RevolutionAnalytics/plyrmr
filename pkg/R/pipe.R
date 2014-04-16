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

drop.gather = 
	function(x){
		if(is.element(".gather", names(x))) {
			x = x[, !(names(x) == ".gather"), drop = FALSE]
			if (ncol(x) * nrow(x) == 0) NULL else x}
		else
			x}

make.task.fun = 																					# this function is a little complicated so some comments are in order
	function(keyf, valf, ungroup, ungroup.args, vectorized) {												# make a valid map function from two separate ones for keys and values
		if(is.null(valf))                                   # the value function defaults to identity
			valf = identity 
		function(k, v) {                                    # this is the signature of a correct map function
			rownames(k) = NULL                                # wipe row names unless you want them to count in the grouping (Hadoop only sees serialization)
			if(vectorized) {
				w = valf(drop.gather(safe.cbind.kv(k, v)))
				k = w[, names(k)]}
			else
				w = valf(drop.gather(safe.cbind.kv(k, v)))        # pass both keys and values to val function as a single data frame, then make sure we keep keys for the next step
			if (ungroup) 					# if ungroup called select or reset keys, otherwise accumulate
				k = {
					if(length(ungroup.args) == 0) 
						NULL            
					else
						do.call(select, c(list(k), lapply(ungroup.args, function(a) as.call(list(as.name("-"), a)))))}
			w = safe.cbind(k,	w)
			k = {	
				if(is.null(keyf)) k 														# by default keep grouping whatever it is
				else safe.cbind(k, keyf(drop.gather(w)))}										# but if you have a key function, use it and cbind old and new keys
			if(!is.null(w) && nrow(w) > 0) keyval(k, drop.gather(w))}}     # special care for empty cases

make.map.fun = 
	function(keyf, valf)
		make.task.fun(keyf, valf, ungroup = FALSE, ungroup.args = NULL, vectorized = FALSE)

make.reduce.fun = 
	function(valf, ungroup, ungroup.args, vectorized) 
		make.task.fun(NULL, valf, ungroup, ungroup.args, vectorized)

make.combine.fun = 
	function(valf, vectorized) {
		cf  = make.task.fun(NULL, valf, ungroup = FALSE, ungroup.args = NULL, vectorized = vectorized)
		function(k, v) {
			retval  = cf(k, v)
			nm = sapply(names(v), function(col) grep(paste0(col), names(retval$val), value=T))
			mn = names(nm)
			names(mn) = nm
			new.names = mn[names(retval$val)]
			mask = !is.na(new.names)
			names(retval$val)[mask] = new.names[mask]
			retval}}

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
		print(as.data.frame(sample(x, method = "any", n = 100)))
		invisible(x)}

make.f1 = 
	function(f, ...) {
		dot.args = dots(...)
		function(.x) {
			.y = do.call(f, c(list(.x), dot.args))
			if(is.data.frame(.y))
				.y else {
					if(is.matrix(.y))
						as.data.frame(.y, stringsAsFactors = F)
					else 
						data.frame(x = .y, stringsAsFactors = F)}}}

mergeable = 
	function(f, flag = TRUE) 
		structure(f, mergeable = flag)

vectorized = 
	function(f, flag = TRUE) 
		structure(f, vectorized = flag)

is.mergeable = 
	function(f) 
		default(attr(f, "mergeable", exact=TRUE), FALSE)

is.vectorized = 
	function(f) 
		default(attr(f, "vectorized", exact=TRUE), FALSE)

gapply =  
	function(.data, .f, ...){
		.f = freeze.env(.f)
		f1 = make.f1(.f, ...)
		if(is.null(.data$group)) #still map phase
			.data$map = comp(.data$map, f1)
		else { #reduce phase
			if(!is.mergeable(.f) && 
				 	is.null(.data$reduce) && 
				 	default(.data$recursive.group, FALSE))
				stop("Did you try to combine a gather with a non-mergeable operation?")
			if(is.mergeable(.f) && is.null(.data$reduce)) { #can use combiner
				.data$recursive.group = TRUE
				.data$combine = f1}
			.data$reduce = comp(.data$reduce, f1)
			.data$vectorized =
				default(.data$vectorized, TRUE) &&
				is.vectorized(.f)}
		.data}

group = 
	function(.data, ..., .envir = parent.frame()) {
		force(.envir)
		dot.args = dots(...)
		group.f(
			.data, 
			function(.y) 
				do.call(CurryHalfLazy(transmute, .envir = .envir), c(list(.y), dot.args)))}

group.f = 
	function(.data, .f, ...) {
		.f = freeze.env(.f)
		f1 = make.f1(.f, ...)
		if(is.null(.data$group)) { #ungrouped
			.data$group = f1}
		else {
			if(is.null(.data$reduce)){ #refine grouping with no mr job
				prev.group = .data$group
				.data$group = function(v) safe.cbind(prev.group(v), f1(v))}
			else #run and apply grouping
				.data = 
				group.f(
					input(run(.data, input.format = "native")), 
					f1)}
		.data}

ungroup = 
	function(.data, ...) {
		if(is.grouped(.data) && !is.null(.data$reduce)) {
			.data$ungroup = TRUE
			.data$ungroup.args = named_dots(...)
			phase1 = input(run(.data, input.format = "native"))
			if(length(.data$ungroup.args) == 0)
				phase1
			else 
				group.f(phase1, function(x) data.frame(.gather = 1))}
		else {
			if (is.grouped(.data)) {
				.data$group = NULL
				.data$ungroup = FALSE #what happens to ungroup.vars here
				.data}
			.data}}

gather = 
	function(.data) {
		if(is.grouped(.data)) 
			.data
		else {
			pipe = group(.data, .gather = 1)
			pipe$recursive.group = TRUE
			pipe}}

is.grouped = 
	function(.data)
		!is.null(.data[["group"]])

mr.options = 
	function(.data, ...) {
		args = list(...)
		.data[names(args)] = args
		.data }

mrexec =
	function(mr.args, input.format) #this is not the input format for the run but the one to encapsulate with the result to read it later
		as.big.data(
			do.call(mapreduce, mr.args),
			format = input.format)

run = 
	function(.data, input.format = NULL, ...) { #this is not the input format for the run but the one to encapsulate with the result to read it later
		dof = default(.data[['output.format']], "native")
		if(is.null(input.format)) {
			if(is.character(dof))
				input.format = dof
			else
				stop("need to specify input format corresponding to custom output format")}
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
					valf = pipe$map)
			if(!is.null(pipe$reduce)) {
				stopifnot(!is.null(pipe$group))
				mr.args$reduce = 
					make.reduce.fun(
						valf = pipe$reduce, 
						ungroup = default(pipe$ungroup, FALSE),
						ungroup.args = pipe$ungroup.args,
						vectorized = default(pipe$vectorized, FALSE))
				mr.args$vectorized.reduce = pipe$vectorized}
			if(!is.null(pipe$recursive.group) &&
				 	pipe$recursive.group) {
				mr.args$combine =
					make.combine.fun(pipe$combine, default(pipe$vectorized, FALSE))}
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
			as.big.data(x))

input = as.pipe

is.generic = 
	function(f) 
		length(methods(f)) > 0

magic.wand = 
	function(f, non.standard.args = TRUE, add.envir.arg = non.standard.args, envir = parent.frame(), mergeable = FALSE, ...){
		suppressPackageStartupMessages(library(R.methodsS3))
		f.name = as.character(substitute(f))
		f.data.frame = {
			if(is.generic(f))
				getMethodS3(f.name, "data.frame")
			else f}
		g = {
			if(add.envir.arg)
				non.standard.eval.patch(f.data.frame)
			else
				f.data.frame}
		setMethodS3(
			f.name,
			"data.frame",
			g,
			overwrite = FALSE,
			envir = envir)
		setMethodS3(
			f.name,
			"pipe", 
			if(non.standard.args)
				function(.data, ..., .envir = parent.frame()) {
					.envir = copy.env(.envir)
					curried.g = CurryHalfLazy(g, .envir = .envir)
					gapply(.data, mergeable(curried.g, mergeable), ...)}
			else
				function(.data, ...)
					do.call(gapply, c(list(.data, mergeable(g, mergeable)), list(...))),
			envir = envir)} 