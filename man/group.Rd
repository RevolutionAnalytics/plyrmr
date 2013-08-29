\name{group}
\alias{group}
\alias{group.f}
\alias{group.together}
\alias{ungroup}

\title{
Control grouping in plyrmr computations}
\description{
Large data sets can not be processed by bringing all the data into memory at once. One alternative is to group records by a key or index and process one group at a time, provided they are not too big. The functions documented here allow to do that in plyrmr.
}
\usage{
group(.data, \dots, recursive = FALSE)
group.f(.data, f, \dots, recursive = FALSE)
group.together(.data, recursive = FALSE)
ungroup(.data, \dots)

}
\arguments{
  \item{.data}{
A pipe
}
  \item{f}{
Function with data frame argument and value to define grouping}
  \item{\dots}{
Additional arguments to f }
}
\details{

}
\value{
%%  ~Describe the value returned
%%  If it is a LIST, use
%%  \item{comp1 }{Description of 'comp1'}
%%  \item{comp2 }{Description of 'comp2'}
%% \dots
}
\references{
%% ~put references to the literature/web site here ~
}
\author{
%%  ~~who you are~~
}
\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{\dots.} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
}
\examples{
##---- Should be DIRECTLY executable !! ----
##-- ==>  Define data, use random,
##--	or do  help(data=index)  for the standard data sets.

## The function is currently defined as
function (.data, \dots) 
{
    group.f(.data, function(y) summarize(y, \dots))
  }
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{ ~kwd1 }
\keyword{ ~kwd2 }% __ONLY ONE__ keyword per line
