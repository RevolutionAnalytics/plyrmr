\name{each.column}
\alias{each.column}
\title{
Create data.frame functions that apply a vector function to each column of a data frame}
\usage{
each.column(f)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{f}{
  One vector function or list thereof. Recycled to match number of columns.
}
}

\value{
A data frame obtained applying the given function(s) to each column of the input
}

\examples{
 log.data.frame = each.column(log)
 log.data.frame(mtcars)
}
