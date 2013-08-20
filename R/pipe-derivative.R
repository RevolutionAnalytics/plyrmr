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

setMethodS3(
	"where",
	"pipe",
	function(.data, ...)
		do.call.do(.data, where, ...))

setMethodS3(
	"select",
	"pipe",
	function(.data, ...)
		do.call.do(.data, select, ...))

setMethodS3(
	"names",
	"pipe",
	function(x)
		as.data.frame(
			group.by.f(
				do(
					x, 
					function(.y) 
						data.frame(names = names(.y))), 
				function(.x) unique(.x$names), recursive = TRUE)))

setMethodS3(
	"sample",
	"pipe",
	function(x, method = c("any", "Bernoulli"), ...) {
		switch(
			match.arg(method),
			any = {
				n = list(...)[['n']]
				head.n = function(x) head(x, n)
				do(
					group.together(
						do(x, head.n),
						recursive = TRUE),
					head.n)},
			Bernoulli = {
				p = list(...)[["p"]]
				do(x, function(x) x[runif(length(x)) < p,])})})

setMethodS3(
	"sample",
	"default",
	base::sample)