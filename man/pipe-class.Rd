\name{pipe-class}
\Rdversion{1.1}
\docType{class}
\alias{pipe-class}

\title{Class \code{"pipe"}}
\description{
A pipe represents a data set by way of specifying the input and the computational steps necessary to generate it but with the option of delaying the actual execution of those steps to actually generate the data.
}

\section{Methods}{
\itemize{
\item as.character 
\item as.data.frame 
\item dcast 
\item melt 
\item merge 
\item mutate 
\item names 
\item print 
\item quantile 
\item sample 
\item select 
\item subset 
\item summarize 
\item transform 
\item unique 
\item where
}}



\examples{
#actual computation
subset(mtcars)
#delayed computation, returns a pipe
subset(input(mtcars))
#actual computation, returns a data frame
as.data.frame(subset(input(mtcars)))
}
