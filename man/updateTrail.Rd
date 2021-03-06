% Generated by roxygen2 (4.1.1): do not edit by hand
% Please edit documentation in R/Pheromone.R
\name{updateTrail}
\alias{updateTrail}
\title{Function to update the trail of pheromones in the model}
\usage{
updateTrail(object, solution, value, ...)
}
\arguments{
\item{object}{Object of class \code{\linkS4class{VectorPheromone}} representing the pheromone model to be updated}

\item{solution}{A vector, either binary or factor, used to update the pheromone trail}

\item{value}{Number to be used in the update}
}
\description{
This function updates the trail of pheromones according to a given solution
}

