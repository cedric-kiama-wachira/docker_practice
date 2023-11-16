FROM ubuntu

RUN apt-get update
RUN apt-get install python3

RUN pip3 install flask
RUN pip3 install flask-mysql

COPY . /opt/source-code
ENTRYPOINT FLASK_APP=/opt/source-code/app.py flask run
