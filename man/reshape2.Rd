\name{dcast}
\alias{dcast}
\alias{melt}
\title{
Function to convert big data sets from tall to wide and back.
}
\description{
Modeled after, and actually implemented on top of, equally named functions in the package \code{reshape2}, they implement the same functionality for large data sets. 
}
\usage{
dcast(data, formula, \dots)
\method{dcast}{pipe}(data, formula, \dots)
\method{melt}{pipe}(data, \dots)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{A data set represented by a pipe or a data frame}
  \item{formula}{Casting formula}
  \item{\dots}{Additional arguments}
}

\details{See reshape2::dcast and reshape2::melt for details.}
\value{A data set with the desired format, represented by an object of the same class as the first argument}
\examples{
mtcars = cbind(model = rownames(mtcars), mtcars)
mmtcars = melt(input(mtcars))
as.data.frame(mmtcars)
as.data.frame(dcast(mmtcars, model ~ variable))

}
