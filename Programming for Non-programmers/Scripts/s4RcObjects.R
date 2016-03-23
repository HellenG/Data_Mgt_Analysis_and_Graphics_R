# s4 Object
setClass(Class = "F", representation = "character")
f <- new(Class = "F")

# RC Object
a <- setRefClass(Class = "A", fields = list(data = "data.frame"))
aObj <- a(data = data.frame())