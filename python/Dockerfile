FROM public.ecr.aws/lambda/python:3.9

RUN yum update -y && yum upgrade -y && rm -Rf /var/cache/yum

COPY app.py ${LAMBDA_TASK_ROOT}
COPY requirements.txt  .

RUN  pip3 install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

CMD [ "app.handler" ]
