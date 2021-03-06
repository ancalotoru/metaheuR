library(metaheuR)
profFile<-"./../rprofiling.out"

set.seed(666)
## Examples of TSP. Size n, random cost matrix
n<-50
cost<-matrix(runif(n^2),n)

## Objective function
tsp.rnd.50<-tsp.problem(cost)
## Neighborhood
swp.ngh<-swapNeighborhood(base = identity.permutation(n),random = FALSE)
exc.ngh<-exchangeNeighborhood(base = identity.permutation(n),random = FALSE)

## Basic local search with no limits. Starting from identity permutation and greedy selector
swap.bls.result<-basic.local.search(evaluate = tsp.rnd.50$evaluate , initial.solution = identity.permutation(n),
                               neighborhood = swp.ngh , selector = greedy.selector)
plot.progress(swap.bls.result)


system.time(exchange.bls.result<-basic.local.search(evaluate = tsp.rnd.50$evaluate , initial.solution = identity.permutation(n),
                                    neighborhood = exc.ngh , selector = greedy.selector))


plot.progress(list(swap=swap.bls.result , exchange = exchange.bls.result))

Rprof(filename = profFile)

sol <- random.permutation(n)
greedy.selector(neighborhood = exc.ngh , evaluate = tsp.rnd.50$evaluate , initial.solution = sol , initial.evaluation = tsp.rnd.50$evaluate(sol))

Rprof(NULL)
summaryRprof(profFile)


## Visualization of the results
swap.bls.result
exchange.bls.result
plot.progress(swap.bls.result)
plot.progress(exchange.bls.result)

## Generator of random permutations of size n (for the multistart approach)
rnd.permutation.generator<-function(n){
  function() random.permutation(n)
}

## Multistart from random permutations, limited resources and first improvement selector
restarts <- 10
resources <- cresource(time = 6.78 , evaluations = 10 * n^2 , iterations = 10 * n) 
msls<-multistart.local.search(evaluate = tsp.rnd.50$evaluate , verbose = TRUE , do.log = TRUE , generate.solution = rnd.permutation.generator(n),
                                       num.restarts = restarts , neighborhood = swp.ngh , selector = first.improvement.selector, resources = resources)

resources(msls)
## Additional parameters can be passed to the plot, including the x axis and geom_line parameters such as col, size or linetype
plot.progress(msls , vs = 'time' , col="blue" , size=1.1)


## Perturbation function generator, for the ILS
perturb.func.generator<-function(ratio){
  function(solution) shuffle(permutation = solution, ratio = ratio)
}

## ILS limited by the number of evaluations and time
restarts <- 10
resources <- cresource(evaluations = 10 * n^2 , time = 5)
perturbation.ratio <- 0.1
## Example of execution with no feedback
ils<-iterated.local.search(evaluate = tsp.rnd.50$evaluate , verbose = T , do.log = T , initial.solution = identity.permutation(n) , 
                           accept = boltzmann.accept , perturb = perturb.func.generator(perturbation.ratio) , num.restarts = restarts , 
                           neighborhood = swp.ngh , selector = greedy.selector, resources = resources , th = 5 , temperature = 2)


plot.progress(ils , col="blue" , size=1.1)

## Simulated annealing
temp.init <- 1
temp.final <- 0.0005
steps <- 10
resources <- cresource(iterations = steps+1 , time = 10)
eq.value <- 500
cooling <- linear.cooling(initial.temperature = temp.init , final.temperature = temp.final , steps = steps)
sa.result<-simulated.annealing(evaluate = tsp.rnd.50$evaluate , initial.solution = identity.permutation(n), final.temperature = temp.final , cooling.scheme = cooling , initial.temperature = temp.init , eq.criterion = 'evaluations' , eq.value = eq.value , neighborhood = swp.ngh , resources = resources, log.frequency = 1)

plot.progress(sa.result, type = "point",alpha=0.25)

## Example knapsack problem with random weights, values and capacity limit

n<-100
w<-runif(n)
v<-runif(n)
l<-sum(w[runif(n)>0.5])

## Define the evaluation function, the validity checker and the correction function
knp <- knapsack.problem(w,v,l)
fngh<- flipNeighborhood(rep(T,n) , T)

start.sol <- knp$correct(runif(n)>0.5)

## Basic local search discarding the non-valid solutions
knp.bls <- basic.local.search(evaluate = knp$evaluate , initial.solution =  start.sol, neighborhood = fngh , selector = greedy.selector , non.valid = 'discard' , valid = knp$is.valid)
plot.progress(knp.bls)

## Perturbation function for the ILS algorithm
binary.perturb.generator<-function (ratio){
  function(solution){
    n<-length(solution)
    id<-sample(1:n,size = ratio*n,replace = F)
    solution[id]<-!solution[id]
    solution
  }
}

ratio<-1/3
perturb<-binary.perturb.generator(ratio)
resources <- cresource(time = 6.1625 , evaluations = 100*n^2 , iterations = 100*n)
initial.solution <- knp$correct(runif(n)>0.5)

## ILS correcting non valid solution and using a first improvement approach and limited resources
knp.ils <- iterated.local.search(evaluate = knp$evaluate , initial.solution = initial.solution , accept = threshold.accept , th=0 ,
                                 neighborhood = fngh , selector = first.improvement.selector , 
                                 perturb = perturb  , non.valid = 'correct' , correct = knp$correct, 
                                 resources = resources)

plot.progress(knp.ils , size=1.1) 
resources(knp.ils)



# Graph coloring ----------------------------------------------------------
n <- 30
rnd.graph <- random.graph.game(n , p.or.m = 0.5)
rnd.sol <- factor (paste("c",sample(1:5 , size = n , replace = T) , sep="") , 
                   levels = paste("c" , 1:n , sep=""))
gcol.problem <- graph.coloring.problem (rnd.graph)
gcol.problem$is.valid(rnd.sol)
corrected.sol <- gcol.problem$correct(rnd.sol)
gcol.problem$is.valid(corrected.sol)
gcol.problem$plot(rnd.sol,node.size=10)
gcol.problem$plot(corrected.sol)
