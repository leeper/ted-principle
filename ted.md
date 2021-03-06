Experiments are on the rise. Widely seen as a useful method to test
causal hypotheses, randomized experiments (or "RCTs") have become a
major tool in the social scientist's toolkit. A key advantage of
experimentation is that the method relies heavily on design to justify
the assumptions needed to draw causal inferences. Analysis of
experimental data is thus remarkably simple: the causal quantity of
interest is often a population-level or sample-level average treatment
effect, which is easily and directly estimated via a mean-difference
comparison of outcomes across treatment conditions. Explaining these
methods to students is therefore incredibly simple: the common tools of
statistical analysis (e.g., t-tests, ordinary least squares regression,
etc.) readily and directly provide appropriate estimators for these
quantities. In teaching experimental methods, however, I have frequently
found a gap in pedagogical material between the analysis of an idealized
experiment and the form of data that experiments, especially survey
experiments, typically generate. This article provides an application of
"tidy data" principles (Wickham 2014) to experimental data, referred to
as the TED principle. The article then shows examples in R and Stata of
the common computational expressions needed to produce a tidy
experimental dataset.

Tidy Experimental Data
----------------------

Wickham (2014) writes that "tidy datasets are all alike but every messy
dataset is messy in its own way". The point is that most computational
analyses require a particular kind of data structure - a tidy,
rectangular dataset where rows are observations and columns are
variables - which rarely if ever is immediately available. Much of a
data analyst's efforts are therefore expended in the preprocessing
stages of analysis, converting an *untidy* dataset into a *tidy* one. A
tidy experimental dataset (TED) is a specific type of tidy dataset that
has at a minimum two variables with values for each experimental unit:

1.  One factor variable per experimental factor, specifying each unit's
    factor level

2.  One numeric variable per outcome measure, specifying each unit's
    outcome value

The most basic design contains two columns: one factor variable
representing "treatmnet" versus "control" experimental condition and one
numeric variable representing a single outcome. All other experimental
datasets are elaborations upon this structure that reflect complexities
of the design (e.g., factorial designs, multiple outcomes, missing data,
covariates, etc.). The TED principle dictates that analysis of an
experiment must begin with the creation of a TED. Table below shows a
simple example of a TED for a two-condition experiment with a binary
outcome:

    ##   condition outcome
    ## 1         0       1
    ## 2         0       0
    ## 3         0       0
    ## 4         1       1
    ## 5         1       1
    ## 6         1       1

(While this example shows the data sorted by treatment condition, the
observations in a TED need not be in any particular order - indeed, row
order should not convey any information.) The TED is the appropriate
structure for analyzing experimental data because it allows for any kind
of analysis without further transformation. For example, the common
tools of t-tests or regression (or ANOVA) can directly be applied to
this structure. For example, in R:

    t.test(outcome ~ condition, data = dat)
    summary(lm(outcome ~ condition, data = dat))
    summary(aov(outcome ~ condition, data = dat))

and in Stata:

    ttest outcome i.condition
    reg outcome i.condition
    oneway outcome i.condition

But is a TED the form that experimental researh tends to generate? I
believe - based upon working with ["other peoples'
data"](https://twitter.com/search?q=%23otherpeoplesdata&src=typd) as
well as my own - that experiments rarely naturally generate a TED.
Instead, experimental datasets tend to feature numerous complexities
that must be cleaned up, removed, added, merged, or transformed to
produce a TED. While these actions are not complex, new and even
experienced researchers may not realize the need to create a TED and
they may engage in data transformation tasks that move them further away
from rather than closer to a TED. The following sections describe
several common use cases.

Covariates
----------

What role do (pretreatment covariates have in a TED? If we are confident
in the physical randomization process and the experimental design is
fully randomized (without any blocking factors), then the covariate data
play no essential role in the experimental analysis. A TED does not
necessarily include any covariate information. It can, but it is not
required.

An exception to this is when an experiment is block randomized with
respect to one or more covariates. Without getting into the details of
why one might rely on block (stratified) randomization (i.e., balance
and statistical power), blocking factors may need to be part of a TED.
Consider for example the following pre-experimental dataset, containing
16 individuals with varying sex, high school degree, and immigration
values:

    ##    sex degree immigrant
    ## 1    0      0         0
    ## 2    0      0         0
    ## 3    0      0         1
    ## 4    0      0         1
    ## 5    0      1         0
    ## 6    0      1         0
    ## 7    0      1         1
    ## 8    0      1         1
    ## 9    1      0         0
    ## 10   1      0         0
    ## 11   1      0         1
    ## 12   1      0         1
    ## 13   1      1         0
    ## 14   1      1         0
    ## 15   1      1         1
    ## 16   1      1         1

If these covariates are used to construct a blocking factor, then the
single 8-level blocking factor variable contains all design-relevant
information about these covariates:

    dat$block <- interaction(dat)
    dat

    ##    sex degree immigrant block
    ## 1    0      0         0 0.0.0
    ## 2    0      0         0 0.0.0
    ## 3    0      0         1 0.0.1
    ## 4    0      0         1 0.0.1
    ## 5    0      1         0 0.1.0
    ## 6    0      1         0 0.1.0
    ## 7    0      1         1 0.1.1
    ## 8    0      1         1 0.1.1
    ## 9    1      0         0 1.0.0
    ## 10   1      0         0 1.0.0
    ## 11   1      0         1 1.0.1
    ## 12   1      0         1 1.0.1
    ## 13   1      1         0 1.1.0
    ## 14   1      1         0 1.1.0
    ## 15   1      1         1 1.1.1
    ## 16   1      1         1 1.1.1

The resulting three-column TED will thus contain the `block` variable,
treatment assignment variable, and outcome variable. The covariates
themselves contain no additional information.

Yet in this example design even the blocking factor is unnecessary. Why?
Whether the blocking variable is needed depends on how large the blocks
are: i.e., do all blocks contain the same number of treatment units and
do all blocks contain the same number of control units? If all blocks
are the same size, then the experiment can be analyzed as if it were
fully randomized but the design ensures covariate balance with respect
to all covariates used to create the blocks. If some blocks were larger
or smaller, or they contained uneven numbers of treatment and control
units, then analysis would need to be performed in a block-specific
manner (estimating the conditional average treatment effect in each
block and taking a weighted average of block-specific CATEs to estimate
the SATE).

Multiple outcomes per unit
--------------------------

Most experiments have more than one outcome measure. Provided these are
distinct measures, then the TED for a multiple-outcome experiment is a
simple extension wherein each outcome is represented as an additional
column variable. Analysis can proceed on the dataset as is.

When multiple outcomes represent repeated measures (such as in a
panel/longitudinal design or a vignette study where each respondent is
exposed to multiple treatments) but treatment is time-constant, the TED
again simply contains one column per outcome variable.

If treatment is not time-constant (i.e., treatment status changes across
time for each unit), the TED must contain unit-time observations in each
row and outcome measures for different time periods should be
represented as a single column, thus necessitating two additional
columns in the TED:

1.  A factor variable representing a unit-specific identifier

2.  A numeric time indicator capturing the order in which outcomes were
    measured

For those familiar with panel data analysis, this TED is simply the
"long" representation of a longitudinal dataset.

This same structure is needed when analyzing a "conjoint" or
vignette-based factorial experiment. Such designs involve multiple
measures per respondent, wherein the minimal TED contains:

1.  A factor variable representing a unit-specific identifier

2.  A numeric time indicator capturing the order of vignettes per
    respondent

3.  Factor variables representing each vignette's experimental
    attributes

4.  A single numeric outcome variable measuring the response to
    each vignette.

Analysis of such designs proceeds as in a traditional factorial
experiment, with the possible addition of unit fixed effects, clustering
by respondent, and control for profile order. In R:

    m <- lm(outcome ~ factor1*factor2*factor3 + respondent + factor(order), data = dat)
    margins(m)

    reg outcome i.factor1##i.factor2##i.factor3 respondent i.order
    margins, dydx(factor1 factor2 factor3)

Within-subjects experiments
---------------------------

Weights
-------

-   panel datasets and conjoints
-   weights (sampling, clustering, etc.)

Practicalities of Creating a TED
--------------------------------

With the key ideas of the TED principle in mind, this section addresses
how to assemble a TED from a variety of common

### Treatment vectors stored as character

A practicality of experimental data entry is that treatment condition is
often recorded as a character string, such as `"treatment"` versus
`"control"`. The treatment variable in a TED is numeric. This may seem
inconsequential, particular for users of R, but character variables
cannot be used in regression analysis in Stata, and requires a variable
class coercion to avoid an error:

    reg outcome condition
    // group:  string variables may not be used as factor variables

    encode condition, gen(condition2)
    reg outcome condition2

By contrast, R allows a character to be handled implicitly as a factor
variable:

    summary(lm(outcome ~ condition, data = dat))

### Factorial designs

Factorial experiments present an unavoidable complexity: the design
contains multiple factors and thus the form of analysis of the
experiment depends to a large extent on what quantities of interest the
researcher desires to know. Consider, for example, a 2x2x2 factorial (a
three-factor experiment, where each factor contains two levels
constituting a total of 8 experimental conditions). This design can be
represented as one of two different TEDs:

1.  A two-column TED, where the treatment variable corresponds to
    numbered experimental cells
2.  A four-column TED, where the treatment is represented by three
    binary variables

Why would a researcher prefer one versus the other? The answer depends
on what the researcher wants to know, but in almost all cases the second
structure is preferred. While the first design is simpler (it has only
two columns), it only enables the researcher to estimate pairwise
experimental effects (comparisons between conditions relative to one
another), such as:

    summary(lm(outcome ~ factor(condition), data = dat))

    reg outcome i.condition

The result is a regression analysis where the intercept estimates the
"control group" mean outcome and all estimates are pairwise comparisons
against this baseline. But what is the marginal effect of a given
factor? This oversimplified TED does not allow us to know without some
further transformation. The second TED (where factors are represented as
separate columns) allows us to parameterize the model in a way that
readily allows the estimation of these marginal effects:

    library("margins")
    summary(m <- lm(outcome ~ factor1*factor2*factor3, data = dat))
    summary(margins(m))

    reg outcome i.factor1##i.factor2##i.factor3
    margins, dydx(*)

### Separated outcomes without a treatment vector

Not all experimental data generating processes produce a treatment
vector. And, of course, it is even possible to analyze experimental data
represented in a form other than a TED, such as a structure with
separated outcome measures for each experimental condition (with or
without a treatment group indicator) and considerable missing data:

    ##   outcome0 outcome1
    ## 1        1       NA
    ## 2        0       NA
    ## 3        0       NA
    ## 4       NA        1
    ## 5       NA        1
    ## 6       NA        1

Such structures enable t-tests (e.g., `t.test(outcome0, outcome1)`,
`ttest outcome0 == outcome1`), but disallow regression analysis as well
as most plotting functionality.

This kind of structure quite commonly results from, for example, a
survey experiment in which respondents are assigned to one of two
different question wordings. The survey software will branch respondents
into their assigned question and then record answers to the treatment
question for those assigned to treatment and return missing values for
those assigned to control, and vice versa. To create a TED from that
structure, two transformations are necessary:

1.  Create a treatment vector based upon missingness in outcomes
2.  "Unbranch" the outcome data

These transformations convert the two variables into the current dataset
into two new variables:

    library("mcode")

    # create treatment vector
    dat$condition <- NA_real_
    dat$condition[!is.na(dat$outcome0)] <- 0L
    dat$condition[!is.na(dat$outcome1)] <- 1L

    # unbranch outcomes
    dat$outcome <- mergeNA(dat$outcome1, dat$outcome2)

    * create treatment vector
    gen condition = .
    replace condition = 0 if outcome0 != .
    replace condition = 1 if outcome1 != .

    * unbranch outcomes
    gen outcome = .
    replace outcome = outcome0 if outcome0 != .
    replace outcome = outcome1 if outcome1 != .

The result is a TED. The original variables in these case are preserved
but no longer needed.

### Merged outcomes where treatment is recorded as an order

Survey experiments sometimes involve question *order* manipulations,
where all respondents are exposed to all parts of a questionnaire but in
a randomly manipulated order. Such designs generate data structures with
limited missing data, but order of presentation information (i.e., the
experimental conditions) are stored as an "order" variable. A common
order variable will be a character variable containing delimited names
or numbers of questions, such as: `1,3,2`, `q1,q3,q2`, `q1|q3|q2`, etc.
Assuming question order is stored as `q1|q2|q3` (and there is a good
reason to rely on this because other delimiters such as `,` or `;` or a
tab are likely to generate conflicts with variable-separators in a
delimited data file), then the procedure to transform these into a TED
is straightforward. The simplest is a case where each possible unique
value of the order variable is a treatment condition, such that it can
be directly used as a treatment vector:

    dat$treatment <- as.factor(dat$order)

    encode order, gen(condition)

But if the order vector contains superfluous information (as it often
does), then other transformations are needed. A first step is often to
coerce the split the order vector based on its delimiter to create new
variables representing order.

    orders <- do.call(rbind.data.frame, strsplit(dat[["order"]], "|"))
    names(order) <- paste0("order", seq_len(ncol(orders)))
    dat <- cbind(dat, orders)

    split order, parse(|)

### One dataset per condition

Some experiments, such as laboratory or field experiments where units
are cluster randomized (i.e., all participants in a given session or at
a given site are assigned to the same condition), can tend to generate
multiple datasets that must be merged. To produce a TED from these
mulltiple files requires either a merge operation followed by tidying or
tidying followed by merging. I prefer the latter approach because it
creates a simplified dataset that is likely to be more easily merged.

Conclusion
----------

This article laid out the TED principle - "that analysis of an
experiment must begin with the creation of a TED" - and showed how to
generate a TED for a number of common experimental designs, including
the practicalities of generating the relevant TED variables from common
representations of designs and outcomes. Of course there will inevitably
be an experiment that includes complexities not covered by these
examples, but the essence of the TED principle which says that data
munging must precede experimental analysis should serve as some useful
guidance.
