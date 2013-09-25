\name{rbind}
\alias{rbind}
\title{
Concatenate two  data sets by rows}
\description{
Like its data frame counterpart, the pipe method ensures that the result will have one row for each of the rows in the arguments, indentical to them. Unlike it, it won't guarantee anthing as far as the order of the rows.}
\usage{
rbind(...)
\method{rbind}{pipe}(...)
}
\arguments{
  \item{\dots}{Data sets to concatenate}
}
\details{
}
\value{
The same type of object as the arguments.
}
\examples{
as.data.frame(rbind(input(mtcars), input(mtcars)))
}
