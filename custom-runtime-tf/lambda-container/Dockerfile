FROM public.ecr.aws/lambda/python:3.12

RUN dnf install jq -y && dnf clean all

COPY bootstrap /var/runtime/bootstrap
COPY *.sh /var/task/
RUN chmod +x /var/runtime/bootstrap /var/task/*.sh

WORKDIR /var/task
CMD [ "function.sh.handler" ]