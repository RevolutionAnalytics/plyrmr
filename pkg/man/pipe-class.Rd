\name{pipe-class}
\Rdversion{1.1}
\docType{class}
\alias{pipe-class}

\title{Class \code{"pipe"}}
\description{
A pipe represents a data set by way of specifying the input and the computational steps necessary to generate it but delaying the execution of part or all of those steps until necessary to return data or produce a side effect. Constructor is \code{\link{input}}, all methods below accept a pipe as first argument and 

}

\section{Methods}{
\code{\link{as.data.frame}},
\code{\link{bottom.k}},
\code{\link{count}},
\code{\link{dcast}},
\code{\link{gapply}},
\code{\link{bind.cols}},
\code{\link{gather}},
\code{\link{group}},
\code{\link{group.f}},
\code{\link{intersect}},
\code{\link{magic.wand}},
\code{\link{merge}},
\code{\link{moving.window}},
\code{\link{output}},
\code{\link{quantile}},
\code{\link{rbind}},
\code{\link{sample}},
\code{\link{select}},
\code{\link{top.k}},
\code{\link{ungroup}},
\code{\link{union}},
\code{\link{unique}},
\code{\link{where}}}


\examples{
#actual computation
transmute(mtcars)
#delayed computation, returns a pipe
z = transmute(input(mtcars))
#actual computation, returns a data frame
as.data.frame(z)
}
