webPage <- "https://en.wikipedia.org/wiki/800-metres"
doc2 <- readLines(webPage, encoding = "UTF-8")
doc <- paste(doc2, collapse = "\n")

#######################################################
######  Web Scraper ###################################
########################################################

webScraper(webPage, css = ".wikitable.plainrowheaders", constructTable = TRUE)

#########################################################
######  Tag Counter  ####################################
#########################################################

tagCounter("span", doc2[194])
tagCounter("span", doc2[194], count = TRUE)
tagCounter("h2", doc2[194])
tagCounter("h2", doc2[194], count = TRUE)

#########################################################
####### Check validity of HTML element  #################
#########################################################

is.htmlElement(doc2[665:868])
is.htmlElement(doc2[194])
is.htmlElement(doc2[4])


##########################################################
#######  Tag Counter  #################################### 
##########################################################

tagCounter("span", doc2[194])
tagCounter("span", doc2[194], count = TRUE)
tagCounter("/span", doc2[194], count = TRUE)


#########################################################
####   Closing tag locator  #############################
#########################################################

# One element
clsTagLocator("meta", doc2, index = 4, startPos = 1)
clsTagLocator("span", doc2, index = 194, startPos = 5)
clsTagLocator("span", doc2, index = 194, startPos = 50) 
clsTagLocator("tr", doc2, index = 123, startPos = 1)
clsTagLocator("li", doc2, index = 2180, startPos = 7)
indices2 <- grep("wikitable plainrowheaders", doc2)
clsTagLocator("table", doc2, index = indices2[1])
clsTagLocator("table", doc2, index = indices2[2])
clsTagLocator("table", doc2, index = indices2[3])
clsTagLocator("table", doc2, index = indices2[4])


clsTagLocator("meta", doc, startPos = 71)
clsTagLocator("span", doc, startPos = 27004)
clsTagLocator("span", doc, startPos = 27049)
clsTagLocator("tr", doc, startPos = 17103)
clsTagLocator("li", doc, startPos = 355056)
clsTagLocator("table", doc, startPos = 68555)
clsTagLocator("table", doc, startPos = 138979)
clsTagLocator("table", doc, startPos = 180663)
clsTagLocator("table", doc, startPos = 215491)

###### Multi tags  #################################

multiClsTagLocator("table", doc2, indices = indices2)
multiClsTagLocator("table", doc, startPos = c(68555, 138979, 180663, 215491))
startPos <- as.vector(gregexpr("<a\\b", doc2[42])[[1]])
multiClsTagLocator("a", doc2, 42, startPos)

indices <- grep("<tr\\b", doc2[665:868]) + 664
startPos <- sapply(1:length(indices), function(i) as.vector(regexpr("<tr\\b", doc2[indices[i]])[[1]]))
system.time(multiClsTagLocator("tr", doc2, indices, startPos))


indices <- grep("<div", doc2[44:2080]) + 43; indices
startPos <- sapply(seq(indices), function(i) regexpr("<div", doc2[indices[i]])[[1]]); startPos
multiClsTagLocator("div", doc2, indices, startPos)

#####################################################
#######  Content Extractor Function  ###############
####################################################

x <- clsTagLocator("table", doc2, index = 665)
contentExtractor(x, doc2, constructTable = TRUE)


#####################################################
#######  Attribute Pattern Constructor  #############
#####################################################

css <- "h3"
css <- '[title~="Broberg"]'
css <- '[href="/wiki/Eunice_Sum"]'
css <- '[title~="Edit"]'
css <- "[role^=\"pre\"]"
css <- '[style$=";"]'
css <- ".wikitable.plainrowheaders"
css <- ".mw-headline#Women_2"
css <- '.external.text[rel="nofollow"][href]'
css <- '.external.text#wd[lang][rel="nofollow"][href~="example"]'

attrPatternConstructor(css)
attrPatternConstructor(css, asis = TRUE)

####################################################
#####  Permutation Tuples  ########################
####################################################

permutationTuples(3)

###################################################
####### Simple Selector  ##########################
###################################################

css1 <- "sup"
css2 <- "span.mw-headline"
css3 <- "span.mw-headline#All-time_top_25_fastest"
css4 <- "a[href][title]"
css5 <- '[colspan="2"][style$=":center"]'
css6 <- "a[title][lang]"
css6 <- 'table.wikitable[class="plainrowheaders"]:nth-of-type(2)'

simpleSelectors(".wikitable.plainrowheaders", doc2, withOutTags = TRUE, content = FALSE)
simpleSelectors(".wikitable.plainrowheaders", doc2, constructTable = TRUE)
simpleSelectors(css1, doc2)
simpleSelectors(css2, doc2)
simpleSelectors(css3, doc2)
simpleSelectors(css4, doc2)
simpleSelectors(css5, doc2, withOutTags = TRUE)
simpleSelectors(css6, doc2, constructTable = TRUE)

###################################################
####  nth interpreter  ############################
###################################################

css <- "table:nth-of-type(2n)"
css <- "table:nth-last-of-type(2n)"
css <- "table:nth-child(2n)"
css <- "table:nth-of-type(2n+1)"
css <- "table:nth-last-of-type(2n+1)"
css <- "table:nth-of-type(even)"
css <- "table:nth-last-of-type(even)"
css <- "table:nth-of-type(odd)"
css <- "table:nth-last-of-type(odd)"
css <- "table.wikitable.plainrowheaders:nth-of-type(2n+2)"
css <- "table.wikitable.plainrowheaders:nth-last-of-type(2n+2)"
css <- "h3:first-of-type"
css <- "table.wikitable.plainrowheaders:first-child"
css <- "li:first-child"
css <- "li:last-child"
css <- "li:nth-child(2n+1)"
css <- "table:last-child"
css <- "h3:only-child"
css <- "table:not(.wikitable.plainrowheaders)"
css <- "p:empty"
css <- ":empty"

nthInterpreter("", 10) #error
nthInterpreter("2n", 18) # 0, 2, 4, 6, ..., 18
nthInterpreter("2n+1", 18) # 1, 3, 5, 7, ..., 17
nthInterpreter("-n+3", 18) # 3, 2, 1, 0, ..., -12
nthInterpreter("n2", 18)
nthInterpreter("2+2", 10) #error
nthInterpreter("n", 20) #error
nthInterpreter("even", 20) # 2, 4, 6, 8, ..., 20
nthInterpreter("odd", 20) # 1, 3, 5, 7, ..., 19
nthInterpreter("even", 20, fromLast = TRUE)
nthInterpreter("odd", 20, fromLast = TRUE)
nthInterpreter("3n+5", 18) # 5, 8
nthInterpreter("3n+5", 18, fromLast = TRUE) # 8, 5
nthInterpreter("2n+1", 17)
nthInterpreter("2n+1", 17, fromLast = TRUE)
nthInterpreter("2n+1", 2)
nthInterpreter("2n+1", 2, fromLast = TRUE)
nthInterpreter("2n", 2)
nthInterpreter("2n", 2, fromLast = TRUE)
