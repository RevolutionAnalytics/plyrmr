\name{get.format}
\alias{get.format}
\alias{to.rmr}
\title{
Functions that allow passing plyrmr data into R
}
\description{
\code{get.format} extracts format information from a big data object. \code{to.rmr} extracts a reference to the data in a form usable in rmr}

\usage{
get.format(x)
to.rmr(x)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{A big data object as returned, for instance, by \code{\link{output}}
}}
\value{
\code{get.format} returns a format specification that can be passed to \code{\link[rmr2]{mapreduce}}, \code{input.format} argument. \code{to.rmr} returns an object that can be used as input to \code{\link[rmr2]{mapreduce}}.
}
\examples{
x = output(transform(input(mtcars)))
get.format(x)
to.rmr(x)
}
