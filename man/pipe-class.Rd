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
\code{\link{count.cols}},
\code{\link{dcast}},
\code{\link{do}},
\code{\link{gather}},
\code{\link{group}},
\code{\link{group.f}},
\code{\link{intersect}},
\code{\link{magic.wand}},
\code{\link{merge}},
\code{\link{moving.window}},
\code{\link{mutate}},
\code{\link{output}},
\code{\link{quantile.cols}},
\code{\link{rbind}},
\code{\link{sample}},
\code{\link{select}},
\code{\link{subset}},
\code{\link{summarize}},
\code{\link{top.k}},
\code{\link{transform}},
\code{\link{ungroup}},
\code{\link{union}},
\code{\link{unique}},
\code{\link{where}}}


\examples{
#actual computation
subset(mtcars)
#delayed computation, returns a pipe
subset(input(mtcars))
#actual computation, returns a data frame
as.data.frame(subset(input(mtcars)))
}
