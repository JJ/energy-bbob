bbob.fixed <- read.csv("data/evostar25-bbob-fixed-12-Nov-08-20-03.csv")

bbob.fixed$watts <- bbob.fixed$PKG / bbob.fixed$seconds

library(dplyr)
bbob.fixed <- bbob.fixed %>%
  group_by(type, size, work) %>%
  mutate(order = row_number()) %>%
  ungroup()

# Per type, size, work make a cumulative sum of the seconds passed and put it in a third column
bbob.fixed <- bbob.fixed %>%
  group_by(type, size, work) %>%
  mutate(cumulative_seconds = cumsum(seconds)) %>%
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
  scale_y_continuous(limits = c(0, 5))

ggplot(bbob.fixed, aes(x=order, y=watts,shape=type)) +
  geom_point( aes(color=work)) +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[bbob.fixed$work == "rosenbrock", ], aes(x=order, y=watts,shape=type)) +
  geom_point( aes(color=work)) +
  labs(title="Watts consumed along the sequence, Rosenbrock experiment", y="Watts", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[bbob.fixed$work == "rosenbrock", ], aes(x=order, y=PKG,shape=type)) +
  geom_point( aes(color=work)) +
  labs(title="Watts consumed along the sequence, Rosenbrock experiment", y="PKG", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggplot(bbob.fixed, aes(x=cumulative_seconds, y=PKG,shape=type)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggplot(bbob.fixed[ bbob.fixed$work == "katsuura",], aes(x=cumulative_seconds, y=PKG,shape=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[ bbob.fixed$work == "katsuura",], aes(x=cumulative_seconds, y=watts,shape=type, color=type, group=type)) + geom_line() +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggplot(bbob.fixed[ bbob.fixed$work == "schaffers",], aes(x=cumulative_seconds, y=PKG,shape=type, group=type,color=type)) + geom_line() +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[ bbob.fixed$work == "schaffers",], aes(x=cumulative_seconds, y=watts,shape=type, color=type, group=type)) + geom_line() +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[ bbob.fixed$work == "sharp_ridge",], aes(x=cumulative_seconds, y=PKG,shape=type, group=type,color=type)) + geom_line() +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.fixed[ bbob.fixed$work == "sharp_ridge",], aes(x=cumulative_seconds, y=watts,shape=type, color=type, group=type)) + geom_line() +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Variable size
bbob.variable <- read.csv("data/variable-evostar25-bbob-10-Nov-19-10-32.csv")
bbob.variable$watts <- bbob.variable$PKG / bbob.variable$seconds
bbob.variable$size <- as.factor(bbob.variable$size)
bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(order = row_number()) %>%
  ungroup()

bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(cumulative_seconds = cumsum(seconds)) %>%
  ungroup()

bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(watts_75 = quantile(watts, 0.75)) %>%
  ungroup()

bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(PKG_75 = quantile(PKG, 0.75)) %>%
  ungroup()


ggplot(bbob.variable, aes(x=cumulative_seconds, y=PKG,shape=type)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="PKG consumed depending on cumulative seconds", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.variable, aes(x=seconds,y=watts, shape=type,color=size)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed depending on seconds", y="Watts", x="Seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+scale_x_log10()

bbob.variable$size <- as.factor(bbob.variable$size)
ggplot(bbob.variable[ bbob.variable$work == "katsuura",], aes(x=cumulative_seconds, y=PKG,shape=size)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ geom_segment(data=bbob.variable[bbob.variable$work == "katsuura",],aes(x=0, xend=max(cumulative_seconds), y=PKG_75, color=type))

ggplot(bbob.variable[ bbob.variable$work == "katsuura",], aes(x=cumulative_seconds, y=watts,shape=size, color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ geom_segment(data=bbob.variable[bbob.variable$work == "katsuura",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))


ggplot(bbob.variable[ bbob.variable$work == "schaffers",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + geom_segment(data=bbob.variable[bbob.variable$work == "schaffers",],aes(x=0, xend=max(cumulative_seconds), y=PKG_75, color=type,linetype=size))

ggplot(bbob.variable[ bbob.variable$work == "schaffers",], aes(x=cumulative_seconds, y=watts,shape=size, color=type, group=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ geom_segment(data=bbob.variable[bbob.variable$work == "schaffers",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))


ggplot(bbob.variable[ bbob.variable$work == "sharp_ridge",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="PKG", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+ geom_segment(data=bbob.variable[bbob.variable$work == "sharp_ridge",],aes(x=0, xend=max(cumulative_seconds), y=PKG_75, color=type,linetype=size))


ggplot(bbob.variable[ bbob.variable$work == "sharp_ridge",], aes(x=cumulative_seconds, y=watts,shape=size, color=type, group=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Cumulative seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) + geom_segment(data=bbob.variable[bbob.variable$work == "sharp_ridge",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))


ggplot(bbob.variable, aes(x=order, y=PKG,shape=type)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="PKG consumed depending on experiment order", y="PKG", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.variable, aes(x=order, y=watts,shape=type)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs(title="PKG consumed depending on experiment order", y="PKG", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(bbob.variable[bbob.variable$work == "rastrigin",], aes(x=seq_along(watts), y=watts, shape=type,color=size)) +
  geom_point() +
  labs(title="Watts consumed in every experiment evaluating 40K chromosomes with 128, 256, 512 dimensions, using float or double for every one of them. Please note the $y$ axes have different scales", y="Watts", x="Experiment") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
