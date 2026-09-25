FROM python:3.11-slim
WORKDIR /srv
COPY pyproject.toml ./
COPY app ./app
RUN pip install --no-cache-dir .
CMD ["python", "-m", "app.serve"]
