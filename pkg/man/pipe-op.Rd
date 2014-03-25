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
x \%|\% f(\dots, ., \dots)
f \%!\% g
}
\arguments{
\item{x}{Anything that can be evaluated}
\item{f, g}{Functions}
\item{\dots}{Additional arguments to \code{f}}
\item{.}{A special argument denoting the position where the value of the left side should be passed}
}
\details{
It has been observed that complex expressions of the type \code{f(g(h(x, args.to.h), args.to.g), args.to.f)} are hard to read because they reverse the temporal order in which functions are executed and can put a lot of space between the the function names and most of its arguments. While careful indentation can help, these operators offer an alternate style inspired by the UNIX pipe  that overcomes these problems but is not as general as nested expressions. Analogous operators exist in packages \code{magrittr} and \code{dplyr}.
}
\value{
For the usage forms above, respectively, \code{f(x)}, \code{f(x, \dots)}, \code{f(\dots, x, \dots)} and \code{function(x) f(g(x))}. \code{\%!\%} accepts the same variants with \dots and \code{.} as \code{\%|\%}.
}
\examples{
4 \%|\% sqrt
mtcars \%|\% transmute(carb, mpg) \%|\% where(mpg/carb > 10)
mtcars \%|\% names \%|\% grep ("c", ., value = TRUE)
transmute(carb, mpg) \%!\% where(mpg/carb > 10)
}
