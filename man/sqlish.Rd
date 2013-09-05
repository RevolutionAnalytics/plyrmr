\name{where}
\alias{where}
\alias{select}
\title{
Functions to perform sql-like operations on data frames and pipes.
}
\description{

}
\usage{
where(.data, \dots)
\method{where}{data.frame}(.data, \dots, .envir = parent.frame())
\method{where}{pipe}(.data, \dots, .envir = parent.frame())
select(.data, \dots)
\method{select}{data.frame}(.data, \dots, .replace = TRUE, .envir = parent.frame())
\method{select}{pipe}(.data, \dots, .replace = TRUE, .envir = parent.frame())
}
\arguments{
  \item{.data}{A data set represented by a pipe}
  \item{\dots}{Additional arguments interpreted as filtering criteria by where and data columns by select}
  \item{.replace}{whether to replace}
  \item{.envir}{environment in which to evaluate the \dots arguments}
}
\details{
}
\value{
}
\examples{
}
