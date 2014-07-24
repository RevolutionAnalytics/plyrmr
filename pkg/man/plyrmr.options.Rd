\name{plyrmr.options}
\alias{plyrmr.options}
\title{
Set package options}
\description{
Allows to choose the backend and to set backend-specific options.
}
\usage{
plyrmr.options(backend = c("local", "hadoop"), ...}
\arguments{
\item{backend}{The system supporting the execution of plyrmr programs}
\item{...}{Other options are simply forwarded to the current backend}}
\details{
Execution of plyrmr-based programs can happen outside the R interpreter, typically on computer clusters of some sort. Right now we have  "local" and "hadoop" backends, inherited from rmr2. In the works is a Spark backend. These can be selected with the \code{backend} argument. All other arguments are forwarded to the backend-specific option setting function, right now \code{\link{rmr.options}} for both backends.
When arguments are named, the corresponding options is set to the value of the argument. When unnamed the value of the option corresponding to the argument, a character string, is returned in a list.
}
\value{
When arguments are unnamed, a list of the current value of the requested options.
}
\examples{
plyrmr.options(backend = "local")
plyrmr.options("backend")


}
