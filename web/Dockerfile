# base image
FROM python:3.8-slim-buster

#workdir
WORKDIR /weather_bot
#install python modules needed by the app
COPY requirements.txt requirements.txt
#RUN python -m venv venv
#RUN venv/bin/pip install --no-cache-dir -r ./requirements.txt
RUN pip3 install -r requirements.txt
#copy files required for the app run
COPY .env models.py weather.py weather_json.py ./

#the port number the container should expose
EXPOSE 8000
#run the application
CMD ["python", "weather.py"]