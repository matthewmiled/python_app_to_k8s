FROM python:3.8
RUN pip3 install pipenv
COPY Pipfile Pipfile.lock /app/
WORKDIR /app
RUN pipenv install
COPY . /app
CMD ["pipenv", "run", "python3", "-m", "src"]
