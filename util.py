import os
import jinja2

from google.appengine.api import mail

import yaml

with open("config.yaml", 'r') as ymlfile:
    cfg = yaml.load(ymlfile)


def send_email(template_values, template_path, subject, sender, to):

    jinja_environment = jinja2.Environment(
        loader=jinja2.FileSystemLoader(os.path.dirname(__file__)),
        extensions=['jinja2.ext.autoescape'],
        autoescape=True)

    template = jinja_environment.get_template(template_path)

    mail.send_mail(sender=sender,
                   to=to,
                   subject=subject,
                   body="",
                   html=template.render(template_values))
