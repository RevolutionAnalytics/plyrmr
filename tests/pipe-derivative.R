stopifnot(
	all(
		(
			function(){
				s = 5
				envir = sys.frame(sys.nframe())
				as.data.frame(where(input(mtcars), cyl>s, carb < s, envir = envir))})() ==
			subset(mtcars, subset = cyl > 5 & carb < 5)))

stopifnot(
	all(
		(function(){as.data.frame(select(input(mtcars), cyl))})() ==
			subset(mtcars, select = cyl)))