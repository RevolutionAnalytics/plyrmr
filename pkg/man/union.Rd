\name{union}
\alias{union}
\alias{intersect}
\title{
Set operation on data sets
}
\description{
Union and intersection of large data sets represented by pipes
}
\usage{
\method{union}{data.frame}(x, y)
\method{union}{pipe}(x, y)
\method{intersect}{data.frame}(x, y)
\method{intersect}{pipe}(x, y)
}
\arguments{
  \item{x,y}{Two data sets represented by pipes}
}

\value{
An object of the same type of the arguments, representing the union or intersection of the two data sets.
}

\examples{
as.data.frame(intersect(input(mtcars[1:10,]), input(mtcars[8:20,])))
}
