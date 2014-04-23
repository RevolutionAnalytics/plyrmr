\name{quantile.cols}
\alias{quantile.cols}
\title{Compute the quantiles of a data set}
\description{Find the quantiles of each numerical column of a data set, represented by a pipe or a data.frame}
\usage{
\method{quantile.cols}{data.frame}(x, \dots)
\method{quantile.cols}{pipe}(x, N = 10^5, \dots)
}
\arguments{
  \item{x}{
A data set represented by a pipe or a data frame.
}
\item{\dots}{
Additional arguments, see stats::quantile for details}
}
\details{
The methods for pipes uses an approximation methods whose exact properties need to be studied in more detail. The interaction with the algorithm selection operated by the type argument have not been explored.
}

\value{
A pipe or a data frame, depending on the class of the first argument}

\examples{
quantile.cols(mtcars)
as.data.frame(quantile.cols(input(mtcars)))
}
