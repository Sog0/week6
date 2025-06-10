FROM python:3.13

WORKDIR /app

COPY requirements.txt .

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 80

ENTRYPOINT ["./entrypoint.sh"]
