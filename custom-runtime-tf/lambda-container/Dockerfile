FROM public.ecr.aws/lambda/python:3.12

RUN pip3 install certbot-dns-route53 awscli

COPY bootstrap /var/runtime/bootstrap
COPY *.sh /var/task/
RUN chmod +x /var/runtime/bootstrap /var/task/*.sh

WORKDIR /var/task
CMD [ "function.sh.handler" ]