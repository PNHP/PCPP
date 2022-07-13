

%\begin{figure}
<<lastObsFig, include=FALSE, echo=FALSE>>=
  #make a beanplot
  #beanplot(lastobsyear~rank_combo,data=eo_lastobs,bw="ucv",cutmin = min(eo_lastobs$lastobsyear),  cutmax = max(eo_lastobs$lastobsyear),col=c("orange"),ll=0.01,border=NA,horizontal=TRUE,frame.plot=FALSE,side="second",
  #         ylim=c( min(eo_lastobs$lastobsyear),max(eo_lastobs$lastobsyear) ) )
  #title("Density of Last Observed Dates by G-rank")
  @
  %\includegraphics{figure/lastObsFig-1.pdf} %place it
%\caption{Density of last observation dates}
%\end{figure}