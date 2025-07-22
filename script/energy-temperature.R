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

bbob.variable$size <- as.factor(bbob.variable$size)
library(ggplot2)
ggplot(bbob.variable[ bbob.variable$work == "katsuura",], aes(x=cumulative_seconds, y=PKG,shape=size)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Katsuura", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-katsuura-variable.png", width=16, height=8, dpi=300)

ggplot(bbob.variable[ bbob.variable$work == "schaffers",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Schaffer's", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-schaffers-variable.png", width=16, height=8, dpi=300)

ggplot(bbob.variable[ bbob.variable$work == "bent_cigar",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Bent cigar", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-bent-cigar-variable.png", width=16, height=8, dpi=300)

bbob.fixed$size <- as.factor(bbob.fixed$size)

ggplot(bbob.fixed[ bbob.fixed$work == "katsuura",], aes(x=cumulative_seconds, y=PKG,shape=size)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Katsuura", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-katsuura-fixed.png", width=16, height=8, dpi=300)

ggplot(bbob.fixed[ bbob.fixed$work == "schaffers",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Schaffer's", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-schaffers-fixed.png", width=16, height=8, dpi=300)

ggplot(bbob.fixed[ bbob.fixed$work == "bent_cigar",], aes(x=cumulative_seconds, y=PKG,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Bent cigar", y="PKG", x="Cumulative seconds")+theme(legend.position="none")+theme_minimal()
ggsave("img/bbob-bent-cigar-fixed.png", width=16, height=8, dpi=300)

bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(watts_75 = quantile(watts, 0.75)) %>%
  ungroup()

bbob.variable <- bbob.variable %>%
  group_by(type, size, work) %>%
  mutate(PKG_75 = quantile(PKG, 0.75)) %>%
  ungroup()

ggplot(bbob.variable[ bbob.variable$work == "katsuura",], aes(x=cumulative_seconds, y=watts,shape=size)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Katsuura", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none") + geom_segment(data=bbob.variable[bbob.variable$work == "katsuura",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+theme_minimal()
ggsave("img/bbob-katsuura-variable-watts.png", width=16, height=8, dpi=300)

ggplot(bbob.variable[ bbob.variable$work == "schaffers",], aes(x=cumulative_seconds, y=watts,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Schaffer's", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none")+ geom_segment(data=bbob.variable[bbob.variable$work == "schaffers",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+ theme_minimal()
ggsave("img/bbob-schaffers-variable-watts.png", width=16, height=8, dpi=300)

ggplot(bbob.variable[ bbob.variable$work == "bent_cigar",], aes(x=cumulative_seconds, y=watts,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Bent cigar", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none")+ geom_segment(data=bbob.variable[bbob.variable$work == "bent_cigar",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+ theme_minimal()
ggsave("img/bbob-bent-cigar-variable-watts.png", width=16, height=8, dpi=300)

bbob.fixed <- bbob.fixed %>%
  group_by(type, size, work) %>%
  mutate(watts_75 = quantile(watts, 0.75)) %>%
  ungroup()

bbob.fixed <- bbob.fixed %>%
  group_by(type, size, work) %>%
  mutate(PKG_75 = quantile(PKG, 0.75)) %>%
  ungroup()

ggplot(bbob.fixed[ bbob.fixed$work == "katsuura",], aes(x=cumulative_seconds, y=watts,shape=size)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Katsuura", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none")+ geom_segment(data=bbob.fixed[bbob.fixed$work == "katsuura",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+ theme_minimal()
ggsave("img/bbob-katsuura-fixed-watts.png", width=16, height=8, dpi=300)

ggplot(bbob.fixed[ bbob.fixed$work == "schaffers",], aes(x=cumulative_seconds, y=watts,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Schaffer's", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none")+ geom_segment(data=bbob.fixed[bbob.fixed$work == "schaffers",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+theme_minimal()
ggsave("img/bbob-schaffers-fixed-watts.png", width=16, height=8, dpi=300)

ggplot(bbob.fixed[ bbob.fixed$work == "bent_cigar",], aes(x=cumulative_seconds, y=watts,shape=size, group=type,color=type)) +
  geom_point( aes(color=type)) + scale_color_brewer(palette="Set1") +
  labs(title="Bent cigar", y="Power (watts)", x="Cumulative seconds")+theme(legend.position="none")+ geom_segment(data=bbob.fixed[bbob.fixed$work == "bent_cigar",],aes(x=0, xend=max(cumulative_seconds), y=watts_75, color=type,linetype=size))+theme_minimal()
ggsave("img/bbob-bent-cigar-fixed-watts.png", width=16, height=8, dpi=300)

ggplot(bbob.variable[bbob.variable$work =="different_powers" | bbob.variable$work =="bent_cigar" | bbob.variable$work == "rosenbrock" | bbob.variable$work=="rastrigin",], aes(x=seconds,y=watts, shape=type,color=size)) +
  geom_point( aes(color=work)) + scale_color_brewer(palette="Set1") +
  labs( y="Watts", x="Seconds") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+scale_x_log10()+theme_minimal()
ggsave("img/bbob-variable-watts.png", width=8, height=4, dpi=300)
