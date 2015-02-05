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

default = rmr2:::default

#strings
# of perl fame
qw = function(...) as.character(match.call())[-1]

#functional
constant = 
	function(x)
		function(...) x

#transfrom a vector function into a data frame one the simplest way

each.column = 
	function(f) {
		if(is.function(f))
			 f = list(f)
		function(df) {
			f = rep_len(f, ncol(df))
			data.frame(mapply(function(x, g) g(x), df, f))}}

# return a function whose env is a copy of the original env (one level only)

copy.env = 
	function(envx) {
		if(!is.null(envx)) {
			list2env(
				as.list(envx, all.names = TRUE), 
				parent= {
					if(
						identical(
							parent.env(envx), 
							parent.env(globalenv())))
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

strip.zerocol.df = 
	function(...)
		lapply(list(...), function(x) if(!is.data.frame(x) || ncol(x) > 0) x)

safe.cbind = 
	function(..., rownames.from = NULL) {
		lengths = sapply(list(...), rmr2:::rmr.length)
		shortest = suppressWarnings(min(lengths))
		if(shortest == Inf) 
			NULL
		else {
			if(!is.null(rownames.from))
				rn = rownames(list(...)[[rownames.from]])
			else {
				rownames.from = which.max(lengths)
				rn = rownames(list(...)[[rownames.from]])}
			ll = lapply(strip.nulls(strip.zerocol.df(...)), selective.I)
			lengths = rmr2:::sapply.rmr.length(ll)
			shortest = suppressWarnings(min(lengths))
			if(shortest == 0)
				data.frame()
			else {
				x = splat(data.frame)(c(ll, list(check.names = FALSE)))
				x = x[, unique(names(x)), drop = FALSE]
				if(!is.null(rn))
					rownames(x) = make.unique(rep(rn, length.out = nrow(x)))
				x}}}

safe.cbind.kv = 
	function(k, v) {
		if(rmr2:::rmr.length(v) == 0) v
		else 
			structure(
				safe.cbind(k, v, rownames.from = 2),
				keys = names(k))}

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

readable.ops = 
	function(x) {
		x %|%
			gsub("\\+", "plus", ..) %|%
			gsub("-", "minus", ..) %|%
			gsub("\\*", "times", ..) %|%
			gsub("/", ".divided.by.", ..) %|%
			gsub("%%", ".mod.", ..) %|%
			gsub("\\^", ".to.pow.", ..)}

data.frame = 
	function(..., row.names = NULL, check.rows = FALSE,
					 check.names = TRUE, stringsAsFactors = FALSE) {
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
			if(!is.null(names(dot.args)))
				names(dot.args) = sapply(names(dot.args), readable.ops)
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
			# if (!is.null(row.names)) {
			# row.names(X) = 
			# make.names(
			# fract.recycling(
			# list(row.names, 1:nrow(X)))[[1]],
			# unique = TRUE)}
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

defactor = 
	function(x)
		lapply(
			x,
			function(y){
				if(is.factor(y))
					as.character(y)
				else y})

deraw = 
	function(x)
		lapply(
			x, 
			function(y) {
				if(is.raw(y))
					as.integer(y)
				else y })

refactor = 
	each.column(function(x) as.factor(as.character(x)))

cmp.df = 
	function(A, B) {
		ord = function(x) do.call(order, deraw(defactor(x)))
		A = refactor(A[ord(A),sort(names(A))])
		B = refactor(B[ord(B),sort(names(B))])
		rownames(A) = NULL
		rownames(B) = NULL
		identical(A, B)}

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

#reflection
# next four functions borrowed from pryr pending CRAN submission, with
# Hadley's permission

"%||%" = function(x, y) if (is.null(x)) y else x

alist = 
	function (...) 
		as.list(sys.call())[-1L]
dots = 
	function(...) 
		eval(substitute(alist(...)))

named_dots =
	function(...) {
		args = dots(...)
		
		nms = names(args) %||% rep("", length(args))
		missing = nms == ""
		if (all(!missing)) return(args)
		
		deparse2 = function(x) paste(deparse(x, 500L), collapse = "")
		defaults = vapply(args[missing], deparse2, character(1), USE.NAMES = FALSE)
		
		names(args)[missing] = defaults
		args}

#non standard eval

VAR = 
	function(x) {
		if(is.character(x))
			eval(as.name(x), parent.frame())
		else
			eval(quote(.data), parent.frame())[,x]}

deVAR = 
	function(expr) {
		if(is.call(expr)) {
			if(expr[[1]] == as.name("VAR"))
				deVAR(expr[[2]])
			else 
				as.call(lapply(as.list(expr), deVAR))}
		else
			expr}

lazy.eval = 
	function(x, data) 
		lazy_eval(x, c(data, list(.data = data)))
		

#pipes

`%|%` = 
	function(x, f) {
		sub.x = substitute(x)
		sub.a.call = substitute(f)
		if(is.name(sub.a.call)) {
			f(x)} 
		else {
			if(is.call(sub.a.call) && !find..(sub.a.call)){
				call.list = as.list(sub.a.call)
				do.call(
					as.character(call.list[[1]]), 
					c(
						list(sub.x), 
						call.list[-1]), 
					envir = parent.frame())}
			else {
				if(is.call(sub.a.call)) {
					env = new.env(parent = parent.frame())
					env$`..` = x
					eval(sub.a.call, envir = env)} 
				else {
					stop("Error in pipe operator")}}}}

find.. = 
	function(x) {
		x = as.list(x)
		if(identical(x[[1]], as.name("%|%")))
			find..(x[[2]])
		else
			any(
				sapply(
					x, 
					function(y) {
						if(is.name(y)) 
							identical(y, as.name(".."))
						else {
							if(is.call(y))
								find..(y)
							else FALSE}}))}	

`%!%` = 
	function(left, right) {
		pf = parent.frame()
		sleft = substitute(left)
		sright = substitute(right)
		function(x) {
			eval(
				substitute(
					x %|% left %|% right,
					list(left = sleft, right = sright)),
				enclos = pf)}}