## ----evostar.bbob.setup, echo=F, message=F, fig.height=4, fig.cap="Time in seconds for every experiment generating 40K chromosomes with 128,256,512 dimensions, using float or double for every one of them"----
library(ggplot2)
library(ggthemes)
library(dplyr)

base.variable.data <- read.csv("data//evostar25-generation-5-Nov-07-30-15.csv")

base.variable.data$size <- as.factor(base.variable.data$size)
base.variable.data$type <- as.factor(base.variable.data$type)
ggplot(base.variable.data, aes(x=PKG, y=seconds, color=type, shape=size)) +
  geom_point() +
  labs(title="Energy consumption of BBOB functions", x="PKG Energy (Joules)", y="seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

base.variable.data %>% group_by(size, type) %>% summarise(mean.seconds=mean(seconds), sd.seconds=sd(seconds), mean.PKG = mean(PKG), sd.PKG = sd(PKG)) -> summary.base.variable.data


## ----evostar.bbob.fixed, echo=F, message=F, fig.height=4, fig.cap="Time in seconds for every experiment generating 40K chromosomes with 128,256,512 dimensions, using float or double for every one of them"----
base.fixed.data <- read.csv("data//fixed-evostar25-generation-5-Nov-07-37-13.csv")

base.fixed.data$size <- as.factor(base.fixed.data$size)
base.fixed.data$type <- as.factor(base.fixed.data$type)
base.fixed.data$work <- rep("array", nrow(base.fixed.data))

base.variable.data.128 <- base.variable.data[base.variable.data$size == 128,]
base.variable.data.128$work <- rep("vector", nrow(base.variable.data.128))

base.data.128 <- rbind(base.fixed.data, base.variable.data.128)

ggplot(base.data.128, aes(x=PKG, y=seconds, color=type, shape=work)) +
  geom_point() +
  labs(title="Energy consumption of BBOB functions, vector vs. array", x="PKG Energy (Joules)", y="seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

base.fixed.data %>% group_by(size, type) %>% summarise(mean.seconds=mean(seconds), sd.seconds=sd(seconds), mean.PKG = mean(PKG), sd.PKG = sd(PKG)) -> summary.base.fixed.data


## ----evostar.bbob.functions, echo=F, message=F, warning=F, fig.height=4, fig.show="hold", fig.cap="PKG energy consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales in every chart. The boxplot is missing when the application of the function takes approximately the same time than generating it."----
functions.data <- read.csv("data//variable-evostar25-bbob-10-Nov-19-10-32.csv")
functions.data <- functions.data[functions.data$work != "none",]
number.of.rows <- nrow(functions.data[ functions.data$size==128 & functions.data$type==" f",])
functions.data$delta.PKG <- 0
functions.data[ functions.data$size==128 & functions.data$type==" f",]$delta.PKG <- functions.data[ functions.data$size==128 & functions.data$type==" f",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 128 & summary.base.variable.data$type==" f", ]$mean.PKG,number.of.rows)

functions.data[ functions.data$size==256 & functions.data$type==" f",]$delta.PKG <- functions.data[ functions.data$size==256 & functions.data$type==" f",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 256 & summary.base.variable.data$type==" f", ]$mean.PKG,number.of.rows)

functions.data[ functions.data$size==512 & functions.data$type==" f",]$delta.PKG <- functions.data[ functions.data$size==512 & functions.data$type==" f",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 512 & summary.base.variable.data$type==" f", ]$mean.PKG,number.of.rows)

functions.data[ functions.data$size==128 & functions.data$type==" d",]$delta.PKG <- functions.data[ functions.data$size==128 & functions.data$type==" d",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 128 & summary.base.variable.data$type==" d", ]$mean.PKG,number.of.rows)

functions.data[ functions.data$size==256 & functions.data$type==" d",]$delta.PKG <- functions.data[ functions.data$size==256 & functions.data$type==" d",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 256 & summary.base.variable.data$type==" d", ]$mean.PKG,number.of.rows)

functions.data[ functions.data$size==512 & functions.data$type==" d",]$delta.PKG <- functions.data[ functions.data$size==512 & functions.data$type==" d",]$PKG - rep(summary.base.variable.data[ summary.base.variable.data$size == 512 & summary.base.variable.data$type==" d", ]$mean.PKG,number.of.rows)

functions.data$delta.PKG <- pmax(functions.data$delta.PKG, 0)

ggplot(functions.data[ functions.data$size==128,], aes(x=work, y=delta.PKG, color=type)) +
  geom_boxplot() +
  labs(title="Energy consumption of BBOB functions, length=128", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_log10()

ggplot(functions.data[ functions.data$size==256,], aes(x=work, y=delta.PKG, color=type)) +
  geom_boxplot() +
  labs(title="Energy consumption of BBOB functions, length=256", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ scale_y_log10()

ggplot(functions.data[ functions.data$size==512,], aes(x=work, y=delta.PKG, color=type)) +
  geom_boxplot() +
  labs(title="Energy consumption of BBOB functions, length=512", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ scale_y_log10()


## ----evostar.bbob.fixed.functions, echo=F, message=F, warning=F, fig.height=4, fig.cap="PKG energy consumed in every experiment evaluating 40K chromosomes with 128, float or double. Please note $y$ scale is logarithmic"----
fixed.functions.data <- read.csv("data//evostar25-bbob-fixed-12-Nov-08-20-03.csv")
number.of.rows <- nrow(fixed.functions.data[ fixed.functions.data$size==128 & fixed.functions.data$type==" f",])
fixed.functions.data$delta.PKG <- 0
fixed.functions.data[ fixed.functions.data$size==128 & fixed.functions.data$type==" f",]$delta.PKG <- fixed.functions.data[ fixed.functions.data$size==128 & fixed.functions.data$type==" f",]$PKG - rep(summary.base.fixed.data[ summary.base.fixed.data$size == 128 & summary.base.fixed.data$type==" f", ]$mean.PKG,number.of.rows)
fixed.functions.data[ fixed.functions.data$size==128 & fixed.functions.data$type==" d",]$delta.PKG <- fixed.functions.data[ fixed.functions.data$size==128 & fixed.functions.data$type==" d",]$PKG - rep(summary.base.fixed.data[ summary.base.fixed.data$size == 128 & summary.base.fixed.data$type==" d", ]$mean.PKG,number.of.rows)
fixed.functions.data$delta.PKG <- pmax(fixed.functions.data$delta.PKG, 0)

ggplot(fixed.functions.data[ fixed.functions.data$size==128,], aes(x=work, y=delta.PKG, color=type)) +
  geom_boxplot() +
  labs(title="Energy consumption of BBOB functions, length=128, fixed-size data structure", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ scale_y_log10()


## ----evostar.bbob.compares, echo=F, message=F, warning=F, fig.height=5, fig.show="hold", fig.cap="PKG energy consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales"----
fixed.functions.data$data.structure <- "Fixed"
functions.data$data.structure <- "Variable"

functions.128 <- rbind(fixed.functions.data[ fixed.functions.data$size==128,], functions.data[ functions.data$size==128,])

ggplot(functions.128[ functions.128$type==" f",], aes(x=work, y=delta.PKG, color=data.structure)) +
  geom_boxplot( position="dodge") +
  labs(title="array vs. vector, length=128, float", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_log10()+ theme(legend.position="none")

ggplot(functions.128[ functions.128$type==" d",], aes(x=work, y=delta.PKG, color=data.structure)) +
  geom_boxplot( position="dodge") +
  labs(title="array vs. vector, length=128, double", y="PKG Energy (Joules)", x="function") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + scale_y_log10() + theme(legend.position="none")

