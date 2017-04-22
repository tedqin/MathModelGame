
library(stringr)
library(lubridate)
library(MASS)
library(mgcv)

setwd("Z:/MyTemp/mathmodel")

f1 = "1.csv"
f2 = "2.csv"
f3 = "3.csv"
f4 = "4.csv"

mode0 <- c("integer","integer","integer","character","numeric")
one1 <- read.csv(f1,stringsAsFactors = FALSE)
one2 <- read.csv(f2,stringsAsFactors = FALSE)
one3 <- read.csv(f3,stringsAsFactors = FALSE)
one4 <- read.csv(f4,stringsAsFactors = FALSE)

two <-  rbind(one1,one2,one3,one4)

colnames(two) <- c("id","date","time","trans","rate","resp")

two <- two[,-1]
two$rate <- as.numeric(sub("%","", two$rate))
summary(two)

dim(two)

two$date <- as.Date(paste0("2017-",substr(two$date,1,1),"-",substr(two$date,2,3)),"%Y-%m-%d")
time1    <- str_pad(as.character(two$time),4,pad="0")
two$hour <- as.numeric(substr(time1,1,2))
two$min  <- as.numeric(substr(time1,3,4))
two$weekday <- wday(two$date)

plot(two$min,two$trans)
plot(two$hour,two$trans)
plot(two$weekday,two$trans)

two1 <- two[two$resp>1e7,]
two1
two2 <- two[two$hour==10,]
hist(two2$trans, breaks=50)
two3 <- two[two$hour==21,]
hist(two3$trans, breaks=50)
two4 <- two[two$min==45 & two$hour==10,]

two5 <- two[two$hour==23 & two$min>=59,]

#danger!!! heavy mem+cpu
#pairs(two[,3:8])

####task 1
#kernel density estimation-----------------------------------------------
out1 <- c()
for (w in 1:7) {
  for (h in 10:20) {
  tmp <- two[two$weekday==w & two$hour==h,]
    
    z = 3  #change for 4=rate, 5=resp
    tmp1 <- tmp[,z]
    d <- density(tmp1, kernel="o", from=min(tmp1)-60,to=max(tmp1)+ 60)         #boundary can be specified, this faclicate calculation prob of unseen event.
    h1 <- hist(tmp1, freq = FALSE, breaks=length(d$x), right=TRUE)             #can turn off plot
    lines(d$x,d$y, col="magenta", lwd=3)                                       #....
    mse = density(tmp1, kernel="o", from=min(tmp1)-60,to=max(tmp1)+ 60, give.Rkern = T)  #check the manual for more kernel options.
  
    width= d$x[2] - d$x[1]
    lb = which(d$x<min(tmp1))
    low_bound = sum(d$y[lb])*width
    ub = which(d$x>max(tmp1))
    upp_bound = sum(d$y[ub])*width
    out1 <-rbind(out1, data.frame(weekday=w, hour=h,low_bound=low_bound, upp_bound=upp_bound, mse=mse))
  }
}

write.csv(out1, "trans_task1.csv", row.names = F)

##revise below for rate loop, note the  boundary change
z = 4  #change for 4=rate, 5=resp
tmp1 <- tmp[,z]
d <- density(tmp1, kernel="o", from=min(tmp1)-5,to=100)
h1 <- hist(tmp1, freq = FALSE, breaks=length(d$x), right=TRUE)
lines(d$x,d$y, col="magenta", lwd=3)
mse = density(tmp1, kernel="o",  from=min(tmp1)-5,to=100, give.Rkern = T)

##revise below for resp, note break into two parts.
z = 5  #change for 4=rate, 5=resp
tmp1 <- tmp[,z]
d <- density(tmp1, kernel="o", from=min(tmp1)-60,to=max(tmp1)+ 60)
h1 <- hist(tmp1, freq = FALSE, breaks=length(d$x), right=TRUE)
lines(d$x,d$y, col="magenta", lwd=3)
mse = density(tmp1, kernel="o", from=min(tmp1)-60,to=max(tmp1)+ 60, give.Rkern = T)

hist(tmp1[tmp1>2000])
hist(tmp1[tmp1<2000])


#####task 2. (b)
#pairwise----------------------------------
plot(tmp[,4],tmp[,3])
  
  #rate~resp
tt <- tmp[,4:5]
tt$x <- cut(tt$rate,breaks=seq(90,100,by=0.25), labels=FALSE)
tt$y <- cut(tt$resp,breaks=seq(40,400,by=10), labels=FALSE)
tt$dummy = 1
tt2  <- aggregate(dummy~x+y, data=tt, sum)

spl1 <- gam(dummy ~ s(x) + s(y), data = tt2, method="REML") 
grid1 <- expand.grid(x=seq(12,34,1),y=seq(3,35,1))
resp <- predict(spl1, grid1, type = "response")
grid1$value = resp

head(grid1)
contourplot(value ~ x + y, data= grid1)


  #trans~resp
plot(tmp[,3],log(tmp[,5]))
tmp2 <- tmp[tmp[,5]<1200,]
plot(tmp2[,3],tmp2[,5])
tmp3 <- tmp[tmp[,5]>2000,]
plot(tmp3[,3],tmp3[,5])
    #----break resp into two parts.

  #trans~resp
    #not much informative association in  my point of view
plot(tmp[,4],tmp[,5])
tmp4 <- tmp[tmp[,5]<1200,]
plot(tmp4[,4],tmp4[,5])


