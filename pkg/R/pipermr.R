# Copyright 2014 Revolution Analytics
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

drop.gather.rmr = 
	function(x){
		if(is.element(".gather", names(x))) {
			x = x[, !(names(x) == ".gather"), drop = FALSE]
			if (ncol(x) * nrow(x) == 0) NULL else x}
		else
			x}

make.task.fun =   																			     	# this function is a little complicated so some comments are in order
	function(keyf, valf,  vectorized) {	  # make a valid map function from two separate ones for keys and values
		if(is.null(valf))                                         # the value function defaults to identity
			valf = identity 
		function(k, v) {                                          # this is the signature of a correct map function
			rownames(k) = NULL                                      # wipe row names unless you want them to count in the grouping (Hadoop only sees serialization)
			if(vectorized) {
				w = 
					as.data.frame(
						valf(
							do.call(
								group_by, 
								c(
									list(
										drop.gather.rmr(safe.cbind.kv(k, v)), 
										names(k))))))
				k = w[, names(k)]}             # here we count on a vectorized grouping fun to keep the keys
			else {
				w = valf(drop.gather.rmr(safe.cbind.kv(k, v)))
				w = safe.cbind.kv(k,	w)} # pass both keys and values to val function as a single data frame, then make sure we keep keys for the next step
			k = {
				if(is.null(keyf)) k              # by default keep grouping whatever it is
				else keyf(structure(drop.gather.rmr(w), keys = names(k)))}		# but if you have a key function, use it and cbind old and new keys
			if(!is.null(w) && nrow(w) > 0) keyval(k, drop.gather.rmr(w))}}  # special care for empty cases

make.map.fun = 
	function(keyf, valf)
		make.task.fun(keyf, valf, vectorized = FALSE)

make.reduce.fun = 
	function(keyf, valf, vectorized) 
		make.task.fun(keyf, valf, vectorized)

make.combine.fun = 
	function(valf, vectorized) {
		cf  = make.task.fun(NULL, valf, vectorized = vectorized)
		function(k, v) {
			retval = cf(k, v)
			nm = sapply(names(v), function(col) grep(paste0(col), names(retval$val), value=T))
			mn = names(nm)
			names(mn) = nm
			new.names = mn[names(retval$val)]
			mask = !is.na(new.names)
			names(retval$val)[mask] = new.names[mask]
			retval}}

gapply.pipermr =
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

group.f.pipermr = 
	function(.data, .f,  ..., .reset = FALSE) {
		.f = freeze.env(.f)
		f1 = make.f1(.f, ...)
		if(is.null(.data$group)) { #ungrouped
			.data$group = f1}
		else {
			if(is.null(.data$reduce)){ #refine grouping with no mr job
				prev.group = .data$group
				.data$group = {
					if(.reset) 
						function(v) {
							pg = prev.group(v)
							f1(structure(v, keys = names(pg)))}
					else
						function(v) {
							pg = prev.group(v)
							safe.cbind(pg, f1(structure(v, keys = names(pg))))}}}
			else #run and apply grouping
				.data = 
				group.f(
					input(run(.data, input.format = "native")), 
					.f = f1,
					.reset = .reset)}
		.data}

ungroup.fun = 
	function(...) {
		ungroup.cols = names(named_dots(...))
		if(length(ungroup.cols) == 0)
			function(w) NULL
		else
			function(w) {
				w[, setdiff(attributes(w)$keys, ungroup.cols), drop = FALSE]}}

ungroup.pipermr = 
	function(.data, ...){ 
		if(!is.grouped(.data))
			.data
		else{
		x = group.f(.data, ungroup.fun(...), .reset = TRUE)
		if(length(dots(...)) == 0)
			x$group = NULL
		x}}

is.grouped.pipermr = 
	function(.data)
		!is.null(.data[["group"]])

gather.pipermr = 
	function(.data) {
		if(is.grouped(.data)) 
			.data
		else {
			pipe = group(.data, .gather = 1)
			pipe$recursive.group = TRUE
			pipe}}

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
memoise(
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
						keyf = NULL,
						valf = pipe$reduce, 
						vectorized = default(pipe$vectorized, FALSE))
				mr.args$vectorized.reduce = pipe$vectorized}
			if(!is.null(pipe$recursive.group) &&
				 	pipe$recursive.group) {
				mr.args$combine =
					make.combine.fun(pipe$combine, default(pipe$vectorized, FALSE))}
			mrexec(mr.args, input.format)}})

output.pipermr = 
	function(.data, path = NULL, format = "native", input.format = format) {
		if(missing(input.format) && !is.character(format))
			stop("need to specify a custom input format for a custom output")
		.data[["output.format"]] = format
		.data[["output"]] = path
		as.big.data(.data, input.format)}

as.big.data.pipe = run

as.pipermr = 
	function(x, ...) UseMethod("as.pipermr")

as.pipermr.big.data = 
	function(x, ...) 
		structure(
			strip.null.args(
				input = x,
				ungroup = FALSE),
			class = c("pipermr", "pipe"))

as.pipermr.data.frame = 
	function(x, ...) 
		as.pipermr(as.big.data(x, "native"))

as.pipermr.character = 
	as.pipermr.function = 
	function(x, format = "native", ...) 
		as.pipermr(as.big.data(x, format))

as.pipermr.list = Compose(as.big.data, as.pipermr)

as.data.frame.pipermr =
	function(x, ...)
		as.data.frame(
			as.big.data(x))

merge.helper.pipermr = 
	function(x, y, by.x, by.y, outer, reduce) {
		ox = output(x)
		oy = output(y)
		stopifnot(ox$format == oy$format)
		map =
			function(by.what)
				function(k, v) 
					keyval(
						if(is.null(by.what)) v else  v[, by.what],
						v)
		map.x = map(by.x)
		map.y =  map(by.y)
		input(
			equijoin(
				ox$data,
				oy$data,
				input.format = ox$format,
				outer = outer,
				map.left = map.x,
				map.right = map.y,
				reduce = reduce))}

rbind.pipermr = 
	function(...)
		gapply(input(lapply(list(...), output)), identity)

