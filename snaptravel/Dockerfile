FROM python:3.7.0
MAINTAINER Andres De Castro <andres@adecastro.ca>

ENV INSTALL_PATH /snaptravel
RUN mkdir -p $INSTALL_PATH

WORKDIR $INSTALL_PATH

COPY requirements3.txt requirements3.txt
RUN pip install -r requirements3.txt

COPY . .

RUN pip install --editable .

CMD gunicorn "snaptravel.app:create_app()" -b 0.0.0.0:8098 --timeout 90 --workers 8 --threads 8 --access-logfile gunicorn_access.log --reload --log-level debug
