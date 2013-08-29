\name{top.k}
\alias{top.k}
\alias{bottom.k}
\title{
Select top and bottom rows according to some order}
\description{

}
\usage{
top.k(x, k, \dots)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{A plyrmr pipe}
  \item{k}{How many rows to select}
  \item{\dots}{Expressions to be used to define the order, evaluated in the context of the data.}
}
\details{
For details on how the \dots are evaluated see summarize and for the order definition see order}
\value{
A pipe with the top or bottom k elements according to the order defined by the \dots arguments}

\examples{
as.data.frame(top.k(input(mtcars), 4, carb))
}