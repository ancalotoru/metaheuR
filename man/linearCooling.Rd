% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/cooling_schemes.R
\name{linearCooling}
\alias{linearCooling}
\title{Linear decreasing of the temperature}
\usage{
linearCooling(initial.temperature, final.temperature, steps)
}
\arguments{
\item{initial.temperature}{Starting temperature}

\item{final.temperature}{Final expected temperature}

\item{steps}{Number of desired steps to get from the initial temperature to the final one}
}
\value{
A function that, given a temperature, returns the updated temperature according to the cooling scheme. The return function uses just a single parameter, the current temperature
}
\description{
This function updates the temperature decreasing it linearly
}
\examples{
update <- linearCooling(initial.temperature=100, final.temperature=10, steps=9)
update(100)
update(update(100))
}
\seealso{
Other Cooling schemes: \code{\link{geometricCooling}}
}

