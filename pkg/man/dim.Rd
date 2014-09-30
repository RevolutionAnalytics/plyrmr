\name{dim}
\alias{dim}
\alias{ncol}
\alias{nrow}
\title{
 Functions to access dimensions of a big data set.
}
\description{
These functions extends the well known \code{dim},\code{ncol} and \code{nrow} functions to work on big data sets.
}
\usage{
\method{dim}{pipe}(x)
\method{dim}{nrow}(x)
\method{dim}{ncol}(x)
}
\arguments{
\item{x}{A big data set}
}
\value{
An integer vector, length 1 for  \code{ncol}. A big data set for \code{ncol} and \code{dim}.
}
\examples{
dim(group(input(mtcars), carb))
ncol(group(input(mtcars), carb))
nrow(group(input(mtcars), carb))
}
