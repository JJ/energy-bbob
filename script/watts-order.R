bbob.fixed <- read.csv("data/evostar25-bbob-fixed-12-Nov-08-20-03.csv")

bbob.fixed$watts <- bbob.fixed$PKG / bbob.fixed$seconds

library(dplyr)
bbob.fixed <- bbob.fixed %>%
  group_by(type, size, work) %>%
  mutate(order = row_number()) %>%
  ungroup()

library(ggplot2)

ggplot(bbob.fixed, aes(x=seq_along(watts), y=watts)) +
  geom_point() +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed, aes(x=order, y=PKG,shape=type)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  scale_y_continuous(limits = c(0, 25))

bbob.variable <- read.csv("data/variable-evostar25-bbob-10-Nov-19-10-32.csv")
bbob.variable$watts <- bbob.variable$PKG / bbob.variable$seconds
# plot bbob.variable$watts by row order
bbob.variable$size <- as.factor(bbob.variable$size)
ggplot(bbob.variable[bbob.variable$work == "rastrigin",], aes(x=seq_along(watts), y=watts, shape=type,color=size)) +
  geom_point() +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
