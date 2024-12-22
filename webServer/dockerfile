FROM python
COPY requirements.txt .
RUN pip3 install -r requirements.txt
WORKDIR /app
COPY main.py .
RUN chmod -x ./main.py
EXPOSE 8000
ENTRYPOINT [ "python3","main.py"]


