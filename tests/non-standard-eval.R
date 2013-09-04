rm(mtcars)
library(plyrmr)
mtcars = cbind(model = rownames(mtcars), mtcars)
param = 4
as.data.frame(transform(input(mtcars), fourcarb = carb/param))
rm(param)
#(function(){param = 4; as.data.frame(transform(input(mtcars), fourcarb = carb/param))})()
param = 4
as.data.frame(subset(input(mtcars), carb > param))
rm(param)
#(function(){param = 4; as.data.frame(subset(input(mtcars), carb > param))})()
param = 4
as.data.frame(select(input(mtcars), fourcarb = carb/param))
rm(param)
(function(){param = 4; as.data.frame(select(input(mtcars), fourcarb = carb/param))})()
param = 4
as.data.frame(where(input(mtcars), carb > param))
rm(param)
(function(){param = 4; as.data.frame(where(input(mtcars), carb > param))})()
param = 4
as.data.frame(mutate(input(mtcars), fourcarb = carb/param))
rm(param)
#(function(){param = 4; as.data.frame(mutate(input(mtcars), fourcarb = carb/param))})()
param = 4
as.data.frame(summarize(input(mtcars), fourcarb = carb/param))
rm(param)
#(function(){param = 4; as.data.frame(summarize(input(mtcars), fourcarb = carb/param))})()
param = "mpg"
mmtcars = as.data.frame(melt(input(mtcars), c("model", param)))
mmtcars
rm(param)
#(function(){param = "mpg"; as.data.frame(melt(input(mtcars), c("model", param)))})()
param = formula(model ~ variable)
as.data.frame(dcast(input(mmtcars), param))
rm(param)
(function(){param = formula(model ~ variable); as.data.frame(dcast(input(mmtcars), model ~ variable))})()