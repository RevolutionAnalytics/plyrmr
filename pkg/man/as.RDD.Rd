\name{as.RDD}
\alias{as.RDD}
\alias{available.spark.formats}
\title{
   Spark specific functions.
}
\description{
	\code{as.RDD} extracts the underlying RDD to be used in SparkR. \code{available.spark.formats} returns a list of implemented formats when the spark backend is active.}
	
\usage{
	as.RDD(x, ...)
	available.spark.formats()
}
\arguments{
\item{x}{A plyrmr pipe}
\item{...}{Not sure, just trying to avoid build warnings}
}

\value{
For \code{as.RDD} a SparkR RDD. For \code{available.spark.formats} a character vector of implemented formats.
}
\examples{
if(require("SparkR")) {
	plyrmr.options(backend = "spark")
	as.RDD(input(mtcars))
	available.spark.formats()
}}

