# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [("profiles", "0002_auto_20150514_1510")]

    operations = [migrations.RunSQL("ALTER TABLE auth_user ALTER COLUMN username TYPE VARCHAR(254);")]
