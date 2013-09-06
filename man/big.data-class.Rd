\name{big.data-class}
\Rdversion{1.1}
\docType{class}
\alias{big.data-class}

\title{Class \code{"big.data"}}
\description{
This class represents a data set stored on the file system. It encapsulates details such as its path and format. It is a front end for rmr2's big data objects, which are garbage collected temporary files, but can also contain persisten, user determined locations. The main call accepting objects of this class is input, and output returns one.
}

\section{Methods}{
	\itemize{
		\item{as.character}
		\item{as.data.frame}
		\item{print}
}}



\examples{
output(
  select(
    input(mtcars), 
    cyl > 4), 
  format = "csv")}
