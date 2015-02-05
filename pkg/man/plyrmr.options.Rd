\name{plyrmr.options}
\alias{plyrmr.options}
\title{
Set package options}
\description{
Allows to choose the backend and to set backend-specific options.
}
\usage{
plyrmr.options(backend = c("local", "hadoop", "spark"), ...)}
\arguments{
\item{backend}{The system supporting the execution of plyrmr programs}
\item{...}{Other options are simply forwarded to the current backend}}
\details{
Execution of plyrmr-based programs can happen outside the R interpreter, typically on computer clusters of some sort. This notion is referred to as a swappable backend. Right now we have  "local", "hadoop" and "spark" backends. These can be selected with the \code{backend} argument. All other arguments are forwarded to the backend-specific option setting function, right now \code{\link{rmr.options}} for "local" and "hadoop" and an internal function for "spark". The only spark-specific option is \code{context} that you can use to share a Spark context with functions in package SparkR, for instance \code{parallelize}. The local backend is fully implemented in a single R session for ease of development and debugging. It's not meant do any large or even medium scale data analysis. 
When arguments are named, the corresponding options is set to the value of the argument. When unnamed the value of the option corresponding to the argument, a character string, is returned in a list.
}
\value{
When arguments are unnamed, a list of the current value for the requested options.
}
\examples{
plyrmr.options(backend = "local")
plyrmr.options("backend")

}
