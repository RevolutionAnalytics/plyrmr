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

#strings
# of perl fame
qw = function(...) as.character(match.call())[-1]

#functional
constant = 
	function(x)
		function(...) x

callapply = 
	function(x, f) {
		x = substitute(x)
		calapply.q(x, f)}

callapply.q = 
	function(x, f)
		as.call(lapply(x, function(y) if(is.call(y)) callapply.q(y, f) else f(y)))

to.function = 
	function(f, envir) {
		if(!is.function(f))
			function(x) chain.value.q(x, f, envir)
		else 
			f}

chain.call.q = 
  function(f, g, envir)
  	Compose(to.function(f, envir), to.function(g, envir))

chain.call = 
	function(f, g, envir = parent.frame()) {
		f = substitute(f)
		g = substitute(g)
		chain.call.q(f, g, envir = envir)}

chain.value.q = 
	function(x, f, envir) {
		ff = { 
			if(is.symbol(f))
				list(f, x)
			else {
				if(f[[1]] == "(")
					list(f[[2]], x)
				else {
					if(f[[1]] == "%!%")
						list(f, x)
					else {
						use.default.arg = TRUE
						f = callapply.q(f, function(y) if(is.symbol(y) && y == ".") {use.default.arg <<- FALSE; x} else y)
						if(use.default.arg) 
							c(list(f[[1]], x), as.list(f[-1]))
						else f}}}}
		eval(as.call(ff), envir = envir)}

chain.value =
	function(x, f, envir = parent.frame()) {
		x = substitute(x)
		f = substitute(f)
		chain.value.q(x, f, envir = envir)}

`%|%` = chain.value
`%!%` = chain.call

#curried arguments are eager, the rest lazy
CurryHalfLazy = 
	function(FUN, ...) {
		.orig = list(...)
		function(...) 
			do.call(FUN, c(.orig, dots(...)))}

# retun a function whose env is a copy of the original env (one level only)

copy.env = 
	function(envx) {
		if(!is.null(envx)) {
			list2env(
				as.list(envx, all.names = TRUE), 
				parent= {
					if(identical(envx, globalenv()))
						parent.env(envx)
					else
						copy.env(parent.env(envx))})}}

freeze.env = 
	function(x) {
		envx = environment(x)
		nenv = copy.env(envx)
		environment(x) = nenv
		x}

#data frames

selective.I = function(x) if(is.list(x) && !is.data.frame(x)) I(x) else x

safe.cbind  = 
	function(...) {
		ll = lapply(strip.zero.col(strip.null.args(...)), selective.I)
		shortest = min(rmr2:::sapply.rmr.length(ll))
		if(shortest == 0)
			data.frame()
		else {
			x = splat(data.frame)(c(ll, list(check.names = FALSE)))
			x[, unique(names(x)), drop = FALSE]}}

safe.cbind.kv = 
	function(k, v) 
		structure(
			safe.cbind(k, v),
			keys = names(k))

fract.recycling = 
	function(ll) {
		ind = 
			do.call(
				cbind, 
				lapply(
					ll, 
					function(x) 1: rmr2:::rmr.length(x)))
		retval =
			lapply(
				1:length(ll), 
				function(i) rmr2:::rmr.slice(ll[[i]],ind[,i]))
		names(retval) = names(ll)
		retval}

data.frame = 
	function(..., row.names = NULL, check.rows = FALSE,
					 check.names = TRUE, stringsAsFactors = default.stringsAsFactors()) {
		dot.args = list(...)
		if(length(dot.args) == 0) 
			base::data.frame()
		else {
			if(is.null(row.names)) {
				row.names = {
					strip.nulls(
						lapply(
							dot.args, 
							function(arg) {
								if(rmr2:::has.rows(arg)) row.names(arg) 
								else names(arg)}))}
				row.names = { 
					if(length(row.names) > 0)
						row.names[[1]]
					else NULL }}
			X =  				
				base::data.frame(
					fract.recycling(
						lapply(
							dot.args, 
							selective.I)),
					row.names = NULL,
					check.rows = check.rows,
					check.names = check.names,
					stringsAsFactors = stringsAsFactors)
# 			if (!is.null(row.names)) {
# 				row.names(X) = 
# 					make.names(
# 						fract.recycling(
# 							list(row.names, 1:nrow(X)))[[1]],
# 						unique = TRUE)}
			X }}

as.data.frame.data.frame = splat(data.frame)

data.frame.fill = 
	function(..., filler = NA) {
		argl = strip.null.args(...)
		argl = splat(c)(argl)
		if(is.null(argl)) NULL
		else {
			maxlen = max(sapply(argl, length))
			sapply(
				seq_along(argl), 
				function(i) length(argl[[i]]) <<- maxlen)
			splat(data.frame)(argl)}}

#lists

strip.nulls = 
	function(x) 
		x[!sapply(x, is.null)]

strip.null.args = 
	function(...)
		strip.nulls(list(...))

strip.zero.col = 
	function(x)
		x[sapply(x, ncol) > 0]

#dynamic scoping

non.standard.eval = 
	function(.data,  ..., .named = TRUE,  .envir = stop("Why wasn't .envir specified? Why?")) {
		force(.envir)
		dotlist = {
			if(.named)
				named_dots(...)
			else
				dots(...) }
		env = list2env(c(.data, list(.data = .data)), parent = .envir)
		lapply(dotlist, function(x) eval(eval(x, env), env))}

non.standard.eval.single = 
	function(.data,  .arg, .named = TRUE,  .envir = stop("Why wasn't .envir specified? Why?")) {
		force(.envir)
		env = list2env(c(.data, list(.data = .data)), parent = .envir)
		eval(eval(.arg, env), env)}

#reflection
# next four functions borrowed from pryr pending CRAN submission, with
# Hadley's permission

"%||%" <- function(x, y) if (is.null(x)) y else x

alist = 
	function (...) 
		as.list(sys.call())[-1L]
dots = 
	function(...) 
		eval(substitute(alist(...)))

named_dots =
	function(...) {
		args <- dots(...)
		
		nms <- names(args) %||% rep("", length(args))
		missing <- nms == ""
		if (all(!missing)) return(args)
		
		deparse2 <- function(x) paste(deparse(x, 500L), collapse = "")
		defaults <- vapply(args[missing], deparse2, character(1), USE.NAMES = FALSE)
		
		names(args)[missing] <- defaults
		args}
