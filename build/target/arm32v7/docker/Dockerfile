ARG hbmBaseImage=agorasdk.azurecr.io/arm32v7/hbm-base:1.0.0
FROM $hbmBaseImage

ARG hbmBaseImage
RUN echo Building from Base image : $hbmBaseImage

COPY lib/* /usr/lib/

COPY module.json /

CMD ["/usr/bin/hbm"]

