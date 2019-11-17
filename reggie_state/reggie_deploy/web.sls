{% set event_name = salt['pillar.get']('reggie:plugins:ubersystem:config:event_name', 'Event') %}

# ============================================================================
# Bump up the number of file descriptors our services are allowed to open
# ============================================================================

{%- from 'macros.jinja' import ulimit %}
{{ ulimit('reggie_deploy.web', ['reggie', 'www-data'], 'nofile', 1048576, 1048576, watch_in=['service: reggie-web', 'service: nginx']) }}


# ============================================================================
# Delete nginx cache if there are code updates
# ============================================================================

nginx delete cache:
  cmd.run:
    - name: 'find /var/cache/nginx/**/* -type f | xargs rm --'
    - onlyif: 'find /var/cache/nginx/**/* -type f 2> /dev/null | grep -q /var/cache/nginx/'
    - onchanges:
      - sls: reggie.install


# ============================================================================
# Enable/disable maintenance page
# ============================================================================

nginx maintenance page:
{% if salt['pillar.get']('reggie:maintenance') %}
  file.managed:
    - name: /var/www/maintenance.html
    - contents: |
        <!DOCTYPE html>
        <html>
          <head>
            <title>{{ event_name }} Maintenance</title>
            <style>
              html, body {
                font-family: Helvetica, Arial, sans-serif;
                text-align: center;
              }
              div {
                margin: 0 auto;
                max-width: 640px;
                text-align: left;
                width: 100%;
              }
              pre {
                display: inline-block;
                font-family: monospace;
                font-size: 1.5em;
                font-weight: bold;
                text-align: left;
                white-space: pre;
              }
            </style>
          </head>
          <body>
            <h1>{{ event_name }} Registration Maintenance Mode</h1>
            <div>
              Our bots are working at 110% to get everything running again... <em>*beep* *boop*</em>
              <br><br>
              Sorry about that, we'll be back in a few. Hang tight!
              <br><br>
              Here's a donut while you wait:
            </div>
            <pre>
           _.-------._
         .' . '___ `  '.
        /` ' ,(___) . ` \
        |'._    . `  _.'|
        |   `'-----'`   |
         \             /
          '-.______..-'
            </pre>
          </body>
        </html>

{% else %}
  file.absent:
    - name: /var/www/maintenance.html
{% endif %}


# ============================================================================
# Enable/disable Schedule Routes
# ============================================================================

nginx schedule disabled page:
{% if salt['pillar.get']('reggie:schedule_disabled') %}
  file.managed:
    - name: /var/www/schedule_disabled.html
    - contents: |
        <!DOCTYPE html>
        <html>
          <head>
            <title>{{ event_name }} - Schedule Disabled</title>
            <style>
              html, body {
                font-family: Helvetica, Arial, sans-serif;
                text-align: center;
              }
              div {
                margin: 0 auto;
                max-width: 640px;
                text-align: left;
                width: 100%;
              }
              pre {
                display: inline-block;
                font-family: monospace;
                font-size: 1.5em;
                font-weight: bold;
                text-align: left;
                white-space: pre;
              }
            </style>
          </head>
          <body>
            <h1>{{ event_name }} - IT'S NOT READY YET</h1>
            <div>
              Our Schedule isn't finished quite yet, so we're keeping things under wraps for a bit longer. 
              <br><br>
              Stay tuned to our social media channels for all the exciting announcements!
              <br><br>
            </div>
          </body>
        </html>

{% else %}
  file.absent:
    - name: /var/www/schedule_disabled.html
{% endif %}
