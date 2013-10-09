\name{top.k}
\alias{top.k}
\alias{bottom.k}
\title{
Select top and bottom rows according to some order}
\description{
Select top and bottom rows according to order specified by the \dots arguments.
}
\usage{
top.k(.x, .k = 1, \dots, .envir = parent.frame())
bottom.k(.x, .k = 1, \dots, .envir = parent.frame())
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{.x}{A \code{plyrmr} pipe}
  \item{.k}{How many rows to select}
  \item{\dots}{Expressions to be used to define the order.}
  \item{.envir}{Environment in which to evaluate the \dots arguments}
}
\details{
For details on how the \dots are evaluated see \link{non standard evaluation}, which also clarifies the role of the \code{.envir} argument, and for the order definition see \code{\link{order}}}

\value{
A data set containing the top or bottom k elements according to the order defined by the \dots arguments, represented by a \link[=pipe-class]{pipe}}

\examples{
as.data.frame(top.k(input(mtcars), 4, carb))
}