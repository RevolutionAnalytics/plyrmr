library(plyrmr)
rmr.options(backend = "local")
magic.wand(transform)
magic.wand(subset)
magic.wand(mutate)
magic.wand(filter)
#works with param in Global env
param = 4
as.data.frame(bind.cols(input(mtcars), fourcarb = carb/param))
as.data.frame(transform(input(mtcars), fourcarb = carb/param))
as.data.frame(mutate(input(mtcars), fourcarb = carb/param))
rm(param)
# only bind.cols work with local env param
# failing tests commented out by design
# we can't fix base or plyr
(function(){param = 4; as.data.frame(bind.cols(input(mtcars), fourcarb = carb/param))})()
#(function(){param = 4; as.data.frame(transform(input(mtcars), fourcarb = carb/param))})()
#Error in eval(expr, envir, enclos) : object 'param' not found
#(function(){param = 4; as.data.frame(mutate(input(mtcars), fourcarb = carb/param))})()
#Error in mutate_impl(.data, named_dots(...), environment()) : 
#	object 'param' not found
# all is fine with param in Global  env
param = 4
as.data.frame(where(input(mtcars), carb > param))
as.data.frame(subset(input(mtcars), carb > param))
as.data.frame(filter(input(mtcars), carb > param))
rm(param)
#only where works with param in local env.
(function(){param = 4; as.data.frame(where(input(mtcars), carb > param))})()
# (function(){param = 4; as.data.frame(subset(input(mtcars), carb > param))})()
# Error in eval(expr, envir, enclos) : object 'param' not found
# (function(){param = 4; as.data.frame(filter(input(mtcars), carb > param))})()
# Error in filter_impl(.data, dots(...), environment()) : 
# 	object 'param' not found
# melt has the same problem
param = "mpg"
rm(mtcars)
mtcars = cbind(model = rownames(mtcars), mtcars)
mmtcars = as.data.frame(melt(input(mtcars), c("model", param)))
mmtcars
rm(param)
(function(){param = "mpg"; as.data.frame(melt(input(mtcars), c("model", param)))})()
# now works, used to end like:
# Error in melt_check(data, id.vars, measure.vars) : 
# 	object 'param' not found
# dcast works, formula evaluated normally 
param = formula(model ~ variable)
as.data.frame(dcast(input(mmtcars), param))
rm(param)
(function(){param = formula(model ~ variable); as.data.frame(dcast(input(mmtcars), param))})()

