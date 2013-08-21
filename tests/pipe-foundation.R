stopifnot(
	all(
		as.data.frame(do(input(mtcars), function(x) list(cyl2 =x$cyl^2))) 
		== 
			mtcars$cyl^2))

stopifnot(
	all(
		(function() {
			expo1 = 2;
			envir = sys.frame(1)
			as.data.frame(
				do(
					input(mtcars), 
					function(x , ...) {
						vars = plyrmr:::non.standard.eval(x, ..., envir = envir)
						list(cyl2 =x$cyl^vars[['expo2']])},
					expo2 = expo1))})()		
		 == 
		 	mtcars$cyl^2))
	