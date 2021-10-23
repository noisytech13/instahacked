FROM python:3.9.2-alpine3.13 as build
WORKDIR /wheels
RUN apk add --no-cache \
    ncurses-dev \
    build-base
COPY docker_reqs.txt /opt/instahacked/requirements.txt
RUN pip3 wheel -r /opt/instahacked/requirements.txt


FROM python:3.9.2-alpine3.13
WORKDIR /home/instahacked
RUN adduser -D instahacked

COPY --from=build /wheels /wheels
COPY --chown=instahacked:instahacked requirements.txt /home/instahacked/
RUN pip3 install -r requirements.txt -f /wheels \
  && rm -rf /wheels \
  && rm -rf /root/.cache/pip/* \
  && rm requirements.txt

COPY --chown=instahacked:instahacked src/ /home/instahacked/src
COPY --chown=instahacked:instahacked main.py /home/instahacked/
COPY --chown=instahacked:instahacked config/ /home/instahacked/config
USER instahacked

ENTRYPOINT ["python", "main.py"]