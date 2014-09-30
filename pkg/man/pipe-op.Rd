\name{\%|\%}
\alias{\%|\%}
\alias{\%!\%}
\title{The pipe operator}
\description{
  Allows to express some complex expressions in a Unix-like pipe notation.
}
\usage{
x \%|\% f
x \%|\% f(\dots)
x \%|\% f(\dots, .., \dots)
g(\dots) \%!\% f
g(\dots) \%!\% f(\dots)
g(\dots) \%!\% f(\dots, .., \dots)
}
\arguments{
\item{x}{Anything that can be evaluated}
\item{f, g}{Functions}
\item{f(\dots), g(\dots), f(\dots, .., \dots)}{Calls}
\item{\dots}{Additional arguments to \code{f}}
\item{..}{A special argument denoting the position where the value of the left side should be passed}
}
\details{
It has been observed that complex expressions of the type \code{f(g(h(x, args.to.h), args.to.g), args.to.f)} are hard to read because they reverse the temporal order in which functions are executed and can put a lot of space between a function name and most of its arguments. While careful indentation can help, this operator offers an alternate style inspired by the UNIX pipe  that overcomes these problems but is not as general as nested expressions. Analogous operators exist in packages \code{magrittr}, \code{vadR} and \code{pipeR}, but the one implemented here has a simpler definition, in your humble developer's opinion. The left side of the operator becomes the value of the variable \code{..} in the right side. If such variable is not present, the left side of the operator becomes the first argument to the call on the right side. \code{g \%!\% f} is a shorthand for function(x) {x \%|\% g \%|\% f}. The same rules for the variable \code{..} apply.
}
\value{
For the usage forms above, respectively, \code{f(x)}, \code{f(x, \dots)}, \code{f(\dots, x, \dots)}. 
}
\examples{
4 \%|\% sqrt
mtcars \%|\% transmute(carb, mpg) \%|\% where(mpg/carb > 10)
mtcars \%|\% names \%|\% grep ("c", .., value = TRUE)
transmute(carb, mpg) \%!\% where(mpg/carb > 10)
}
