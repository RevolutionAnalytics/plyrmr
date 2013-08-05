\name{top.k}
\alias{top.k}
\alias{bottom.k}
\title{
Retirm  the top or bottom rows but the specified criteria
}
\description{
%%  ~~ A concise (1-5 lines) description of what the function does. ~~
}
\usage{
top.k(x, k, ...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{x}{A plyrmr pipe}
  \item{k}{How many items}
  \item{...}{Expressions to be used to define the order.}
}
\details{
For details on how the ... are evaluated see summarize and for the order definition see order}
\value{
A pipe with the top or bottom k elements according to the order defined by ... arguments}

\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.
}