stopifnot(
	all(
		(function(){s = 5; where(mtcars, cyl>s, carb < s)})() ==
			subset(mtcars, subset = cyl > 5 & carb < 5)))

stopifnot(
	all(
		(function(){select(mtcars, cyl)})() ==
			subset(mtcars, select = cyl)))